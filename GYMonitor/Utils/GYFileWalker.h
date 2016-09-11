//
//  GYFileWalker.h
//  GYMonitor
//
//  Created by towerfeng on 16/3/18.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GYFileItem : NSObject

@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) BOOL isDir;
@property (nonatomic, assign) unsigned long long size;
@property (nonatomic, strong) NSDate *modifyDate;

@end

@interface GYFileWalker : NSObject

@property (nonatomic, strong) NSString *currentDir;

- (NSInteger)numberOfSetions;
- (NSInteger)itemCountAtSection:(NSInteger)section;
- (GYFileItem *)itemAtIndex:(NSInteger)index ofSection:(NSInteger)section;
- (void)reloadData;
@end
