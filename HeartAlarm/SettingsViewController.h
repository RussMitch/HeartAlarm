//
//  SettingsViewController.h
//  TMTimester
//
//  Created by Russell on 3/22/14.
//  Copyright (c) 2014 Russell Research Corporation. All rights reserved.
//
//------------------------------------------------------------------------------

#import <UIKit/UIKit.h>

#import "ViewController.h"

#define kAge                @"Age"
#define kUpperAlarmRate     @"UpperAlarmRate"
#define kLowerAlarmRate     @"LowerAlarmRate"

#define kUpperAlarmEnabled  @"UpperAlarmEnabled"
#define kLowerAlarmEnabled  @"LowerAlarmEnabled"

#define kUpperAlarmRepeats  @"UpperAlarmRepeats"
#define kLowerAlarmRepeats  @"LowerAlarmRepeats"

#define kTextMessageNumber  @"TextMessageNumber"
#define kPatientName        @"PatientName"

@interface SettingsViewController : UIViewController

- (id)initWithParentViewController:(ViewController *)parentViewController;

@end
