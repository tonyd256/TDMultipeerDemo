//
//  TDMotion.h
//  TDMultipeerDemo
//
//  Created by Tony DiPasquale on 1/9/14.
//  Copyright (c) 2014 thoughtbot. All rights reserved.
//

#pragma pack(push, 4)

typedef struct {
    char axis;
    double value;
} AccelerationStruct;

typedef union {
    uint8_t bytes[sizeof(AccelerationStruct)];
    AccelerationStruct data;
} AccelerationUnion;

#pragma pack(pop)

@protocol TDMotionDelegate <NSObject>

- (void)didReceiveAcceleration:(CMAcceleration)acceleration;

@end

@interface TDMotion : NSObject

@property (assign, nonatomic) id<TDMotionDelegate> delegate;
@property (assign, atomic) CMAcceleration acceleration;

- (void)start;

@end
