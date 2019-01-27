//
//  SteamController.m
//  SteamController
//
//  Created by Jesús A. Álvarez on 16/12/2018.
//  Copyright © 2018 namedfork. All rights reserved.
//

#import "SteamController.h"
#import "SteamControllerInput.h"
#import "SteamControllerExtendedGamepad.h"
@import CoreBluetooth;

static inline float S16ToFloat(int16_t value) {
    if (value == 0) {
        return 0.0;
    } else if (value > 0) {
        return value / (float)INT16_MAX;
    } else {
        return value / (float)-INT16_MIN;
    }
}

static void UpdateStatePad(SteamControllerExtendedGamepadSnapshotData* state, SteamControllerMapping pad, float x, float y, BOOL button) {
    switch (pad) {
        case SteamControllerMappingLeftThumbstick:
            state->leftThumbstickX = x;
            state->leftThumbstickY = y;
            state->leftThumbstickButton = button;
            break;
        case SteamControllerMappingRightThumbstick:
            state->rightThumbstickX = x;
            state->rightThumbstickY = y;
            state->rightThumbstickButton = button;
            break;
        case SteamControllerMappingDPad:
            state->dpadX = x;
            state->dpadY = y;
            state->leftThumbstickButton |= button;
            break;
        default:
            break;
    }
}

static CBUUID *SteamControllerInputCharacteristicUUID;
static CBUUID *SteamControllerInputDescriptorUUID;
static CBUUID *SteamControllerReportCharacteristicUUID;

@interface SteamController () <CBPeripheralDelegate>
- (void)playTune:(uint8_t)tune;
@end

@implementation SteamController
{
    CBCharacteristic *reportCharacteristic;
    SteamControllerExtendedGamepad *extendedGamepad;
    GCControllerPlayerIndex playerIndex;
    dispatch_queue_t handlerQueue;
    void (^controllerPausedHandler)(GCController *controller);
    BOOL enteringValveMode, handledSteamCombos;
    SteamControllerState state;
    uint32_t currentSteamCombos;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Please don't init SteamController without a peripheral." userInfo:nil];
    return [self initWithPeripheral:nil];
}

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SteamControllerInputCharacteristicUUID = [CBUUID UUIDWithString:@"100F6C33-1735-4313-B402-38567131E5F3"];
        SteamControllerInputDescriptorUUID = [CBUUID UUIDWithString:@"00002902-0000-1000-8000-00805f9b34fb"];
        SteamControllerReportCharacteristicUUID = [CBUUID UUIDWithString:@"100F6C34-1735-4313-B402-38567131E5F3"];
    });
    if ((self = [super init])) {
        _peripheral = peripheral;
        _peripheral.delegate = self;
        _steamLeftTrackpadMapping = SteamControllerMappingDPad;
        _steamRightTrackpadMapping = SteamControllerMappingRightThumbstick;
        _steamThumbstickMapping = SteamControllerMappingDPad;
        _steamLeftTrackpadRequiresClick = NO;
        _steamRightTrackpadRequiresClick = NO;
        memset(&state, 0, sizeof(state));
        extendedGamepad = [[SteamControllerExtendedGamepad alloc] initWithController:self];
        self.playerIndex = GCControllerPlayerIndexUnset;
        self.handlerQueue = dispatch_get_main_queue();
    }
    return self;
}

#pragma mark - Accessors

- (GCControllerPlayerIndex)playerIndex {
    return playerIndex;
}

- (void)setPlayerIndex:(GCControllerPlayerIndex)newPlayerIndex {
    playerIndex = newPlayerIndex;
}

- (BOOL)isAttachedToDevice {
    return NO;
}

- (NSString *)vendorName {
    return @"Steam Controller";
}

- (dispatch_queue_t)handlerQueue {
    return handlerQueue;
}

- (void)setHandlerQueue:(dispatch_queue_t)newHandlerQueue {
    handlerQueue = newHandlerQueue;
}

- (GCExtendedGamepad *)extendedGamepad {
    return extendedGamepad;
}

- (GCGamepad *)gamepad {
    return (GCGamepad *)extendedGamepad;
}

- (GCMicroGamepad *)microGamepad {
    return nil;
}

- (GCMotion *)motion {
    return nil;
}

- (void (^)(GCController * _Nonnull))controllerPausedHandler {
    return controllerPausedHandler;
}

- (void)setControllerPausedHandler:(void (^)(GCController * _Nonnull))newHandler {
    controllerPausedHandler = newHandler;
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:SteamControllerInputCharacteristicUUID]) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        [peripheral discoverDescriptorsForCharacteristic:characteristic];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if ([characteristic.UUID isEqual:SteamControllerReportCharacteristicUUID]) {
        reportCharacteristic = characteristic;
        [self enterValveMode];
    }
}

- (void)enterValveMode {
    enteringValveMode = YES;
    NSData *enterValveMode = [NSData dataWithBytes:"\xC0\x87\x03\x08\x07\x00" length:6];
    [_peripheral writeValue:enterValveMode forCharacteristic:reportCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if ([characteristic.UUID isEqual:SteamControllerReportCharacteristicUUID] && error == nil && enteringValveMode) {
        enteringValveMode = NO;
        [self didEnterValveMode];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if ([characteristic.UUID isEqual:SteamControllerInputCharacteristicUUID]) {
        NSData *value = characteristic.value;
        const uint8_t *bytes = value.bytes;
        if (value.length < 2 || bytes[0] != 0xc0) return; // interesting events start with c0
        [self didReceiveInput:value];
    }
}

- (void)didConnect {
    [_peripheral discoverServices:nil];
}

- (void)didDisconnect {
    [[NSNotificationCenter defaultCenter] postNotificationName:GCControllerDidDisconnectNotification object:self];
}

- (void)didEnterValveMode {
    [[NSNotificationCenter defaultCenter] postNotificationName:GCControllerDidConnectNotification object:self];
}

- (void)didReceiveInput:(NSData*)data {
    const uint8_t *bytes = data.bytes;
    
    if (memcmp(bytes, "\xc0\x04\x00\x00", 4) == 0 || memcmp(bytes, "\xc0\x05\x55\x02", 4) == 0) return;
    //printf("%s\n", data.description.UTF8String);
    
    // Parse update
    uint8_t b1 = bytes[1], b2 = bytes[2];
    BOOL hasButtons = b1 & 0x10;
    BOOL hasTriggers = b1 & 0x20;
    BOOL hasStick = b1 & 0x80;
    BOOL hasLeftTrackpad = b2 & 0x01;
    BOOL hasRightTrackpad = b2 & 0x02;
    
    // Update internal state
    const uint8_t *buf = bytes + 3;
    uint32_t previousButtons = state.buttons;
    if (hasButtons) {
        state.buttons = OSReadBigInt32(buf, -1) & 0xffffff;
        buf += 3;
    }
    
    if (hasTriggers) {
        state.leftTrigger = buf[0];
        state.rightTrigger = buf[1];
        buf += 2;
    }
    
    if (hasStick) {
        state.stick.x = OSReadLittleInt16(buf, 0);
        state.stick.y = OSReadLittleInt16(buf, 2);
        buf += 4;
    }
    
    if (hasLeftTrackpad) {
        state.leftPad.x = OSReadLittleInt16(buf, 0);
        state.leftPad.y = OSReadLittleInt16(buf, 2);
        buf += 4;
    }
    
    if (hasRightTrackpad) {
        state.rightPad.x = OSReadLittleInt16(buf, 0);
        state.rightPad.y = OSReadLittleInt16(buf, 2);
        buf += 4;
    }
    
    // Update extended gamepad state
    SteamControllerExtendedGamepadSnapshotData snapshot = extendedGamepad.state;
#define ButtonToFloat(b) ((state.buttons & b) ? 1.0 : 0.0)
#define ButtonToBool(b) ((state.buttons & b) ? YES : NO)
    snapshot.buttonA = ButtonToFloat(SteamControllerButtonA);
    snapshot.buttonB = ButtonToFloat(SteamControllerButtonB);
    snapshot.buttonX = ButtonToFloat(SteamControllerButtonX);
    snapshot.buttonY = ButtonToFloat(SteamControllerButtonY);
    snapshot.leftShoulder = ButtonToFloat(SteamControllerButtonLeftBumper);
    snapshot.rightShoulder = ButtonToFloat(SteamControllerButtonRightBumper);
    snapshot.leftTrigger = (state.buttons & SteamControllerButtonLeftTrigger) ? 1.0 : state.leftTrigger / 255.0;
    snapshot.rightTrigger = (state.buttons & SteamControllerButtonRightTrigger) ? 1.0 : state.rightTrigger / 255.0;
    snapshot.leftThumbstickButton = (state.buttons & SteamControllerButtonLeftGrip);
    snapshot.rightThumbstickButton = (state.buttons & SteamControllerButtonRightGrip);
    
    BOOL hasUpdatedPads[] = {
        [SteamControllerMappingDPad] = NO,
        [SteamControllerMappingLeftThumbstick] = NO,
        [SteamControllerMappingRightThumbstick] = NO
    };
    
    if (_steamLeftTrackpadRequiresClick) {
        if ((state.buttons & SteamControllerButtonLeftTrackpadClick)) {
            UpdateStatePad(&snapshot, _steamLeftTrackpadMapping, S16ToFloat(state.leftPad.x), S16ToFloat(state.leftPad.y), (state.buttons & SteamControllerButtonLeftGrip));
            hasUpdatedPads[_steamLeftTrackpadMapping] = state.leftPad.x || state.leftPad.y;
        } else {
            UpdateStatePad(&snapshot, _steamLeftTrackpadMapping, 0.0, 0.0, (state.buttons & SteamControllerButtonLeftGrip));
        }
    } else {
        UpdateStatePad(&snapshot, _steamLeftTrackpadMapping, S16ToFloat(state.leftPad.x), S16ToFloat(state.leftPad.y), (state.buttons & (SteamControllerButtonLeftTrackpadClick)));
        hasUpdatedPads[_steamLeftTrackpadMapping] = state.leftPad.x || state.leftPad.y;
    }

    if (_steamRightTrackpadRequiresClick) {
        if ((state.buttons & SteamControllerButtonRightTrackpadClick)) {
            UpdateStatePad(&snapshot, _steamRightTrackpadMapping, S16ToFloat(state.rightPad.x), S16ToFloat(state.rightPad.y), (state.buttons & SteamControllerButtonRightGrip));
            hasUpdatedPads[_steamRightTrackpadMapping] |= state.rightPad.x || state.rightPad.y;
        } else {
            UpdateStatePad(&snapshot, _steamRightTrackpadMapping, 0.0, 0.0, (state.buttons & SteamControllerButtonRightGrip));
        }
    } else {
        UpdateStatePad(&snapshot, _steamRightTrackpadMapping, S16ToFloat(state.rightPad.x), S16ToFloat(state.rightPad.y), (state.buttons & (SteamControllerButtonRightTrackpadClick)));
        hasUpdatedPads[_steamRightTrackpadMapping] |= state.rightPad.x || state.rightPad.y;
    }

    if (_steamThumbstickMapping && !hasUpdatedPads[_steamThumbstickMapping]) {
        UpdateStatePad(&snapshot, _steamThumbstickMapping, S16ToFloat(state.stick.x), S16ToFloat(state.stick.y), (state.buttons & SteamControllerButtonStick));
        hasUpdatedPads[_steamThumbstickMapping] = state.stick.x || state.stick.y;
    }
    
    // Ensure grip buttons override thumbstick button state
    snapshot.leftThumbstickButton |= (state.buttons & SteamControllerButtonLeftGrip);
    snapshot.rightThumbstickButton |= (state.buttons & SteamControllerButtonRightGrip);
    
    if (hasButtons) {
        // TEMP: Test feeding full MFi+ combos (used in Provenance app) in single button click
        // Feed MFi+ [Start] via auto-combo (Temporary PoC)
        if (state.buttons & SteamControllerButtonForward) {
            snapshot.leftShoulder = YES;
            snapshot.rightShoulder = YES;
            snapshot.leftTrigger = 1.0;
            snapshot.rightTrigger = 1.0;
            snapshot.buttonX = YES;
        }
        
        // Feed MFi+ [Select] via auto-combo (Temporary PoC)
        if (state.buttons & SteamControllerButtonBack) {
            snapshot.leftShoulder = YES;
            snapshot.rightShoulder = YES;
            snapshot.leftTrigger = 1.0;
            snapshot.rightTrigger = 1.0;
            snapshot.dpadX = 1.0;
        } else if (!hasUpdatedPads[SteamControllerMappingDPad]) {
            snapshot.dpadX = 0.0;
        }
    }

    if (hasButtons && (state.buttons & SteamControllerButtonSteam)) {
        // Handle steam button combos
        handledSteamCombos |= [self handleSteamButtonCombos:(state.buttons & ~SteamControllerButtonSteam)];
    } else if (hasButtons && (previousButtons & SteamControllerButtonSteam)) {
        // Released steam button
        if (handledSteamCombos) {
            [self handleSteamButtonCombos:0];
            handledSteamCombos = NO;
            // Update client
            extendedGamepad.state = snapshot;
        } else if (controllerPausedHandler) {
            controllerPausedHandler(self);
        }
    } else if (!(state.buttons & SteamControllerButtonSteam)) {
        // Update client
        extendedGamepad.state = snapshot;
    }
}

- (BOOL)handleSteamButtonCombos:(uint32_t)buttons {
    uint32_t changes = buttons ^ currentSteamCombos;
    if (changes == 0 || _steamButtonCombinationHandler == nil) {
        return NO;
    }
    for (uint32_t mask = 0x800000; mask; mask >>= 1) {
        if (changes & mask) {
            _steamButtonCombinationHandler(self, mask, buttons & mask);
        }
    }
    currentSteamCombos = buttons;
    return YES;
}

#pragma mark - Operations

- (void)identify {
    [self playTune:4];
}

- (void)playTune:(uint8_t)tune {
    char command[] = "\xC0\xB6\x04\x04\x00\x00\x00";
    command[3] = (tune & 0xf);
    [_peripheral writeValue:[NSData dataWithBytes:command length:7] forCharacteristic:reportCharacteristic type:CBCharacteristicWriteWithResponse];
}

@end

NSString* NSStringFromSteamControllerButton(SteamControllerButton button) {
    switch (button) {
        case SteamControllerButtonRightGrip:
            return @"Right Grip";
        case SteamControllerButtonLeftTrackpadClick:
            return @"Left Trackpad Click";
        case SteamControllerButtonRightTrackpadClick:
            return @"Right Trackpad Click";
        case SteamControllerButtonLeftTrackpadTouch:
            return @"Left Trackpad Touch";
        case SteamControllerButtonRightTrackpadTouch:
            return @"Right Trackpad Touch";
        case SteamControllerButtonStick:
            return @"Stick Click";
        case SteamControllerButtonLeftTrackpadClickUp:
            return @"Left Trackpad Click Up";
        case SteamControllerButtonLeftTrackpadClickRight:
            return @"Left Trackpad Click Right";
        case SteamControllerButtonLeftTrackpadClickLeft:
            return @"Left Trackpad Click Left";
        case SteamControllerButtonLeftTrackpadClickDown:
            return @"LeftTrackpad Click Down";
        case SteamControllerButtonBack:
            return @"Back";
        case SteamControllerButtonSteam:
            return @"Steam";
        case SteamControllerButtonForward:
            return @"Forward";
        case SteamControllerButtonLeftGrip:
            return @"Left Grip";
        case SteamControllerButtonRightTrigger:
            return @"Right Trigger";
        case SteamControllerButtonLeftTrigger:
            return @"Left Trigger";
        case SteamControllerButtonRightBumper:
            return @"Right Bumper";
        case SteamControllerButtonLeftBumper:
            return @"Left Bumper";
        case SteamControllerButtonA:
            return @"A";
        case SteamControllerButtonB:
            return @"B";
        case SteamControllerButtonX:
            return @"X";
        case SteamControllerButtonY:
            return @"Y";
        default:
            return [NSString stringWithFormat:@"%06x", button & 0xffffff];
    }
}

