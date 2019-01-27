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
+ (BOOL)listenForConnections;

/** Scans for steam controllers in bluetooth mode */
- (void)scanForControllers;

@end

NS_ASSUME_NONNULL_END
