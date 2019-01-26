//
//  ControllerTableViewCell.m
//  SteamController
//
//  Created by Jesús A. Álvarez on 19/12/2018.
//  Copyright © 2018 namedfork. All rights reserved.
//

#import "ControllerTableViewCell.h"
#import "XYView.h"

@implementation ControllerTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.controller = nil;
}

- (void)setController:(GCController *)controller {
    _controller.extendedGamepad.valueChangedHandler = nil;
    _controller.controllerPausedHandler = nil;
    _controller = controller;
    controller.extendedGamepad.valueChangedHandler = ^(GCExtendedGamepad * _Nonnull gamepad, GCControllerElement * _Nonnull element) {
        [self didUpdateElement:element inGamepad:gamepad];
    };
    controller.controllerPausedHandler = ^(GCController * _Nonnull controller) {
        self.pauseButton.selected = YES;
        [self.pauseButton performSelector:@selector(setSelected:) withObject:nil afterDelay:0.2];
    };
}

- (void)didUpdateElement:(GCControllerElement*)element inGamepad:(GCExtendedGamepad*)gamepad {
    if (element == gamepad.buttonA) {
        self.buttonA.selected = gamepad.buttonA.pressed;
    } else if (element == gamepad.buttonB) {
        self.buttonB.selected = gamepad.buttonB.pressed;
    } else if (element == gamepad.buttonX) {
        self.buttonX.selected = gamepad.buttonX.pressed;
    } else if (element == gamepad.buttonY) {
        self.buttonY.selected = gamepad.buttonY.pressed;
    } else if (element == gamepad.leftShoulder) {
        self.leftShoulder.selected = gamepad.leftShoulder.pressed;
    } else if (element == gamepad.rightShoulder) {
        self.rightShoulder.selected = gamepad.rightShoulder.pressed;
    } else if (element == gamepad.leftTrigger) {
        int percent = gamepad.leftTrigger.value * 100;
        NSString *title = percent ? [NSString stringWithFormat:@"%d%%", percent] : @"LT";
        [self.leftTrigger setTitle:title forState:UIControlStateNormal];
        self.leftTrigger.selected = gamepad.leftTrigger.pressed;
    } else if (element == gamepad.rightTrigger) {
        int percent = gamepad.rightTrigger.value * 100;
        NSString *title = percent ? [NSString stringWithFormat:@"%d%%", percent] : @"RT";
        [self.rightTrigger setTitle:title forState:UIControlStateNormal];
        self.rightTrigger.selected = gamepad.rightTrigger.pressed;
    } else if (element == gamepad.dpad) {
        [self.dpadView setX:gamepad.dpad.xAxis.value Y:gamepad.dpad.yAxis.value];
    } else if (element == gamepad.leftThumbstick) {
        [self.leftTrackpadView setX:gamepad.leftThumbstick.xAxis.value Y:gamepad.leftThumbstick.yAxis.value];
    } else if (element == gamepad.rightThumbstick) {
        [self.rightTrackpadView setX:gamepad.rightThumbstick.xAxis.value Y:gamepad.rightThumbstick.yAxis.value];
    }
    if (@available(iOS 12.1, *)) {
        if (element == gamepad.leftThumbstickButton) {
            self.leftTrackpadView.backgroundColor = gamepad.leftThumbstickButton.pressed ? [UIColor darkGrayColor] : [UIColor lightGrayColor];
        } else if (element == gamepad.rightThumbstickButton) {
            self.rightTrackpadView.backgroundColor = gamepad.rightThumbstickButton.pressed ? [UIColor darkGrayColor] : [UIColor lightGrayColor];
        }
    }
}

@end
