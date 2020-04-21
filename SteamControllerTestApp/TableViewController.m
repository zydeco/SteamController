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
    [nc removeObserver:self name:GCControllerDidConnectNotification object:nil];
    [nc removeObserver:self name:GCControllerDidDisconnectNotification object:nil];
}

- (void)scanForControllers:(id)sender {
    [GCController startWirelessControllerDiscoveryWithCompletionHandler:nil];
    [[SteamControllerManager sharedManager] scanForControllers];
}

- (void)didConnectController:(NSNotification*)notification {
    GCController *controller = notification.object;
    if ([controller isKindOfClass:[GCController class]] && ![controllers containsObject:controller]) {
        [controllers addObject:controller];
        [self.tableView reloadData];
    }
}

- (void)didDisconnectController:(NSNotification*)notification {
    GCController *controller = notification.object;
    if ([controller isKindOfClass:[GCController class]] && [controllers containsObject:controller]) {
        [controllers removeObject:controller];
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
