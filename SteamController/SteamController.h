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

NS_ASSUME_NONNULL_BEGIN

@interface SteamController : GCController

@property (nonatomic, readonly, retain) CBPeripheral *peripheral;

- (instancetype)initWithPeripheral:(CBPeripheral*)peripheral NS_DESIGNATED_INITIALIZER;

/** Plays the identify tune on the controller. */
- (void)identify;

@end

NS_ASSUME_NONNULL_END


