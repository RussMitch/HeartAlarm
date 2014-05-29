//
//  ViewController.m
//  HeartAlarm
//
//  Created by Russell on 4/23/14.
//  Copyright (c) 2014 Russell Research Corporation. All rights reserved.
//
//------------------------------------------------------------------------------

#import <AVFoundation/AVFoundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "AppDelegate.h"
#import "LabelBorder.h"
#import "BarChartView.h"
#import "ViewController.h"
#import "SettingsViewController.h"

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

@interface ViewController () <CBCentralManagerDelegate,CBPeripheralDelegate,UITableViewDataSource,UITableViewDelegate> {
    
    UIView *mOverlayView;
    NSDate *mLastTextDate;
    UITableView *mTableView;
    NSInteger mUpperAlarmCount;
    NSInteger mLowerAlarmCount;
    NSMutableArray *mTableData;
    BarChartView *mBarChartView;
    NSMutableArray *mRateLabels;
    UIButton *mDisconnectButton;
    LabelBorder *mHeartRateLabel;
    UIView *mViewStyleButtonView;
    LabelBorder *mHeartRateButtonLabel;
    CBCentralManager *mCBCentralManager;
    SettingsViewController *mSettingsViewController;
    
}

@property( nonatomic, strong ) CBPeripheral *mPeripheral;

@end

@implementation ViewController

#define kIsFirstLaunchKey @"IsFirstLaunch"

//------------------------------------------------------------------------------
- (void)viewDidLoad
//------------------------------------------------------------------------------
{
    [super viewDidLoad];
    
    if (![[NSUserDefaults standardUserDefaults] valueForKey:kAge]) {
        self.mAge= 40;
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:self.mAge] forKey:kAge];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        self.mAge= [[[NSUserDefaults standardUserDefaults] valueForKey:kAge] integerValue];
    }

    if (self.mAge==123) {
        self.mAge= 40;
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:self.mAge] forKey:kAge];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if (![[NSUserDefaults standardUserDefaults] valueForKey:kUpperAlarmRate]) {
        self.mUpperAlarmRate= 220;
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:self.mUpperAlarmRate] forKey:kUpperAlarmRate];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        self.mUpperAlarmRate= [[[NSUserDefaults standardUserDefaults] valueForKey:kUpperAlarmRate] integerValue];
    }

    if (![[NSUserDefaults standardUserDefaults] valueForKey:kLowerAlarmRate]) {
        self.mLowerAlarmRate= 0;
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:self.mLowerAlarmRate] forKey:kLowerAlarmRate];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        self.mLowerAlarmRate= [[[NSUserDefaults standardUserDefaults] valueForKey:kLowerAlarmRate] integerValue];
    }
    
    if (![[NSUserDefaults standardUserDefaults] valueForKey:kUpperAlarmEnabled]) {
        self.mUpperAlarmEnabled= NO;
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:self.mUpperAlarmEnabled] forKey:kUpperAlarmEnabled];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        self.mUpperAlarmEnabled= [[[NSUserDefaults standardUserDefaults] valueForKey:kUpperAlarmEnabled] boolValue];
    }

    if (![[NSUserDefaults standardUserDefaults] valueForKey:kLowerAlarmEnabled]) {
        self.mLowerAlarmEnabled= NO;
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:self.mLowerAlarmEnabled] forKey:kLowerAlarmEnabled];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        self.mLowerAlarmEnabled= [[[NSUserDefaults standardUserDefaults] valueForKey:kLowerAlarmEnabled] boolValue];
    }

    if (![[NSUserDefaults standardUserDefaults] valueForKey:kUpperAlarmRepeats]) {
        self.mUpperAlarmRepeats= NO;
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:self.mUpperAlarmRepeats] forKey:kUpperAlarmRepeats];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        self.mUpperAlarmRepeats= [[[NSUserDefaults standardUserDefaults] valueForKey:kUpperAlarmRepeats] boolValue];
    }
    
    if (![[NSUserDefaults standardUserDefaults] valueForKey:kLowerAlarmRepeats]) {
        self.mLowerAlarmRepeats= NO;
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:self.mLowerAlarmRepeats] forKey:kLowerAlarmRepeats];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        self.mLowerAlarmRepeats= [[[NSUserDefaults standardUserDefaults] valueForKey:kLowerAlarmRepeats] boolValue];
    }

    self.mPatientName= [[NSUserDefaults standardUserDefaults] valueForKey:kPatientName];
    self.mTextMessageNumber= [[NSUserDefaults standardUserDefaults] valueForKey:kTextMessageNumber];
    
    {
        UILabel *label= [[UILabel alloc] initWithFrame:CGRectMake( 0, 20, 320, 44 )];
        label.backgroundColor= [UIColor clearColor];
        label.text= @"Heart Alarm";
        label.textColor= [UIColor redColor];
        label.font= [UIFont boldSystemFontOfSize:18];
        label.textAlignment= NSTextAlignmentCenter;
        label.backgroundColor= [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1.0];
        [self.view addSubview:label];
    }

    {
        UIView *view= [[UIView alloc] initWithFrame:CGRectMake( 0, 63, 320, 1 )];
        view.backgroundColor= [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
        [self.view addSubview:view];
    }

    {
        UIButton *button= [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame= CGRectMake( self.view.frame.size.width-44-8, 20, 44, 44 );
        
        UIImageView *imageView= [[UIImageView alloc] initWithFrame:CGRectMake( 4, 4, 36, 36 )];
        imageView.layer.cornerRadius= 8;
        imageView.layer.masksToBounds= YES;
        imageView.image= [UIImage imageNamed:@"settings2"];
        
        [button addTarget:self action:@selector( settingsButtonTapped ) forControlEvents:UIControlEventTouchDown];
        [button addSubview:imageView];
        
        [self.view addSubview:button];
    }
    
    {
        mViewStyleButtonView= [[UIView alloc] initWithFrame:CGRectMake( 8, 20, 44, 44 )];
        mViewStyleButtonView.hidden= YES;
        [self.view addSubview:mViewStyleButtonView];

        UIImageView *imageView= [[UIImageView alloc] initWithFrame:CGRectMake( 4, 4, 36, 36 )];
        imageView.image= [UIImage imageNamed:@"barChartIcon"];
        [mViewStyleButtonView addSubview:imageView];
        
        mHeartRateButtonLabel= [[LabelBorder alloc] initWithFrame:CGRectMake( 4, 4, 36, 36 )];
        mHeartRateButtonLabel.backgroundColor= [UIColor whiteColor];
        mHeartRateButtonLabel.text= @"220";
        mHeartRateButtonLabel.hidden= YES;
        mHeartRateButtonLabel.layer.borderWidth= 1;
        mHeartRateButtonLabel.layer.borderColor= [[UIColor blackColor] CGColor];
        mHeartRateButtonLabel.layer.cornerRadius= 9;
        mHeartRateButtonLabel.layer.masksToBounds= YES;
        mHeartRateButtonLabel.font= [UIFont boldSystemFontOfSize:18];
        mHeartRateButtonLabel.textAlignment= NSTextAlignmentCenter;
        [mViewStyleButtonView addSubview:mHeartRateButtonLabel];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector( viewStyleButtonTapped )];
        [mViewStyleButtonView addGestureRecognizer:tapGestureRecognizer];
    }
    
    float h= (self.view.frame.size.height>480)?270:180;
    
    mHeartRateLabel= [[LabelBorder alloc] initWithFrame:CGRectMake( 0, 40, 320, h) ];
    mHeartRateLabel.textAlignment= NSTextAlignmentCenter;
    mHeartRateLabel.text= @"0";
    mHeartRateLabel.textColor= [UIColor redColor];
    mHeartRateLabel.font= [UIFont fontWithName:@"HelveticaNeue-Thin" size:140];
    mHeartRateLabel.hidden= YES;
    [self.view addSubview:mHeartRateLabel];

    {
        float h= (self.view.frame.size.height>480)?270:180;
        
        mBarChartView= [[BarChartView alloc] initWithFrame:CGRectMake( 0, 64, 320, h )];
        mBarChartView.hidden= YES;
        [self.view addSubview:mBarChartView];
    }

    mDisconnectButton= [UIButton buttonWithType:UIButtonTypeCustom];
    mDisconnectButton.frame= CGRectMake( 20, 64+h-44, 280, 44 );
    mDisconnectButton.layer.borderColor= [[UIColor blackColor] CGColor];
    mDisconnectButton.layer.borderWidth= 2;
    mDisconnectButton.layer.cornerRadius= 9.0;
    mDisconnectButton.layer.masksToBounds= YES;
    mDisconnectButton.hidden= YES;
    mDisconnectButton.backgroundColor= [UIColor blueColor];
    [mDisconnectButton setTitle:@"Disconnect" forState:UIControlStateNormal];
    [mDisconnectButton.titleLabel setFont:[UIFont systemFontOfSize:24]];
    [mDisconnectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [mDisconnectButton addTarget:self action:@selector( disconnectButtonPressed ) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:mDisconnectButton];
    
    h= (self.view.frame.size.height>480)?5*44:4*44;
    
    mTableView= [[UITableView alloc] initWithFrame:CGRectMake( 0, 64, 320, h )];
    mTableView.delegate= self;
    mTableView.dataSource= self;
    
    if ([mTableView respondsToSelector:@selector( setSeparatorInset: )])
        [mTableView setSeparatorInset:UIEdgeInsetsMake( 0, 0, 0, 0 )];

    [self.view addSubview:mTableView];

    mTableData= [[NSMutableArray alloc] init];
    
    [mTableData addObject:@"Searching for Heart Rate devices..."];
    
    float x= 15;
    float y= self.view.frame.size.height-15-30*7;
    
    {
        UILabel *label= [[UILabel alloc] initWithFrame:CGRectMake( x, y, 80, 30 )];
        label.text= @"COLOR";
        label.font= [UIFont boldSystemFontOfSize:16];
        [self.view addSubview:label];
        
        x+= 80;
    }
    {
        UILabel *label= [[UILabel alloc] initWithFrame:CGRectMake( x, y, 320-x-15, 30 )];
        label.text= @"LOWER - UPPER HR LIMIT";
        label.font= [UIFont boldSystemFontOfSize:16];
        [self.view addSubview:label];
    }
    
    NSArray *colors= @[[UIColor cyanColor], [UIColor blueColor], [UIColor greenColor], [UIColor yellowColor], [UIColor magentaColor], [UIColor redColor]];
    NSArray *colorLabels= @[@"Cyan",@"Blue",@"Green",@"Yellow",@"Magenta",@"Red"];
    NSArray *rates= @[@"  0% - 50% of MHR",@"50% - 60% of MHR",@"60% - 70% of MHR",@"70% - 80% of MHR",@"80% - 90% of MHR",@"90% or more of MHR"];

    x= 15;
    y+= 30;

    float yorg= y;
    
    for (int i=0;i<colors.count;i++) {
        UIColor *color= colors[i];
        LabelBorder *label= [[LabelBorder alloc] initWithFrame:CGRectMake( x, y, 80, 30 )];
        label.text= colorLabels[i];
        label.textColor= color;
        label.font= [UIFont boldSystemFontOfSize:16];
        [self.view addSubview:label];
        y+= 30;
    }

    x+= 80;
    y= yorg;

    mRateLabels= [[NSMutableArray alloc] init];
    
    for (int i=0;i<rates.count;i++) {
        UILabel *label= [[UILabel alloc] initWithFrame:CGRectMake( x, y, 320-x-10, 30 )];
        label.font= [UIFont systemFontOfSize:16];
        [self.view addSubview:label];
        [mRateLabels addObject:label];
        y+= 30;
    }
    
    [self updateRateTable];

    mCBCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector( applicationDidBecomeActive ) name:kApplicationDidBecomeActive object:nil];

    if (![[NSUserDefaults standardUserDefaults] valueForKey:kIsFirstLaunchKey]) {
		
        [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:kIsFirstLaunchKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
		[self settingsButtonTapped];
        
    }
}

//------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//------------------------------------------------------------------------------
{
    return [mTableData count];
}

//------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//------------------------------------------------------------------------------
{
	return 44;
}

//------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//------------------------------------------------------------------------------
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *nameLabel;
    UILabel *uuidLabel;
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle= UITableViewCellSelectionStyleBlue;
        
        nameLabel= [[UILabel alloc] initWithFrame:CGRectMake( 5, 0, cell.contentView.frame.size.width-10, 22 )];
        nameLabel.font= [UIFont boldSystemFontOfSize:16];
        nameLabel.tag= 1;
        [cell.contentView addSubview:nameLabel];
        
        uuidLabel= [[UILabel alloc] initWithFrame:CGRectMake( 5, 22, cell.contentView.frame.size.width-10, 22 )];
        uuidLabel.font= [UIFont systemFontOfSize:14];
        uuidLabel.tag= 2;
        [cell.contentView addSubview:uuidLabel];
        
    } else {
        
        nameLabel= (UILabel *)[cell.contentView viewWithTag:1];
        uuidLabel= (UILabel *)[cell.contentView viewWithTag:2];
        
    }
    
    if ([[mTableData objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]) {
        
        nameLabel.text= [mTableData objectAtIndex:indexPath.row];
        nameLabel.frame= CGRectMake( 5, 0, cell.contentView.frame.size.width-10, 44 );
        uuidLabel.hidden= YES;
        
        cell.selectionStyle= UITableViewCellSelectionStyleNone;
        
    } else {
        
        CBPeripheral *peripheral= [mTableData objectAtIndex:indexPath.row];
        
        nameLabel.text= peripheral.name;
        uuidLabel.text= [peripheral.identifier UUIDString];
        
        uuidLabel.hidden= NO;
        nameLabel.frame= CGRectMake( 5, 0, cell.contentView.frame.size.width-10, 22 );
        
        cell.selectionStyle= UITableViewCellSelectionStyleBlue;
        
    }
    
    return cell;
}

//------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//------------------------------------------------------------------------------
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    CBPeripheral *peripheral= [mTableData objectAtIndex:indexPath.row];
    
    if ([peripheral isKindOfClass:[CBPeripheral class]]) {
        [self connectPeripheral:peripheral];
    }
}

//------------------------------------------------------------------------------
- (void)viewStyleButtonTapped
//------------------------------------------------------------------------------
{
    if (mHeartRateButtonLabel.hidden) {
        
        mBarChartView.hidden= NO;
        mHeartRateButtonLabel.hidden= NO;
        
    } else {

        mBarChartView.hidden= YES;
        mHeartRateButtonLabel.hidden= YES;
        
    }
}

//------------------------------------------------------------------------------
- (void)applicationDidBecomeActive
//------------------------------------------------------------------------------
{
    if ((self.mAge!=123)&&(!self.mPeripheral)) {

        mTableData= [[NSMutableArray alloc] init];
        [mTableData addObject:@"Searching for Heart Rate devices..."];
        [mTableView reloadData];
        
        mUpperAlarmCount= mLowerAlarmCount= 0;
        
        [mBarChartView removeAllData];
        
        [mCBCentralManager retrieveConnectedPeripherals];
        
    }
}

//------------------------------------------------------------------------------
- (void)disconnectButtonPressed
//------------------------------------------------------------------------------
{
    
    if (self.mAge==123) {
    
        self.mAge= 40;
        mTableView.hidden= NO;
        mHeartRateLabel.hidden= YES;
        mDisconnectButton.hidden= YES;
        mViewStyleButtonView.hidden= YES;

    } else {

        [mCBCentralManager cancelPeripheralConnection:self.mPeripheral];
        
    }
}

//------------------------------------------------------------------------------
- (void)updateRateTable
//------------------------------------------------------------------------------
{
    float val1= 0;
    float val2= 0.5;
    uint8_t maxHeartRate= 220 - self.mAge;

    for (int i=0;i<mRateLabels.count;i++) {
        UILabel *label= mRateLabels[i];
        label.text= [NSString stringWithFormat:@"%d - %d (%d%% of MHR)", (int)(maxHeartRate*val1), (int)(maxHeartRate*val2), (int)(val2*100)];
        val1= val2;
        val2= val2 + 0.1;
    }
    
    if ((self.mAge==123)&&(!self.mPeripheral)) {
        
        mTableView.hidden= YES;
        mHeartRateLabel.hidden= NO;
        mDisconnectButton.hidden= NO;
        mViewStyleButtonView.hidden= NO;

        [self performSelector:@selector( simulateTestData ) withObject:nil afterDelay:1];
        
    }
}

//------------------------------------------------------------------------------
- (void)simulateTestData
//------------------------------------------------------------------------------
{
    [self peripheral:nil didUpdateValueForCharacteristic:nil error:nil];
}

//------------------------------------------------------------------------------
- (void)settingsButtonTapped
//------------------------------------------------------------------------------
{
    mSettingsViewController= [[SettingsViewController alloc] initWithParentViewController:self];
    
    [UIView transitionWithView:self.view
                      duration:1
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        [self.view addSubview:mSettingsViewController.view];
                    } completion:nil];
}

//------------------------------------------------------------------------------
- (void)connectButtonPressed
//------------------------------------------------------------------------------
{
    mOverlayView= [[UIView alloc] initWithFrame:self.view.bounds];
    mOverlayView.backgroundColor= [UIColor blackColor];
    mOverlayView.alpha= 0.5;
    [self.view addSubview:mOverlayView];
    
    UIActivityIndicatorView *activityIndicatorView= [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicatorView.frame= self.view.bounds;
    [activityIndicatorView startAnimating];
    [mOverlayView addSubview:activityIndicatorView];
    
    [self performSelector:@selector( connectionTimeout ) withObject:nil afterDelay:10];
    
    [mCBCentralManager retrieveConnectedPeripherals];
}

//------------------------------------------------------------------------------
- (void)connectionTimeout
//------------------------------------------------------------------------------
{
    [mOverlayView removeFromSuperview];
    mOverlayView= nil;
}

//------------------------------------------------------------------------------
- (void)centralManagerDidUpdateState:(CBCentralManager *)centralManager
//------------------------------------------------------------------------------
{
	switch ([centralManager state]) {
	
		case CBCentralManagerStatePoweredOn: {
            
            [mCBCentralManager retrieveConnectedPeripherals];
			break;
		}
            
        default: {
            break;
        }
	}
}

//------------------------------------------------------------------------------
- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals
//------------------------------------------------------------------------------
{
    if ([peripherals count]) {
        
        if ([mTableData count]) {
            NSString *string= [mTableData objectAtIndex:0];
            if ([string isKindOfClass:[NSString class]]) {
                [mTableData removeObjectAtIndex:0];
            }
        }
        
        for (CBPeripheral *peripheral in peripherals) {
            [mTableData addObject:peripheral];
        }
        
        [mTableView reloadData];
        
    } else {
        
        [mCBCentralManager scanForPeripheralsWithServices:nil options:nil];
        
    }
}

//------------------------------------------------------------------------------
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
//------------------------------------------------------------------------------
{
    if (peripheral) {
        
        if ([mTableData count]) {
            NSString *string= [mTableData objectAtIndex:0];
            if ([string isKindOfClass:[NSString class]]) {
                [mTableData removeObjectAtIndex:0];
            }
        }

        [mTableData addObject:peripheral];
        [mTableView reloadData];
    }
}

//------------------------------------------------------------------------------
- (void)connectPeripheral:(CBPeripheral *)peripheral
//------------------------------------------------------------------------------
{
    mOverlayView= [[UIView alloc] initWithFrame:self.view.bounds];
    mOverlayView.backgroundColor= [UIColor blackColor];
    mOverlayView.alpha= 0.5;
    [self.view addSubview:mOverlayView];
    
    UIActivityIndicatorView *activityIndicatorView= [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicatorView.frame= self.view.bounds;
    [activityIndicatorView startAnimating];
    [mOverlayView addSubview:activityIndicatorView];
    
    [self performSelector:@selector( connectionTimeout ) withObject:nil afterDelay:10];
    self.mPeripheral= peripheral;
    self.mPeripheral.delegate= self;
    [mCBCentralManager connectPeripheral:peripheral options:nil];
}

//------------------------------------------------------------------------------
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
//------------------------------------------------------------------------------
{
    [mOverlayView removeFromSuperview];
    mOverlayView= nil;

    mTableView.hidden= YES;
    mHeartRateLabel.hidden= NO;
    mDisconnectButton.hidden= NO;
    mViewStyleButtonView.hidden= NO;
    
    NSArray *services= [NSArray arrayWithObject:[CBUUID UUIDWithString:@"180D"]];
    [peripheral discoverServices:services];
}

//------------------------------------------------------------------------------
- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
//------------------------------------------------------------------------------
{
    self.mPeripheral= nil;
    
    mTableView.hidden= NO;
    mHeartRateLabel.hidden= YES;
    mDisconnectButton.hidden= YES;
    mViewStyleButtonView.hidden= YES;

    mTableData= [[NSMutableArray alloc] init];
    [mTableData addObject:@"Searching for Heart Rate devices..."];
    [mTableView reloadData];
    
    mUpperAlarmCount= mLowerAlarmCount= 0;

    [mBarChartView removeAllData];

    [mCBCentralManager retrieveConnectedPeripherals];
}

//------------------------------------------------------------------------------
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
//------------------------------------------------------------------------------
{
    if (![[peripheral services] count])
        return;
        
    CBService *service= [peripheral.services objectAtIndex:0];
    
    NSArray *characteristics= [NSArray arrayWithObject:[CBUUID UUIDWithString:@"2A37"]];
    
    [peripheral discoverCharacteristics:characteristics forService:service];
}

//------------------------------------------------------------------------------
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
//------------------------------------------------------------------------------
{
    if (![[service characteristics] count])
        return;

    CBCharacteristic *characteristic= [service.characteristics objectAtIndex:0];
    
    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
}

//------------------------------------------------------------------------------
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
//------------------------------------------------------------------------------
{
    uint8_t heartRate= 0;

    if (self.mAge==123) {
        
        heartRate= 100;
        
    } else {
        
        if (![[characteristic value] length])
            return;
        
        uint8_t value[5];
        
        [[characteristic value] getBytes:&value length:sizeof (value)];
        
        heartRate= value[1];
        
    }
    
    mHeartRateLabel.text= [NSString stringWithFormat:@"%d", heartRate];
    mHeartRateButtonLabel.text= mHeartRateLabel.text;

    uint8_t maxHeartRate= 220 - self.mAge;

    UIColor *color;

    if (heartRate < (maxHeartRate*0.5)) {
        color= [UIColor cyanColor];
    } else if (heartRate < (maxHeartRate*0.6)) {
        color= [UIColor blueColor];
    } else if (heartRate < (maxHeartRate*0.7)) {
        color= [UIColor greenColor];
    } else if (heartRate < (maxHeartRate*0.8)) {
        color= [UIColor yellowColor];
    } else if (heartRate < (maxHeartRate*0.9)) {
        color= [UIColor magentaColor];
    } else {
        color= [UIColor redColor];
    }
    
    mHeartRateLabel.textColor= color;
    mHeartRateButtonLabel.textColor= color;
    
    [mBarChartView addHeartRate:heartRate withColor:color];

    if ((self.mUpperAlarmEnabled)&&(heartRate>=self.mUpperAlarmRate)) {

        mUpperAlarmCount++;
        
        if (mUpperAlarmCount>=3) {
            
            BOOL soundAlarm= NO;
            
            if (self.mUpperAlarmRepeats)
                soundAlarm= YES;
            else if (!self.mUpperAlarmSounded)
                soundAlarm= YES;
            
            if (soundAlarm) {
                [self soundAlarm];
                self.mUpperAlarmSounded= YES;
                [self sendMessageForHeartRate:heartRate];
            }
        }
        
    } else {
        
        mUpperAlarmCount= 0;
    }
    
    if ((self.mLowerAlarmEnabled)&&(heartRate<=self.mLowerAlarmRate)) {
        
        mLowerAlarmCount++;
        
        if (mLowerAlarmCount>=3) {
            
            BOOL soundAlarm= NO;
            
            if (self.mLowerAlarmRepeats)
                soundAlarm= YES;
            else if (!self.mLowerAlarmSounded)
                soundAlarm= YES;
            
            if (soundAlarm) {
                [self soundAlarm];
                self.mLowerAlarmSounded= YES;
                [self sendMessageForHeartRate:heartRate];
            }
        }
        
    } else {
        
        mLowerAlarmCount= 0;
    }
    
    if (self.mAge==123) {
        [self performSelector:@selector( simulateTestData ) withObject:nil afterDelay:1];
    }
}

#define kMinTimeBetweenTexts 60*60

//------------------------------------------------------------------------------
- (void)sendMessageForHeartRate:(NSInteger)heartRate
//------------------------------------------------------------------------------
{
    if ((mLastTextDate)&&(fabs( [mLastTextDate timeIntervalSinceNow] ) < kMinTimeBetweenTexts))
        return;
    
    if (([self.mPatientName length])&&([self.mTextMessageNumber length])) {
        
        mLastTextDate= [NSDate date];
        
        NSString *msg= [NSString stringWithFormat:@"number=%@&message=%@'s heart rate has reached an alarming %d BPM", self.mTextMessageNumber, self.mPatientName, (int)heartRate];
        NSString *url= @"http://textbelt.com/text";
        NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:url]];
        [request setHTTPMethod:@"POST"];
        [request setValue:[NSString stringWithFormat:@"%d", (int)[data length]] forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:data];

        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        
        NSString *jsonString= [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
        
        NSLog( @"%@", jsonString );

    }
}

//------------------------------------------------------------------------------
- (void)soundAlarm
//------------------------------------------------------------------------------
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"bell" ofType:@"wav"];
    
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:path];
 
    SystemSoundID systemSoundID;
    
    CFURLRef cfURLRef= (__bridge CFURLRef)fileURL;
    
    AudioServicesCreateSystemSoundID( cfURLRef, &systemSoundID );
    
    AudioServicesPlaySystemSound( systemSoundID );
}

@end
