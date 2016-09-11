//
//  GYMonitorUtils.h
//  GYMonitor
//
//  Created by towerfeng on 16/7/6.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifdef DEBUG

#define GYMLog(msg, args...) {\
NSLog(@"[GYMonitor] " msg, ## args); \
}

#else

#define GYMLog(msg, args...)

#endif

#define GYM_CURRENT_MS (CACurrentMediaTime() * 1000.0)



@class UIViewController;

@interface GYMonitorUtils : NSObject

+ (UIColor *)colorWithHex:(uint32_t)hex alpha:(CGFloat)alpha;
+ (NSString *)genCrashReport;
+ (NSString *)md5:(NSString *)str;

+ (void)gyswizzleSEL:(SEL)originalSEL withSEL:(SEL)swizzledSEL forClass:(Class)clz;

@end
