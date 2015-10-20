//
//  AUSettingsViewController.m
//  audion
//
//  Created by Nick Porter on 6/6/15.
//  Copyright (c) 2015 Nick Porter. All rights reserved.
//

#import "AUSettingsViewController.h"
#import "AUColors.h"

@interface AUSettingsViewController ()

@end

@implementation AUSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupButtons];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupButtons
{    
    CGFloat size = self.view.frame.size.width / 3;
    int yOffSet = 64;
    
    UIButton *rateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rateButton.frame = CGRectMake(0, yOffSet, size, size);
    [rateButton setBackgroundImage:[UIImage imageNamed:@"rate"] forState:UIControlStateNormal];
    [rateButton addTarget:self action:@selector(openRate) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    shareButton.frame = CGRectMake(size, yOffSet, size, size);
    [shareButton setBackgroundImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(openShareSheet) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *twitterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    twitterButton.frame = CGRectMake(size * 2, yOffSet, size, size);
    [twitterButton setBackgroundImage:[UIImage imageNamed:@"twitter"] forState:UIControlStateNormal];
    [twitterButton addTarget:self action:@selector(openTwitter) forControlEvents:UIControlEventTouchUpInside];
    
    int yOffSetRowTwo = 64 + size - 1;
    
    UIButton *instaButton = [UIButton buttonWithType:UIButtonTypeCustom];
    instaButton.frame = CGRectMake(0, yOffSetRowTwo, size, size);
    [instaButton setBackgroundImage:[UIImage imageNamed:@"insta"] forState:UIControlStateNormal];
    [instaButton addTarget:self action:@selector(openInstagram) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *spotifyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    spotifyButton.frame = CGRectMake(size, yOffSetRowTwo, size, size);
    [spotifyButton setBackgroundImage:[UIImage imageNamed:@"spotify"] forState:UIControlStateNormal];
    [spotifyButton addTarget:self action:@selector(openSpotify) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *supportButton = [UIButton buttonWithType:UIButtonTypeCustom];
    supportButton.frame = CGRectMake(size * 2, yOffSetRowTwo, size, size);
    [supportButton setBackgroundImage:[UIImage imageNamed:@"support"] forState:UIControlStateNormal];
    [supportButton addTarget:self action:@selector(openSupport) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.view addSubview:rateButton];
    [self.view addSubview:shareButton];
    [self.view addSubview:twitterButton];
    [self.view addSubview:instaButton];
    [self.view addSubview:spotifyButton];
    [self.view addSubview:supportButton];
}

- (void)openShareSheet
{
    NSLog(@"insert correct url");
    NSString *string = @"LiftOff. A new way to discover music.";
    NSURL *URL = [NSURL URLWithString:@"http://worldofnick.net"];
    
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:@[string, URL]
                                      applicationActivities:nil];
    [self.navigationController presentViewController:activityViewController
                                       animated:YES
                                     completion:^{
                                         
                                     }];
}

- (void)openRate
{
    NSString *appID = @"1003506916";
    
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8", appID]]];
}

- (void)openTwitter
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?id=3238562094"]];
}

- (void)openInstagram
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"instagram://user?username=liftoff_app"]];
}

- (void)openSpotify
{
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Currently Unsupported"
                              message:@"Soon you will be able to share what you are listing to on spotify!"
                              delegate:self
                              cancelButtonTitle:@"Sweet!"
                              otherButtonTitles:nil];
    
    [alertView show];
}

- (void)openSupport
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://worldofnick.net/contact"]];
}
@end
