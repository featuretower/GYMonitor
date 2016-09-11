//
//  GYMonitorIndicator.h
//  GYMonitor
//
//  Created by towerfeng on 16/3/18.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, GYMonitorIndicatorColor) {
    GYMonitorIndicatorColorDefault,
    GYMonitorIndicatorColorGood,
    GYMonitorIndicatorColorBad,
    GYMonitorIndicatorColorBlocked
};

typedef NS_ENUM(NSInteger, GYShowType) {
    GYShowTypeFPS,
    GYShowTypeBadStat,
};

@interface GYMonitorIndicator : NSObject

@property (nonatomic, assign) BOOL showFPS;
@property (nonatomic, assign) GYShowType showType;

+ (GYMonitorIndicator *)sharedInstance;

- (void)prepare;
- (void)show;
- (void)hide;
- (BOOL)isShowing;
- (void)updateTips;

@end
