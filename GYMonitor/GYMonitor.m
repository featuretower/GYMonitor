//
//  GYMonitor.m
//  GYMonitor
//
//  Created by Zepo She on 2/6/15.
//  Copyright (c) 2015 Tencent. All rights reserved.
//

#import "GYMonitor.h"
#import <UIKit/UIKit.h>
#import "GYFPSMonitor.h"
#import "GYMonitorIndicator.h"
#import "GYMonitorUtils.h"
#import "GYMonitorDataCenter.h"

@implementation UIViewController (GYMonitor)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [GYMonitorUtils gyswizzleSEL:@selector(viewWillAppear:) withSEL:@selector(gymviewWillAppear:) forClass:[UIViewController class]];
    });
}

- (void)gymviewWillAppear:(BOOL)animated {
    NSString *name = NSStringFromClass([self class]);
    if (![name isEqualToString:@"UIInputWindowController"]) {
        [GYMonitorDataCenter sharedInstance].currentVCName = name;
    }
    GYMLog(@"gymviewWillAppear: %@", [GYMonitorDataCenter sharedInstance].currentVCName);
    [self gymviewWillAppear:animated];
}

@end

@interface GYMonitor ()<GYFPSMonitorDelegate>

@end

@implementation GYMonitor {
    GYFPSMonitor *_fpsMonitor;
}

+ (GYMonitor *)sharedInstance {
    static dispatch_once_t pred;
    static GYMonitor *sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        sharedInstance = [[GYMonitor alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startMonitor {
    NSAssert([NSThread isMainThread], @"start monitor not on maithread");

    // FPS
    if (self.monitorFPS) {
        if (!_fpsMonitor) {
            _fpsMonitor = [[GYFPSMonitor alloc] init];
            _fpsMonitor.delegate = self;
        }
        [_fpsMonitor start];
    } else {
        [_fpsMonitor stop];
    }
    
    if (self.showDebugView) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[GYMonitorIndicator sharedInstance] prepare];
            [[GYMonitorIndicator sharedInstance] show];
        });
    } else {
        [[GYMonitorIndicator sharedInstance] hide];
    }

}

- (void)appDidBecomeActive {
    [_fpsMonitor resume];
}

- (void)appWillResignActive {
    [_fpsMonitor pause];
    [GYMonitorDataCenter sharedInstance].fps = 0;
    [[GYMonitorIndicator sharedInstance] updateTips];
}

#pragma mark - GYFPSMonitorDelegate

- (BOOL)fpsMonitorShouldGenerateReport:(GYFPSMonitor *)monitor {
    return self.showDebugView && [[GYMonitorIndicator sharedInstance] isShowing];
}

- (void)fpsMonitor:(GYFPSMonitor *)mointor belowThreshold:(NSInteger)fps {
    if (self.fpsBelowThresholdBlock) {
        self.fpsBelowThresholdBlock(fps);
    }
}

@end
