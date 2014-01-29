//
//  CSBeaconViewController.m
//  LocationSpike
//
//  Created by Keith Ermel on 1/28/14.
//  Copyright (c) 2014 Keith Ermel. All rights reserved.
//

#import "CSBeaconViewController.h"


NSString *const kBeaconUUID             = @"0C99E399-BAD0-4A20-9876-CB4D5E115902";
NSString *const kMiniPadBeaconUUID      = @"C4269F71-EAA5-4681-AF03-8600897472EB";
NSString *const kMaxPixelsBeaconUUID    = @"E656F137-FF82-4383-8754-A772C8BB3FA3";

NSUInteger const kMaxPixelsID           = 0x7294da4;
NSUInteger const kiPhone5ID             = 0x3c8ab9c0;
NSUInteger const kMiniPad               = 0xecd85729;


@interface CSBeaconViewController ()
@property (strong, nonatomic, readonly) NSUUID *proximityUUID;
@property (strong, nonatomic, readonly) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic, readonly) CBPeripheralManager *peripheralManager;
@property (strong, nonatomic, readonly) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UIButton *startAdvertisingButton;
@property (weak, nonatomic) IBOutlet UIButton *stopAdvertisingButton;
@property (weak, nonatomic) IBOutlet UIButton *startMonitoringButton;
@property (weak, nonatomic) IBOutlet UIButton *stopMonitoringButton;
@property (weak, nonatomic) IBOutlet UITextView *outputDisplay;
@property (weak, nonatomic) IBOutlet UILabel *proximityLabel;
@property (weak, nonatomic) IBOutlet UILabel *regionLabel;
@end


@implementation CSBeaconViewController


#pragma mark - CBPeripheralManagerDelegate

-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    NSString *message = [NSString stringWithFormat:@"peripheral state: %@",
                         [self CBPeriperalManagerStateToString:peripheral.state]];
    [self appendTextToOutputDisplay:message];
    
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        self.startAdvertisingButton.enabled = YES;
        self.startMonitoringButton.enabled = YES;
    }
}


#pragma mark - CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager
     didDetermineState:(CLRegionState)state
             forRegion:(CLRegion *)region
{
    NSString *message = [NSString stringWithFormat:@"region state:%@",
                         [self CLRegionStateToString:state]];
    [self appendTextToOutputDisplay:message];
    
    if (state == CLRegionStateInside) {
        [self startBeaconRangeMonitoring];
    }
    else if (state == CLRegionStateOutside) {
        [self stopBeaconRangeMonitoring];
    }
    
    [self updateRegionLabelWithState:state];
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    [self appendTextToOutputDisplay:@"entered region"];
    [self updateRegionLabelWithState:CLRegionStateInside];

    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    [self appendTextToOutputDisplay:@"exited region"];
    [self updateRegionLabelWithState:CLRegionStateOutside];
    
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
}

-(void)locationManager:(CLLocationManager *)manager
       didRangeBeacons:(NSArray *)beacons
              inRegion:(CLBeaconRegion *)region
{
    if (beacons.count > 0) {
        CLBeacon *beacon = [beacons objectAtIndex:0];
        [self updateProximityLabelWithProximity:beacon.proximity];
    }
}


#pragma mark - Beacon Region Management

-(void)startBeaconAdvertising
{
    NSLog(@"startBeaconAdvertising");
    
    NSDictionary *beaconPeripheralData = [self.beaconRegion peripheralDataWithMeasuredPower:nil];
    [self.peripheralManager startAdvertising:beaconPeripheralData];
}

-(void)stopBeaconAdvertising
{
    NSLog(@"stopBeaconAdvertising");
    
    [self.peripheralManager stopAdvertising];
}

-(void)startBeaconMonitoring
{
    [self appendTextToOutputDisplay:@"start beacon monitoring"];
    
    self.beaconRegion.notifyEntryStateOnDisplay = YES;
    self.beaconRegion.notifyOnEntry = NO;
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
}

-(void)stopBeaconMonitoring
{
    [self appendTextToOutputDisplay:@"stop beacon monitoring"];
    
    [self.locationManager stopMonitoringForRegion:self.beaconRegion];
    [self stopBeaconRangeMonitoring];
    [self updateRegionLabelWithState:0];
    [self updateProximityLabelWithProximity:0];
}

-(void)startBeaconRangeMonitoring
{
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

-(void)stopBeaconRangeMonitoring
{
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
}


#pragma mark - Helpers

-(void)appendTextToOutputDisplay:(NSString *)text
{
    NSString *line = [NSString stringWithFormat:@"%@\n%@", self.outputDisplay.text, text];
    self.outputDisplay.text = line;
    [self scrollTextViewToBottom:self.outputDisplay];
}

-(void)scrollTextViewToBottom:(UITextView *)textView
{
    if (textView.text.length > 0 ) {
        NSRange bottom = NSMakeRange(textView.text.length - 1, 1);
        [textView scrollRangeToVisible:bottom];
    }
    
}

-(void)updateRegionLabelWithState:(CLRegionState)state
{
    NSString *regionState = [self CLRegionStateToString:state];
    
    if (state == CLRegionStateInside || state == CLRegionStateOutside) {
        self.regionLabel.text = regionState;
    }
    else {
        self.regionLabel.text = @"";
    }
}

-(void)updateProximityLabelWithProximity:(CLProximity)proximity
{
    if ([self isProximitWithinRange:proximity]) {
        self.proximityLabel.text = [self CLProximityToString:proximity];
    }
    else {
        self.proximityLabel.text = @"";
    }
}

-(BOOL)isProximitWithinRange:(CLProximity)proximity
{
    return proximity == CLProximityFar
        || proximity == CLProximityImmediate
        || proximity == CLProximityNear;
}

-(NSString *)CBPeriperalManagerStateToString:(CBPeripheralManagerState)state
{
    NSString *result = nil;
    switch (state) {
        case CBPeripheralManagerStatePoweredOff: result = @"Powered Off"; break;
        case CBPeripheralManagerStatePoweredOn: result = @"Powered On"; break;
        case CBPeripheralManagerStateResetting: result = @"Resetting"; break;
        case CBPeripheralManagerStateUnauthorized: result = @"Unauthorized"; break;
        case CBPeripheralManagerStateUnsupported: result = @"Unsupported"; break;
        default: result = @"Unknown"; break;
    }
    return result;
}

-(NSString *)CLProximityToString:(CLProximity)proximity
{
    NSString *result = nil;
    switch (proximity) {
        case CLProximityFar: result = @"Far"; break;
        case CLProximityImmediate: result = @"Immediate"; break;
        case CLProximityNear: result = @"Near"; break;
        default: result = @"Unknown"; break;
    }
    return result;
}

-(NSString *)CLRegionStateToString:(CLRegionState)state
{
    NSString *result = nil;
    switch (state) {
        case CLRegionStateInside: result = @"Inside"; break;
        case CLRegionStateOutside: result = @"Outside"; break;
        default: result = @"Unknown"; break;
    }
    return result;
}


#pragma mark - Actions

-(IBAction)startAdvertisingAction:(id)sender
{
    NSLog(@"startAdvertisingAction");
    
    [self startBeaconAdvertising];
    
    self.startAdvertisingButton.enabled = NO;
    self.stopAdvertisingButton.enabled = YES;
}

-(IBAction)stopAdvertisingAction:(id)sender
{
    NSLog(@"stopAdvertisingAction");
    
    [self stopBeaconAdvertising];

    self.startAdvertisingButton.enabled = YES;
    self.stopAdvertisingButton.enabled = NO;
}

- (IBAction)startMonitoringAction:(id)sender
{
    NSLog(@"startMonitoringAction");
 
    [self startBeaconMonitoring];
    
    self.startMonitoringButton.enabled = NO;
    self.stopMonitoringButton.enabled = YES;
}

- (IBAction)stopMonitoringAction:(id)sender
{
    NSLog(@"stopMonitoringAction");
    
    [self stopBeaconMonitoring];
    
    self.startMonitoringButton.enabled = YES;
    self.stopMonitoringButton.enabled = NO;
}


#pragma mark - Initialization / Configuration

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)configureBeacon
{
    NSString *deviceName = [UIDevice currentDevice].name;
    NSUInteger deviceHash = [deviceName hash];
    NSLog(@"deviceName: %@ (0x%x)", deviceName, deviceHash);

    NSString *beaconUUID = nil;
    switch (deviceHash) {
        case kMaxPixelsID:
            beaconUUID = kMaxPixelsBeaconUUID;
            break;
            
        case kMiniPad:
            beaconUUID = kMiniPadBeaconUUID;
            break;
            
        case kiPhone5ID:
            beaconUUID = kBeaconUUID;
            break;
    }
    NSLog(@"beaconUUID: %@", beaconUUID);

    _proximityUUID = [[NSUUID alloc] initWithUUIDString:kBeaconUUID];
    _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:self.proximityUUID
                                                       identifier:[self.proximityUUID UUIDString]];
}

-(void)configurePeripheralAndLocationManagers
{
    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    
    _locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
}


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"CSBeaconViewController view did load");
    [self configureBeacon];
    [self configurePeripheralAndLocationManagers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
