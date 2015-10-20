//
//  AUCommentTableViewCell.h
//  audion
//
//  Created by Nick Porter on 6/15/15.
//  Copyright (c) 2015 Nick Porter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AUCommentTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end
