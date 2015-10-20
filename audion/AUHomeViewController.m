//
//  AUHomeViewController.m
//  audion
//
//  Created by Nick Porter on 5/26/15.
//  Copyright (c) 2015 Nick Porter. All rights reserved.
//

#import "AUHomeViewController.h"
#import "AUFonts.h"
#import "AUColors.h"
#import "AUTrack.h"
#import "AUTrackGetter.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface AUHomeViewController ()

@property (nonatomic, strong) MPMusicPlayerController *musicPlayer;
@property (nonatomic, strong)NSNotificationCenter *notificationCenter;
@property (nonatomic, strong)SSPullToRefreshView *refreshView;

@end

@implementation AUHomeViewController

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    _tableViewManager.parent = self;
    _tableView.tableFooterView = [UIView new];
    [self getLocation];
    [SVProgressHUD setBackgroundColor:[UIColor whiteColor]];
    [SVProgressHUD setRingThickness:3];
    [SVProgressHUD setForegroundColor:[AUColors primaryColor]];
    [SVProgressHUD show];
    
    self.refreshView = [[SSPullToRefreshView alloc] initWithScrollView:self.tableView delegate:self];
    
    [self presentTutorialIfNeeded];
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [_trackCollectionView reloadData];
    [_tableView reloadData];
    // creating simple audio player
    self.musicPlayer = [MPMusicPlayerController systemMusicPlayer];
    
    // assing a playback queue containing all media items on the device
    [self.musicPlayer setQueueWithQuery:[MPMediaQuery songsQuery]];
    
    self.notificationCenter = [NSNotificationCenter defaultCenter];
    
    [self.notificationCenter addObserver:self
                                selector:@selector(updatePlayingTracks)
                                    name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                                  object:self.musicPlayer];
    
    [self.notificationCenter addObserver:self
                                selector:@selector(updatePlayingTracks)
                                    name:MPMusicPlayerControllerPlaybackStateDidChangeNotification
                                  object:self.musicPlayer];
    
    
    [self.musicPlayer beginGeneratingPlaybackNotifications];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self.notificationCenter removeObserver:self
                                       name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                                     object:self.musicPlayer];
    
    [self.notificationCenter removeObserver:self
                                       name:MPMusicPlayerControllerPlaybackStateDidChangeNotification
                                     object:self.musicPlayer];
    
    [self.musicPlayer endGeneratingPlaybackNotifications];
    [SVProgressHUD dismiss];
    
}

- (void)presentTutorialIfNeeded
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        
    } else
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self presentTutorial];
    }
    
}

- (void)presentTutorial
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"panels" ofType:@"json"];
    SRFSurfboardViewController *surfboard = [[SRFSurfboardViewController alloc] initWithPathToConfiguration:path];
    NSArray *panels = [SRFSurfboardViewController panelsFromConfigurationAtPath:path];
    [surfboard setPanels:panels];
    surfboard.delegate = self;
    surfboard.backgroundColor = [AUColors primaryColor];
    [self presentViewController:surfboard animated:YES completion:nil];
}

- (void)updatePlayingTracks
{
    [_tableViewManager updatePlayingTrackWithCompletion:^(BOOL success) {
       
        [_tableView reloadData];
        [_trackCollectionView reloadData];
        
    }];
}

- (void)updateFeed
{
    [AUTrackGetter getFeed:_currentLocation WithCompletion:^(NSArray *tracks) {
        
        NSMutableArray *AUTracks = [[NSMutableArray alloc]init];
        for (PFObject *object in tracks) {
            AUTrack *track = [[AUTrack alloc]initWithPFObject:object];
            [AUTracks addObject:track];
        }
        _tableViewManager.feedTracks = AUTracks;
        _tableView.emptyDataSetSource = _tableViewManager;
        _tableView.emptyDataSetDelegate = _tableViewManager;
        [_tableView reloadData];
        [self.refreshView finishLoading];
        [SVProgressHUD dismiss];
        
    }];
}

#pragma mark <CLLocationManagerDelegate>

- (void)getLocation
{
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = 75; // meteres
    _locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    
    [_locationManager requestWhenInUseAuthorization];
    [_locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (!_currentLocation) {
         _currentLocation = newLocation;
        [self updateFeed];
    }
}

#pragma mark - <SSPullToRefreshViewDelegate>

- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView *)view
{
    [self updateFeed];
}

#pragma mark - <SRFSurfboardViewController>
- (void)surfboard:(SRFSurfboardViewController*)surfboard didTapButtonAtIndexPath:(NSIndexPath *)indexPath
{
    [surfboard dismissViewControllerAnimated:YES completion:nil];
}
@end
