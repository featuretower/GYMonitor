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

#ifndef IS_LANDSCAPE
#define IS_LANDSCAPE UIDeviceOrientationIsLandscape((UIDeviceOrientation)[UIApplication sharedApplication].statusBarOrientation)
#endif

#ifndef SCREEN_WIDTH
#define SCREEN_WIDTH (IOS_VERSION >= 8.0 ? [[UIScreen mainScreen] bounds].size.width : (IS_LANDSCAPE ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width))
#endif

#ifndef SCREEN_HEIGHT
#define SCREEN_HEIGHT (IOS_VERSION >= 8.0 ? [[UIScreen mainScreen] bounds].size.height : (IS_LANDSCAPE ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height))
#endif

typedef NS_ENUM(NSInteger, GYIndicatorMode) {
    GYIndicatorModePortraitAndNormal,
    GYIndicatorModePortraitAndSpecial,
    GYIndicatorModeLandscape
};

@implementation GYIndicatorWindow

- (instancetype)init {
    self = [super init];
    if (self) {
        _tipsButton = [[UIButton alloc] init];
        _tipsButton.backgroundColor = [UIColor grayColor];
        _tipsButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
        _tipsButton.titleLabel.textColor = [UIColor whiteColor];
        _tipsButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_tipsButton setTitle:@" -- " forState:UIControlStateNormal];
        [_tipsButton addTarget:self action:@selector(didTapTipsButton) forControlEvents:UIControlEventTouchUpInside];
        
        _menuTableView = [[UITableView alloc] init];
        _menuTableView.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3].CGColor;
        _menuTableView.layer.shadowOpacity = 1.0;
        _menuTableView.layer.shadowOffset = CGSizeMake(0, 2);
        _menuTableView.layer.shadowRadius = 2;
        _menuTableView.hidden = YES;
        
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor clearColor];
        [_containerView addSubview:_tipsButton];
        [_containerView addSubview:_menuTableView];
        
        self.backgroundColor = [UIColor clearColor];
        self.windowLevel = UIWindowLevelStatusBar + 10.0;
        [self addSubview:_containerView];
        [self render];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

- (void)setDelegate:(id<GYIndicatorWindowDelegate,UITableViewDataSource,UITableViewDelegate>)delegate {
    _delegate = delegate;
    _menuTableView.dataSource = delegate;
    _menuTableView.delegate = delegate;
}

- (void)orientationDidChange:(NSNotification *)notification {
    if (!self.hidden) {
        [self render];
    }
}

- (void)render {
    self.transform = CGAffineTransformIdentity;
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
        self.transform = CGAffineTransformMakeRotation(-M_PI / 2);
    } else if (orientation == UIInterfaceOrientationLandscapeRight) {
        self.transform = CGAffineTransformMakeRotation(M_PI / 2);
    } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        self.transform = CGAffineTransformMakeRotation(-M_PI);
    } else {
        self.transform = CGAffineTransformIdentity;
    }
    
    CGRect frame = self.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    self.frame = frame;
    [self renderSubviews];
}

- (void)renderSubviews {
    GYIndicatorMode currMode = [self modeForStatusBar];
    
    CGFloat screenWidth = SCREEN_WIDTH;
    CGFloat containerWidth = 75;
    CGFloat statusBarWidth = screenWidth;
    CGFloat statusBarHeight = 20;
    switch (currMode) {
        case GYIndicatorModePortraitAndNormal:
            _containerView.frame = CGRectMake(statusBarWidth - containerWidth * 1.5, 0, containerWidth, statusBarHeight);
            break;
        case GYIndicatorModePortraitAndSpecial:
            _containerView.frame = CGRectMake(statusBarWidth - containerWidth * 1.5, 0, containerWidth, statusBarHeight);
            break;
        case GYIndicatorModeLandscape:
            _containerView.frame = CGRectMake(screenWidth - containerWidth * 1.5, 0, containerWidth, statusBarHeight);
            break;
        default:
            break;
    }
    
    _tipsButton.frame = _containerView.bounds;
    
    CGFloat tableViewWidth = _tipsButton.frame.size.width + 40;
    _menuTableView.frame = CGRectMake(_containerView.frame.size.width - tableViewWidth, _containerView.frame.size.height, tableViewWidth, _menuTableView.contentSize.height);
    _menuTableView.backgroundColor = [UIColor clearColor];
}

- (GYIndicatorMode)modeForStatusBar {
    if (!IS_LANDSCAPE) {
        if (![self statusBarFrameIsInCallOrNot] ) {
            return GYIndicatorModePortraitAndNormal;
        } else {
            return GYIndicatorModePortraitAndSpecial;
        }
    } else {
        return GYIndicatorModeLandscape;
    }
}

- (BOOL)statusBarFrameIsInCallOrNot {
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    NSInteger height = 20;
    if (statusBarFrame.size.height > height) {
        return YES;
    } else {
        return NO;
    }
}

- (void)didTapTipsButton {
//    _menuTableView.hidden = !_menuTableView.hidden;
//    if (!_menuTableView.hidden) {
//        [_menuTableView reloadData];
//        [self renderSubviews];
//    }
    [self.delegate indicatorWindowDidTapTipsButton:self];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.hidden) {
        return nil;
    }
    if (event.type == UIEventTypeTouches && CGRectContainsPoint(_containerView.frame, point)) {
        GYMLog(@"touch containerView");
        return [super hitTest:point withEvent:event];
    } else {
        if (!_menuTableView.hidden) {
            CGRect rect = CGRectMake(_containerView.frame.origin.x + _containerView.frame.size.width - _menuTableView.frame.size.width, _containerView.frame.size.height, _menuTableView.frame.size.width, _menuTableView.frame.size.height);
            if (CGRectContainsPoint(rect, point)) {
                GYMLog(@"touch menuTableView inside");
                return _menuTableView;
            } else {
                GYMLog(@"touch menuTableView outside");
                _menuTableView.hidden = YES;
                return [super hitTest:point withEvent:event];
            }
        }
    }
    return nil;
}

@end
