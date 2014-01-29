//
//  CSBeaconViewController.h
//  LocationSpike
//
//  Created by Keith Ermel on 1/28/14.
//  Copyright (c) 2014 Keith Ermel. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>


@interface CSBeaconViewController : UIViewController
    <CBPeripheralManagerDelegate, CLLocationManagerDelegate>

@end
