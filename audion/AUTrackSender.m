//
//  AUTrackSender.m
//  audion
//
//  Created by Nick Porter on 6/9/15.
//  Copyright (c) 2015 Nick Porter. All rights reserved.
//

#import "AUTrackSender.h"
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "AUColors.h"

@implementation AUTrackSender

+ (PFObject *)shareTrack:(MPMediaItem *)track WithImage:(UIImage *)artwork
{
    if (![self canShareSong:track]) {
        return nil;
    }
    
    [SVProgressHUD setBackgroundColor:[UIColor whiteColor]];
    [SVProgressHUD setRingThickness:3];
    [SVProgressHUD setForegroundColor:[AUColors primaryColor]];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    
    CLLocation *currentLocation = ((AppDelegate *)[UIApplication sharedApplication].delegate).currentLocation;
    
    if (currentLocation) {
        NSLog(@"shared");
        PFObject *parseTrack = [PFObject objectWithClassName:@"Track"];
        
        NSString *trackTitle = [track valueForProperty:MPMediaItemPropertyTitle];
        NSString *trackAlbumTitle = [track valueForProperty:MPMediaItemPropertyAlbumTitle];
        NSString *trackArtist = [track valueForProperty:MPMediaItemPropertyArtist];
        
        if (trackTitle) {
            [parseTrack setObject:trackTitle forKey:@"title"];
        }
        
        if (trackAlbumTitle) {
            [parseTrack setObject:trackAlbumTitle forKey:@"album"];
        }
        
        if (trackArtist) {
            [parseTrack setObject:trackArtist forKey:@"artist"];
        }
        
        [parseTrack setObject:[PFFile fileWithData:UIImagePNGRepresentation(artwork)] forKey:@"albumArtwork"];
        [parseTrack setObject:[NSNumber numberWithInt:0] forKey:@"votes"];
        // will use the count from the comments array
        
        [parseTrack setObject:[PFGeoPoint geoPointWithLocation:currentLocation] forKey:@"location"];
        
        [parseTrack saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        
            // Save To iCloud
            NSUserDefaults *store = [NSUserDefaults standardUserDefaults];
            
            if (store) {
                
                NSMutableArray *sharedTracks = [store valueForKey:@"sharedTracks"];
                sharedTracks = sharedTracks.mutableCopy;
                if (!sharedTracks) {
                    sharedTracks = [[NSMutableArray alloc]init];
                }
                
                [sharedTracks insertObject:parseTrack.objectId atIndex:0];
                [store setObject:sharedTracks forKey:@"sharedTracks"];
                [store synchronize];
            }
        
            [SVProgressHUD dismiss];
        }];
        return parseTrack;
    }
    NSLog(@"current location not working");
    return nil;
}

// Prevents users from spamming songs
// Returns NO if the song was shared within a day
+ (BOOL)canShareSong:(MPMediaItem *)track
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dict = [defaults objectForKey:@"sharedDict"];
    dict = dict.mutableCopy;
    
    if (!dict) {
        dict = [[NSMutableDictionary alloc]init];
    }
    NSDate *shareDate = [dict objectForKey:[NSString stringWithFormat:@"%llu", track.persistentID]];
    if (!shareDate) {
        [dict setObject:[NSDate date] forKey:[NSString stringWithFormat:@"%llu", track.persistentID]];
        [defaults setObject:dict forKey:@"sharedDict"];
        return YES;
    }
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    BOOL isToday = [calendar isDateInToday:shareDate];
    
    if (!isToday) {
        [dict setObject:[NSDate date] forKey:[NSString stringWithFormat:@"%llu", track.persistentID]];
    }
    [defaults setObject:dict forKey:@"sharedDict"];
    return !isToday;
}

+ (NSNumber *)upVoteTrack:(AUTrack *)track
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *upVotedTracks = [defaults objectForKey:@"upVotedTracks"];
    upVotedTracks = upVotedTracks.mutableCopy;
    
    if (!upVotedTracks) {
        upVotedTracks = [[NSMutableArray alloc]init];
    }
    if (![upVotedTracks containsObject:track.objectId]) {
        
        [upVotedTracks addObject:track.objectId];
        [defaults setObject:upVotedTracks forKey:@"upVotedTracks"];
        
        int increment = 1;
        NSMutableArray *downVotedTracks = [defaults objectForKey:@"downVotedTracks"];
        downVotedTracks = downVotedTracks.mutableCopy;
        if ([downVotedTracks containsObject:track.objectId]) {
            [downVotedTracks removeObject:track.objectId];
            [defaults setObject:downVotedTracks forKey:@"downVotedTracks"];
            increment++;
        }
        
        PFQuery *query = [PFQuery queryWithClassName:@"Track"];
        [query whereKey:@"objectId" equalTo:track.objectId];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            PFObject *PFTrack = objects.firstObject;
            [PFTrack incrementKey:@"votes" byAmount:[NSNumber numberWithInt:increment]];
            [PFTrack saveInBackground];
        }];
        return [NSNumber numberWithInt:increment];
        
    }
    
    return 0;
}

+ (NSNumber *)downVoteTrack:(AUTrack *)track
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *downVotedTracks = [defaults objectForKey:@"downVotedTracks"];
    downVotedTracks = downVotedTracks.mutableCopy;
    
    if (!downVotedTracks) {
        downVotedTracks = [[NSMutableArray alloc]init];
    }
    if (![downVotedTracks containsObject:track.objectId]) {
        
        [downVotedTracks addObject:track.objectId];
        [defaults setObject:downVotedTracks forKey:@"downVotedTracks"];
        
        int increment = -1;
        NSMutableArray *upVotedTracks = [defaults objectForKey:@"upVotedTracks"];
        upVotedTracks = upVotedTracks.mutableCopy;
        if ([upVotedTracks containsObject:track.objectId]) {
            [upVotedTracks removeObject:track.objectId];
            [defaults setObject:upVotedTracks forKey:@"upVotedTracks"];
            increment--;
        }
        
        PFQuery *query = [PFQuery queryWithClassName:@"Track"];
        [query whereKey:@"objectId" equalTo:track.objectId];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            PFObject *PFTrack = objects.firstObject;
            [PFTrack incrementKey:@"votes" byAmount:[NSNumber numberWithInt:increment]];
            [PFTrack saveInBackground];
        }];
        return [NSNumber numberWithInt:increment];
        
    }
    
    return 0;
}

+ (PFObject *)postComment:(NSString *)comment WithTrack:(AUTrack *)track;
{
    [SVProgressHUD setBackgroundColor:[UIColor whiteColor]];
    [SVProgressHUD setRingThickness:3];
    [SVProgressHUD setForegroundColor:[AUColors primaryColor]];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    
    if (track.objectId) {
        
        PFQuery *query = [PFQuery queryWithClassName:@"Track"];
        [query whereKey:@"objectId" equalTo:track.objectId];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            PFObject *PFTrack = objects.firstObject;
            PFObject *PFComment = [PFObject objectWithClassName:@"Comment"];
            [PFComment setObject:comment forKey:@"text"];
            
            NSMutableArray *comments = [PFTrack objectForKey:@"comments"];
            comments = comments.mutableCopy;
            if (!comments) {
                comments = [[NSMutableArray alloc]init];
            }
            [comments addObject:PFComment];
            
            [PFTrack setObject:comments forKey:@"comments"];
            [PFTrack saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            [SVProgressHUD dismiss];
            }];
        }];
        
    } else {
            
            PFQuery *query = [PFQuery queryWithClassName:@"Track"];
            [query whereKey:@"album" equalTo:track.albumTitle];
            [query whereKey:@"artist" equalTo:track.artist];
            [query whereKey:@"artist" equalTo:track.artist];
            [query orderByDescending:@"createdAt"];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                PFObject *PFTrack = objects.firstObject;
                PFObject *PFComment = [PFObject objectWithClassName:@"Comment"];
                [PFComment setObject:comment forKey:@"text"];
                
                NSMutableArray *comments = [PFTrack objectForKey:@"comments"];
                comments = comments.mutableCopy;
                if (!comments) {
                    comments = [[NSMutableArray alloc]init];
                }
                [comments addObject:PFComment];
                
                [PFTrack setObject:comments forKey:@"comments"];
                [PFTrack saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    [SVProgressHUD dismiss];
                }];
            }];
            
        }
    
    return nil;
}
@end
