//
//  GYFPSMonitor.h
//  GYMonitor
//
//  Created by bang on 15/2/27.
//  Copyright (c) 2015年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GYFPSMonitor;

@protocol GYFPSMonitorDelegate <NSObject>

@optional

- (BOOL)fpsMonitorShouldGenerateReport:(GYFPSMonitor *)monitor;
- (void)fpsMonitor:(GYFPSMonitor *)mointor belowThreshold:(NSInteger)fps;

@end

@interface GYFPSMonitor : NSObject

@property (nonatomic, weak) id<GYFPSMonitorDelegate> delegate;

+ (instancetype)shareInstance;

- (void)start;
- (void)stop;
- (void)pause;
- (void)resume;

- (NSInteger)currentFPS;
- (CFTimeInterval)lastTickTimestamp;

@end
