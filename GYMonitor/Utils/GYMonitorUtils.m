//
//  GYMonitorUtils.m
//  GYMonitor
//
//  Created by towerfeng on 16/7/6.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "GYMonitorUtils.h"
#import <UIKit/UIKit.h>

#import "mach/mach_init.h"
#import "mach/task.h"
#import <mach/mach.h>
#import <CommonCrypto/CommonDigest.h>
#import <CrashReporter/CrashReporter.h>
#import <objc/runtime.h>

#define MD5_CHAR_TO_STRING_16 [NSString stringWithFormat:               \
@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",    \
result[0], result[1], result[2], result[3],                             \
result[4], result[5], result[6], result[7],                             \
result[8], result[9], result[10], result[11],                           \
result[12], result[13], result[14], result[15]]                         \

@implementation GYMonitorUtils

+ (UIColor *)colorWithHex:(uint32_t)hex alpha:(CGFloat)alpha {
    CGFloat red   = (CGFloat) ((hex & 0xff0000) >> 16) / 255.0f;
    CGFloat green = (CGFloat) ((hex & 0x00ff00) >> 8)  / 255.0f;
    CGFloat blue  = (CGFloat)  (hex & 0x0000ff)        / 255.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (void)gyswizzleSEL:(SEL)originalSEL withSEL:(SEL)swizzledSEL forClass:(Class)clz {
    
    Method originalMethod = class_getInstanceMethod(clz, originalSEL);
    Method swizzledMethod = class_getInstanceMethod(clz, swizzledSEL);
    
    BOOL didAddMethod =
    class_addMethod(clz,
                    originalSEL,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(clz,
                            swizzledSEL,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

+ (NSString *)genCrashReport {
    PLCrashReporterSymbolicationStrategy strategy = PLCrashReporterSymbolicationStrategySymbolTable;
#if TARGET_OS_SIMULATOR
    strategy = PLCrashReporterSymbolicationStrategyAll;
#endif
    PLCrashReporterConfig *config = [[PLCrashReporterConfig alloc] initWithSignalHandlerType:PLCrashReporterSignalHandlerTypeBSD symbolicationStrategy:strategy];
    PLCrashReporter *crashReporter = [[PLCrashReporter alloc] initWithConfiguration:config];
    NSData *data = [crashReporter generateLiveReport];
    PLCrashReport *reporter = [[PLCrashReport alloc] initWithData:data error:NULL];
    NSString *report = [PLCrashReportTextFormatter stringValueForCrashReport:reporter
                                                              withTextFormat:PLCrashReportTextFormatiOS];
    
    NSLog(@"------------\n%@\n------------", report);
    return report;
}

+ (NSString *)md5:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (int)strlen(cStr), result);
    return MD5_CHAR_TO_STRING_16;
}

@end
