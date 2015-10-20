//
//  AUHomeViewController.h
//  audion
//
//  Created by Nick Porter on 5/26/15.
//  Copyright (c) 2015 Nick Porter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AUTableViewManager.h"
#import <CoreLocation/CoreLocation.h>
#import <SSPullToRefresh/SSPullToRefresh.h>
#import "SRFSurfboard.h"

@interface AUHomeViewController : UIViewController <CLLocationManagerDelegate, SSPullToRefreshViewDelegate, SRFSurfboardDelegate>

// views
@property (weak, nonatomic) IBOutlet UICollectionView *trackCollectionView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// also acts as collectionview manager
@property (strong, nonatomic) IBOutlet AUTableViewManager *tableViewManager;

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) CLLocation *currentLocation;
@end
