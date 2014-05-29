//
//  AppDelegate.m
//  HeartAlarm
//
//  Created by Russell on 4/23/14.
//  Copyright (c) 2014 Russell Research Corporation. All rights reserved.
//
//------------------------------------------------------------------------------

#import "AppDelegate.h"

@interface AppDelegate () {

    BOOL mIsFirstLaunch;
    
}

@end

@implementation AppDelegate

//------------------------------------------------------------------------------
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
//------------------------------------------------------------------------------
{
    mIsFirstLaunch= YES;
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];

    return YES;
}

//------------------------------------------------------------------------------
- (void)applicationDidBecomeActive:(UIApplication *)application
//------------------------------------------------------------------------------
{
    if (mIsFirstLaunch) {
        mIsFirstLaunch= NO;
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kApplicationDidBecomeActive object:nil];
    }
}

@end
