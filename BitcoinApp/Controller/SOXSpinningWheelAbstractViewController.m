//
//  SOXSpinningWheelAbstractViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 05.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXSpinningWheelAbstractViewController.h"

@interface SOXSpinningWheelAbstractViewController ()

@property (weak) IBOutlet NSView *spinningBackgroundView;
@property (weak) IBOutlet NSProgressIndicator *circularProgressIndicator;

@end

@implementation SOXSpinningWheelAbstractViewController

- (void)viewWillAppear {
    [super viewWillAppear];
    self.spinningBackgroundView.hidden = YES;
    self.spinningBackgroundView.layer.backgroundColor = [NSColor colorWithCalibratedRed:0
                                                                                  green:0
                                                                                   blue:0
                                                                                  alpha:0.1].CGColor;
}

- (void)enableSpinningWheel {
    self.spinningBackgroundView.hidden = NO;
    [self.circularProgressIndicator startAnimation:nil];
}

- (void)disableSpinningWheel {
    self.spinningBackgroundView.hidden = YES;
    [self.circularProgressIndicator stopAnimation:nil];
}

@end
