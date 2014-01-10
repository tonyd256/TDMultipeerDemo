//
//  TDSession.h
//  TDMultipeerDemo
//
//  Created by Tony DiPasquale on 1/9/14.
//  Copyright (c) 2014 thoughtbot. All rights reserved.
//

@protocol TDSessionDelegate <NSObject>

@optional;
- (void)didReceiveStream:(NSInputStream *)stream fromPeer:(MCPeerID *)peerID;
- (void)didConnectToPeer:(MCPeerID *)peerID;

@end

@interface TDSession : NSObject

@property (assign, nonatomic) id<TDSessionDelegate> delegate;
@property (strong, nonatomic, readonly) MCBrowserViewController *browserViewController;

- (void)startAdvertising;
- (void)stopAdvertising;

- (NSOutputStream *)openStreamToPeer:(MCPeerID *)peerID;

@end
