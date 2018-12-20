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

@import GameController;

@interface TableViewController ()

@end

@implementation TableViewController
{
    NSMutableArray<SteamController*> *controllers;
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
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:GCControllerDidConnectNotification object:nil];
    [nc removeObserver:self name:GCControllerDidDisconnectNotification object:nil];
}

- (void)scanForControllers:(id)sender {
    [[SteamControllerManager sharedManager] scanForControllers];
}

- (void)didConnectController:(NSNotification*)notification {
    SteamController *controller = notification.object;
    [controllers addObject:controller];
    NSUInteger row = controllers.count - 1;
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)didDisconnectController:(NSNotification*)notification {
    SteamController *controller = notification.object;
    NSUInteger row = [controllers indexOfObject:controller];
    if (row != NSNotFound) {
        [controllers removeObjectAtIndex:row];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return controllers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ControllerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"controller" forIndexPath:indexPath];
    SteamController *controller = controllers[indexPath.row];
    cell.controller = controller;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SteamController *controller = controllers[indexPath.row];
    [controller identify];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
