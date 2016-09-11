//
//  GYReportManager.m
//  GYMonitor
//
//  Created by Zachwang on 15/3/3.
//  Copyright (c) 2015年 Tencent. All rights reserved.
//

#import "GYReportManager.h"
#import "GYMonitorUtils.h"

#define REPORT_FILE_SUFFIX @"crash"

@implementation GYReportManager

+ (instancetype)shareInstance {
    static GYReportManager *reportManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        reportManager = [[GYReportManager alloc] init];
    });
    return reportManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self deleteOutOfDateFiles:[self fpsDir]];
    }
    return self;
}

- (void)deleteOutOfDateFiles:(NSString *)dir {
    NSArray *filenames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:nil];
    for (NSString *filename in filenames) {
        NSString *path = [dir stringByAppendingPathComponent:filename];
        NSDictionary *attr = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
        NSDate *createDate = attr[NSFileModificationDate];
        NSTimeInterval since = -[createDate timeIntervalSinceNow];
        if (since > 60 * 60 * 24 * 3) {
            GYMLog(@"delete out of date file: %@", path);
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
    }
}

- (NSString *)rename:(NSString *)filename suffix:(NSString *)suffix inDir:(NSString *)dir {
    NSArray *filenames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:nil];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"%@(.*)\\.%@", filename, suffix] options:0 error:nil];
    NSInteger maxIndex = 0;
    for (NSString *f in filenames) {
        NSArray *matches = [regex matchesInString:f options:0 range:NSMakeRange(0, f.length)];
        for (NSTextCheckingResult *match in matches) {
            NSString *matchText = [f substringWithRange:[match rangeAtIndex:1]];
            NSString *index = @"1";
            if (matchText.length > 0) {
                index = [matchText stringByReplacingOccurrencesOfString:@"[" withString:@""];
                index = [index stringByReplacingOccurrencesOfString:@"]" withString:@""];
            }
            maxIndex = MAX(maxIndex, index.integerValue);
        }
    }
    if (maxIndex > 0) {
        filename = [NSString stringWithFormat:@"%@[%@]", filename, @(maxIndex + 1)];
    }
    return filename;
}

- (void)saveCrashReportToLocal:(NSString *)report witchFileName:(NSString *)filename {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *fpsDir = [self fpsDir];
        NSString *f = [self rename:filename suffix:REPORT_FILE_SUFFIX inDir:fpsDir];
        NSString *filePath = [NSString stringWithFormat:@"%@/%@.%@", fpsDir, f, REPORT_FILE_SUFFIX];
        [report writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        GYMLog(@"save report to file: %@", filePath);
    });
}

- (NSString *)monitorDir {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *dir = [NSString stringWithFormat:@"%@/GYMonitor", docDir];
    return dir;
}

- (NSString *)fpsDir {
    NSString *dir = [NSString stringWithFormat:@"%@/fps", [self monitorDir]];
    [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    return dir;
}

- (NSString *)sqlFile {
    NSString *dir = [self monitorDir];
    [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *path = [NSString stringWithFormat:@"%@/sql", dir];
    if(![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
    }
    return path;
}

@end
