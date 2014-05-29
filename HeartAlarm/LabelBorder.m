//
//  LabelBorder.m
//  HeartAlarm
//
//  Created by Russell on 4/24/14.
//  Copyright (c) 2014 Russell Research Corporation. All rights reserved.
//
//------------------------------------------------------------------------------

#import "LabelBorder.h"

@implementation LabelBorder

//------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame
//------------------------------------------------------------------------------
{
    if (!(self = [super initWithFrame:frame]))
        return nil;
    return self;
}

//------------------------------------------------------------------------------
- (void)drawTextInRect:(CGRect)rect
//------------------------------------------------------------------------------
{
    CGSize shadowOffset = self.shadowOffset;
    UIColor *textColor = self.textColor;
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(c, 1);
    CGContextSetLineJoin(c, kCGLineJoinRound);
    
    CGContextSetTextDrawingMode(c, kCGTextStroke);
    self.textColor = [UIColor blackColor];
    [super drawTextInRect:rect];
    
    CGContextSetTextDrawingMode(c, kCGTextFill);
    self.textColor = textColor;
    self.shadowOffset = CGSizeMake(0, 0);
    [super drawTextInRect:rect];
    
    self.shadowOffset = shadowOffset;
}

@end
