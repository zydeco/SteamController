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

@interface SteamControllerManager : NSObject

@property (nonatomic, readonly) NSArray<SteamController*> *controllers;

+ (instancetype)sharedManager;

/** Scans for steam controllers in bluetooth mode */
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
