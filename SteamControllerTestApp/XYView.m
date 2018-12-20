//
//  XYView.m
//  SteamController
//
//  Created by Jesús A. Álvarez on 19/12/2018.
//  Copyright © 2018 namedfork. All rights reserved.
//

#import "XYView.h"

@implementation XYView
{
    UIView *indicator;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    indicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, 6)];
    indicator.layer.masksToBounds = YES;
    indicator.layer.cornerRadius = 3.0;
    indicator.backgroundColor = [UIColor redColor];
    [self addSubview:indicator];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setX:0.0 Y:0.0];
}

- (void)setX:(float)xValue Y:(float)yValue {
    CGRect bounds = self.bounds;
    [indicator setCenter:CGPointMake(xValue * (bounds.size.width / 2.0) + (bounds.size.width / 2.0), yValue * (bounds.size.height / -2.0) + (bounds.size.height / 2.0))];
}

@end
