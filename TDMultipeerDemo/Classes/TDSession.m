//
//  TDSession.m
//  TDMultipeerDemo
//
//  Created by Tony DiPasquale on 1/9/14.
//  Copyright (c) 2014 thoughtbot. All rights reserved.
//

#import "TDSession.h"

@interface TDSession () <MCSessionDelegate, MCBrowserViewControllerDelegate>

@property (strong, nonatomic) MCPeerID *peerID;
@property (strong, nonatomic) MCSession *session;
@property (strong, nonatomic) MCAdvertiserAssistant *advertiser;
@property (strong, nonatomic) MCBrowserViewController *browserViewController;

@end

@implementation TDSession

#pragma mark - Properties

- (MCSession *)session
{
    if (!_session) {
        _session = [[MCSession alloc] initWithPeer:self.peerID];
        _session.delegate = self;
    }
    return _session;
}

- (MCPeerID *)peerID
{
    if (!_peerID) {
        _peerID = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
    }
    return _peerID;
}

- (MCBrowserViewController *)browserViewController
{
    if (!_browserViewController) {
        _browserViewController = [[MCBrowserViewController alloc] initWithServiceType:@"td-demo" session:self.session];
        _browserViewController.delegate = self;
    }
    return _browserViewController;
}

#pragma mark - MCSessionDelegate

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    if (state == MCSessionStateConnecting) {
        NSLog(@"Connecting to %@", peerID.displayName);
    } else if (state == MCSessionStateConnected) {
        NSLog(@"Connected to %@", peerID.displayName);

        if ([self.delegate respondsToSelector:@selector(didConnectToPeer:)])
            [self.delegate didConnectToPeer:peerID];
    } else if (state == MCSessionStateNotConnected) {
        NSLog(@"Disconnected from %@", peerID.displayName);
    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{

}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    if ([self.delegate respondsToSelector:@selector(didReceiveStream:fromPeer:)])
        [self.delegate didReceiveStream:stream fromPeer:peerID];
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{

}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    
}

#pragma mark - MCBrowserViewControllerDelegate

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Public

- (void)startAdvertising
{
    if (!self.advertiser)
        self.advertiser = [[MCAdvertiserAssistant alloc] initWithServiceType:@"td-demo" discoveryInfo:nil session:self.session];

    [self.advertiser start];
}

- (void)stopAdvertising
{
    [self.advertiser stop];
}

- (NSOutputStream *)openStreamToPeer:(MCPeerID *)peerID
{
    NSError *error;
    NSOutputStream *stream = [self.session startStreamWithName:@"data-stream" toPeer:peerID error:&error];
    if (error) {
        NSLog(@"%@", error.userInfo);
    }

    return stream;
}

@end
