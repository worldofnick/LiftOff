//
//  AUTableViewCell.h
//  audion
//
//  Created by Nick Porter on 5/27/15.
//  Copyright (c) 2015 Nick Porter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MCSwipeTableViewCell/MCSwipeTableViewCell.h>
#import <ParseUI/ParseUI.h>

@interface AUTableViewCell : MCSwipeTableViewCell


@property (weak, nonatomic) IBOutlet PFImageView *albumImage;
@property (weak, nonatomic) IBOutlet UILabel *songTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *votesLabel;
@property (weak, nonatomic) IBOutlet UILabel *repliesLabel;

@end
