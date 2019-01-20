//
//  SteamController.h
//  SteamController
//
//  Created by Jesús A. Álvarez on 20/12/2018.
//  Copyright © 2018 namedfork. All rights reserved.
//

#import <GameController/GameController.h>
#import <SteamController/SteamControllerManager.h>

@class CBPeripheral;

typedef enum : NSUInteger {
    SteamControllerMappingNone,
    SteamControllerMappingLeftThumbstick,
    SteamControllerMappingRightThumbstick,
    SteamControllerMappingDPad
} SteamControllerMapping;

NS_ASSUME_NONNULL_BEGIN

@interface SteamController : GCController

@property (nonatomic, readonly, retain) CBPeripheral *peripheral;
@property (nonatomic, assign) SteamControllerMapping steamLeftTrackpadMapping, steamRightTrackpadMapping, steamThumbstickMapping;
@property (nonatomic, assign) BOOL steamLeftTrackpadRequiresClick, steamRightTrackpadRequiresClick;

- (instancetype)initWithPeripheral:(CBPeripheral*)peripheral NS_DESIGNATED_INITIALIZER;

/** Plays the identify tune on the controller. */
- (void)identify;

@end

NS_ASSUME_NONNULL_END


