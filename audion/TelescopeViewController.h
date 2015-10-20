//
//  TelescopeViewController.h
//  audion
//
//  Created by Nick Porter on 6/10/15.
//  Copyright (c) 2015 Nick Porter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectedLocation.h"
#import "AUTableViewManager.h"
#import <SSPullToRefresh/SSPullToRefresh.h>

@interface TelescopeViewController : UIViewController <SSPullToRefreshViewDelegate>

@property (nonatomic, strong)SelectedLocation *location;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet AUTableViewManager *tableViewManager;

@end
