//
//  SteamControllerExtendedGamepad.m
//  SteamController
//
//  Created by Jesús A. Álvarez on 18/12/2018.
//  Copyright © 2018 namedfork. All rights reserved.
//

#import "SteamControllerExtendedGamepad.h"
#import "SteamController.h"
#import "SteamControllerInput.h"

@implementation SteamControllerExtendedGamepad
{
    SteamControllerDirectionPad *leftThumbstick, *rightThumbstick, *dpad;
    SteamControllerButtonInput *leftShoulder, *rightShoulder;
    SteamControllerButtonInput *leftThumbstickButton, *rightThumbstickButton;
    SteamControllerButtonInput *leftTrigger, *rightTrigger;
    SteamControllerButtonInput *buttonA, *buttonB, *buttonX, *buttonY;
    __weak SteamController *steamController;
    SteamControllerExtendedGamepadSnapshotData state;
    GCExtendedGamepadValueChangedHandler valueChangedHandler;
}

@synthesize leftThumbstick, rightThumbstick, dpad;
@synthesize leftShoulder, rightShoulder;
@synthesize leftTrigger, rightTrigger;
@synthesize buttonA, buttonB, buttonX, buttonY;
@synthesize leftThumbstickButton, rightThumbstickButton;
@synthesize state;

- (instancetype)initWithController:(SteamController *)controller {
    if (self = [super init]) {
        steamController = controller;
        leftThumbstick = [SteamControllerDirectionPad new];
        rightThumbstick = [SteamControllerDirectionPad new];
        dpad = [SteamControllerDirectionPad new];
        leftShoulder = [SteamControllerButtonInput new];
        rightShoulder = [SteamControllerButtonInput new];
        leftTrigger = [SteamControllerButtonInput new];
        rightTrigger = [SteamControllerButtonInput new];
        buttonA = [SteamControllerButtonInput new];
        buttonB = [SteamControllerButtonInput new];
        buttonX = [SteamControllerButtonInput new];
        buttonY = [SteamControllerButtonInput new];
        if ([GCExtendedGamepad instancesRespondToSelector:@selector(leftThumbstickButton)]) {
            // runtime supports thumbstick buttons
            leftThumbstickButton = [SteamControllerButtonInput new];
            rightThumbstickButton = [SteamControllerButtonInput new];
            state.version = 0x0101;
            state.size = 62;
        } else {
            leftThumbstickButton = nil;
            rightThumbstickButton = nil;
            // pretend to be GCExtendedGamepadSnapShotDataV100
            state.version = 0x0100;
            state.size = 60;
        }
    }
    return self;
}

- (GCController *)controller {
    return steamController;
}

- (GCExtendedGamepadValueChangedHandler)valueChangedHandler {
    return valueChangedHandler;
}

- (void)setValueChangedHandler:(GCExtendedGamepadValueChangedHandler)newHandler {
    valueChangedHandler = newHandler;
}

- (GCExtendedGamepadSnapshot *)saveSnapshot {
    NSData *snapshotData = [NSData dataWithBytes:&state length:state.size];
    return [[GCExtendedGamepadSnapshot alloc] initWithController:self.controller snapshotData:snapshotData];
}

- (void)setState:(SteamControllerExtendedGamepadSnapshotData)newState {
#define ChangedState(_field) (state._field != newState._field)
#define UpdateStateValue(_field) if (ChangedState(_field)) { _field.value = newState._field; [self didChangeValueForElement:_field]; }
#define UpdateStateBool(_field) if (ChangedState(_field)) { _field.value = newState._field ? 1.0 : 0.0; [self didChangeValueForElement:_field]; }
#define UpdateXYValue(_fieldX, _fieldY, _input) if (ChangedState(_fieldX) || ChangedState(_fieldY)) { [_input setX:newState._fieldX Y:newState._fieldY]; [self didChangeValueForElement:_input]; }
    UpdateStateValue(buttonA);
    UpdateStateValue(buttonB);
    UpdateStateValue(buttonX);
    UpdateStateValue(buttonY);
    UpdateStateValue(leftShoulder);
    UpdateStateValue(leftTrigger);
    UpdateStateValue(rightShoulder);
    UpdateStateValue(rightTrigger);
    UpdateXYValue(dpadX, dpadY, dpad);
    UpdateXYValue(leftThumbstickX, leftThumbstickY, leftThumbstick);
    UpdateXYValue(rightThumbstickX, rightThumbstickY, rightThumbstick);
    UpdateStateBool(leftThumbstickButton);
    UpdateStateBool(rightThumbstickButton);
    state = newState;
}

- (void)didChangeValueForElement:(GCControllerElement*)element {
    if (valueChangedHandler) {
        valueChangedHandler(self, element);
    }
}

@end
