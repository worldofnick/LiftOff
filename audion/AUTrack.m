//
//  AUTrack.m
//  audion
//
//  Created by Nick Porter on 6/10/15.
//  Copyright (c) 2015 Nick Porter. All rights reserved.
//

#import "AUTrack.h"

@implementation AUTrack

- (id)initWithPFObject:(PFObject *)object
{
    self = [super init];
    
    NSDictionary *data = [object valueForKey:@"estimatedData"];
    
    _title = [data objectForKey:@"title"];
    _artist = [data objectForKey:@"artist"];
    _albumTitle = [data objectForKey:@"album"];
    _votes = [data objectForKey:@"votes"];
    _objectId = object.objectId;
    _shareDate = object.createdAt;
    _comments = [object objectForKey:@"comments"];
    
    if (!_shareDate) {
        _shareDate = [NSDate date];
    }
    if (!_comments) {
        _comments = [[NSMutableArray alloc]init];
    }
    
    _imageFile = [data objectForKey:@"albumArtwork"];
    return self;
}

@end
