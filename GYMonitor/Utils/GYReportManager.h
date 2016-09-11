//
//  GYReportManager.h
//  GYMonitor
//
//  Created by Zachwang on 15/3/3.
//  Copyright (c) 2015年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GYReportManager : NSObject

+ (instancetype)shareInstance;

- (void)saveCrashReportToLocal:(NSString *)report witchFileName:(NSString *)filename;

- (NSString *)monitorDir;
- (NSString *)fpsDir;
- (NSString *)sqlFile;

@end
