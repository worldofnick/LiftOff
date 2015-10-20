//
//  AUHotViewController.h
//  audion
//
//  Created by Nick Porter on 5/26/15.
//  Copyright (c) 2015 Nick Porter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AUTableViewManager.h"
#import <SSPullToRefresh/SSPullToRefresh.h>

@interface AUHotViewController : UIViewController <SSPullToRefreshViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet AUTableViewManager *tableViewManager;

@end
