//
//  AUSongViewController.h
//  audion
//
//  Created by Nick Porter on 6/13/15.
//  Copyright (c) 2015 Nick Porter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AUTrack.h"
#import <SSPullToRefresh/SSPullToRefresh.h>
#import <PHFComposeBarView/PHFComposeBarView.h>

@interface AUSongViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, PHFComposeBarViewDelegate>

@property (nonatomic, strong)AUTrack *track;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *noRepliesLabel;

@property (nonatomic)CGFloat initialTVHeight;

@end
