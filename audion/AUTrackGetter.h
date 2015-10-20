//
//  AUTrackGetter.h
//  audion
//
//  Created by Nick Porter on 6/9/15.
//  Copyright (c) 2015 Nick Porter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface AUTrackGetter : NSObject

+ (void)getGlobalFeed:(void(^)(NSArray *tracks))completionBlock;
+ (void)getUserFeedWithObjectIds:(NSArray *)Ids :(void(^)(NSArray *tracks))completionBlock;
+ (void)getFeed:(CLLocation *)location WithCompletion:(void(^)(NSArray *tracks))completionBlock;

@end
