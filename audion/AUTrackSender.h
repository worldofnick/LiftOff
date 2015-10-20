//
//  AUTrackSender.h
//  audion
//
//  Created by Nick Porter on 6/9/15.
//  Copyright (c) 2015 Nick Porter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <Parse/Parse.h>
#import "AUTrack.h"

@interface AUTrackSender : NSObject

+ (PFObject *)shareTrack:(MPMediaItem *)track WithImage:(UIImage *)artwork;

+ (NSNumber *)upVoteTrack:(AUTrack *)track;
+ (NSNumber *)downVoteTrack:(AUTrack *)track;

+ (PFObject *)postComment:(NSString *)comment WithTrack:(AUTrack *)track;
@end
