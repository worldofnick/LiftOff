//
//  AUHeaderTableViewCell.h
//  audion
//
//  Created by Nick Porter on 6/14/15.
//  Copyright (c) 2015 Nick Porter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AUHeaderTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *albumImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *albumTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *votesLabel;
@property (weak, nonatomic) IBOutlet UILabel *repliesLabel;

@end
