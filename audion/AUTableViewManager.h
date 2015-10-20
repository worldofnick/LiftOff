//
//  AUTableViewManager.h
//  audion
//
//  Created by Nick Porter on 5/27/15.
//  Copyright (c) 2015 Nick Porter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface AUTableViewManager : NSObject <UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource>


- (void)updatePlayingTrackWithCompletion:(void(^)(BOOL success))completionBlock;
@property (nonatomic, strong)id parent;
@property (nonatomic, strong)NSMutableArray *feedTracks;

@end
