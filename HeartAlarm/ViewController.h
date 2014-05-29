//
//  ViewController.h
//  HeartAlarm
//
//  Created by Russell on 4/23/14.
//  Copyright (c) 2014 Russell Research Corporation. All rights reserved.
//
//------------------------------------------------------------------------------

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property NSInteger mAge;
@property NSInteger mUpperAlarmRate;
@property NSInteger mLowerAlarmRate;

@property BOOL mTestModeEnabled;

@property BOOL mUpperAlarmEnabled;
@property BOOL mLowerAlarmEnabled;
@property BOOL mUpperAlarmRepeats;
@property BOOL mLowerAlarmRepeats;

@property BOOL mUpperAlarmSounded;
@property BOOL mLowerAlarmSounded;

@property( nonatomic, retain ) NSString *mPatientName;
@property( nonatomic, retain ) NSString *mTextMessageNumber;

- (void)updateRateTable;

@end
