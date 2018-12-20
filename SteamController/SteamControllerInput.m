//
//  SteamControllerInput.m
//  SteamController
//
//  Created by Jesús A. Álvarez on 18/12/2018.
//  Copyright © 2018 namedfork. All rights reserved.
//

#import "SteamControllerInput.h"

@implementation SteamControllerAxisInput
{
    GCControllerAxisValueChangedHandler valueChangedHandler;
    SteamControllerDirectionPad *directionPad;
    float value;
}

- (instancetype)initWithDirectionPad:(SteamControllerDirectionPad*)dpad {
    if (self = [super init]) {
        directionPad = dpad;
    }
    return self;
}

- (BOOL)isAnalog {
    return YES;
}

- (GCControllerAxisValueChangedHandler)valueChangedHandler {
    return valueChangedHandler;
}

- (void)setValueChangedHandler:(GCControllerAxisValueChangedHandler)newHandler {
    valueChangedHandler = newHandler;
}

- (GCControllerElement *)collection {
    return directionPad;
}

- (float)value {
    return value;
}

- (void)setValue:(float)newValue {
    float oldValue = value;
    value = newValue;
    if (value != oldValue && valueChangedHandler) valueChangedHandler(self, value);
}

@end

#define kButtonPressedThreshold 0.3

@implementation SteamControllerButtonInput
{
    GCControllerButtonValueChangedHandler valueChangedHandler, pressedChangedHandler;
    SteamControllerDirectionPad *directionPad;
    float value;
}

- (instancetype)initWithDirectionPad:(SteamControllerDirectionPad*)dpad {
    if (self = [super init]) {
        directionPad = dpad;
    }
    return self;
}

- (BOOL)isAnalog {
    return YES;
}

- (GCControllerButtonValueChangedHandler)valueChangedHandler {
    return valueChangedHandler;
}

- (void)setValueChangedHandler:(GCControllerButtonValueChangedHandler)newHandler {
    valueChangedHandler = newHandler;
}

- (GCControllerButtonValueChangedHandler)pressedChangedHandler {
    return pressedChangedHandler;
}

- (void)setPressedChangedHandler:(GCControllerButtonValueChangedHandler)newHandler {
    pressedChangedHandler = newHandler;
}

- (GCControllerElement *)collection {
    return directionPad;
}

- (float)value {
    return value;
}

- (void)setValue:(float)newValue {
    BOOL wasPressed = value > kButtonPressedThreshold;
    BOOL pressed = newValue > kButtonPressedThreshold;
    float oldValue = value;
    value = newValue;
    if (value != oldValue && valueChangedHandler) valueChangedHandler(self, value, pressed);
    if (pressed != wasPressed && pressedChangedHandler) pressedChangedHandler(self, value, pressed);
}

- (BOOL)isPressed {
    return value > kButtonPressedThreshold;
}

@end

@implementation SteamControllerDirectionPad
{
    SteamControllerAxisInput *xAxis, *yAxis;
    SteamControllerButtonInput *up, *down, *left, *right;
    GCControllerDirectionPadValueChangedHandler valueChangedHandler;
}

@synthesize xAxis, yAxis;
@synthesize up, down, left, right;

- (instancetype)init {
    if (self = [super init]) {
        xAxis = [[SteamControllerAxisInput alloc] initWithDirectionPad:self];
        yAxis = [[SteamControllerAxisInput alloc] initWithDirectionPad:self];
        up = [[SteamControllerButtonInput alloc] initWithDirectionPad:self];
        down = [[SteamControllerButtonInput alloc] initWithDirectionPad:self];
        left = [[SteamControllerButtonInput alloc] initWithDirectionPad:self];
        right = [[SteamControllerButtonInput alloc] initWithDirectionPad:self];
    }
    return self;
}

- (GCControllerDirectionPadValueChangedHandler)valueChangedHandler {
    return valueChangedHandler;
}

- (void)setValueChangedHandler:(GCControllerDirectionPadValueChangedHandler)newHandler {
    valueChangedHandler = newHandler;
}

- (void)setX:(float)xValue Y:(float)yValue {
    [xAxis setValue:xValue];
    if (xValue > 0.0) {
        [right setValue:xValue];
        [left setValue:0.0];
    } else if (xValue < 0.0) {
        [right setValue:0.0];
        [left setValue:-xValue];
    } else {
        [left setValue:0.0];
        [right setValue:0.0];
    }
    
    [yAxis setValue:yValue];
    if (yValue > 0.0) {
        [up setValue:yValue];
        [down setValue:0.0];
    } else if (yValue < 0.0) {
        [up setValue:0.0];
        [down setValue:-yValue];
    } else {
        [up setValue:0.0];
        [down setValue:0.0];
    }
    
    if (valueChangedHandler) valueChangedHandler(self, xValue, yValue);
}

@end
