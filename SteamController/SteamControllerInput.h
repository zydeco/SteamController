//
//  SteamControllerInput.h
//  SteamController
//
//  Created by Jesús A. Álvarez on 18/12/2018.
//  Copyright © 2018 namedfork. All rights reserved.
//

#import <GameController/GameController.h>

@class SteamControllerDirectionPad;

NS_ASSUME_NONNULL_BEGIN

@interface SteamControllerButtonInput : GCControllerButtonInput

- (instancetype)initWithDirectionPad:(SteamControllerDirectionPad*)dpad;
- (void)setValue:(float)value;

@end

@interface SteamControllerAxisInput : GCControllerAxisInput

- (instancetype)initWithDirectionPad:(SteamControllerDirectionPad*)dpad;
- (void)setValue:(float)value;

@end

@interface SteamControllerDirectionPad : GCControllerDirectionPad

@property (nonatomic, readonly) SteamControllerAxisInput *xAxis;
@property (nonatomic, readonly) SteamControllerAxisInput *yAxis;

@property (nonatomic, readonly) SteamControllerButtonInput *up;
@property (nonatomic, readonly) SteamControllerButtonInput *down;
@property (nonatomic, readonly) SteamControllerButtonInput *left;
@property (nonatomic, readonly) SteamControllerButtonInput *right;

- (void)setX:(float)x Y:(float)y;

@end



NS_ASSUME_NONNULL_END
