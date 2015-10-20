//
//  AUTableViewManager.m
//  audion
//
//  Created by Nick Porter on 5/27/15.
//  Copyright (c) 2015 Nick Porter. All rights reserved.
//

#import "AUTableViewManager.h"
#import "AUTableViewCell.h"
#import "AUTrackCollectionViewCell.h"
#import "AUColors.h"
#import "AUFonts.h"
#import "AUHomeViewController.h"
#import "AUTrackSender.h"
#import "AUTrack.h"
#import <Parse/Parse.h>
#import "TelescopeViewController.h"
#import <NSDate+TimeAgo/NSDate+TimeAgo.h>
#import "AUMeViewController.h"
#import "AUSongViewController.h"

@interface AUTableViewManager ()

@property (nonatomic, strong) NSMutableArray *tracks;
@property (nonatomic, strong) MPMusicPlayerController *musicPlayer;
@property (nonatomic) BOOL isCurrentlyPlayingTrack;

@property (nonatomic)CGFloat previousScrollViewYOffset;

@end

@implementation AUTableViewManager

- (id)init
{
    self = [super init];
    [self fillTracks];
    return self;
}

#pragma mark - Public
/**
    Method is called when the system music player starts a new song or changes playback states.
*/
- (void)updatePlayingTrackWithCompletion:(void(^)(BOOL success))completionBlock
{
    [self getCurrentlyPlayingTrack];
    completionBlock(YES);
}

#pragma mark - Grabbing Music
/**
    Method fills tracks with the most recently played songs, then calls getCurrentlyPlayingTrack to get the newest song
    The reason this is nessisary is becuase fillTracks only provides songs which have been played in entirety
 */
- (void)fillTracks
{
    
    [_tracks removeAllObjects];
    MPMediaQuery *songsQuery = [MPMediaQuery songsQuery];
    NSArray *songsArray = [songsQuery items];
    
    NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:MPMediaItemPropertyLastPlayedDate
                                                             ascending:NO];
    NSArray *sortedSongsArray = [songsArray sortedArrayUsingDescriptors:@[sorter]];
    
    
    @try {
        self.tracks =  [sortedSongsArray subarrayWithRange:NSMakeRange(0, 10)].mutableCopy;
    }
    @catch (NSException *exception) {
        
    }
    
    NSMutableArray *tracksCopy = self.tracks.mutableCopy;
    for (MPMediaItem *item in tracksCopy) {
        
        if (![item valueForProperty:MPMediaItemPropertyArtist] || ![item valueForProperty:MPMediaItemPropertyTitle] || ![item valueForProperty:MPMediaItemPropertyAlbumTitle]) {
            
            [self.tracks removeObject:item];
            
        }
        
    }
    
    [self getCurrentlyPlayingTrack];
}

// if there is currently a song playing it moves the array back, and inserts the now playing track
- (void)getCurrentlyPlayingTrack
{
    self.musicPlayer = [MPMusicPlayerController systemMusicPlayer];
    
    MPMediaItem *currentItem = self.musicPlayer.nowPlayingItem;
    MPMediaItem *firstTrackItem = _tracks.firstObject;
    
    NSString *currentItemTitle = [currentItem valueForProperty:MPMediaItemPropertyTitle];
    NSString *firstTrackTitle = [firstTrackItem valueForProperty:MPMediaItemPropertyTitle];
    
    if (currentItem && ![firstTrackTitle isEqualToString:currentItemTitle]) {
        //set the array
        
        NSMutableArray *newTracks = [[NSMutableArray alloc]initWithObjects:currentItem, nil];
        [newTracks addObjectsFromArray:[_tracks subarrayWithRange:NSMakeRange(0, 4)] ];
        _tracks = newTracks;
    }
    
    // update player statuso
    if (self.musicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
        self.isCurrentlyPlayingTrack = YES;
    } else {
        self.isCurrentlyPlayingTrack = NO;
    }
    
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _feedTracks.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *simpleTableIdentifier = @"songCell";
    
    // reset a few parts of the cell
    AUTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    cell.albumImage.image = [UIImage imageNamed:@"noArtwork"];
    cell.subTitleLabel.text = @"";
    
    tableView.tableFooterView = [UIView new];
    
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"AUMusicTableViewCell" bundle:nil] forCellReuseIdentifier:simpleTableIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    }
    
    AUTrack *track = _feedTracks[indexPath.row];
    
    if (track.albumArtwork) {
        cell.albumImage.image = track.albumArtwork;
    }
    
    // If an object does not have an objectId that means it was just shared.
    if (track.objectId && !track.albumArtwork) {
        
        cell.albumImage.file = track.imageFile;
        [cell.albumImage loadInBackground:^(UIImage *image, NSError *error) {
        
            track.albumArtwork = image;
        }];

    } else if(!track.objectId){
        
        // find track that was just shared and get the album artwork
        
        for (MPMediaItem *item in _tracks) {
            
            if ([[item valueForProperty:MPMediaItemPropertyTitle] isEqualToString:track.title]) {
                
                CGSize artworkImageViewSize = cell.albumImage.bounds.size;
                MPMediaItemArtwork *artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
                if (artwork)
                {
                    UIImage *image = [artwork imageWithSize:artworkImageViewSize];
                    if (image) {
                        cell.albumImage.image = [artwork imageWithSize:artworkImageViewSize];
                    } else {
                        cell.albumImage.image = [UIImage imageNamed:@"noArtwork"];
                    }
                }
            }
            
        }
        
    } else {
        cell.albumImage.image = track.albumArtwork;
    }
    
    cell.albumImage.layer.borderColor = [AUColors darkTextColor].CGColor;
    cell.albumImage.layer.borderWidth = 0.3;
    
    // Settings labels
    cell.songTitleLabel.text = track.title;
    
    if (track.artist) {
        cell.subTitleLabel.text = [NSString stringWithFormat:@"%@", track.artist];
    }
//    if (track.albumTitle) {
//        cell.subTitleLabel.text = [cell.subTitleLabel.text stringByAppendingString:[NSString stringWithFormat:@" - %@", track.albumTitle]];
//    }
    
    cell.votesLabel.text = [NSString stringWithFormat:@"%@ votes", track.votes];

    cell.timeLabel.text = track.shareDate.timeAgoSimple;
    cell.repliesLabel.text = [NSString stringWithFormat:@"%lu replies", (unsigned long)track.comments.count];
    
    // Only add top shadow to the first cell in AUMeViewController
    if (indexPath.row == 0 && [_parent isKindOfClass:[AUMeViewController class]]) {
        CGRect cellBounds       = cell.layer.bounds;
        CGRect shadowFrame      = CGRectMake(cellBounds.origin.x, cellBounds.origin.y, tableView.frame.size.width, 10.0);
        CGPathRef shadowPath    = [UIBezierPath bezierPathWithRect:shadowFrame].CGPath;
        cell.layer.shadowPath   = shadowPath;
        [cell.layer setShadowOffset:CGSizeMake(-2, -2)];
        [cell.layer setShadowColor:[[UIColor grayColor] CGColor]];
        [cell.layer setShadowOpacity:.75];
    }
    
    // Can't vote on songs outside of a local range
    if (![_parent isKindOfClass:[TelescopeViewController class]] && track.objectId && ![_parent isKindOfClass:[AUMeViewController class]]) {
        UIView *upVoteView = [self viewWithImageName:@"upVote"];
        UIView *downVoteView = [self viewWithImageName:@"downVote"];
        
        [cell setSwipeGestureWithView:upVoteView color:AUColors.upVoteColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState3 completionBlock: ^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
            
            AUTrack *track = _feedTracks[indexPath.row];
            track.votes = [NSNumber numberWithInt:[[AUTrackSender upVoteTrack:_feedTracks[indexPath.row]]intValue] + [track.votes intValue]];
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            
        }];
        
        [cell setSwipeGestureWithView:downVoteView color:AUColors.downVoteColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState1 completionBlock: ^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
            
            AUTrack *track = _feedTracks[indexPath.row];
            track.votes = [NSNumber numberWithInt:[[AUTrackSender downVoteTrack:_feedTracks[indexPath.row]]intValue] + [track.votes intValue]];
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
    }
    
    return cell;
}
#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AUSongViewController *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:NULL] instantiateViewControllerWithIdentifier:@"song"];
    viewController.track = _feedTracks[indexPath.row];
    
    if (!viewController.track.albumArtwork) {
        // get artwork from cell
        AUTableViewCell *cell = (AUTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        viewController.track.albumArtwork = cell.albumImage.image;
    }
    
    
    UIViewController *parentVC = (UIViewController *)_parent;
    [parentVC.navigationController pushViewController:viewController animated:YES];
    // present song view
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.tracks.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    AUTrackCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"trackCell" forIndexPath:indexPath];
    
    if (self.isCurrentlyPlayingTrack && indexPath.row == 0) {
        cell.nowPlayingView.hidden = NO;
    } else {
        cell.nowPlayingView.hidden = YES;
    }
    
    // set labels and image view
    MPMediaItem *song = self.tracks[indexPath.row];
    
    cell.artistLabel.text = [song valueForProperty:MPMediaItemPropertyArtist];
    cell.albumLabel.text = [song valueForProperty:MPMediaItemPropertyTitle];
    
    CGSize artworkImageViewSize = cell.albumImage.bounds.size;
    MPMediaItemArtwork *artwork = [song valueForProperty:MPMediaItemPropertyArtwork];
    
    if (artwork)
    {
        UIImage *image = [artwork imageWithSize:artworkImageViewSize];
        if (image) {
            cell.albumImage.image = [artwork imageWithSize:artworkImageViewSize];
        } else {
            cell.albumImage.image = [UIImage imageNamed:@"noArtwork"];
        }
    }
    else
    {
        cell.albumImage.image = [UIImage imageNamed:@"noArtwork"];
    }
    
    if (!cell.hasAddedFade) {
        CAGradientLayer *bottomFade = [CAGradientLayer layer];
        CGRect bounds = cell.albumImage.bounds;
        bounds.size.height *= 2;
        bounds.size.width *= 2;
        bottomFade.bounds = bounds;
        bottomFade.startPoint = CGPointMake(0.5, 1.0);
        bottomFade.endPoint = CGPointMake(0.5, 0.0);
        bottomFade.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0.0 alpha:0.32f] CGColor], (id)[[UIColor colorWithWhite:0.0 alpha:0.0f] CGColor], nil];
        [cell.albumImage.layer addSublayer:bottomFade];
        
        
        cell.hasAddedFade = YES;
    }
    
    cell.blackTextView.backgroundColor = [UIColor clearColor];
    
    cell.nowPlayingView.backgroundColor = [[AUColors primaryColor] colorWithAlphaComponent:0.5];
    
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // share the item selected
    MPMediaItem *item = self.tracks[indexPath.row];
    NSLog(@"Share song: %@:", [item valueForProperty:MPMediaItemPropertyTitle]);
    AUTrackCollectionViewCell *cell = (AUTrackCollectionViewCell *) [collectionView cellForItemAtIndexPath:indexPath];
    
    PFObject *object = [AUTrackSender shareTrack:item WithImage:cell.albumImage.image];
    if (object) {
        
        AUTrack *newTrack = [[AUTrack alloc]initWithPFObject:object];
        
        [_feedTracks insertObject:newTrack atIndex:0];
        
        AUHomeViewController *parent = (AUHomeViewController *)_parent;
        
        // ensures that voting indexes are updated after inserting new row.
        [CATransaction begin];
        [parent.tableView beginUpdates];
        
        [CATransaction setCompletionBlock: ^{
            [parent.tableView reloadData];
        }];
        
        [parent.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
        
        [parent.tableView endUpdates];
        
        [CATransaction commit];
        
    }
}

#pragma mark - <DZNEmptyDataSetSource>

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"No nearby shares";
    NSDictionary *attributes = @{NSFontAttributeName: [AUFonts interstateRegularWithSize:25], NSForegroundColorAttributeName: [AUColors darkTextColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"Tap on a recently played track to get the sharing started!";
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [AUFonts interstateRegularWithSize:15], NSForegroundColorAttributeName: [AUColors lightTextColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

#pragma mark - Helper Methods

- (UIView *)viewWithImageName:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeCenter;
    return imageView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (![_parent isKindOfClass:[AUHomeViewController class]]) {
        return;
    }
    
    AUHomeViewController *parent = (AUHomeViewController *)_parent;
    
    CGRect frame = parent.trackCollectionView.frame;
    CGFloat size = frame.size.height - 64;
    //CGFloat framePercentageHidden = ((20 - frame.origin.y) / (frame.size.height - 1));
    CGFloat scrollOffset = scrollView.contentOffset.y;
    CGFloat scrollDiff = scrollOffset - self.previousScrollViewYOffset;
    CGFloat scrollHeight = scrollView.frame.size.height;
    CGFloat scrollContentSizeHeight = scrollView.contentSize.height + scrollView.contentInset.bottom;
    
    if (scrollOffset <= -scrollView.contentInset.top) {
        frame.origin.y = 63;
    } else if ((scrollOffset + scrollHeight) >= scrollContentSizeHeight) {
        frame.origin.y = -size;
    } else {
        frame.origin.y = MIN(63, MAX(-size, frame.origin.y - scrollDiff));
    }
    
    [parent.trackCollectionView setFrame:frame];
    CGRect tableViewFrame = parent.tableView.frame;
    tableViewFrame.origin.y = parent.trackCollectionView.frame.origin.y + 127;
    [parent.tableView setFrame:tableViewFrame];
    [parent.view bringSubviewToFront:parent.tableView];
    self.previousScrollViewYOffset = scrollOffset;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (![_parent isKindOfClass:[AUHomeViewController class]]) {
        return;
    }
    
    [self stoppedScrolling];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{
    if (![_parent isKindOfClass:[AUHomeViewController class]]) {
        return;
    }
    
    if (!decelerate) {
        [self stoppedScrolling];
    }
}

#pragma mark Scrolling Helper Methods

- (void)stoppedScrolling
{
    if (![_parent isKindOfClass:[AUHomeViewController class]]) {
        return;
    }
    
    AUHomeViewController *parent = (AUHomeViewController *)_parent;
    
    CGRect frame = parent.trackCollectionView.frame;
    if (frame.origin.y < 63) {
        [self animateNavBarTo:-(frame.size.height - 64)];
    }
}

- (void)animateNavBarTo:(CGFloat)y
{
    
    if (![_parent isKindOfClass:[AUHomeViewController class]]) {
        return;
    }
    
    AUHomeViewController *parent = (AUHomeViewController *)_parent;
    
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = parent.trackCollectionView.frame;
        
        frame.origin.y = y;
        [parent.trackCollectionView setFrame:frame];
        CGRect tableViewFrame = parent.tableView.frame;
        tableViewFrame.origin.y = parent.trackCollectionView.frame.origin.y + 127;
        [parent.tableView setFrame:tableViewFrame];
        [parent.view bringSubviewToFront:parent.tableView];
    }];
}


@end
