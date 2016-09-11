//
//  GYFPSMonitor.m
//  GYMonitor
//
//  Created by bang on 15/2/27.
//  Copyright (c) 2015年 Tencent. All rights reserved.
//

#import "GYFPSMonitor.h"
#import <UIKit/UIKit.h>

#import "GYReportManager.h"
#import "GYMonitorUtils.h"
#import "GYMonitor.h"
#import "GYMonitorDataCenter.h"

static double CheckInterval = 0.5;
static double MinReportInterval = 12;//如果两次卡顿发送的间隔少于MinReportInterval，不记录后者

#define START_RECORD_TIME_GAP 400
#define NEED_RECORD_TIME_GAP 3000
#define MAX_FPSUINTS_COUNT 60

@implementation GYFPSMonitor {
    BOOL _isPause;
    CADisplayLink *_displayLink;
    CFTimeInterval _lastTickTimestamp;
    CFTimeInterval _lastUpdateTimestamp;
    NSUInteger _historyCount;
    NSInteger _currentFPS;
    
    NSThread *_checkThread;
    NSTimer *_checkTimer;
    NSTimeInterval _lastReportTime;
    BOOL _isGeneratingReport;
}

+ (instancetype)shareInstance {
    static GYFPSMonitor *fpsMonitor;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fpsMonitor = [[GYFPSMonitor alloc] init];
    });
    return fpsMonitor;
}

- (id)init {
    self = [super init];
    if( self ){
        _isPause = YES;
        
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkTick)];
        _displayLink.frameInterval = 2;
        [_displayLink setPaused:YES];
        // TODO 测试tracking状态下能否正常运行
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        
    }
    return self;
}

- (void)dealloc {
    [_displayLink setPaused:YES];
    [_displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)start {
    GYMLog(@"FPS monitor start");
    _isPause = NO;
    _historyCount = 0;
    _lastUpdateTimestamp = 0;
    [_displayLink setPaused:NO];
    
    [self startChecker];
}

- (void)pause {
    GYMLog(@"FPS monitor pause");
    _isPause = YES;
    [_displayLink setPaused:YES];
}

- (void)resume {
    GYMLog(@"FPS monitor resume");
    if (_isPause) {
        [self start];
    }
}

- (void)stop {
    GYMLog(@"FPS monitor stop");
    _isPause = YES;
    [self stopTimer];
    [_checkThread cancel];
    _checkThread = nil;
}

- (NSInteger)currentFPS {
    return _currentFPS;
}

- (CFTimeInterval)lastTickTimestamp {
    return _lastTickTimestamp;
}

- (void)displayLinkTick {
    _lastTickTimestamp = GYM_CURRENT_MS;
    if (_lastUpdateTimestamp <= 0) {
        _lastUpdateTimestamp = _displayLink.timestamp;
        return;
    }
    _historyCount += _displayLink.frameInterval;
    
    CFTimeInterval interval = _displayLink.timestamp - _lastUpdateTimestamp;
    if(interval >= 1) {
        _lastUpdateTimestamp = _displayLink.timestamp;
        _currentFPS = _historyCount / interval;
        _historyCount = 0;
        [self fpsUpdated:_currentFPS];
        
        if (_currentFPS <= 30 && _currentFPS > 0 && [self.delegate respondsToSelector:@selector(fpsMonitor:belowThreshold:)]) {
            [self.delegate fpsMonitor:self belowThreshold:_currentFPS];
        }
    }
}

- (void)fpsUpdated:(NSInteger)fps {
    [GYMonitorDataCenter sharedInstance].fps = fps;
}

#pragma mark - 卡顿监控

- (void)startChecker {
    GYMLog(@"FPS monitor startChecker");
    if (!_checkThread || _checkThread.isCancelled) {
        _checkThread = [[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil];
        [_checkThread setName:@"GYFPSMonitor"];
        [_checkThread start];
    }
}

- (void)run {
    while (![_checkThread isCancelled]) {
        @autoreleasepool {
            NSRunLoop *runloop = [NSRunLoop currentRunLoop];
            [self startTimer];
            [[NSRunLoop currentRunLoop] addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
            [runloop run];
        }
    }
}

- (void)startTimer {
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    _checkTimer = [NSTimer timerWithTimeInterval:CheckInterval target:self selector:@selector(onThreadTimer:) userInfo:nil repeats:YES];
    [runloop addTimer:_checkTimer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer {
    [_checkTimer invalidate];
    _checkTimer = nil;
}

- (void )onThreadTimer:(id)timer {
    if (_isPause || _isGeneratingReport) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(fpsMonitorShouldGenerateReport:)]) {
        if (![self.delegate fpsMonitorShouldGenerateReport:self]) {
            return;
        }
    }
    CFTimeInterval currentTime = GYM_CURRENT_MS;
    CFTimeInterval lastTickTime = _lastTickTimestamp;
    if (currentTime - lastTickTime < CheckInterval * 1000.0) {
        return;
    }
    GYMLog(@"mainThread stuck, currentTime:%@ lastTickTime:%@ delta:%@", @(currentTime), @(lastTickTime), @(currentTime - lastTickTime));
    
    //防止频繁上报
    if (currentTime - _lastReportTime <= MinReportInterval * 1000.0) {
        GYMLog(@"stuck too frequently....");
        return;
    }
    
    _isGeneratingReport = YES;
    _lastReportTime = currentTime;
    
    GYMLog(@"start gen report");
    NSString *crashReport = [GYMonitorUtils genCrashReport];
    GYMLog(@"end gen report");
    
    NSString *filename = [GYMonitorDataCenter sharedInstance].currentVCName;
    if (filename.length <= 0) {
        filename = @"app";
    }
    [[GYReportManager shareInstance] saveCrashReportToLocal:crashReport witchFileName:filename];
    _isGeneratingReport = NO;
    
    [GYMonitorDataCenter sharedInstance].badFPSCount++;
}

@end
