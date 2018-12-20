//
//  SteamControllerExtendedGamepad.h
//  SteamController
//
//  Created by Jesús A. Álvarez on 18/12/2018.
//  Copyright © 2018 namedfork. All rights reserved.
//

#import <GameController/GameController.h>
#import "SteamController.h"
#import "SteamControllerInput.h"

NS_ASSUME_NONNULL_BEGIN

@interface SteamControllerExtendedGamepad : GCExtendedGamepad

@property (nonatomic, readonly) SteamControllerDirectionPad *dpad;
@property (nonatomic, readonly) SteamControllerButtonInput *buttonA;
@property (nonatomic, readonly) SteamControllerButtonInput *buttonB;
@property (nonatomic, readonly) SteamControllerButtonInput *buttonX;
@property (nonatomic, readonly) SteamControllerButtonInput *buttonY;
@property (nonatomic, readonly) SteamControllerDirectionPad *leftThumbstick;
@property (nonatomic, readonly) SteamControllerDirectionPad *rightThumbstick;
@property (nonatomic, readonly) SteamControllerButtonInput *leftShoulder;
@property (nonatomic, readonly) SteamControllerButtonInput *rightShoulder;
@property (nonatomic, readonly) SteamControllerButtonInput *leftTrigger;
@property (nonatomic, readonly) SteamControllerButtonInput *rightTrigger;
@property (nonatomic, readonly, nullable) SteamControllerButtonInput *leftThumbstickButton;
@property (nonatomic, readonly, nullable) SteamControllerButtonInput *rightThumbstickButton;
@property (nonatomic, assign) GCExtendedGamepadSnapShotDataV100 state;

- (instancetype)initWithController:(SteamController*)controller;

@end

NS_ASSUME_NONNULL_END
