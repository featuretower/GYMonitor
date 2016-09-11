//
//  AppDelegate.m
//  GYMonitorExample
//
//  Created by towerfeng on 16/9/11.
//  Copyright © 2016年 none. All rights reserved.
//

#import "AppDelegate.h"
#import "GYRootViewController.h"
#import "GYMonitor.h"

@interface AppDelegate ()

@end

@implementation AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    GYRootViewController *rootVC = [[GYRootViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:rootVC];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    
    [self startMonitor];
    
    return YES;
}

- (void)startMonitor {
    [GYMonitor sharedInstance].monitorFPS = YES;
    [GYMonitor sharedInstance].showDebugView = YES;
    [[GYMonitor sharedInstance] startMonitor];
}

- (void)stopMonitor {
    [GYMonitor sharedInstance].monitorFPS = NO;
    [GYMonitor sharedInstance].showDebugView = NO;
    [[GYMonitor sharedInstance] startMonitor];
}

@end
