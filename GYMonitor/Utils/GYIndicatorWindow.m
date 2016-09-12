//
//  GYIndicatorWindow.m
//  GYMonitor
//
//  Created by towerfeng on 16/9/6.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "GYIndicatorWindow.h"
#import "GYMonitorUtils.h"

#ifndef IOS_VERSION
#define IOS_VERSION ([[[UIDevice currentDevice] systemVersion] floatValue])
#endif

@interface GYWindowRootViewController : UIViewController

@end

@implementation GYWindowRootViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

@end

@implementation GYIndicatorWindow

- (instancetype)init {
    if (IOS_VERSION >= 9.0) {
        self = [super init];
    } else {
        self = [super initWithFrame:[UIScreen mainScreen].bounds];
    }
    if (self) {
        _tipsButton = [[UIButton alloc] init];
        _tipsButton.backgroundColor = [UIColor grayColor];
        _tipsButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
        _tipsButton.titleLabel.textColor = [UIColor whiteColor];
        _tipsButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_tipsButton setTitle:@" -- " forState:UIControlStateNormal];
        [_tipsButton addTarget:self action:@selector(didTapTipsButton) forControlEvents:UIControlEventTouchUpInside];
        
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor clearColor];
        [_containerView addSubview:_tipsButton];
        
        self.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:.3];
        self.windowLevel = UIWindowLevelStatusBar + 10.0;
        self.rootViewController = [[UIViewController alloc] init];
        [self addSubview:_containerView];
        [self render];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

- (void)orientationDidChange:(NSNotification *)notification {
    if (!self.hidden) {
        [self render];
    }
}

- (void)render {
    CGFloat screenWidth = self.frame.size.width;
    CGFloat containerWidth = 75;
    CGFloat statusBarWidth = screenWidth;
    CGFloat statusBarHeight = 20;
    if (UIDeviceOrientationIsLandscape((UIDeviceOrientation)[UIApplication sharedApplication].statusBarOrientation)) {
        _containerView.frame = CGRectMake(screenWidth - containerWidth * 1.5, 0, containerWidth, statusBarHeight);
    } else {
        _containerView.frame = CGRectMake(statusBarWidth - containerWidth * 1.5, 0, containerWidth, statusBarHeight);
    }
    
    _tipsButton.frame = _containerView.bounds;
}

- (void)didTapTipsButton {
    [self.gydelegate indicatorWindowDidTapTipsButton:self];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.hidden) {
        return nil;
    }
    if (event.type == UIEventTypeTouches && CGRectContainsPoint(_containerView.frame, point)) {
        GYMLog(@"touch containerView");
        return _tipsButton;
    }
    return nil;
}

@end
