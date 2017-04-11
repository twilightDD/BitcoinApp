//
//  SOXAutomaticTradingViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 11.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXAutomaticTradingViewController.h"

#pragma mark - Interface
@interface SOXAutomaticTradingViewController ()

#pragma mark IBOutlets
@property (weak) IBOutlet NSButton *enableAutomaticTradingButton;

@property (weak) IBOutlet NSBox *automaticTradingBox;

#pragma mark Properties
@property (nonatomic) BOOL userEnabledAutomaticTrading;

@end

#pragma mark - Implementation
@implementation SOXAutomaticTradingViewController

#pragma mark Init&Co.
- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
}

#pragma mark - Public methods

#pragma mark - Private methods
- (void)setupUI {
    self.enableAutomaticTradingButton.state = 0;
    self.automaticTradingBox.hidden = YES;
}

#pragma mark - Action methods
- (IBAction)enableAutomaticTradingAction:(NSButton *)sender {
    self.userEnabledAutomaticTrading = sender.state;
    self.automaticTradingBox.hidden = !self.userEnabledAutomaticTrading;
}

@end
