//
//  SOXAutomaticTradingViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 11.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXAutomaticTradingViewController.h"

#import "SOXMarket_BitcoinDE_Core.h"
#import "SOXAutomaticTrading_BitcoinDE_Core.h"

#pragma mark - Interface
@interface SOXAutomaticTradingViewController () <SOXAutomaticTradingCoreProtocol>

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
@property (strong, nonatomic) NSString *log;
@end

@implementation SOXAutomaticTradingViewController

#pragma mark - Init&Co.
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupCore];
    [self setupUI];
    
    self.log = @"";
}

#pragma mark - Public methods

#pragma mark - Private methods
- (void)setupCore {
    if (self.orderType == BitcoinDE_BuyOrderType) {
        [SOXAutomaticTrading_BitcoinDE_Core registerController:self
                                             forUpdatesForType:BitcoinDE_BuyOrderType];
    }
    else if (self.orderType == BitcoinDE_SellOrderType) {
        [SOXAutomaticTrading_BitcoinDE_Core registerController:self
                                             forUpdatesForType:BitcoinDE_SellOrderType];
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
       // [self.tradingCore startAutomaticTrading];
    }
    
}

- (IBAction)startAutomaticAction:(NSButton *)sender {
//    NSString *longString = @"bububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \nbububububububu \n";
//    for (int a = 0; a <5; a++) {
//        longString = [longString stringByAppendingString:longString];
//    }
//    self.logTextView.string = longString;
//    return;
    self.automaticTradingIsRunning = !self.automaticTradingIsRunning;
    if (self.automaticTradingIsRunning) {
        sender.title = @"Stop";
        [SOXAutomaticTrading_BitcoinDE_Core startAutomaticTrading];
    }
    else {
        sender.title = @"Start";
        [SOXAutomaticTrading_BitcoinDE_Core stopAutomaticTrading];
    }
    
    NSString *infoSring;
    switch (self.orderType) {
        case BitcoinDE_BuyOrderType:
            infoSring = [NSString stringWithFormat:@"Threshhold: %0.4f",
                         [SOXMarket_BitcoinDE_Core sharedCore].rate_weighted.doubleValue * (1 - 0.01/100)];
            break;
        case BitcoinDE_SellOrderType:
            infoSring = [NSString stringWithFormat:@"Threshhold: %0.4f",
                         [SOXMarket_BitcoinDE_Core sharedCore].rate_weighted.doubleValue * (1 + 0.01/100)];
            break;
        default:
            infoSring = @"ERROR: No orderType";
            break;
    }
    self.statusTextField.stringValue = infoSring;
}

- (IBAction)useMaxReservation:(NSButton *)sender {
}

- (IBAction)clearLogAction:(NSButton *)sender {
}

#pragma mark - SOXAutomaticTradingCoreProtocol
- (void)executedTrade:(NSString *)tradeLine {
    self.log = [self.log stringByAppendingString:@"\n"];
    self.log = [self.log stringByAppendingString:tradeLine];
    
    self.logTextView.string = self.log;
}


@end
