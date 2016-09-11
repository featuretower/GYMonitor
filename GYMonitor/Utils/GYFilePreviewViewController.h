//
//  GYFilePreviewViewController.h
//  GYMonitor
//
//  Created by towerfeng on 16/3/18.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GYFilePreviewViewController : UIViewController<UIGestureRecognizerDelegate>

- (instancetype)initWithFilePath:(NSString *)path;

@end
