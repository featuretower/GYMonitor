//
//  GYMonitorIndicator.m
//  GYMonitor
//
//  Created by towerfeng on 16/3/18.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "GYMonitorIndicator.h"
#import <UIKit/UIKit.h>
#import "GYMonitorUtils.h"
#import "GYFilesViewController.h"
#import "GYReportManager.h"
#import "GYMonitorDataCenter.h"
#import "GYIndicatorWindow.h"

#define CELL_HEIGHT 30.0f

@interface GYMonitorIndicator ()<GYIndicatorWindowDelegate, UITableViewDataSource, UITableViewDelegate>

@end

@implementation GYMonitorIndicator {
    GYIndicatorWindow *_window;
    
    UIColor *_goodColor;
    UIColor *_badColor;
    
}

+ (GYMonitorIndicator *)sharedInstance {
    static dispatch_once_t pred;
    static GYMonitorIndicator *sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        sharedInstance = [[GYMonitorIndicator alloc] init];
    });
    
    return sharedInstance;
}

- (void)prepare {
    if (_window) {
        return;
    }
    
    _window = [[GYIndicatorWindow alloc] init];
    _window.delegate = self;
    _window.hidden = YES;
    
    _goodColor = [GYMonitorUtils colorWithHex:0x66a300 alpha:1.0];
    _badColor = [GYMonitorUtils colorWithHex:0xff7f0d alpha:1.0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(monitorDataDidChanged:) name:GYMonitorDataDidChangNotification object:nil];
}

#pragma mark - GYIndicatorWindowDelegate

- (void)indicatorWindowDidTapTipsButton:(GYIndicatorWindow *)window {
    [self showFileVC];
}

- (void)showFileVC {
    GYMLog(@"showFileVC called");
    GYFilesViewController *vc = [[GYFilesViewController alloc] initWithDir:[[GYReportManager shareInstance] monitorDir]];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *hostVC = rootVC;
    while (hostVC.presentedViewController) {
        hostVC = hostVC.presentedViewController;
    }
    hostVC = hostVC ?: rootVC;
    [hostVC presentViewController:nav animated:YES completion:NULL];
}

- (void)show {
    GYMLog(@"GYMonitorIndicator show");
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self show];
        });
        return;
    }
    _window.hidden = NO;
}

- (void)hide {
    GYMLog(@"GYMonitorIndicator hide");
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hide];
        });
        return;
    }
    _window.hidden = YES;
}

- (BOOL)isShowing {
    return !_window.hidden;
}

- (void)setShowType:(GYShowType)showType {
    if (showType == GYShowTypeFPS) {
        
    } else if (showType == GYShowTypeBadStat) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(changeToShowFPS) object:nil];
        [self performSelector:@selector(changeToShowFPS) withObject:nil afterDelay:8];
    }
    _showType = showType;
}

- (void)changeToShowFPS {
    _showType = GYShowTypeFPS;
}

- (void)monitorDataDidChanged:(NSNotification *)notification {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self monitorDataDidChanged:notification];
        });
        return;
    }
    NSString *name = notification.userInfo[@"name"];
    if ([name isEqualToString:@"badFPSCount"] || [name isEqualToString:@"badSQLCount"]) {
        NSInteger value = [notification.userInfo[@"value"] integerValue];
        if (value > 0) {
            self.showType = GYShowTypeBadStat;
        }
    }
    [self updateTips];
}

- (void)updateTips {
    if (self.showType == GYShowTypeFPS) {
        NSInteger fps = [GYMonitorDataCenter sharedInstance].fps;
        if (fps <= 0) {
            [self _updateTips:nil withColor:GYMonitorIndicatorColorDefault];
        } else {
            GYMonitorIndicatorColor color = fps > 30 ? GYMonitorIndicatorColorGood : GYMonitorIndicatorColorBad;
            [self _updateTips:[NSString stringWithFormat:@"%@ fps", @(fps)] withColor:color];
        }
    } else if (self.showType == GYShowTypeBadStat) {
        NSInteger badFPSCount = [GYMonitorDataCenter sharedInstance].badFPSCount;
        NSInteger badSQLCount = [GYMonitorDataCenter sharedInstance].badSQLCount;
        if (badFPSCount + badSQLCount <= 0) {
            [self _updateTips:nil withColor:GYMonitorIndicatorColorDefault];
        } else {
            NSMutableString *tips = [[NSMutableString alloc] init];
            if (badFPSCount > 0) {
                [tips appendString:[NSString stringWithFormat:@"%@-fps", @(badFPSCount)]];
            } if (badSQLCount) {
                [tips appendString:[NSString stringWithFormat:@"%@-sql", @(badSQLCount)]];
            }
            [self _updateTips:tips withColor:GYMonitorIndicatorColorBlocked];
        }
    }
}

- (void)_updateTips:(NSString *)tips withColor:(GYMonitorIndicatorColor)colorType {
    if (!tips) {
        tips = @" -- ";
    }
    [_window.tipsButton setTitle:tips forState:UIControlStateNormal];
    if (colorType == GYMonitorIndicatorColorGood) {
        _window.tipsButton.backgroundColor = _goodColor;
    } else if (colorType == GYMonitorIndicatorColorBad) {
        _window.tipsButton.backgroundColor = _badColor;
    } else if (colorType == GYMonitorIndicatorColorBlocked) {
        _window.tipsButton.backgroundColor = [UIColor redColor];
    }else {
        _window.tipsButton.backgroundColor = [UIColor grayColor];
    }
}

#pragma mark - UITableViewDataSource UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellId"];
        cell.textLabel.font = [UIFont systemFontOfSize:20.0];
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"浏览文件";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"实时fps";
    } else if (indexPath.row == 2) {
        cell.textLabel.text = @"显示卡顿";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        GYMLog(@"select showFileVC");
        [self showFileVC];
    } else if (indexPath.row == 1) {
        self.showType = GYShowTypeFPS;
        GYMLog(@"select ShowTypeFPS");
    } else if (indexPath.row == 2) {
        self.showType = GYShowTypeBadStat;
        GYMLog(@"select ShowTypeBadStat");
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    tableView.hidden = YES;
    [self updateTips];
}


@end
