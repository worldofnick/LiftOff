//
//  AUHotViewController.m
//  audion
//
//  Created by Nick Porter on 5/26/15.
//  Copyright (c) 2015 Nick Porter. All rights reserved.
//

#import "AUHotViewController.h"
#import <Parse/Parse.h>
#import "AUTrackGetter.h"
#import "AUTrack.h"
#import "AUColors.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface AUHotViewController ()
@property (nonatomic, strong) SSPullToRefreshView *refreshView;
@end

@implementation AUHotViewController

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1];
    _tableView.tableFooterView = [UIView new];
    _tableViewManager.parent = self;

    [SVProgressHUD setBackgroundColor:[UIColor whiteColor]];
    [SVProgressHUD setRingThickness:3];
    [SVProgressHUD setForegroundColor:[AUColors primaryColor]];
    [SVProgressHUD show];
    [self updateFeed];
    self.refreshView = [[SSPullToRefreshView alloc] initWithScrollView:self.tableView delegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)updateFeed
{
    [AUTrackGetter getGlobalFeed:^(NSArray *tracks) {
        
        NSMutableArray *AUTracks = [[NSMutableArray alloc]init];
        for (PFObject *object in tracks) {
            AUTrack *track = [[AUTrack alloc]initWithPFObject:object];
            [AUTracks addObject:track];
        }
        _tableViewManager.feedTracks = AUTracks;
        _tableView.emptyDataSetSource = _tableViewManager;
        _tableView.emptyDataSetDelegate = _tableViewManager;
        [_tableView reloadData];
        [SVProgressHUD dismiss];
    }];
}

- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView *)view
{
    [self updateFeed];
}
@end
