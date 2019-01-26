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

typedef NS_OPTIONS(uint32_t, SteamControllerButton) {
    SteamControllerButtonRightGrip = 0x000001,
    SteamControllerButtonLeftTrackpadClick = 0x000002,
    SteamControllerButtonRightTrackpadClick = 0x000004,
    SteamControllerButtonLeftTrackpadTouch = 0x000008,
    SteamControllerButtonRightTrackpadTouch = 0x000010,
    SteamControllerButtonStick = 0x000040,
    SteamControllerButtonLeftTrackpadClickUp = 0x000100,
    SteamControllerButtonLeftTrackpadClickRight = 0x000200,
    SteamControllerButtonLeftTrackpadClickLeft = 0x000400,
    SteamControllerButtonLeftTrackpadClickDown = 0x000800,
    SteamControllerButtonBack = 0x001000,
    SteamControllerButtonSteam = 0x002000,
    SteamControllerButtonForward = 0x004000,
    SteamControllerButtonLeftGrip = 0x008000,
    SteamControllerButtonRightTrigger = 0x010000,
    SteamControllerButtonLeftTrigger = 0x020000,
    SteamControllerButtonRightBumper = 0x040000,
    SteamControllerButtonLeftBumper = 0x080000,
    SteamControllerButtonA = 0x800000,
    SteamControllerButtonB = 0x200000,
    SteamControllerButtonX = 0x400000,
    SteamControllerButtonY = 0x100000
};

NSString* NSStringFromSteamControllerButton(SteamControllerButton button);

typedef void(^SteamControllerButtonHandler)(SteamController *controller, SteamControllerButton button, BOOL isDown);

NS_ASSUME_NONNULL_BEGIN

@interface SteamController : GCController

@property (nonatomic, readonly, retain) CBPeripheral *peripheral;
@property (nonatomic, assign) SteamControllerMapping steamLeftTrackpadMapping, steamRightTrackpadMapping, steamThumbstickMapping;
@property (nonatomic, assign) BOOL steamLeftTrackpadRequiresClick, steamRightTrackpadRequiresClick;
@property (nonatomic, copy, nullable) SteamControllerButtonHandler steamButtonCombinationHandler;

- (instancetype)initWithPeripheral:(CBPeripheral*)peripheral NS_DESIGNATED_INITIALIZER;

/** Plays the identify tune on the controller. */
- (void)identify;

@end

NS_ASSUME_NONNULL_END


