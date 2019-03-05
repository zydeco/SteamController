//
//  SteamControllerManager.h
//  SteamController
//
//  Created by Jesús A. Álvarez on 16/12/2018.
//  Copyright © 2018 namedfork. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SteamController;

NS_ASSUME_NONNULL_BEGIN

/**
 `SteamControllerManager` handles the connection and disconnection of Steam Controllers, and inserts connected Steam
 Controllers into the array of controllers returned by `[GCController controllers]`.
 */
@interface SteamControllerManager : NSObject

/** Returns the shared instance of `SteamControllerManager`. */
+ (instancetype)sharedManager;

/**
 Returns the currently connected Steam Controllers. Unless you only want to support Steam Controllers, you should
 use `[GCController controllers]` instead of this property. */
@property (nonatomic, readonly) NSArray<SteamController*> *controllers;

/**
 Detects connected and pairing Steam Controllers.
 If a controller is in pairing mode, this will initiate the pairing process. If it is already paired and connected,
 it will configure it and post a `GCControllerDidConnectNotification` notification when it's ready. */
- (void)scanForControllers;

@end

#ifndef STEAMCONTROLLER_NO_IOKIT
@interface SteamControllerManager (IOKit)

/** Listens for controller connections.
 
 This enables controllers to be detected automatically when they connect/reconnect, without calling `scanForControllers`.
 This feature calls IOKit functions dynamically, which is private API on iOS/tvOS, it can be excluded from the build by
 passing `-DSTEAMCONTROLLER_NO_IOKIT` to the compiler.
 */
+ (BOOL)listenForConnections;
@end
#endif

NS_ASSUME_NONNULL_END
