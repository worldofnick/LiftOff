//
//  AUTrackGetter.m
//  audion
//
//  Created by Nick Porter on 6/9/15.
//  Copyright (c) 2015 Nick Porter. All rights reserved.
//

#import "AUTrackGetter.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import <MapKit/MapKit.h>

@implementation AUTrackGetter

+ (void)getFeed:(CLLocation *)location WithCompletion:(void(^)(NSArray *tracks))completionBlock
{

    PFQuery *query = [PFQuery queryWithClassName:@"Track"];
    
    // calculate bounding box
    CLLocationCoordinate2D center = location.coordinate;
    // 80467.2 == 50 miles in meteres
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(center, 80467.2, 80467.2);
    CLLocationCoordinate2D southWestCorner, northEastCorner;
    
    northEastCorner.latitude  = center.latitude  + (region.span.latitudeDelta  / 2.0);
    northEastCorner.longitude = center.longitude + (region.span.longitudeDelta / 2.0);
    southWestCorner.latitude  = center.latitude  - (region.span.latitudeDelta  / 2.0);
    southWestCorner.longitude = center.longitude - (region.span.longitudeDelta / 2.0);
    
    PFGeoPoint *southWest = [PFGeoPoint geoPointWithLatitude:southWestCorner.latitude longitude:southWestCorner.longitude];
    PFGeoPoint *northEast = [PFGeoPoint geoPointWithLatitude:northEastCorner.latitude longitude:northEastCorner.longitude];
    
    [query whereKey:@"location" withinGeoBoxFromSouthwest:southWest toNortheast:northEast];
    [query orderByDescending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        // Fetching an array of PFObject comments for each object
        for (int i = 0; i < objects.count; i++) {
            
            PFObject *object = objects[i];
            NSArray *comments = [object valueForKey:@"comments"];
            
            [PFObject fetchAllIfNeededInBackground:comments block:^(NSArray *objects, NSError *error) {
               
                [object setObject:objects forKey:@"comments"];
                
            }];
            
            if (i == objects.count - 1) {
                completionBlock(objects);
            }

        }
        
    }];
}

+ (void)getUserFeedWithObjectIds:(NSArray *)Ids :(void(^)(NSArray *tracks))completionBlock
{
    PFQuery *query = [PFQuery queryWithClassName:@"Track"];
    [query whereKey:@"objectId" containedIn:Ids];
    query.limit = 75;
    [query orderByDescending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        for (int i = 0; i < objects.count; i++) {
            
            PFObject *object = objects[i];
            NSArray *comments = [object valueForKey:@"comments"];
            
            [PFObject fetchAllIfNeededInBackground:comments block:^(NSArray *objects, NSError *error) {
                
                [object setObject:objects forKey:@"comments"];
                
            }];
            
            if (i == objects.count - 1) {
                completionBlock(objects);
            }
            
        }
        
    }];
}

+ (void)getGlobalFeed:(void(^)(NSArray *tracks))completionBlock
{
    PFQuery *query = [PFQuery queryWithClassName:@"Track"];
    query.limit = 50;
    [query orderByDescending:@"votes"];
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute| NSCalendarUnitSecond ) fromDate:[[NSDate alloc] init]];
    [components setDay:([components day] - 14)];
    NSDate *twoWeeksAgo  = [cal dateFromComponents:components];

    [query whereKey:@"createdAt" greaterThanOrEqualTo:twoWeeksAgo];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        for (int i = 0; i < objects.count; i++) {
            
            PFObject *object = objects[i];
            NSArray *comments = [object valueForKey:@"comments"];
            
            [PFObject fetchAllIfNeededInBackground:comments block:^(NSArray *objects, NSError *error) {
                
                [object setObject:objects forKey:@"comments"];
                
            }];
            
            if (i == objects.count - 1) {
                completionBlock(objects);
            }
            
        }
        
    }];
}

@end
