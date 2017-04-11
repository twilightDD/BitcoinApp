//
//  SOXAutomaticTradingViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 11.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXAutomaticTradingMainViewController.h"

#import "SOXAutomaticTradingViewController.h"

static NSString *EmbedAutomaticBuySegueKey  = @"EmbedAutomaticBuySegue";
static NSString *EmbedAutomaticSellSegueKey = @"EmbedAutomaticSellSegue";

#pragma mark - Interface
@interface SOXAutomaticTradingMainViewController ()

#pragma mark IBOutlets
@property (weak) IBOutlet NSButton *enableAutomaticTradingButton;

@property (weak) IBOutlet NSBox *automaticTradingBox;

#pragma mark Properties
@property (nonatomic) BOOL userEnabledAutomaticTrading;

@end

#pragma mark - Implementation
@implementation SOXAutomaticTradingMainViewController

#pragma mark Init&Co.
- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
}

- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:EmbedAutomaticBuySegueKey]) {
        SOXAutomaticTradingViewController *destinationViewController = segue.destinationController;
        destinationViewController.orderType = BitcoinDE_BuyOrderType;
    }
    else if ([segue.identifier isEqualToString:EmbedAutomaticSellSegueKey]) {
        SOXAutomaticTradingViewController *destinationViewController = segue.destinationController;
        destinationViewController.orderType = BitcoinDE_SellOrderType;
    }
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
