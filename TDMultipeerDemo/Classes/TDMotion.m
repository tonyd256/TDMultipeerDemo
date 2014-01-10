//
//  TDMotion.m
//  TDMultipeerDemo
//
//  Created by Tony DiPasquale on 1/9/14.
//  Copyright (c) 2014 thoughtbot. All rights reserved.
//

#import "TDMotion.h"

@interface TDMotion ()

@property (strong, nonatomic) CMMotionManager *manager;

@end

@implementation TDMotion

#pragma mark - Properties

- (CMMotionManager *)manager
{
    if (!_manager)
        _manager = [[CMMotionManager alloc] init];

    return _manager;
}

#pragma mark - Public

- (void)start
{
    self.manager.accelerometerUpdateInterval = 1.0;

    [self.manager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        [self.delegate didReceiveAcceleration:accelerometerData.acceleration];
    }];
}

@end
