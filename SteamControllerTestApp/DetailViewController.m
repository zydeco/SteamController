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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _controllerCell.controller = _steamController;
    _leftTrackpadMapping.selectedSegmentIndex = _steamController.steamLeftTrackpadMapping;
    _leftTrackpadRequiresClick.on = _steamController.steamLeftTrackpadRequiresClick;
    _rightTrackpadMapping.selectedSegmentIndex = _steamController.steamRightTrackpadMapping;
    _rightTrackpadRequiresClick.on = _steamController.steamRightTrackpadRequiresClick;
    _stickMapping.selectedSegmentIndex = _steamController.steamThumbstickMapping;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    _controllerCell.controller = nil;
}

- (IBAction)identifyController:(id)sender {
    [self.steamController identify];
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
