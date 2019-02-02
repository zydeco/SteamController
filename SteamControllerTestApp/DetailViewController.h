//
//  DetailViewController.h
//  SteamControllerTestApp
//
//  Created by Jesús A. Álvarez on 02/02/2019.
//  Copyright © 2019 namedfork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SteamController/SteamController.h>
#import "ControllerTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface DetailViewController : UITableViewController

@property (nonatomic, weak) SteamController *steamController;
@property (nonatomic, weak) IBOutlet ControllerTableViewCell *controllerCell;
@property (nonatomic, weak) IBOutlet UISegmentedControl *leftTrackpadMapping, *rightTrackpadMapping, *stickMapping;
@property (nonatomic, weak) IBOutlet UISwitch *leftTrackpadRequiresClick, *rightTrackpadRequiresClick;

@end

NS_ASSUME_NONNULL_END
