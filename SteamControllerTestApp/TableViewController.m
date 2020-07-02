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
    NSMutableArray<GCController*> *controllers;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Scan" style:UIBarButtonItemStylePlain target:self action:@selector(scanForControllers:)];
    controllers = [NSMutableArray arrayWithCapacity:1];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(didConnectController:) name:GCControllerDidConnectNotification object:nil];
    [nc addObserver:self selector:@selector(didDisconnectController:) name:GCControllerDidDisconnectNotification object:nil];

    if (@available(iOS 14.0, *)) {
        [nc addObserver:self selector:@selector(controllerDidBecomeCurrent:) name:GCControllerDidBecomeCurrentNotification object:nil];
        [nc addObserver:self selector:@selector(controllerDidBecomeNonCurrent:) name:GCControllerDidStopBeingCurrentNotification object:nil];
        
        [nc addObserver:self selector:@selector(didConnectKeyboard:) name:GCKeyboardDidConnectNotification object:nil];
        [nc addObserver:self selector:@selector(didDisconnectKeyboard:) name:GCKeyboardDidDisconnectNotification object:nil];

        [nc addObserver:self selector:@selector(didConnectMouse:) name:GCMouseDidConnectNotification object:nil];
        [nc addObserver:self selector:@selector(didDisconnectMouse:) name:GCMouseDidDisconnectNotification object:nil];
        
        [nc addObserver:self selector:@selector(mouseDidBecomeCurrent:) name:GCMouseDidBecomeCurrentNotification object:nil];
        [nc addObserver:self selector:@selector(mouseDidBecomeNonCurrent:) name:GCMouseDidStopBeingCurrentNotification object:nil];
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

#pragma mark - controller connect/disconect

- (void)didConnectController:(NSNotification*)notification {
    GCController *controller = notification.object;
    if ([controller isKindOfClass:[GCController class]] && ![controllers containsObject:controller]) {
        NSLog(@"CONTROLER DID CONNECT: %@", controller);
        [controllers addObject:controller];
        [self.tableView reloadData];
    }
}

- (void)didDisconnectController:(NSNotification*)notification {
    GCController *controller = notification.object;
    if ([controller isKindOfClass:[GCController class]] && [controllers containsObject:controller]) {
        NSLog(@"CONTROLER DID DIS-CONNECT: %@", controller);
        [controllers removeObject:controller];
        [self.tableView reloadData];
    }
}

#pragma mark - controller become current

- (void)controllerDidBecomeCurrent:(NSNotification*)notification {
    GCController *controller = notification.object;
    if ([controller isKindOfClass:[GCController class]] && [controllers containsObject:controller]) {
        NSLog(@"CONTROLER DID BECOME CURRENT: %@", controller);
        [self.tableView reloadData];
    }
}

- (void)controllerDidBecomeNonCurrent:(NSNotification*)notification {
    GCController *controller = notification.object;
    if ([controller isKindOfClass:[GCController class]] && [controllers containsObject:controller]) {
        NSLog(@"CONTROLER DID BECOME NON-CURRENT: %@", controller);
        [self.tableView reloadData];
    }
}

#pragma mark - keyboard connect

- (void)didConnectKeyboard:(NSNotification*)notification API_AVAILABLE(ios(14.0)) {
    GCKeyboard *keyboard = notification.object;
    if ([keyboard isKindOfClass:[GCKeyboard class]] && ![controllers containsObject:keyboard]) {
        NSLog(@"KEYBOARD DID CONNECT: %@", keyboard);
        //[controllers addObject:controller];
        [self.tableView reloadData];
    }
}

- (void)didDisconnectKeyboard:(NSNotification*)notification  API_AVAILABLE(ios(14.0)) {
    GCKeyboard *keyboard = notification.object;
    if ([keyboard isKindOfClass:[GCKeyboard class]] && [controllers containsObject:keyboard]) {
        NSLog(@"KEYBOARD DID DIS-CONNECT: %@", keyboard);
        //[controllers removeObject:keyboard];
        [self.tableView reloadData];
    }
}

#pragma mark - mouse connect

- (void)didConnectMouse:(NSNotification*)notification API_AVAILABLE(ios(14.0)) {
    GCMouse *mouse = notification.object;
    if ([mouse isKindOfClass:[GCMouse class]] && ![controllers containsObject:mouse]) {
        NSLog(@"MOUSE DID CONNECT: %@", mouse);
        //[controllers addObject:mouse];
        [self.tableView reloadData];
    }
}

- (void)didDisconnectMouse:(NSNotification*)notification API_AVAILABLE(ios(14.0)) {
    GCMouse *mouse = notification.object;
    if ([mouse isKindOfClass:[GCMouse class]] && [controllers containsObject:mouse]) {
        NSLog(@"MOUSE DID DIS-CONNECT: %@", mouse);
        //[controllers removeObject:mouse];
        [self.tableView reloadData];
    }
}

- (void)mouseDidBecomeCurrent:(NSNotification*)notification API_AVAILABLE(ios(14.0))  {
    GCMouse *mouse = notification.object;
    if ([mouse isKindOfClass:[GCController class]] && [controllers containsObject:mouse]) {
        NSLog(@"MOUSE DID BECOME CURRENT: %@", mouse);
        [self.tableView reloadData];
    }
}

- (void)mouseDidBecomeNonCurrent:(NSNotification*)notification API_AVAILABLE(ios(14.0)) {
    GCMouse *mouse = notification.object;
    if ([mouse isKindOfClass:[GCMouse class]] && [controllers containsObject:mouse]) {
        NSLog(@"MOUSE DID BECOME NON-CURRENT: %@", mouse);
        [self.tableView reloadData];
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
    ControllerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"controller" forIndexPath:indexPath];
    GCController *controller = controllers[indexPath.section];
    cell.controller = controller;
    
    if (@available(iOS 14.0, *))
        cell.selected = GCController.current == controller;
    
    return cell;
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
