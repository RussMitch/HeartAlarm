//
//  BarChartView.h
//  HeartAlarm
//
//  Created by Russell on 4/25/14.
//  Copyright (c) 2014 Russell Research Corporation. All rights reserved.
//
//------------------------------------------------------------------------------

#import <UIKit/UIKit.h>

@interface BarChartView : UIView

- (void)removeAllData;
- (void)addHeartRate:(NSInteger)heartRate withColor:(UIColor *)color;

@end
