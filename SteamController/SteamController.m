//
//  SteamController.m
//  SteamController
//
//  Created by Jesús A. Álvarez on 16/12/2018.
//  Copyright © 2018 namedfork. All rights reserved.
//

#import "SteamController.h"
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

static void UpdateStatePad(GCExtendedGamepadSnapShotDataV100* state, SteamControllerMapping pad, float x, float y) {
    switch (pad) {
        case SteamControllerMappingLeftThumbstick:
            state->leftThumbstickX = x;
            state->leftThumbstickY = y;
            break;
        case SteamControllerMappingRightThumbstick:
            state->rightThumbstickX = x;
            state->rightThumbstickY = y;
            break;
        case SteamControllerMappingDPad:
            state->dpadX = x;
            state->dpadY = y;
        default:
            break;
    }
}

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
    BOOL enteringValveMode;
    uint32_t buttons;
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
        _steamLeftTrackpadMapping = SteamControllerMappingLeftThumbstick;
        _steamRightTrackpadMapping = SteamControllerMappingRightThumbstick;
        _steamThumbstickMapping = SteamControllerMappingDPad;
        _steamLeftTrackpadRequiresClick = YES;
        _steamRightTrackpadRequiresClick = YES;
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
    
    // What does the packet contain?
    uint8_t b1 = bytes[1], b2 = bytes[2];
    BOOL hasButtons = b1 & 0x10;
    BOOL hasTriggers = b1 & 0x20;
    BOOL hasStick = b1 & 0x80;
    BOOL hasLeftTrackpad = b2 & 0x01;
    BOOL hasRightTrackpad = b2 & 0x02;
    
    // Parse fields
    GCExtendedGamepadSnapShotDataV100 state = extendedGamepad.state;
    const uint8_t *buf = bytes + 3;
    if (hasButtons) {
        buttons = OSReadBigInt32(buf, -1) & 0xffffff;
#define ButtonToFloat(b) ((buttons & b) ? 1.0 : 0.0)
#define ButtonToBool(b) ((buttons & b) ? YES : NO)
        state.buttonA = ButtonToFloat(BUTTON_A);
        state.buttonB = ButtonToFloat(BUTTON_B);
        state.buttonX = ButtonToFloat(BUTTON_X);
        state.buttonY = ButtonToFloat(BUTTON_Y);
        state.leftShoulder = ButtonToFloat(BUTTON_LEFT_BUMPER);
        state.rightShoulder = ButtonToFloat(BUTTON_RIGHT_BUMPER);
    
        // TEMP: Test Mapping Start to prefeed MFi+ combo (used in Provenance)
        // TODO: handlers/protocol for extended buttons…
        
        if (hasTriggers) {
            if (buttons & BUTTON_LEFT_TRIGGER) state.leftTrigger = 1.0;
            if (buttons & BUTTON_RIGHT_TRIGGER) state.rightTrigger = 1.0;
        } else {
            state.leftTrigger = ButtonToFloat(BUTTON_LEFT_TRIGGER);
            state.rightTrigger = ButtonToFloat(BUTTON_RIGHT_TRIGGER);
        }
        
        // Toggle Trackpad Modes
        
        if ((buttons & BUTTON_BACK) && (buttons & BUTTON_LEFT_TRACKPAD_CLICK)) {
            _steamLeftTrackpadRequiresClick = !_steamLeftTrackpadRequiresClick;
        }
            
        if ((buttons & BUTTON_FORWARD) && (buttons & BUTTON_RIGHT_TRACKPAD_CLICK)) {
            _steamRightTrackpadRequiresClick = !_steamRightTrackpadRequiresClick;
        }
        
        // Feed MFi+ [Start] via auto-combo
        
        if ((buttons & BUTTON_FORWARD) && !(buttons & BUTTON_RIGHT_TRACKPAD_CLICK)) {
            state.leftShoulder = YES;
            state.rightShoulder = YES;
            state.leftTrigger = 1.0;
            state.rightTrigger = 1.0;
            state.buttonX = YES;
        }
        
        // Feed MFi+ [Select] via auto-combo
        
        if ((buttons & BUTTON_BACK) && !(buttons & BUTTON_LEFT_TRACKPAD_CLICK)) {
            state.leftShoulder = YES;
            state.rightShoulder = YES;
            state.leftTrigger = 1.0;
            state.rightTrigger = 1.0;
            state.dpadX = 1.0;
        } else if (!(buttons & BUTTON_LEFT_TRACKPAD_CLICK_LEFT) && !(buttons & BUTTON_LEFT_TRACKPAD_CLICK_RIGHT)) {
            state.dpadX = 0.0;
        }
        
        if ((buttons & BUTTON_STEAM) && controllerPausedHandler) {
            controllerPausedHandler(self);
        }
        // TODO: get iOS 12.1 SDK
//        newState.leftThumbstickButton = ButtonToBool(BUTTON_LEFT_TRACKPAD_CLICK);
//        newState.rightThumbstickButton = ButtonToBool(BUTTON_RIGHT_TRACKPAD_CLICK);
        buf += 3;
    }
    
    if (hasTriggers) {
        uint8_t leftTrigger = buf[0];
        uint8_t rightTrigger = buf[1];
        state.leftTrigger = leftTrigger / 255.0;
        state.rightTrigger = rightTrigger / 255.0;
        buf += 2;
    }
    
    if (hasStick) {
        int16_t sx = OSReadLittleInt16(buf, 0);
        int16_t sy = OSReadLittleInt16(buf, 2);
        UpdateStatePad(&state, _steamThumbstickMapping, S16ToFloat(sx), S16ToFloat(sy));
        buf += 4;
    }

    if (hasLeftTrackpad) {
        int16_t tx = OSReadLittleInt16(buf, 0);
        int16_t ty = OSReadLittleInt16(buf, 2);
        if (_steamLeftTrackpadRequiresClick) {
            if (buttons & BUTTON_LEFT_TRACKPAD_CLICK) {
                UpdateStatePad(&state, _steamLeftTrackpadMapping, S16ToFloat(tx), S16ToFloat(ty));
            } else {
                UpdateStatePad(&state, _steamLeftTrackpadMapping, 0.0, 0.0);
            }
        } else {
            UpdateStatePad(&state, _steamLeftTrackpadMapping, S16ToFloat(tx), S16ToFloat(ty));
        }
        buf += 4;
    } else if (_steamLeftTrackpadRequiresClick) {
        UpdateStatePad(&state, _steamLeftTrackpadMapping, 0.0, 0.0);
    }
    
    if (hasRightTrackpad) {
        int16_t tx = OSReadLittleInt16(buf, 0);
        int16_t ty = OSReadLittleInt16(buf, 2);
        if (_steamRightTrackpadRequiresClick) {
            if (buttons & BUTTON_RIGHT_TRACKPAD_CLICK) {
                UpdateStatePad(&state, _steamRightTrackpadMapping, S16ToFloat(tx), S16ToFloat(ty));
            } else {
                UpdateStatePad(&state, _steamRightTrackpadMapping, 0.0, 0.0);
            }
        } else {
            UpdateStatePad(&state, _steamRightTrackpadMapping, S16ToFloat(tx), S16ToFloat(ty));
        }
        buf += 4;
    } else if (_steamRightTrackpadRequiresClick) {
        UpdateStatePad(&state, _steamRightTrackpadMapping, 0.0, 0.0);
    }
    
    extendedGamepad.state = state;
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
