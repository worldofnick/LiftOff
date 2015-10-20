//
//  AUTabBar.m
//  audion
//
//  Created by Nick Porter on 5/26/15.
//  Copyright (c) 2015 Nick Porter. All rights reserved.
//

#import "AUTabBarController.h"
#import "AUColors.h"

@implementation AUTabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setupTabBar];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupTabBar];
    [self setSelectedIndex:0];

}

- (void)setupTabBar
{
    self.tabBar.barTintColor = [UIColor whiteColor];;
    self.tabBar.translucent = NO;
    self.tabBar.tintColor = [AUColors primaryColor]; // set the tab bar tint color to something cool.
    self.delegate = self;   // Just to demo that delegate methods are being called.
    
    self.rippleFromTapLocation = YES;
    self.backgroundFadeColor = [UIColor clearColor];
    self.tapCircleDiameter = 100;
    self.tapCircleColor = [AUColors primaryColor];
    self.underlineThickness = self.tabBar.frame.size.height;
}

@end
