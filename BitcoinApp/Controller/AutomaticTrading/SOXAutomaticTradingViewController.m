//
//  SOXAutomaticTradingViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 11.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXAutomaticTradingViewController.h"

#import "SOXAutomaticTrading_BitcoinDE_BuyCore.h"
#import "SOXAutomaticTrading_BitcoinDE_SellCore.h"

#pragma mark - Interface
@interface SOXAutomaticTradingViewController ()

#pragma mark IBOutlets
@property (weak) IBOutlet NSButton *runAutomaticButton;
@property (weak) IBOutlet NSTextField *statusTextField;

@property (weak) IBOutlet NSView *automaticBackgroundView;

@property (weak) IBOutlet NSTextField *maxInvestmentDescriptionTextField;
@property (weak) IBOutlet NSTextField *automaticInvestmentTextField;
@property (weak) IBOutlet NSButton *useMaxReservationButton;
@property (weak) IBOutlet NSTextField *minInterestDescriptionTextField;
@property (weak) IBOutlet NSTextField *minInvestmentTextField;
@property (weak) IBOutlet NSButton *startAutomaticButton;

@property (weak) IBOutlet NSTextField *logDescriptionTextField;
@property (unsafe_unretained) IBOutlet NSTextView *logTextView;
@property (weak) IBOutlet NSButton *clearLogButton;

#pragma mark Properties
@property (nonatomic) BOOL automaticTradingIsRunning;
@property (strong, nonatomic) SOXAutomaticTrading_BitcoinDE_Core *tradingCore;
@end

@implementation SOXAutomaticTradingViewController

#pragma mark - Init&Co.
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupCore];
    [self setupUI];
}

#pragma mark - Public methods

#pragma mark - Private methods
- (void)setupCore {
    if (self.orderType == BitcoinDE_BuyOrderType) {
        self.tradingCore = [SOXAutomaticTrading_BitcoinDE_BuyCore sharedTradingCore];
        
    }
    else if (self.orderType == BitcoinDE_SellOrderType) {
        self.tradingCore = [SOXAutomaticTrading_BitcoinDE_SellCore sharedTradingCore];
    }
    else {
        NSLog(@"ERROR - no orderType set");
    }
}

- (void)setupUI {
    NSString *runAutomaticButtonTitle;
    NSString *startAutomaticButtonTitle;
    
    if (self.orderType == BitcoinDE_BuyOrderType) {
        runAutomaticButtonTitle = @"Buy automatically";
        startAutomaticButtonTitle = @"Start Automatic Buy";
    }
    else if (self.orderType == BitcoinDE_SellOrderType) {
        runAutomaticButtonTitle = @"Sell automatically";
        startAutomaticButtonTitle = @"Start Automatic Sell";
    }
    else {
        NSLog(@"ERROR - no orderType set");
    }

    self.runAutomaticButton.state = 0;
    self.runAutomaticButton.title = runAutomaticButtonTitle;
    self.statusTextField.stringValue = @"";
    
    self.automaticBackgroundView.hidden = YES;
    {
        self.maxInvestmentDescriptionTextField.stringValue = @"Max. Investment";
        self.automaticInvestmentTextField.doubleValue = 0;
        self.useMaxReservationButton.state = 0;
        self.useMaxReservationButton.title = @"Use maximal reservation";
        self.minInterestDescriptionTextField.stringValue = @"Min. Investment [%]";
        self.minInvestmentTextField.doubleValue = 0;
        self.startAutomaticButton.title = startAutomaticButtonTitle;
        
        self.logDescriptionTextField.stringValue = @"Log output";
        self.logTextView.string = @"";
        self.clearLogButton.title = @"Clear Log";
    }

}


#pragma mark - Action methods
- (IBAction)runAutomaticAction:(NSButton *)sender {
    self.automaticBackgroundView.hidden = !sender.state;
    if (self.automaticTradingIsRunning == YES
        && sender.state == NO) {
        [self.tradingCore startAutomaticTrading];
    }
    
}

- (IBAction)startAutomaticAction:(NSButton *)sender {
    self.automaticTradingIsRunning = !self.automaticTradingIsRunning;
    if (self.automaticTradingIsRunning) {
        sender.title = @"Stop";
        [self.tradingCore startAutomaticTrading];
    }
    else {
        sender.title = @"Start";
        [self.tradingCore stopAutomaticTrading];
    }
}

- (IBAction)useMaxReservation:(NSButton *)sender {
}

- (IBAction)clearLogAction:(NSButton *)sender {
}


@end
