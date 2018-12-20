//
//  SteamController.h
//  SteamController
//
//  Created by Jesús A. Álvarez on 20/12/2018.
//  Copyright © 2018 namedfork. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for SteamController.
FOUNDATION_EXPORT double SteamControllerVersionNumber;

//! Project version string for SteamController.
FOUNDATION_EXPORT const unsigned char SteamControllerVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <SteamController/PublicHeader.h>
#import <SteamController/SteamControllerManager.h>

@import GameController;

@class CBPeripheral;

NS_ASSUME_NONNULL_BEGIN

@interface SteamController : GCController

@property (nonatomic, readonly, retain) CBPeripheral *peripheral;

- (instancetype)initWithPeripheral:(CBPeripheral*)peripheral NS_DESIGNATED_INITIALIZER;

/** Plays the identify tune on the controller. */
- (void)identify;

@end

NS_ASSUME_NONNULL_END


