//
//  GYMonitorDataCenter.m
//  GYMonitor
//
//  Created by towerfeng on 16/9/6.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "GYMonitorDataCenter.h"
#import "GYReportManager.h"

@implementation GYMonitorDataCenter


+ (GYMonitorDataCenter *)sharedInstance {
    static dispatch_once_t pred;
    static GYMonitorDataCenter *sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        sharedInstance = [[GYMonitorDataCenter alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *fpsDir = [[GYReportManager shareInstance] fpsDir];
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fpsDir error:nil];
        _badFPSCount = files.count;
    }
    return self;
}

- (void)setFps:(NSInteger)fps {
    _fps = fps;
    [self postUpdate:@"fps" value:fps];
}

- (void)setBadFPSCount:(NSInteger)badFPSCount {
    _badFPSCount = badFPSCount;
    [self postUpdate:@"badFPSCount" value:badFPSCount];
}

- (void)setBadSQLCount:(NSInteger)badSQLCount {
    _badSQLCount = badSQLCount;
    [self postUpdate:@"badSQLCount" value:badSQLCount];
}

- (void)postUpdate:(NSString *)name value:(NSInteger)value {
    [[NSNotificationCenter defaultCenter] postNotificationName:GYMonitorDataDidChangNotification object:self userInfo:@{@"name": name, @"value": @(value)}];
}

@end
