//
//  GYMonitor.h
//  GYMonitor
//
//  Created by Zepo She on 2/6/15.
//  Copyright (c) 2015 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GYMonitorDelegate;

@interface GYMonitor : NSObject

@property (nonatomic, assign) BOOL monitorFPS;
@property (nonatomic, assign) BOOL showDebugView;

@property (nonatomic, copy) void (^fpsBelowThresholdBlock)(NSInteger fps);

+ (GYMonitor *)sharedInstance;
- (void)startMonitor;

@end
