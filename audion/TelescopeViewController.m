//
//  TelescopeViewController.m
//  audion
//
//  Created by Nick Porter on 6/10/15.
//  Copyright (c) 2015 Nick Porter. All rights reserved.
//

#import "TelescopeViewController.h"
#import "AUTrackGetter.h"
#import <Parse/Parse.h>
#import "AUTrack.h"
#import "AUColors.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface TelescopeViewController ()
@property (nonatomic, strong)SSPullToRefreshView *refreshView;
@property (nonatomic, strong)CLLocation *currentLocation;
@end

@implementation TelescopeViewController

- (void)viewDidLoad
{
    self.title = _location.name;
    self.view.backgroundColor = [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    _tableView.tableFooterView = [UIView new];
    _tableViewManager.parent = self;
    self.currentLocation = [[CLLocation alloc]initWithLatitude:_location.locationCoordinates.latitude longitude:_location.locationCoordinates.longitude];
    
    [SVProgressHUD setBackgroundColor:[UIColor whiteColor]];
    [SVProgressHUD setRingThickness:3];
    [SVProgressHUD setForegroundColor:[AUColors primaryColor]];
    [SVProgressHUD show];
    [self updateFeedWithLocation:self.currentLocation];
    self.refreshView = [[SSPullToRefreshView alloc] initWithScrollView:self.tableView delegate:self];
}


- (void)updateFeedWithLocation:(CLLocation *)location
{
    [AUTrackGetter getFeed:location WithCompletion:^(NSArray *tracks) {
        
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
    [self updateFeedWithLocation:self.currentLocation];
}
@end
