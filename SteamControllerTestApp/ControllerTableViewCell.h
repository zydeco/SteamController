//
//  ControllerTableViewCell.h
//  SteamController
//
//  Created by Jesús A. Álvarez on 19/12/2018.
//  Copyright © 2018 namedfork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameController/GameController.h>

@class XYView;

NS_ASSUME_NONNULL_BEGIN

@interface ControllerTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet XYView *leftTrackpadView, *rightTrackpadView, *dpadView;
@property (nonatomic, weak) IBOutlet UIButton *leftShoulder, *leftTrigger, *rightShoulder, *rightTrigger;
@property (nonatomic, weak) IBOutlet UIButton *buttonA, *buttonB, *buttonX, *buttonY, *pauseButton;
@property (nonatomic, weak) IBOutlet UIButton *backButton, *forwardButton;
@property (nonatomic, retain, nullable) GCController *controller;

@end

NS_ASSUME_NONNULL_END
