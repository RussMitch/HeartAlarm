//
//  BarChartView.m
//  HeartAlarm
//
//  Created by Russell on 4/25/14.
//  Copyright (c) 2014 Russell Research Corporation. All rights reserved.
//
//------------------------------------------------------------------------------

#import "BarChartView.h"

@interface BarChartView () {
    
    float mXoffset;
    UIScrollView *mScrollView;
    
}

@end
    
@implementation BarChartView

//------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame
//------------------------------------------------------------------------------
{
    if (!(self = [super initWithFrame:frame]))
        return nil;
    
    self.backgroundColor= [UIColor whiteColor];
    
    [self createScrollView];
    
    return self;
}

//------------------------------------------------------------------------------
- (void)createScrollView
//------------------------------------------------------------------------------
{
    [mScrollView removeFromSuperview];
    
    mScrollView= [[UIScrollView alloc] initWithFrame:CGRectMake( 10, 10, self.frame.size.width-20, self.frame.size.height-10-44-10 )];
    mScrollView.backgroundColor= [UIColor whiteColor];
    mScrollView.layer.borderColor= [[UIColor blackColor] CGColor];
    mScrollView.layer.borderWidth= 1;
    mScrollView.contentSize= CGSizeMake( mScrollView.frame.size.width, mScrollView.frame.size.height );
    
    mXoffset= 4;
    
    [self addSubview:mScrollView];
}

//------------------------------------------------------------------------------
- (void)addHeartRate:(NSInteger)heartRate withColor:(UIColor *)color
//------------------------------------------------------------------------------
{
    float y= mScrollView.frame.size.height-1;
    
    UIView *contentView= [[UIView alloc] initWithFrame:CGRectMake( mXoffset, 0, 4, mScrollView.frame.size.height )];
    [mScrollView addSubview:contentView];
    
    for (int i=0;i<heartRate;i++) {
        UIView *view= [[UIView alloc] initWithFrame:CGRectMake( 0, y, 4, 1 )];
        view.backgroundColor= color;
        [contentView addSubview:view];
        y--;
    }
    
    mXoffset+= 8;
    
    if ([mScrollView.subviews count]> 40*5) {

        [[[mScrollView subviews] objectAtIndex:0] removeFromSuperview];

    }
    
    if (mXoffset>mScrollView.frame.size.width) {
        
        float offsetX= mScrollView.contentOffset.x;
        offsetX+= 8;
        mScrollView.contentOffset= CGPointMake( offsetX, 0 );
        mScrollView.contentSize= CGSizeMake( mScrollView.contentSize.width+8, mScrollView.contentSize.height );
        
    }
}

//------------------------------------------------------------------------------
- (void)removeAllData
//------------------------------------------------------------------------------
{
    [self createScrollView];
}

@end
