//
//  TDHostViewController.m
//  TDMultipeerDemo
//
//  Created by Tony DiPasquale on 1/9/14.
//  Copyright (c) 2014 thoughtbot. All rights reserved.
//

#import "TDHostViewController.h"
#import "TDSession.h"
#import "TDMotion.h"

@interface TDHostViewController () <TDSessionDelegate, NSStreamDelegate>

@property (strong, nonatomic) TDSession *session;
@property (strong, nonatomic) NSInputStream *stream;

@property (weak, nonatomic) IBOutlet UILabel *xLabel;
@property (weak, nonatomic) IBOutlet UILabel *yLabel;
@property (weak, nonatomic) IBOutlet UILabel *zLabel;

- (IBAction)connect:(id)sender;

@end

@implementation TDHostViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.session = [[TDSession alloc] init];
    self.session.delegate = self;
}

#pragma mark - TDSessionDelegate

- (void)didReceiveStream:(NSInputStream *)stream fromPeer:(MCPeerID *)peerID
{
    self.stream = stream;
    self.stream.delegate = self;

    static NSThread *receiveThread;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        receiveThread = [[NSThread alloc] initWithTarget:self selector:@selector(startReceiving) object:nil];
        [receiveThread start];
    });
}

- (void)startReceiving
{
    @autoreleasepool {
        [self.stream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.stream open];

        while (YES && [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]) ;
    }
}

#pragma mark - NSStreamDelegate
AccelerationUnion value;
int offset = 0;

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    if (eventCode == NSStreamEventHasBytesAvailable) {
        uint8_t bytes[sizeof(AccelerationStruct)];
        NSInteger length = [self.stream read:bytes maxLength:sizeof(AccelerationStruct)];

        for (int i = 0; i < length; i++) {
            value.bytes[offset] = bytes[i];
            offset++;

            if (offset == sizeof(AccelerationStruct)) {
                [self performSelectorOnMainThread:@selector(updateView:) withObject:[NSValue valueWithPointer:&value.data] waitUntilDone:YES];
                NSLog(@"%c: %.2fg", value.data.axis, value.data.value);
                offset = 0;
            }
        }
    }
}

- (void)updateView:(NSValue *)value;
{
    AccelerationStruct *accel = [value pointerValue];
    if (accel->axis == 'x') {
        self.xLabel.text = [NSString stringWithFormat:@"%.2fg", accel->value];
    } else if (accel->axis == 'y') {
        self.yLabel.text = [NSString stringWithFormat:@"%.2fg", accel->value];
    } else if (accel->axis == 'z') {
        self.zLabel.text = [NSString stringWithFormat:@"%.2fg", accel->value];
    }
}

#pragma mark - Actions

- (IBAction)connect:(id)sender
{
    MCBrowserViewController *view = [self.session browserViewController];
    [self presentViewController:view animated:YES completion:nil];
}

@end
