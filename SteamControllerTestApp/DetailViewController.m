//
//  DetailViewController.m
//  SteamControllerTestApp
//
//  Created by Jesús A. Álvarez on 02/02/2019.
//  Copyright © 2019 namedfork. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Identify" style:UIBarButtonItemStylePlain target:self action:@selector(identifyController:)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _controllerCell.controller = _steamController;
    [_steamController addObserver:self forKeyPath:@"steamLeftTrackpadMapping" options:0 context:NULL];
    [_steamController addObserver:self forKeyPath:@"steamRightTrackpadMapping" options:0 context:NULL];
    [_steamController addObserver:self forKeyPath:@"steamThumbstickMapping" options:0 context:NULL];
    [_steamController addObserver:self forKeyPath:@"steamLeftTrackpadRequiresClick" options:0 context:NULL];
    [_steamController addObserver:self forKeyPath:@"steamRightTrackpadRequiresClick" options:0 context:NULL];
    [_steamController addObserver:self forKeyPath:@"batteryLevel" options:0 context:NULL];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(didDisconnectController:) name:GCControllerDidDisconnectNotification object:_steamController];
    [self updateSettingsDisplay];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_steamController removeObserver:self forKeyPath:@"steamLeftTrackpadMapping"];
    [_steamController removeObserver:self forKeyPath:@"steamRightTrackpadMapping"];
    [_steamController removeObserver:self forKeyPath:@"steamThumbstickMapping"];
    [_steamController removeObserver:self forKeyPath:@"steamLeftTrackpadRequiresClick"];
    [_steamController removeObserver:self forKeyPath:@"steamRightTrackpadRequiresClick"];
    [_steamController removeObserver:self forKeyPath:@"batteryLevel"];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:GCControllerDidDisconnectNotification object:_steamController];
    _controllerCell.controller = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == _steamController) {
        [self updateSettingsDisplay];
    }
}

- (void)didDisconnectController:(NSNotification*)notification {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)identifyController:(id)sender {
    [self.steamController identify];
}

- (void)updateSettingsDisplay {
    _leftTrackpadMapping.selectedSegmentIndex = _steamController.steamLeftTrackpadMapping;
    _leftTrackpadRequiresClick.on = _steamController.steamLeftTrackpadRequiresClick;
    _rightTrackpadMapping.selectedSegmentIndex = _steamController.steamRightTrackpadMapping;
    _rightTrackpadRequiresClick.on = _steamController.steamRightTrackpadRequiresClick;
    _stickMapping.selectedSegmentIndex = _steamController.steamThumbstickMapping;
    int percent = _steamController.batteryLevel * 100;
    int millivolts = _steamController.batteryLevel * 3000.0;
    _batteryLevelCell.detailTextLabel.text = [NSString stringWithFormat:@"%d%% (%d mV)", percent, millivolts];
}

- (IBAction)updateSetting:(id)sender {
    if (sender == _leftTrackpadMapping) {
        _steamController.steamLeftTrackpadMapping = _leftTrackpadMapping.selectedSegmentIndex;
    } else if (sender == _rightTrackpadMapping) {
        _steamController.steamRightTrackpadMapping = _rightTrackpadMapping.selectedSegmentIndex;
    } else if (sender == _stickMapping) {
        _steamController.steamThumbstickMapping = _stickMapping.selectedSegmentIndex;
    } else if (sender == _leftTrackpadRequiresClick) {
        _steamController.steamLeftTrackpadRequiresClick = _leftTrackpadRequiresClick.on;
    } else if (sender == _rightTrackpadRequiresClick) {
        _steamController.steamRightTrackpadRequiresClick = _rightTrackpadRequiresClick.on;
    }
}

@end
