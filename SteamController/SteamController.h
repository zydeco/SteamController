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

/** Represents the mapping of a Steam Controller's trackpad or stick to a GCController thumbstick or directional pad. */
typedef NS_ENUM(NSUInteger, SteamControllerMapping) {
    /// Not mapped to anything.
    SteamControllerMappingNone,
    /// Mapped to the left thumbstick.
    SteamControllerMappingLeftThumbstick,
    /// Mapped to the right thumbstick.
    SteamControllerMappingRightThumbstick,
    /// Mapped to the directional pad.
    SteamControllerMappingDPad
};

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

/**
 Steam Controllers are available to an application that links to `SteamController.framework`. To detect connected
 or pairing Steam Controllers, call `scanForControllers` on `SteamControllerManager`. Because of the way bluetooth
 accessories communicate with iOS apps, it's not possible to detect the connection automatically using public API,
 so you will need to call `scanForControllers` accordingly to ensure they're available when needed (e.g. before
 starting a game, after a controller is disconnected).
 
 Once connected, they work in the same way as the native `GCGameController` from `GameController.framework`, and
 can be accessed in the same ways:
 
 1. Querying for the the current array or controllers using `[GCController controllers]`.
 2. Registering for Connection/Disconnection notifications from `NSNotificationCenter`.
 
 Steam Controllers are represented by the `SteamController` class, a subclass of `GCController`. It implements the
 `GCGamepad` and `GCExtendedGamepad` profiles, and has additional functionality relevant to the Steam Controller:
 
 - Changing the mapping of the trackpads and stick.
 - Requiring clicking on the trackpads for input to be sent.
 - Identifying a controller by playing a tune on it.
 
 */
@interface SteamController : GCController

#pragma mark - Input Mapping
/** Mapping of the Steam Controller's left trackpad. Defaults to `SteamControllerMappingDPad`. */
@property (nonatomic, assign) SteamControllerMapping steamLeftTrackpadMapping;
/** Mapping of the Steam Controller's right trackpad. Defaults to `SteamControllerMappingRightThumbstick`. */
@property (nonatomic, assign) SteamControllerMapping steamRightTrackpadMapping;
/** Mapping of the Steam Controller's analog stick. Defaults to `SteamControllerMappingLeftThumbstick`. */
@property (nonatomic, assign) SteamControllerMapping steamThumbstickMapping;
#pragma mark - Trackpad Configuration
/** If `YES`, the input from the left trackpad will only be sent when it is clicked. Otherwise, input
will be sent as soon as it's touched. Defaults to `YES`. */
@property (nonatomic, assign) BOOL steamLeftTrackpadRequiresClick;
/** If `YES`, the input from the right trackpad will only be sent when it is clicked. Otherwise, input
 will be sent as soon as it's touched. Defaults to `YES`. */
@property (nonatomic, assign) BOOL steamRightTrackpadRequiresClick;

#pragma mark - Miscellaneous
/** The CoreBluetooth peripheral associated with this controller. */
@property (nonatomic, readonly, retain) CBPeripheral *peripheral;
@property (nonatomic, copy, nullable) SteamControllerButtonHandler steamButtonCombinationHandler;

/** Plays the identify tune on the controller. */
- (void)identify;

/// :nodoc:
- (instancetype)initWithPeripheral:(CBPeripheral*)peripheral NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END


