//
//  GYRootViewController.m
//  GYMonitorDemo
//
//  Created by towerfeng on 16/9/9.
//  Copyright © 2016年 featuretower. All rights reserved.
//

#import "GYRootViewController.h"

@implementation GYRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"RootVC";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"TestCell"];
}

- (void)blockUpForSecond:(float)sec {
    [NSThread sleepForTimeInterval:sec];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5000;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TestCell" forIndexPath:indexPath];
    NSString *text = [NSString stringWithFormat:@"%@", @(indexPath.row)];
    
    if (indexPath.row > 0 && indexPath.row % 40 == 0) {
        cell.backgroundColor = [UIColor grayColor];
        text = [text stringByAppendingString:@" slow!"];
        [self blockUpForSecond:.2];
    } else if (indexPath.row > 0 && indexPath.row % 110 == 0) {
        cell.backgroundColor = [UIColor redColor];
        text = [text stringByAppendingString:@" stucked!"];
        [self blockUpForSecond:2];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    cell.textLabel.text = text;
    cell.imageView.image = [UIImage imageNamed:@"rose_PNG642"];
    
    return cell;
}

@end
