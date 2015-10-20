//
//  AUTrack.h
//  audion
//
//  Created by Nick Porter on 6/10/15.
//  Copyright (c) 2015 Nick Porter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface AUTrack : NSObject

- (id)initWithPFObject:(PFObject *)object;

@property (nonatomic, strong)NSString *title;
@property (nonatomic, strong)NSString *artist;
@property (nonatomic, strong)NSString *albumTitle;
@property (nonatomic, strong)UIImage *albumArtwork;
@property (nonatomic, strong)NSNumber *votes;
@property (nonatomic, strong)NSMutableArray *comments;
@property (nonatomic, strong)NSDate *shareDate;
@property (nonatomic, strong)NSString *objectId;


@property (nonatomic, strong)PFFile *imageFile;
@end
