//
//  CSViewController.m
//  LocationSpike
//
//  Created by Keith Ermel on 1/28/14.
//  Copyright (c) 2014 Keith Ermel. All rights reserved.
//

#import "CSViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface CSViewController ()

@end

@implementation CSViewController

-(BOOL)checkLocationServicesAvailability
{
    BOOL canDo = [CLLocationManager locationServicesEnabled];
    NSLog(@"canDo: %d", canDo);
    return canDo;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	if (![self checkLocationServicesAvailability]) {
        NSLog(@"Location services unavailable");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
