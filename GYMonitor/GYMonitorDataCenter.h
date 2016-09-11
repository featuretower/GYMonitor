//
//  GYMonitorDataCenter.h
//  GYMonitor
//
//  Created by towerfeng on 16/9/6.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

#define GYMonitorDataDidChangNotification @"GYMonitorDataDidChangNotification"

@interface GYMonitorDataCenter : NSObject

@property (nonatomic, assign) NSInteger fps;
@property (nonatomic, assign) NSInteger badFPSCount;
@property (nonatomic, assign) NSInteger badSQLCount;
@property (nonatomic, copy)   NSString *currentVCName;

+ (GYMonitorDataCenter *)sharedInstance;

@end
