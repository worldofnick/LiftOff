//
//  AUMeViewController.m
//  audion
//
//  Created by Nick Porter on 6/6/15.
//  Copyright (c) 2015 Nick Porter. All rights reserved.
//

#import "AUMeViewController.h"
#import "LocationPickerView.h"
#import "AUTrackGetter.h"
#import <Parse/Parse.h>
#import "AUTrack.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "AUColors.h"

@interface AUMeViewController ()
@property (nonatomic, strong)LocationPickerView *locationPickerView;
@end

@implementation AUMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableViewManager.parent = self;
    
    self.locationPickerView = [[LocationPickerView alloc] initWithFrame:self.view.bounds];
    self.locationPickerView.tableViewDataSource = _tableViewManager;
    self.locationPickerView.tableViewDelegate = _tableViewManager;
    self.locationPickerView.tableView.emptyDataSetDelegate = _tableViewManager;
    self.locationPickerView.tableView.emptyDataSetSource = _tableViewManager;
    self.locationPickerView.backgroundColor = [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1];
    self.locationPickerView.defaultMapHeight = 260.0;
    self.locationPickerView.pullToExpandMapEnabled = NO;
    
    [self.view addSubview:self.locationPickerView];
    
    [self getLatestShares];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getLatestShares];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)getLatestShares
{
    [SVProgressHUD setBackgroundColor:[UIColor whiteColor]];
    [SVProgressHUD setRingThickness:3];
    [SVProgressHUD setForegroundColor:[AUColors primaryColor]];
    [SVProgressHUD show];
    
    NSUserDefaults *store = [NSUserDefaults standardUserDefaults];
    // array of PFObject objectId's that the user has shared
    NSArray *sharedTracks = [store objectForKey:@"sharedTracks"];
    
    if (!sharedTracks) {
        [SVProgressHUD dismiss];
        return;
    }
    
    [AUTrackGetter getUserFeedWithObjectIds:sharedTracks:^(NSArray *tracks) {
        
        NSMutableArray *AUTracks = [[NSMutableArray alloc]init];
        for (PFObject *object in tracks) {
            AUTrack *track = [[AUTrack alloc]initWithPFObject:object];
            [AUTracks addObject:track];
        }
        _tableViewManager.feedTracks = AUTracks;
        [self.locationPickerView.tableView reloadData];
        [SVProgressHUD dismiss];
        
        
    }];
}
@end
