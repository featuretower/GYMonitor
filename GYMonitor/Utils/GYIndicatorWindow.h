//
//  GYIndicatorWindow.h
//  GYMonitor
//
//  Created by towerfeng on 16/9/6.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GYIndicatorWindow;

@protocol GYIndicatorWindowDelegate <NSObject>

- (void)indicatorWindowDidTapTipsButton:(GYIndicatorWindow *)window;

@end

@interface GYIndicatorWindow : UIWindow

@property (nonatomic, strong) UIButton *tipsButton;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, weak) id<GYIndicatorWindowDelegate> gydelegate;

@end
