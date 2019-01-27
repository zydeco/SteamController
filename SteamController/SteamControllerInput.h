//
//  SteamControllerInput.h
//  SteamController
//
//  Created by Jesús A. Álvarez on 18/12/2018.
//  Copyright © 2018 namedfork. All rights reserved.
//

#import <GameController/GameController.h>
#import <Availability.h>

#define BUTTON_BACK 0x001000
#define BUTTON_STEAM 0x002000
#define BUTTON_FORWARD 0x004000
#define BUTTON_LEFT_BUMPER 0x080000
#define BUTTON_LEFT_TRIGGER 0x020000
#define BUTTON_LEFT_GRIP 0x008000
#define BUTTON_LEFT_TRACKPAD_CLICK 0x000002
#define BUTTON_LEFT_TRACKPAD_CLICK_DOWN 0x000800
#define BUTTON_LEFT_TRACKPAD_CLICK_LEFT 0x000400
#define BUTTON_LEFT_TRACKPAD_CLICK_RIGHT 0x000200
#define BUTTON_LEFT_TRACKPAD_CLICK_UP 0x000100
#define BUTTON_LEFT_TRACKPAD_TOUCH 0x000008
#define BUTTON_STICK 0x000040
#define BUTTON_RIGHT_BUMPER 0x040000
#define BUTTON_RIGHT_TRIGGER 0x010000
#define BUTTON_RIGHT_GRIP 0x000001
#define BUTTON_RIGHT_TRACKPAD_CLICK 0x000004
#define BUTTON_RIGHT_TRACKPAD_TOUCH 0x000010
#define BUTTON_A 0x800000
#define BUTTON_B 0x200000
#define BUTTON_X 0x400000
#define BUTTON_Y 0x100000

typedef struct SteamPadState {
    int16_t x, y;
} SteamPadState;

typedef struct SteamControllerState {
    uint32_t buttons;
    SteamPadState leftPad, rightPad, stick;
    uint8_t leftTrigger, rightTrigger;
} SteamControllerState;

@class SteamControllerDirectionPad, SteamController;

NS_ASSUME_NONNULL_BEGIN

@interface SteamControllerButtonInput : GCControllerButtonInput

- (instancetype)initWithDirectionPad:(SteamControllerDirectionPad*)dpad;
- (instancetype)initWithController:(SteamController *)controller analog:(BOOL)isAnalog;
- (void)setValue:(float)value;

@end

@interface SteamControllerAxisInput : GCControllerAxisInput

- (instancetype)initWithDirectionPad:(SteamControllerDirectionPad*)dpad;
- (instancetype)initWithController:(SteamController *)controller;
- (void)setValue:(float)value;

@end

@interface SteamControllerDirectionPad : GCControllerDirectionPad

@property (nonatomic, readonly) SteamControllerAxisInput *xAxis;
@property (nonatomic, readonly) SteamControllerAxisInput *yAxis;

@property (nonatomic, readonly) SteamControllerButtonInput *up;
@property (nonatomic, readonly) SteamControllerButtonInput *down;
@property (nonatomic, readonly) SteamControllerButtonInput *left;
@property (nonatomic, readonly) SteamControllerButtonInput *right;

@property (nonatomic, readonly, weak) SteamController *steamController;

- (instancetype)initWithController:(SteamController *)controller;
- (void)setX:(float)x Y:(float)y;

@end



NS_ASSUME_NONNULL_END
