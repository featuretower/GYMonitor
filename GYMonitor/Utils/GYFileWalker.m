//
//  GYFileWalker.m
//  GYMonitor
//
//  Created by towerfeng on 16/3/18.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "GYFileWalker.h"

@implementation GYFileItem



@end

@implementation GYFileWalker
{
    NSMutableDictionary *_dirContents;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dirContents = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)setCurrentDir:(NSString *)currentDir
{
    if (![currentDir isEqualToString:_currentDir]) {
        _currentDir = currentDir;
        [self listDir];
    }
}

- (void)listDir
{
    NSMutableArray *sections = [[NSMutableArray alloc] init];
    NSMutableArray *files = [[NSMutableArray alloc] init];
    NSMutableArray *dirs = [[NSMutableArray alloc] init];
    NSArray *filenames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_currentDir error:nil];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    for (NSString *filename in filenames) {
        GYFileItem *item = [[GYFileItem alloc] init];
        NSString *path = [NSString stringWithFormat:@"%@/%@", _currentDir, filename];
        NSDictionary *fileAttr = [fileMgr attributesOfItemAtPath:path error:nil];
        
        item.path = path;
        item.name = filename;
        item.size = [fileAttr fileSize];
        item.modifyDate = [fileAttr fileModificationDate];
        if ([[fileAttr fileType] isEqualToString:NSFileTypeDirectory]) {
            item.isDir = YES;
        }
        if (item.isDir) {
            [dirs addObject:item];
        } else {
            [files addObject:item];
        }
    }
    NSComparator c = ^NSComparisonResult(GYFileItem *item1, GYFileItem *item2) {
        if ([item1.modifyDate timeIntervalSince1970] > [item2.modifyDate timeIntervalSince1970]) {
            return NSOrderedAscending;
        } else if ([item1.modifyDate timeIntervalSince1970] < [item2.modifyDate timeIntervalSince1970]) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    };
    [dirs sortUsingComparator:c];
    [files sortUsingComparator:c];
    [sections addObject:dirs];
    [sections addObject:files];
    _dirContents[_currentDir] = sections;
}

- (NSInteger)numberOfSetions
{
    NSMutableArray *sections = _dirContents[_currentDir];
    return sections.count;
}

- (NSInteger)itemCountAtSection:(NSInteger)section
{
    NSMutableArray *sections = _dirContents[_currentDir];
    NSMutableArray *items = sections[section];
    return items.count;
}

- (GYFileItem *)itemAtIndex:(NSInteger)index ofSection:(NSInteger)section
{
    NSMutableArray *sections = _dirContents[_currentDir];
    NSMutableArray *items = sections[section];
    return items[index];
}

- (void)reloadData
{
    [self listDir];
}
@end
