//
//  AppDelegate.m
//  audion
//
//  Created by Nick Porter on 5/26/15.
//  Copyright (c) 2015 Nick Porter. All rights reserved.
//

#import "AppDelegate.h"
#import "AUFonts.h"
#import "AUColors.h"
#import <Parse/Parse.h>
#import <ParseCrashReporting/ParseCrashReporting.h>

@implementation AppDelegate

@synthesize locationManager;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self setUI];
    
    [ParseCrashReporting enable];
    [Parse enableLocalDatastore];
    
    // Initialize Parse.
    [Parse setApplicationId:@"APP_ID"
                  clientKey:@"CLIENT_ID"];
    
    // [Optional] Track statistics around application opens.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];

    
    return YES;
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self getLocation];
    return YES;
}

- (void)setUI
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                            NSForegroundColorAttributeName: [UIColor whiteColor],
                                                            NSFontAttributeName: [AUFonts interstateRegularWithSize:19.5]
                                                            }];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0 green:0.29 blue:0.45 alpha:1]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[UINavigationBar appearance] setBackIndicatorImage:[UIImage imageNamed:@"backArrow"]];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"backArrow"]];
    
    [self setupTabBarItems];
    
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setDefaultTextAttributes:@{
                                                                                                 NSFontAttributeName: [AUFonts interstateLightWithSize:15.5],
                                                                                                 }];
}

- (void)getLocation
{
    self.locationManager = [[CLLocationManager alloc] init];
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    _currentLocation = newLocation;
}

- (void)setupTabBarItems {
    // Override point for customization after application launch.
    
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    UITabBar *tabBar = tabBarController.tabBar;
    
    // repeat for every tab, but increment the index each time
    UITabBarItem *firstTab = [tabBar.items objectAtIndex:0];
    
    // also repeat for every tab
    firstTab.image = [[UIImage imageNamed:@"home"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    firstTab.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    firstTab.title = nil;
    firstTab.selectedImage = [[UIImage imageNamed:@"homeSelected"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    
    UITabBarItem *secondTab = [tabBar.items objectAtIndex:1];
    
    // also repeat for every tab
    secondTab.image = [[UIImage imageNamed:@"chart"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    secondTab.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    secondTab.title = nil;
    secondTab.selectedImage = [[UIImage imageNamed:@"chartSelected"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    
    UITabBarItem *thirdTab = [tabBar.items objectAtIndex:2];
    
    // also repeat for every tab
    thirdTab.image = [[UIImage imageNamed:@"ninja"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    thirdTab.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    thirdTab.title = nil;
    thirdTab.selectedImage = [[UIImage imageNamed:@"ninjaSelected"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem *fourthTab = [tabBar.items objectAtIndex:3];
    
    // also repeat for every tab
    fourthTab.image = [[UIImage imageNamed:@"me"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    fourthTab.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    fourthTab.title = nil;
    fourthTab.selectedImage = [[UIImage imageNamed:@"userSelected"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem *fifthTab = [tabBar.items objectAtIndex:4];
    
    // also repeat for every tab
    fifthTab.image = [[UIImage imageNamed:@"settings"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    fifthTab.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    fifthTab.title = nil;
    fifthTab.selectedImage = [[UIImage imageNamed:@"settingsSelected"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    // remove glow
    [[UITabBar appearance] setSelectionIndicatorImage:[[UIImage alloc] init]];
    
}

@end
