//
//  SOXAutomaticTradingViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 11.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXAutomaticTradingViewController.h"

#import "SOXMarket_BitcoinDE_Core.h"
#import "SOXAutomaticTrading_BitcoinDE_Core_OLD.h"
#import "SOXAutomaticTrading_BitcoinDE_Core.h"
#import "SOXShowOrderbook_BitcoinDE_Data.h"

#import "SOXFormatters.h"

#pragma mark - Interface
@interface SOXAutomaticTradingViewController () <SOXAutomaticTradingCoreProtocol>

#pragma mark IBOutlets
@property (weak) IBOutlet NSButton *showAutomaticTradingAreaButton;
@property (weak) IBOutlet NSButton *executeTradesButton;
@property (weak) IBOutlet NSTextField *statusTextField;

@property (weak) IBOutlet NSView *automaticBackgroundView;

@property (weak) IBOutlet NSTextField *maxInvestmentDescriptionTextField;
@property (weak) IBOutlet NSTextField *maxInvestmentTextField;
@property (weak) IBOutlet NSButton *useMaxReservationButton;
@property (weak) IBOutlet NSTextField *minInterestDescriptionTextField;
@property (weak) IBOutlet NSTextField *minInterestTextField;

@property (weak) IBOutlet NSButton *startAutomaticButton;

@property (weak) IBOutlet NSTextField *logDescriptionTextField;
@property (unsafe_unretained) IBOutlet NSTextView *logTextView;
@property (weak) IBOutlet NSButton *clearLogButton;

#pragma mark Properties
@property (nonatomic) BOOL automaticTradingIsRunning;
@property (nonatomic) BOOL executeTrades;
@property (strong, nonatomic) SOXAutomaticTrading_BitcoinDE_Core_OLD *tradingCore;
@property (strong, nonatomic) NSString *log;

@property (nonatomic) double currentLimit;
@end

@implementation SOXAutomaticTradingViewController

#pragma mark - Init&Co.
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    
    self.log = @"";
}

#pragma mark - Public methods

#pragma mark - Private methods
- (void)setupUI {
    if (self.orderType == BitcoinDE_UnknownOrderType) {
        self.logTextView.string = @"Error - no self.orderType";
        return;
    }

    self.automaticBackgroundView.hidden = YES; // disable on startup

    NSString *showAutomaticTradingAreaButtonTitle;
    NSString *startAutomaticButtonTitle;
    NSString *executeTradesButtonTitle;
    NSString *useMaxReservationButtonTitle;
    NSString *clearLogButtonTitle = @"Clear log";

    NSString *maxInvestmentDescriptionText;
    NSString *minInterestDescriptionText = @"Min. Interest Rate [%]";

    if (self.orderType == BitcoinDE_BuyOrderType) {
        showAutomaticTradingAreaButtonTitle   = @"Buy automatically";
        startAutomaticButtonTitle = @"Start Automatic Buy";
        executeTradesButtonTitle  = @"Execute Trades";
        useMaxReservationButtonTitle = @"Use Maximal Fidor reservation";

        maxInvestmentDescriptionText = @"Max. Investment";
    }
    else if (self.orderType == BitcoinDE_SellOrderType) {
        showAutomaticTradingAreaButtonTitle   = @"Sell automatically";
        startAutomaticButtonTitle = @"Start Automatic Sell";
        executeTradesButtonTitle  = @"Execute Trades";
        useMaxReservationButtonTitle = @"Use Maximal BTC amount";

        maxInvestmentDescriptionText = @"Max. Investment";
    }

    self.showAutomaticTradingAreaButton.state = 0;
    self.showAutomaticTradingAreaButton.title = showAutomaticTradingAreaButtonTitle;

    self.startAutomaticButton.title = startAutomaticButtonTitle;

    self.executeTradesButton.state = NSControlStateValueOff;
    self.executeTradesButton.title = executeTradesButtonTitle;
    self.executeTrades = NO;

    self.useMaxReservationButton.state = NSControlStateValueOff;
    self.useMaxReservationButton.title = useMaxReservationButtonTitle;

    self.clearLogButton.title = clearLogButtonTitle;

    self.statusTextField.stringValue = @"";

    self.maxInvestmentDescriptionTextField.stringValue  = maxInvestmentDescriptionText;
    self.maxInvestmentTextField.doubleValue             = 0;

    self.minInterestDescriptionTextField.stringValue = minInterestDescriptionText;
    self.minInterestTextField.doubleValue            = 0;

    self.logDescriptionTextField.stringValue = @"Log output";
    self.logTextView.string                  = @"";
}

- (void)startAutomaticTrading {
    
    if (self.orderType) {
        [SOXAutomaticTrading_BitcoinDE_Core registerController:self
                                        forUpdatesForOrderType:self.orderType];
    }
    else {
        NSLog(@"An error occured: no orderType");
    }

    return;
}

- (void)stopAutomaticTrading {
    if (self.orderType) {
        [SOXAutomaticTrading_BitcoinDE_Core_OLD unRegisterController:self
                                          forUpdatesForOrderType:self.orderType];
    }
    else {
        NSLog(@"ERROR - no orderType set");
    }
}

#pragma mark - Action methods
- (IBAction)showAutomaticTradingAreaAction:(NSButton *)sender {
    self.automaticBackgroundView.hidden = !sender.state;
    if (self.automaticTradingIsRunning == YES
        && sender.state == NO) {
       // [self.tradingCore startAutomaticTrading];
    }
    
}
- (IBAction)executeTradesAction:(NSButton *)sender {
    self.executeTrades = !self.executeTrades;
    [SOXAutomaticTrading_BitcoinDE_Core executeTrades:self.executeTrades
                                         forOrderType:self.orderType];
}

- (IBAction)startAutomaticAction:(NSButton *)sender {
    self.automaticTradingIsRunning = !self.automaticTradingIsRunning;
    if (self.automaticTradingIsRunning) {
        sender.title = @"Stop";
        self.statusTextField.stringValue = @"Fetching base data ...";
        [self startAutomaticTrading];
    }
    else {
        sender.title = @"Start";
        self.statusTextField.stringValue = @"Automatic trading stopped";
        [self stopAutomaticTrading];
    }
}

- (IBAction)useMaxReservation:(NSButton *)sender {
}

- (IBAction)clearLogAction:(NSButton *)sender {
}


#pragma mark - NSControlTextEditingDelegate
-(void)controlTextDidEndEditing:(NSNotification *)notification {
//- (void)controlTextDidChange:(NSNotification *)notification {
    NSTextField* valueField           = notification.object;
    NSNumberFormatter* fieldFormatter = valueField.formatter;
    NSText* fieldEditor               = valueField.currentEditor;
    
    id newValue = ( fieldEditor != nil ? [fieldFormatter numberFromString:fieldEditor.string] : valueField.objectValue );
    NSLog(@"newValue: %@", newValue);
    if (valueField == self.minInterestTextField) { // %
        switch (self.orderType) {
            case BitcoinDE_BuyOrderType:
                [SOXAutomaticTrading_BitcoinDE_Core setBuyInterestRate:newValue];
                break;
            case BitcoinDE_SellOrderType:
                [SOXAutomaticTrading_BitcoinDE_Core setSellInterestRate:newValue];
            default:
                break;
        }
    }
    else if (valueField == self.maxInvestmentTextField) { // €
        switch (self.orderType) {
            case BitcoinDE_BuyOrderType:
                [SOXAutomaticTrading_BitcoinDE_Core setBuyMaximalEuro:newValue];
                break;
            case BitcoinDE_SellOrderType:
                [SOXAutomaticTrading_BitcoinDE_Core setSellMaximalBTC:newValue];
            default:
                break;
        }
    }
    
}

#pragma mark - SOXAutomaticTradingCoreProtocol
- (void)logLine:(NSString *)line {
    self.log = [self.log stringByAppendingString:@"\n"];
    NSString *lineWithDate = [NSString stringWithFormat:@"%@: %@"
                              , [SOXFormatters shortDateShortTimeStringForDate:[NSDate date]]
                              , line];
    self.log = [self.log stringByAppendingString:lineWithDate];
    
    self.logTextView.string = self.log;
}

- (void)currentLimitHasChangedTo:(NSNumber *)newLimit {
    NSLog(@"currentLimitHasChangedTo %@ - orderType: %tu", newLimit, self.orderType);
    self.statusTextField.stringValue = [NSString stringWithFormat:@"Limit: %0.3f (%@)", newLimit.doubleValue, [[NSDate date] description]];
}

@end
