//
//  TDClientViewController.m
//  TDMultipeerDemo
//
//  Created by Tony DiPasquale on 1/9/14.
//  Copyright (c) 2014 thoughtbot. All rights reserved.
//

#import "TDClientViewController.h"
#import "TDMotion.h"
#import "TDSession.h"

@interface TDClientViewController () <TDSessionDelegate, TDMotionDelegate>

@property (strong, nonatomic) TDMotion *motion;
@property (strong, nonatomic) TDSession *session;
@property (strong, nonatomic) NSOutputStream *stream;

@end

@implementation TDClientViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.motion = [[TDMotion alloc] init];
    self.motion.delegate = self;

    self.session = [[TDSession alloc] init];
    self.session.delegate = self;

    [self.session startAdvertising];
}

#pragma mark - TDMotionDelegate

- (void)didReceiveAcceleration:(CMAcceleration)acceleration
{
    // send to stream
    if ([self.stream hasSpaceAvailable]) {
        AccelerationStruct x = { 'x', acceleration.x };
        AccelerationUnion xVal;
        xVal.data = x;
        [self.stream write:xVal.bytes maxLength:sizeof(AccelerationStruct)];
        NSLog(@"x:%.2fg", xVal.data.value);

        AccelerationStruct y = { 'y', acceleration.y };
        AccelerationUnion yVal;
        yVal.data = y;
        [self.stream write:yVal.bytes maxLength:sizeof(AccelerationStruct)];
        NSLog(@"y:%.2fg", yVal.data.value);

        AccelerationStruct z = { 'z', acceleration.z };
        AccelerationUnion zVal;
        zVal.data = z;
        [self.stream write:zVal.bytes maxLength:sizeof(AccelerationStruct)];
        NSLog(@"z:%.2fg", zVal.data.value);
    }
}

#pragma mark - TDSessionDelegate

- (void)didConnectToPeer:(MCPeerID *)peerID
{
    self.stream = [self.session openStreamToPeer:peerID];
    [self.stream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [self.stream open];

    [self.motion start];
}

@end
