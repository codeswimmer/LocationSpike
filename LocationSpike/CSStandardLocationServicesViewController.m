//
//  CSStandardLocationServicesViewController.m
//  LocationSpike
//
//  Created by Keith Ermel on 1/27/14.
//  Copyright (c) 2014 Keith Ermel. All rights reserved.
//

#import "CSStandardLocationServicesViewController.h"


@interface CSStandardLocationServicesViewController ()
@property (strong, nonatomic, readonly) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UITextView *outputDisplay;
@end

@implementation CSStandardLocationServicesViewController


#pragma mark - Helpers

-(void)appendTextToOutputDisplay:(NSString *)text
{
    NSString *line = [NSString stringWithFormat:@"%@\n%@", self.outputDisplay.text, text];
    self.outputDisplay.text = line;
}


#pragma mark - CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSString *output = [NSString stringWithFormat:@"didUpdateLocations: %lu",
                        (unsigned long)locations.count];
    [self appendTextToOutputDisplay:output];
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

-(void)configureLocationManager
{
    _locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
}


#pragma mark - Actions

- (IBAction)startAction:(id)sender
{
    NSLog(@"start action invoked");
    [self.locationManager startUpdatingLocation];
    [self appendTextToOutputDisplay:@"Standard location services started"];
}

- (IBAction)stopAction:(id)sender
{
    NSLog(@"stop action invoked");
}


#pragma mark -  View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"CSStandardLocationServicesViewController view did load");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
