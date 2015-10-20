//
//  AUSongViewController.m
//  audion
//
//  Created by Nick Porter on 6/13/15.
//  Copyright (c) 2015 Nick Porter. All rights reserved.
//

#import "AUSongViewController.h"
#import "AUHeaderTableViewCell.h"
#import "AUCommentTableViewCell.h"
#import <NSDate+TimeAgo/NSDate+TimeAgo.h>
#import "AUColors.h"
#import "AUFonts.h"
#import "AUTrackSender.h"
#import "SearchViewController.h"

@interface AUSongViewController ()
@property (nonatomic, strong)PHFComposeBarView *composeView;
@end

@implementation AUSongViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.title = @"Song";
    
    self.view.backgroundColor = [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1];
    _tableView.backgroundColor = [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1];
    _tableView.tableFooterView = [UIView new];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (![self.navigationController.childViewControllers.firstObject isKindOfClass:[SearchViewController class]]) {
        [self setupComposeBar];
    }
}

-(void)dismissKeyboard
{
    [self.view endEditing:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)setupComposeBar
{
    CGRect viewBounds = self.view.frame;
    CGRect frame = CGRectMake(0.0f,
                              viewBounds.size.height - PHFComposeBarViewInitialHeight,
                              viewBounds.size.width,
                              PHFComposeBarViewInitialHeight);
    self.composeView = [[PHFComposeBarView alloc] initWithFrame:frame];
    [self.composeView setMaxCharCount:140];
    [self.composeView setMaxLinesCount:5];
    [self.composeView setPlaceholder:@"Type something..."];
    [self.composeView setButtonTitle:@"Reply"];
    self.composeView.delegate = self;
    self.composeView.textView.font = [AUFonts interstateLightWithSize:17];
    self.composeView.textView.tintColor = [AUColors primaryColor];
    self.composeView.button.titleLabel.font = [AUFonts interstateLightWithSize:17];
    self.composeView.placeholderLabel.font = [AUFonts interstateLightWithSize:17];
    [self.view addSubview:self.composeView];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillToggle:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillToggle:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)keyboardWillToggle:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    NSTimeInterval duration;
    UIViewAnimationCurve animationCurve;
    CGRect startFrame;
    CGRect endFrame;
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&duration];
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey]    getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey]        getValue:&startFrame];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]          getValue:&endFrame];
    
    NSInteger signCorrection = 1;
    if (startFrame.origin.y < 0 || startFrame.origin.x < 0 || endFrame.origin.y < 0 || endFrame.origin.x < 0)
        signCorrection = -1;
    
    CGFloat widthChange  = (endFrame.origin.x - startFrame.origin.x) * signCorrection;
    CGFloat heightChange = (endFrame.origin.y - startFrame.origin.y) * signCorrection;
    
    CGFloat sizeChange = UIInterfaceOrientationIsLandscape([self interfaceOrientation]) ? widthChange : heightChange;
    
    CGRect newContainerFrame = self.composeView.frame;
    newContainerFrame.origin.y += sizeChange;
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:(animationCurve << 16)|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [[self composeView] setFrame:newContainerFrame];
                     }
                     completion:NULL];
    
}

#pragma mark - <PHFComposeBarViewDelegate>

- (void)composeBarViewDidPressButton:(PHFComposeBarView *)composeBarView
{
    // Post comment
    [AUTrackSender postComment:self.composeView.text WithTrack:_track];
    
    PFObject *comment = [PFObject objectWithClassName:@"Comment"];
    [comment setObject:self.composeView.text forKey:@"text"];
    
    [_track.comments addObject:comment];
    [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:_track.comments.count inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    // Reset composeview
    [self.composeView.textView resignFirstResponder];
    self.composeView.textView.text = @"";
    [self.composeView setPlaceholder:@"Type something..."];
    self.composeView.placeholderLabel.hidden = NO;
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1 + _track.comments.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        _noRepliesLabel.hidden = NO;
        [self.view bringSubviewToFront:_noRepliesLabel];
        return 165;
    }
    return 87;
}

- (AUCommentTableViewCell *)buildCommentCell:(UITableView *)tableView WithIndexPath:(NSIndexPath*)indexPath
{
    [self.view bringSubviewToFront:_tableView];
    [self.view bringSubviewToFront:_composeView];
    _noRepliesLabel.text = @"";
    // comment cell
    NSString *simpleTableIdentifier = @"commentCell";
    AUCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"AUCommentTableViewCell" bundle:nil] forCellReuseIdentifier:simpleTableIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    }
    
    PFObject *comment = _track.comments[indexPath.row - 1];
    
    cell.commentLabel.text = [comment objectForKey:@"text"];
    cell.commentLabel.textAlignment = NSTextAlignmentJustified;
    cell.commentLabel.numberOfLines = 0;
    [cell.commentLabel sizeToFit];
    cell.timeLabel.text = comment.createdAt.timeAgo;
    if (cell.timeLabel.text.length == 0) {
        cell.timeLabel.text = @"Just now";
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        AUHeaderTableViewCell *cell = [self buildHeaderCell:tableView];
        return cell;
    }
    AUCommentTableViewCell *cell;
    cell = [self buildCommentCell:tableView WithIndexPath:indexPath];
    return cell;
    
}

#pragma mark - Cell Creation

- (AUHeaderTableViewCell *)buildHeaderCell:(UITableView *)tableView
{
    NSString *simpleTableIdentifier = @"headerCell";
    AUHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"AUHeaderTableViewCell" bundle:nil] forCellReuseIdentifier:simpleTableIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    }
    
    if (_track.albumArtwork) {
        cell.albumImageView.image = _track.albumArtwork;
    }
    cell.albumImageView.layer.borderColor = [AUColors darkTextColor].CGColor;
    cell.albumImageView.layer.borderWidth = 0.3;
    
    cell.titleLabel.text = _track.title;
    cell.albumTitleLabel.text = _track.albumTitle;
    cell.artistLabel.text = _track.artist;
    
    cell.timeLabel.text = _track.shareDate.timeAgoSimple;
    cell.votesLabel.text = [NSString stringWithFormat:@"%@ votes", _track.votes];
    cell.repliesLabel.text = [NSString stringWithFormat:@"%lu replies", (unsigned long)_track.comments.count];
    return cell;
}
@end
