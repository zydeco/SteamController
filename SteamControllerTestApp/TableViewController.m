//
//  TableViewController.m
//  SteamController
//
//  Created by Jesús A. Álvarez on 19/12/2018.
//  Copyright © 2018 namedfork. All rights reserved.
//

#import "TableViewController.h"
#import "SteamControllerManager.h"
#import "SteamController.h"
#import "ControllerTableViewCell.h"
#import "DetailViewController.h"

@import GameController;

@interface TableViewController ()

@end

@implementation TableViewController
{
    NSMutableArray* controllers;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Scan" style:UIBarButtonItemStylePlain target:self action:@selector(scanForControllers:)];
    controllers = [NSMutableArray arrayWithCapacity:1];
}

- (void)reloadData {
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(didConnectDevice:) name:GCControllerDidConnectNotification object:nil];
    [nc addObserver:self selector:@selector(didDisconnectDevice:) name:GCControllerDidDisconnectNotification object:nil];

    if (@available(iOS 14.0, *)) {
        [nc addObserver:self selector:@selector(didConnectDevice:) name:GCKeyboardDidConnectNotification object:nil];
        [nc addObserver:self selector:@selector(didDisconnectDevice:) name:GCKeyboardDidDisconnectNotification object:nil];

        [nc addObserver:self selector:@selector(didConnectDevice:) name:GCMouseDidConnectNotification object:nil];
        [nc addObserver:self selector:@selector(didDisconnectDevice:) name:GCMouseDidDisconnectNotification object:nil];

        [nc addObserver:self selector:@selector(deviceDidBecomeCurrent:) name:GCControllerDidBecomeCurrentNotification object:nil];
        [nc addObserver:self selector:@selector(deviceDidBecomeNonCurrent:) name:GCControllerDidStopBeingCurrentNotification object:nil];

        [nc addObserver:self selector:@selector(deviceDidBecomeCurrent:) name:GCMouseDidBecomeCurrentNotification object:nil];
        [nc addObserver:self selector:@selector(deviceDidBecomeNonCurrent:) name:GCMouseDidStopBeingCurrentNotification object:nil];
    }

#ifdef STEAMCONTROLLER_NO_PRIVATE_API
    [self scanForControllers:self];
#endif

#ifndef STEAMCONTROLLER_NO_SWIZZLING
    // get all controllers (steam, MFi) with a call to GCController
    controllers = GCController.controllers.mutableCopy;
#else
    // need to call both SteamControllerManager and GCController
    controllers = GCController.controllers.mutableCopy;
    [controllers addObjectsFromArray:SteamControllerManager.sharedManager.controllers];
#endif
    if (@available(iOS 14.0, *)) {
        for (GCMouse* mouse in GCMouse.mice) {
            [controllers addObject:mouse];
        }
        for (GCKeyboard* keyboard in @[GCKeyboard.coalescedKeyboard]) {
            [controllers addObject:keyboard];
        }
    }
    [self.tableView reloadData];

    if (controllers.count == 0) {
        [self scanForControllers:self];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:nil object:nil];
}

- (void)scanForControllers:(id)sender {
    [GCController startWirelessControllerDiscoveryWithCompletionHandler:nil];
    [[SteamControllerManager sharedManager] scanForControllers];
}

#pragma mark - device connect/disconect

- (void)didConnectDevice:(NSNotification*)notification {
    NSObject *device = notification.object;
    if (![controllers containsObject:device]) {
        NSLog(@"DEVICE DID CONNECT: %@", device);
        [controllers addObject:device];
        [self.tableView reloadData];
    }
}

- (void)didDisconnectDevice:(NSNotification*)notification {
    NSObject *device = notification.object;
    if ([controllers containsObject:device]) {
        NSLog(@"DEVICE DID DIS-CONNECT: %@", device);
        [controllers removeObject:device];
        [self.tableView reloadData];
    }
}

#pragma mark - device become current

- (void)deviceDidBecomeCurrent:(NSNotification*)notification {
    NSObject *device = notification.object;
    if ([controllers containsObject:device]) {
        NSLog(@"CONTROLER DID BECOME CURRENT: %@", device);
        [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
}

- (void)deviceDidBecomeNonCurrent:(NSNotification*)notification {
    NSObject *device = notification.object;
    if ([controllers containsObject:device]) {
        NSLog(@"DEVICE DID BECOME NON-CURRENT: %@", device);
        [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return controllers.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    GCController *controller = controllers[section];
    
    if (@available(iOS 13.0, *))
        return [NSString stringWithFormat:@"%@ (%@)", controller.vendorName, controller.productCategory];
    else
        return [NSString stringWithFormat:@"%@", controller.vendorName];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSObject *device = controllers[indexPath.section];
    
    if ([device isKindOfClass:[GCController class]]) {
        GCController *controller = (GCController *)device;

        ControllerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"controller" forIndexPath:indexPath];
        cell.controller = controller;

        if (@available(iOS 14.0, *))
            cell.backgroundColor = (GCController.controllers.count > 1 && GCController.current == controller) ? UIColor.orangeColor : UIColor.clearColor;

        return cell;
    }
    
    if (@available(iOS 14.0, *)) {
        if ([device isKindOfClass:[GCMouse class]]) {
            GCMouse *mouse = (GCMouse*)device;
            
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
            cell.textLabel.text = [mouse description];
            
            cell.backgroundColor = (GCMouse.mice.count > 1 && GCMouse.current == mouse) ? UIColor.orangeColor : UIColor.clearColor;

            __weak UITableViewCell* _cell = cell;
            [mouse.mouseInput setMouseMovedHandler:^(GCMouseInput* mouse, float deltaX, float deltaY) {
                _cell.detailTextLabel.text = [NSString stringWithFormat:@"MOVE: %f, %f", deltaX, deltaY];
            }];
            [mouse.mouseInput.leftButton setValueChangedHandler:^(GCControllerButtonInput*  button, float value, BOOL pressed) {
                _cell.detailTextLabel.text = [NSString stringWithFormat:@"LEFT BUTTON: %s", pressed ? "DOWN" : "UP"];
            }];
            [mouse.mouseInput.rightButton setValueChangedHandler:^(GCControllerButtonInput*  button, float value, BOOL pressed) {
                _cell.detailTextLabel.text = [NSString stringWithFormat:@"RIGHT BUTTON: %s", pressed ? "DOWN" : "UP"];
            }];
            [mouse.mouseInput.scroll setValueChangedHandler:^(GCControllerDirectionPad* dpad, float xValue, float yValue) {
                _cell.detailTextLabel.text = [NSString stringWithFormat:@"SCROLL: %f, %f", xValue, yValue];
            }];

            return cell;
        }

        if ([device isKindOfClass:[GCKeyboard class]]) {
            GCKeyboard *keyboard = (GCKeyboard*)device;
            
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
            cell.textLabel.text = [keyboard description];
            
            __weak UITableViewCell* _cell = cell;
            [keyboard.keyboardInput setKeyChangedHandler:^(GCKeyboardInput* keyboard, GCControllerButtonInput* key, GCKeyCode keyCode, BOOL pressed) {
                _cell.detailTextLabel.text = [NSString stringWithFormat:@"Key: %@ (%ld) - %s",key, keyCode, pressed ? "DOWN" : "UP"];
            }];
            
            return cell;
        }
    }

    return nil;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath == nil)
            return FALSE;
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        return [controllers[indexPath.section] isKindOfClass:[SteamController class]];
    }
    return TRUE;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[DetailViewController class]] && [sender isKindOfClass:[UITableViewCell class]]) {
        DetailViewController *detailViewController = (DetailViewController*)segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath != nil && [controllers[indexPath.section] isKindOfClass:[SteamController class]])
            detailViewController.steamController = (SteamController*)controllers[indexPath.section];
    }
}

@end
