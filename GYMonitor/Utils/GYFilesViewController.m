//
//  GYFilesViewController.m
//  GYMonitor
//
//  Created by towerfeng on 16/3/18.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "GYFilesViewController.h"
#import "GYFileWalker.h"
#import "GYFilePreviewViewController.h"
#import "GYMonitor.h"
#import "GYMonitorDataCenter.h"

@interface GYFilesViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation GYFilesViewController
{
    UITableView *_tableView;
    GYFileWalker *_fileWalker;
    UIColor *_cellColor;
    NSDateFormatter *_dateFormatter;
}

- (instancetype)initWithDir:(NSString *)dir
{
    self = [super init];
    if (self) {
        BOOL isDir = NO;
        if (dir.length <= 0) {
            dir = NSHomeDirectory();
        }
        if (![[NSFileManager defaultManager] fileExistsAtPath:dir isDirectory:&isDir] || !isDir) {
            [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        _fileWalker = [[GYFileWalker alloc] init];
        _fileWalker.currentDir = dir;
        _cellColor = [UIColor colorWithRed:240/255.0f green:248/255.0f blue:255/255.0f alpha:1.0];
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"yy-MM-dd HH:mm:ss";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = [_fileWalker.currentDir lastPathComponent];
    [self initViews];
}

- (void)initViews
{
    if (self.navigationController.viewControllers.count == 1 && ![_fileWalker.currentDir isEqualToString:NSHomeDirectory()]) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"home" style:UIBarButtonItemStyleDone target:self action:@selector(goHome)];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleDone target:self action:@selector(closeMe)];
    
    _tableView = [[UITableView alloc] init];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _tableView.frame = self.view.bounds;
}

- (void)goHome
{
    GYFilesViewController *vc = [[GYFilesViewController alloc] initWithDir:NSHomeDirectory()];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)closeMe
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_fileWalker numberOfSetions];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_fileWalker itemCountAtSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellID = @"GYFileCellId";
    GYFileItem *item = [_fileWalker itemAtIndex:indexPath.row ofSection:indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellID];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    }
    cell.textLabel.text = item.name;
    NSString *dateString = [_dateFormatter stringFromDate:item.modifyDate];
    if (item.isDir) {
        cell.detailTextLabel.text = dateString;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = _cellColor;
    } else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@  %@", dateString, [self readableSize:item.size]];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = [UIColor whiteColor];
    }
    return cell;
}

- (NSString *)readableSize:(unsigned long long)size {
    if (size < 1024) {
        return [NSString stringWithFormat:@"%lluB", size];
    } else if (size < 1024 * 1024) {
        return [NSString stringWithFormat:@"%.2fKB", (size / 1024.0)];
    } else {
        return [NSString stringWithFormat:@"%.2fMB", (size / 1024.0 / 1024)];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GYFileItem *item = [_fileWalker itemAtIndex:indexPath.row ofSection:indexPath.section];
    if (item.isDir) {
        GYFilesViewController *vc = [[GYFilesViewController alloc] initWithDir:item.path];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        GYFilePreviewViewController *vc = [[GYFilePreviewViewController alloc] initWithFilePath:item.path];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        GYFileItem *item = [_fileWalker itemAtIndex:indexPath.row ofSection:indexPath.section];
        if (item.path) {
            [[NSFileManager defaultManager] removeItemAtPath:item.path error:nil];
            if (item.isDir && [item.path.lastPathComponent isEqualToString:@"fps"]) {
                [GYMonitorDataCenter sharedInstance].badFPSCount = 0;
            }
            if ([item.path.lastPathComponent isEqualToString:@"sql"]) {
                [GYMonitorDataCenter sharedInstance].badSQLCount = 0;
            }
            [_fileWalker reloadData];
            [tableView reloadData];
        }
        
    }
}

@end
