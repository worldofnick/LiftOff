//
//  AUTrackCollectionViewCell.h
//  audion
//
//  Created by Nick Porter on 5/26/15.
//  Copyright (c) 2015 Nick Porter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AUTrackCollectionViewCell : UICollectionViewCell


@property (weak, nonatomic) IBOutlet UIImageView *albumImage;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *albumLabel;
@property (weak, nonatomic) IBOutlet UIView *blackTextView;
@property (weak, nonatomic) IBOutlet UIView *nowPlayingView;

@property (nonatomic)BOOL hasAddedFade;

@end
