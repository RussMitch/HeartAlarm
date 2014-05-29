//
//  SettingsViewController.m
//  TMTimester
//
//  Created by Russell on 3/22/14.
//  Copyright (c) 2014 Russell Research Corporation. All rights reserved.
//
//------------------------------------------------------------------------------

#import "SettingsViewController.h"

@interface SettingsViewController () <UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate> {

    UILabel *mAgeLabel;
    UIView *mOverlayView;
    UIView *mPickerRootView;
    UILabel *mUpperAlarmLabel;
    UILabel *mLowerAlarmLabel;
    UIPickerView *mPickerView;
    UIScrollView *mScrollView;
    
}

@property( nonatomic, retain ) ViewController *mParentViewController;

@end

@implementation SettingsViewController

#define kNumberTag  1
#define kNameTag    2

//------------------------------------------------------------------------------
- (id)initWithParentViewController:(ViewController *)parentViewController
//------------------------------------------------------------------------------
{
    if (!(self= [super init]))
        return nil;
    
    self.mParentViewController= parentViewController;
    
    return self;
}

//------------------------------------------------------------------------------
- (void)viewDidLoad
//------------------------------------------------------------------------------
{
    [super viewDidLoad];
    
    self.view.backgroundColor= [UIColor whiteColor];
}

//------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//------------------------------------------------------------------------------
{
    [super viewDidAppear:animated];
    
    {
        UILabel *label= [[UILabel alloc] initWithFrame:CGRectMake( 0, 20, 320, 44 )];
        label.backgroundColor= [UIColor clearColor];
        label.text= @"Settings";
        label.textColor= [UIColor redColor];
        label.font= [UIFont boldSystemFontOfSize:18];
        label.textAlignment= NSTextAlignmentCenter;
        label.backgroundColor= [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1.0];
        [self.view addSubview:label];
    }
    {
        UIButton *button= [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame= CGRectMake( self.view.frame.size.width-60, 20, 60, 44 );
        [button setTitle:@"Done" forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:18]];
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector( doneButtonTapped ) forControlEvents:UIControlEventTouchDown];
        
        [self.view addSubview:button];
    }
    {
        UIView *view= [[UIView alloc] initWithFrame:CGRectMake( 0, 63, 320, 1 )];
        view.backgroundColor= [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
        [self.view addSubview:view];
    }

    mScrollView= [[UIScrollView alloc] initWithFrame:CGRectMake( 0, 64, 320, self.view.frame.size.height-64 )];
    mScrollView.backgroundColor= [UIColor whiteColor];
    [self.view addSubview:mScrollView];

    float y= 0;
    
    {
        UILabel *label= [[UILabel alloc] initWithFrame:CGRectMake( 20, y, 280, 30 )];
        label.backgroundColor= [UIColor clearColor];
        label.text= @"Your Age:";
        label.textColor= [UIColor blackColor];
        [mScrollView addSubview:label];
        
        y+= 30;
    }
    {
        UIView *view= [[UIView alloc] initWithFrame:CGRectMake( 20, y, 280, 44 )];
        view.backgroundColor= [UIColor whiteColor];
        view.layer.borderColor= [[UIColor blueColor] CGColor];
        view.layer.borderWidth= 2;
        [mScrollView addSubview:view];
        
        mAgeLabel= [[UILabel alloc] initWithFrame:CGRectMake( 7, 7, 268, 30 ) ];
        mAgeLabel.textColor= [UIColor redColor];
        mAgeLabel.font= [UIFont systemFontOfSize:24];
        mAgeLabel.text= [NSString stringWithFormat:@"%d", (int)self.mParentViewController.mAge];
        [view addSubview:mAgeLabel];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector( ageTapped )];
        [view addGestureRecognizer:tapGestureRecognizer];
        
        y+= 44+10;
    }    
    {
        UILabel *label= [[UILabel alloc] initWithFrame:CGRectMake( 20, y, 280, 30 )];
        label.backgroundColor= [UIColor clearColor];
        label.text= @"Sound Alarm if HR is greater than:";
        label.textColor= [UIColor blackColor];
        [mScrollView addSubview:label];
        
        y+= 30;
    }
    {
        UIView *view= [[UIView alloc] initWithFrame:CGRectMake( 20, y, 54, 44 )];
        view.backgroundColor= [UIColor whiteColor];
        view.layer.borderColor= [[UIColor blueColor] CGColor];
        view.layer.borderWidth= 2;
        [mScrollView addSubview:view];
        
        mUpperAlarmLabel= [[UILabel alloc] initWithFrame:CGRectMake( 7, 7, 40, 30 ) ];
        mUpperAlarmLabel.textColor= [UIColor redColor];
        mUpperAlarmLabel.font= [UIFont systemFontOfSize:24];
        mUpperAlarmLabel.text= [NSString stringWithFormat:@"%d", (int)self.mParentViewController.mUpperAlarmRate];
        [view addSubview:mUpperAlarmLabel];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector( upperAlarmTapped )];
        [view addGestureRecognizer:tapGestureRecognizer];

        {
            UISwitch *switchView= [[UISwitch alloc] initWithFrame:CGRectMake( self.view.frame.size.width/2-50/2, y, 50, 30 )];
            [switchView addTarget:self action:@selector( upperAlarmEnabledSwitchChanged: ) forControlEvents:UIControlEventValueChanged];
            switchView.on= self.mParentViewController.mUpperAlarmEnabled;
            [mScrollView addSubview:switchView];

            UILabel *label= [[UILabel alloc] initWithFrame:CGRectMake( switchView.frame.origin.x, y+30+2, 50, 14 )];
            label.backgroundColor= [UIColor clearColor];
            label.text= @"Enabled";
            label.textAlignment= NSTextAlignmentCenter;
            label.font= [UIFont systemFontOfSize:13];
            label.textColor= [UIColor blackColor];
            [mScrollView addSubview:label];
        }
        {
            UISwitch *switchView= [[UISwitch alloc] initWithFrame:CGRectMake( self.view.frame.size.width-20-50, y, 50, 30 )];
            [switchView addTarget:self action:@selector( upperAlarmRepeatsSwitchChanged: ) forControlEvents:UIControlEventValueChanged];
            switchView.on= self.mParentViewController.mUpperAlarmRepeats;
            [mScrollView addSubview:switchView];
            
            UILabel *label= [[UILabel alloc] initWithFrame:CGRectMake( switchView.frame.origin.x, y+30+2, 50, 14 )];
            label.backgroundColor= [UIColor clearColor];
            label.text= @"Repeats";
            label.textAlignment= NSTextAlignmentCenter;
            label.font= [UIFont systemFontOfSize:13];
            label.textColor= [UIColor blackColor];
            [mScrollView addSubview:label];
        }
        
        y+= 44+10;
    }
    {
        UILabel *label= [[UILabel alloc] initWithFrame:CGRectMake( 20, y, 280, 30 )];
        label.backgroundColor= [UIColor clearColor];
        label.text= @"Sound Alarm if HR is lower than:";
        label.textColor= [UIColor blackColor];
        [mScrollView addSubview:label];
        
        y+= 30;
    }
    {
        UIView *view= [[UIView alloc] initWithFrame:CGRectMake( 20, y, 54, 44 )];
        view.backgroundColor= [UIColor whiteColor];
        view.layer.borderColor= [[UIColor blueColor] CGColor];
        view.layer.borderWidth= 2;
        [mScrollView addSubview:view];
        
        mLowerAlarmLabel= [[UILabel alloc] initWithFrame:CGRectMake( 7, 7, 40, 30 ) ];
        mLowerAlarmLabel.textColor= [UIColor redColor];
        mLowerAlarmLabel.font= [UIFont systemFontOfSize:24];
        mLowerAlarmLabel.text= [NSString stringWithFormat:@"%d", (int)self.mParentViewController.mLowerAlarmRate];
        [view addSubview:mLowerAlarmLabel];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector( lowerAlarmTapped )];
        [view addGestureRecognizer:tapGestureRecognizer];
        
        {
            UISwitch *switchView= [[UISwitch alloc] initWithFrame:CGRectMake( self.view.frame.size.width/2-50/2, y, 50, 30 )];
            [switchView addTarget:self action:@selector( lowerAlarmEnabledSwitchChanged: ) forControlEvents:UIControlEventValueChanged];
            switchView.on= self.mParentViewController.mLowerAlarmEnabled;
            [mScrollView addSubview:switchView];
            
            UILabel *label= [[UILabel alloc] initWithFrame:CGRectMake( switchView.frame.origin.x, y+30+2, 50, 14 )];
            label.backgroundColor= [UIColor clearColor];
            label.text= @"Enabled";
            label.textAlignment= NSTextAlignmentCenter;
            label.font= [UIFont systemFontOfSize:13];
            label.textColor= [UIColor blackColor];
            [mScrollView addSubview:label];
        }
        {
            UISwitch *switchView= [[UISwitch alloc] initWithFrame:CGRectMake( self.view.frame.size.width-20-50, y, 50, 30 )];
            [switchView addTarget:self action:@selector( lowerAlarmRepeatsSwitchChanged: ) forControlEvents:UIControlEventValueChanged];
            switchView.on= self.mParentViewController.mLowerAlarmRepeats;
            [mScrollView addSubview:switchView];
            
            UILabel *label= [[UILabel alloc] initWithFrame:CGRectMake( switchView.frame.origin.x, y+30+2, 50, 14 )];
            label.backgroundColor= [UIColor clearColor];
            label.text= @"Repeats";
            label.textAlignment= NSTextAlignmentCenter;
            label.font= [UIFont systemFontOfSize:13];
            label.textColor= [UIColor blackColor];
            [mScrollView addSubview:label];
        }
        
        y+= 44+10;
    }
    {
        UILabel *label= [[UILabel alloc] initWithFrame:CGRectMake( 20, y, 280, 30 )];
        label.backgroundColor= [UIColor clearColor];
        label.text= @"Send text msg for either alarm to:";
        label.textColor= [UIColor blackColor];
        [mScrollView addSubview:label];
        
        y+= 30;
    }
    {
        UIView *view= [[UIView alloc] initWithFrame:CGRectMake( 20, y, 280, 44 )];
        view.backgroundColor= [UIColor whiteColor];
        view.layer.borderColor= [[UIColor blueColor] CGColor];
        view.layer.borderWidth= 2;
        [mScrollView addSubview:view];

        UITextField *textField= [[UITextField alloc] initWithFrame:CGRectMake( 7, 7, 268, 30 ) ];
        textField.tag= kNumberTag;
        textField.textColor= [UIColor redColor];
        textField.delegate= self;
        textField.returnKeyType= UIReturnKeyDone;
        textField.font= [UIFont systemFontOfSize:24];
        textField.text= self.mParentViewController.mTextMessageNumber;
        [view addSubview:textField];
        
        y+= 44+10;
    }
    {
        UILabel *label= [[UILabel alloc] initWithFrame:CGRectMake( 20, y, 280, 30 )];
        label.backgroundColor= [UIColor clearColor];
        label.text= @"Patient's Name:";
        label.textColor= [UIColor blackColor];
        [mScrollView addSubview:label];
        
        y+= 30;
    }
    {
        UIView *view= [[UIView alloc] initWithFrame:CGRectMake( 20, y, 280, 44 )];
        view.backgroundColor= [UIColor whiteColor];
        view.layer.borderColor= [[UIColor blueColor] CGColor];
        view.layer.borderWidth= 2;
        [mScrollView addSubview:view];
        
        UITextField *textField= [[UITextField alloc] initWithFrame:CGRectMake( 7, 7, 268, 30 ) ];
        textField.tag= kNameTag;
        textField.textColor= [UIColor redColor];
        textField.delegate= self;
        textField.returnKeyType= UIReturnKeyDone;
        textField.font= [UIFont systemFontOfSize:24];
        textField.text= self.mParentViewController.mPatientName;
        [view addSubview:textField];        
    }
}

//------------------------------------------------------------------------------
- (void)textFieldDidBeginEditing:(UITextField *)textField
//------------------------------------------------------------------------------
{
    UIAlertView *alertView= [[UIAlertView alloc] initWithTitle:@"Please Note" message:@"You must provide both a text message number and a patient name before a text message will be sent.\n\nNo more than 1 text message will be sent per hour." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alertView show];

    if (textField.tag==kNumberTag) {
        float y= (self.view.frame.size.height>480)?44:44*3;
        mScrollView.contentOffset= CGPointMake( 0, y );
    } else {
        float y= (self.view.frame.size.height>480)?44*3:44*5;
        mScrollView.contentOffset= CGPointMake( 0, y );
    }
}

//------------------------------------------------------------------------------
- (BOOL)textFieldShouldReturn:(UITextField *)textField
//------------------------------------------------------------------------------
{
    mScrollView.contentOffset= CGPointMake( 0, 0 );
    [textField resignFirstResponder];
    
    if (textField.tag==kNumberTag) {
        
        NSString *number= [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        NSCharacterSet *characterSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];

        if ([number rangeOfCharacterFromSet:characterSet].location!=NSNotFound) {
            
            UIAlertView *alertView= [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Text Message Number contains invalid characters." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alertView show];

            
        } else {
            
            self.mParentViewController.mTextMessageNumber= number;
            
            [[NSUserDefaults standardUserDefaults] setValue:self.mParentViewController.mTextMessageNumber forKey:kTextMessageNumber];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }
        
    } else {
        
        self.mParentViewController.mPatientName= textField.text;
        
        [[NSUserDefaults standardUserDefaults] setValue:self.mParentViewController.mPatientName forKey:kPatientName];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    
    return YES;
}

//------------------------------------------------------------------------------
- (void)upperAlarmEnabledSwitchChanged:(UISwitch *)sender
//------------------------------------------------------------------------------
{
    self.mParentViewController.mUpperAlarmSounded= NO;
    self.mParentViewController.mUpperAlarmEnabled= sender.on;

    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:self.mParentViewController.mUpperAlarmEnabled] forKey:kUpperAlarmEnabled];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//------------------------------------------------------------------------------
- (void)lowerAlarmEnabledSwitchChanged:(UISwitch *)sender
//------------------------------------------------------------------------------
{
    self.mParentViewController.mLowerAlarmSounded= NO;
    self.mParentViewController.mLowerAlarmEnabled= sender.on;

    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:self.mParentViewController.mLowerAlarmEnabled] forKey:kLowerAlarmEnabled];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//------------------------------------------------------------------------------
- (void)upperAlarmRepeatsSwitchChanged:(UISwitch *)sender
//------------------------------------------------------------------------------
{
    self.mParentViewController.mUpperAlarmSounded= NO;
    self.mParentViewController.mUpperAlarmRepeats= sender.on;

    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:self.mParentViewController.mUpperAlarmRepeats] forKey:kUpperAlarmRepeats];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//------------------------------------------------------------------------------
- (void)lowerAlarmRepeatsSwitchChanged:(UISwitch *)sender
//------------------------------------------------------------------------------
{
    self.mParentViewController.mLowerAlarmSounded= NO;
    self.mParentViewController.mLowerAlarmRepeats= sender.on;

    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:self.mParentViewController.mLowerAlarmRepeats] forKey:kLowerAlarmRepeats];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//------------------------------------------------------------------------------
- (void)upperAlarmTapped
//------------------------------------------------------------------------------
{
    mOverlayView= [[UIView alloc] initWithFrame:self.view.bounds];
    mOverlayView.backgroundColor= [UIColor blackColor];
    mOverlayView.alpha= 0.5;
    [self.view addSubview:mOverlayView];

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector( upperAlarmPickerDoneButtonTapped )];
    [mOverlayView addGestureRecognizer:tapGestureRecognizer];
    
    mPickerRootView= [[UIView alloc] initWithFrame:CGRectMake( 0, self.view.frame.size.height-244, self.view.frame.size.width, 244 )];
    mPickerRootView.backgroundColor= [UIColor whiteColor];
    [self.view addSubview:mPickerRootView];
    
    {
        UIView *view= [[UIView alloc] initWithFrame:CGRectMake( 0, 0, self.view.frame.size.width, 1 )];
        view.backgroundColor= [UIColor colorWithRed:0.50 green:0.50 blue:0.50 alpha:1.0];
        [mPickerRootView addSubview:view];
    }
    {
        UIView *view= [[UIView alloc] initWithFrame:CGRectMake( 0, 1, self.view.frame.size.width, 44 )];
        view.backgroundColor= [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.0];
        [mPickerRootView addSubview:view];
        
        UIButton *button= [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame= CGRectMake( self.view.frame.size.width-60, 1, 60, 44 );
        [button setTitle:@"Done" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector( upperAlarmPickerDoneButtonTapped ) forControlEvents:UIControlEventTouchDown];
        
        [view addSubview:button];
    }
    {
        UIView *view= [[UIView alloc] initWithFrame:CGRectMake( 0, 43, self.view.frame.size.width, 1 )];
        view.backgroundColor= [UIColor colorWithRed:0.50 green:0.50 blue:0.50 alpha:1.0];
        [mPickerRootView addSubview:view];
    }
    
    mPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake( 0, 44, self.view.frame.size.width, 200 )];
    mPickerView.dataSource = self;
    mPickerView.delegate = self;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake( self.view.frame.size.width/2-90/2, 0, 90, 30)];
    label.text = @"Heart Rate";
    label.textAlignment= NSTextAlignmentCenter;
    [mPickerView addSubview:label];
    
    [mPickerView selectRow:self.mParentViewController.mUpperAlarmRate inComponent:0 animated:NO];
    
    [mPickerRootView addSubview:mPickerView];
}

//------------------------------------------------------------------------------
- (void)lowerAlarmTapped
//------------------------------------------------------------------------------
{
    mOverlayView= [[UIView alloc] initWithFrame:self.view.bounds];
    mOverlayView.backgroundColor= [UIColor blackColor];
    mOverlayView.alpha= 0.5;
    [self.view addSubview:mOverlayView];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector( lowerAlarmPickerDoneButtonTapped )];
    [mOverlayView addGestureRecognizer:tapGestureRecognizer];
    
    mPickerRootView= [[UIView alloc] initWithFrame:CGRectMake( 0, self.view.frame.size.height-244, self.view.frame.size.width, 244 )];
    mPickerRootView.backgroundColor= [UIColor whiteColor];
    [self.view addSubview:mPickerRootView];
    
    {
        UIView *view= [[UIView alloc] initWithFrame:CGRectMake( 0, 0, self.view.frame.size.width, 1 )];
        view.backgroundColor= [UIColor colorWithRed:0.50 green:0.50 blue:0.50 alpha:1.0];
        [mPickerRootView addSubview:view];
    }
    {
        UIView *view= [[UIView alloc] initWithFrame:CGRectMake( 0, 1, self.view.frame.size.width, 44 )];
        view.backgroundColor= [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.0];
        [mPickerRootView addSubview:view];
        
        UIButton *button= [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame= CGRectMake( self.view.frame.size.width-60, 1, 60, 44 );
        [button setTitle:@"Done" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector( lowerAlarmPickerDoneButtonTapped ) forControlEvents:UIControlEventTouchDown];
        
        [view addSubview:button];
    }
    {
        UIView *view= [[UIView alloc] initWithFrame:CGRectMake( 0, 43, self.view.frame.size.width, 1 )];
        view.backgroundColor= [UIColor colorWithRed:0.50 green:0.50 blue:0.50 alpha:1.0];
        [mPickerRootView addSubview:view];
    }
    
    mPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake( 0, 44, self.view.frame.size.width, 200 )];
    mPickerView.dataSource = self;
    mPickerView.delegate = self;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake( self.view.frame.size.width/2-90/2, 0, 90, 30)];
    label.text = @"Heart Rate";
    label.textAlignment= NSTextAlignmentCenter;
    [mPickerView addSubview:label];
    
    [mPickerView selectRow:self.mParentViewController.mLowerAlarmRate inComponent:0 animated:NO];
    
    [mPickerRootView addSubview:mPickerView];
}

//------------------------------------------------------------------------------
- (void)ageTapped
//------------------------------------------------------------------------------
{
    mOverlayView= [[UIView alloc] initWithFrame:self.view.bounds];
    mOverlayView.backgroundColor= [UIColor blackColor];
    mOverlayView.alpha= 0.5;
    [self.view addSubview:mOverlayView];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector( agePickerDoneButtonTapped )];
    [mOverlayView addGestureRecognizer:tapGestureRecognizer];
    
    mPickerRootView= [[UIView alloc] initWithFrame:CGRectMake( 0, self.view.frame.size.height-244, self.view.frame.size.width, 244 )];
    mPickerRootView.backgroundColor= [UIColor whiteColor];
    [self.view addSubview:mPickerRootView];
    
    {
        UIView *view= [[UIView alloc] initWithFrame:CGRectMake( 0, 0, self.view.frame.size.width, 1 )];
        view.backgroundColor= [UIColor colorWithRed:0.50 green:0.50 blue:0.50 alpha:1.0];
        [mPickerRootView addSubview:view];
    }
    {
        UIView *view= [[UIView alloc] initWithFrame:CGRectMake( 0, 1, self.view.frame.size.width, 44 )];
        view.backgroundColor= [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.0];
        [mPickerRootView addSubview:view];

        UIButton *button= [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame= CGRectMake( self.view.frame.size.width-60, 1, 60, 44 );
        [button setTitle:@"Done" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector( agePickerDoneButtonTapped ) forControlEvents:UIControlEventTouchDown];
        
        [view addSubview:button];
    }
    {
        UIView *view= [[UIView alloc] initWithFrame:CGRectMake( 0, 43, self.view.frame.size.width, 1 )];
        view.backgroundColor= [UIColor colorWithRed:0.50 green:0.50 blue:0.50 alpha:1.0];
        [mPickerRootView addSubview:view];
    }
    
    mPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake( 0, 44, self.view.frame.size.width, 200 )];
    mPickerView.dataSource = self;
    mPickerView.delegate = self;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake( self.view.frame.size.width/2-60/2, 0, 60, 30)];
    label.text = @"Age";
    label.textAlignment= NSTextAlignmentCenter;
    [mPickerView addSubview:label];
    
    [mPickerView selectRow:self.mParentViewController.mAge inComponent:0 animated:NO];
    
    [mPickerRootView addSubview:mPickerView];
}

//------------------------------------------------------------------------------
- (void)agePickerDoneButtonTapped
//------------------------------------------------------------------------------
{
    int age= (int)[mPickerView selectedRowInComponent:0];
    
    self.mParentViewController.mAge= age;
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:age] forKey:kAge];
    [[NSUserDefaults standardUserDefaults] synchronize];

    mAgeLabel.text= [NSString stringWithFormat:@"%d", (int)self.mParentViewController.mAge];

    [mOverlayView removeFromSuperview];
    mOverlayView= nil;
    
    [mPickerRootView removeFromSuperview];
    mPickerRootView= nil;

    uint8_t maxHeartRate= 220 - age;
    
    self.mParentViewController.mUpperAlarmRate= maxHeartRate * 0.8;
    mUpperAlarmLabel.text= [NSString stringWithFormat:@"%d", (int)self.mParentViewController.mUpperAlarmRate];

    [self.mParentViewController updateRateTable];
}

//------------------------------------------------------------------------------
- (void)upperAlarmPickerDoneButtonTapped
//------------------------------------------------------------------------------
{
    int rate= (int)[mPickerView selectedRowInComponent:0];
    
    self.mParentViewController.mUpperAlarmRate= rate;
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:rate] forKey:kUpperAlarmRate];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    mUpperAlarmLabel.text= [NSString stringWithFormat:@"%d", (int)self.mParentViewController.mUpperAlarmRate];

    [mOverlayView removeFromSuperview];
    mOverlayView= nil;
    
    [mPickerRootView removeFromSuperview];
    mPickerRootView= nil;
}

//------------------------------------------------------------------------------
- (void)lowerAlarmPickerDoneButtonTapped
//------------------------------------------------------------------------------
{
    int rate= (int)[mPickerView selectedRowInComponent:0];
    
    self.mParentViewController.mLowerAlarmRate= rate;
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:rate] forKey:kLowerAlarmRate];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    mLowerAlarmLabel.text= [NSString stringWithFormat:@"%d", (int)self.mParentViewController.mLowerAlarmRate];
    
    [mOverlayView removeFromSuperview];
    mOverlayView= nil;
    
    [mPickerRootView removeFromSuperview];
    mPickerRootView= nil;
}

//------------------------------------------------------------------------------
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
//------------------------------------------------------------------------------
{
    return 1;
}

//------------------------------------------------------------------------------
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
//------------------------------------------------------------------------------
{
    return 221;
}

//------------------------------------------------------------------------------
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
//------------------------------------------------------------------------------
{
    return 30;
}

//------------------------------------------------------------------------------
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
//------------------------------------------------------------------------------
{
    UILabel *columnView = [[UILabel alloc] initWithFrame:CGRectMake( 35, 0, self.view.frame.size.width/3 - 35, 30 )];
    columnView.textColor= [UIColor redColor];
    
    columnView.text = [NSString stringWithFormat:@"%lu", (long)row];
    
    columnView.textAlignment = NSTextAlignmentCenter;
    
    return columnView;
}

//------------------------------------------------------------------------------
- (void)doneButtonTapped
//------------------------------------------------------------------------------
{
    [UIView transitionWithView:self.mParentViewController.view
                      duration:1
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        [self.view removeFromSuperview];
                    } completion:nil];
}

@end
