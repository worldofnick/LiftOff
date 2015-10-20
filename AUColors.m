//
//  AUColors.m
//
//
//  Created by Nick Porter on 5/26/15.
//  Copyright (c) 2015 Nick Porter. All rights reserved.
//

#import "AUColors.h"

@implementation AUColors

+ (UIColor *)primaryColor
{
    return [UIColor colorWithRed:0.14 green:0.4 blue:0.54 alpha:1];
}

+ (UIColor *)darkTextColor
{
    return [self lightTextColor];
}

+ (UIColor *)lightTextColor
{
    return [UIColor colorWithRed:0.43 green:0.43 blue:0.43 alpha:1];
}

+ (UIColor *)upVoteColor
{
    return [UIColor colorWithRed:0.15 green:0.73 blue:0.38 alpha:1];
}

+ (UIColor *)downVoteColor
{
    return [UIColor colorWithRed:0.91 green:0.34 blue:0.29 alpha:1];
}

@end
