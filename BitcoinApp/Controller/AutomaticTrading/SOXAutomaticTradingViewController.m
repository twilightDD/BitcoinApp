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
#import "SOXShowOrderbook_BitcoinDE_Data.h"

#import "SOXFormatters.h"

#pragma mark - Interface
@interface SOXAutomaticTradingViewController () <SOXAutomaticTradingCoreProtocol>

#pragma mark IBOutlets
@property (weak) IBOutlet NSButton *showAutomaticTradingAreaButton;

@property (weak) IBOutlet NSButton *executeTradesButton;
@property (weak) IBOutlet NSButton *executeAutomaticTradesButton;
@property (weak) IBOutlet NSButton *executeBalanceTradesButton;

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
@property (weak) IBOutlet NSScrollView *logTextScrollView;

@property (weak) IBOutlet NSButton *clearLogButton;

#pragma mark Properties
@property (nonatomic) BOOL automaticTradingIsRunning;
@property (nonatomic) BOOL executeTrades;
@property (nonatomic) BOOL executeAutomaticTrades;
@property (nonatomic) BOOL executeBalanceTrades;

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

    { // On startup hide view
        self.automaticBackgroundView.hidden = YES; // disable on startup
        self.executeTradesButton.hidden = YES;
    }

    NSString *showAutomaticTradingAreaButtonTitle;
    NSString *startAutomaticButtonTitle;
    NSString *executeTradesButtonTitle          = @"Execute trades";
    NSString *executeAutomaticTradesButtonTitle = @"Execute Automatic Trades";
    NSString *executeBalanceTradesButtonTitle   = @"Execute Balance Trades";
    NSString *useMaxReservationButtonTitle;
    NSString *clearLogButtonTitle               = @"Clear log";

    NSString *maxInvestmentText;
    NSString *maxInvestmentDescriptionText;
    NSString *minInterestText                   = @"0.01";
    NSString *minInterestDescriptionText        = @"Min. Interest Rate [%]";

    if (self.orderType == BitcoinDE_BuyOrderType) {
        showAutomaticTradingAreaButtonTitle = @"Buy automatically";
        startAutomaticButtonTitle           = @"Start Automatic Buy";
        useMaxReservationButtonTitle        = @"Use Maximal Fidor reservation";
        maxInvestmentText                   = @"200";
        maxInvestmentDescriptionText        = @"Max. Investment";

    }
    else if (self.orderType == BitcoinDE_SellOrderType) {
        showAutomaticTradingAreaButtonTitle = @"Sell automatically";
        startAutomaticButtonTitle           = @"Start Automatic Sell";
        useMaxReservationButtonTitle        = @"Use Maximal BTC amount";
        maxInvestmentText                   = @"0.2";
        maxInvestmentDescriptionText        = @"Max. Investment";
    }
    else {
        showAutomaticTradingAreaButtonTitle = @"Error - no orderType";
        startAutomaticButtonTitle           = @"Error - no orderType";
        executeAutomaticTradesButtonTitle   = @"Error - no orderType";
        useMaxReservationButtonTitle        = @"Error - no orderType";
        maxInvestmentText                   = @"0";
        maxInvestmentDescriptionText        = @"Error - no orderType";
    }

    self.showAutomaticTradingAreaButton.state = 0;
    self.showAutomaticTradingAreaButton.title = showAutomaticTradingAreaButtonTitle;

    self.startAutomaticButton.title = startAutomaticButtonTitle;

    self.executeTradesButton.state = NSOffState;
    self.executeTradesButton.title = executeTradesButtonTitle;
    self.executeTrades = NO;

    self.executeAutomaticTradesButton.state = NSOffState;
    self.executeAutomaticTradesButton.title = executeAutomaticTradesButtonTitle;
    self.executeAutomaticTradesButton.enabled = NO;
    self.executeAutomaticTrades = NO;

    self.executeBalanceTradesButton.state = NSOffState;
    self.executeBalanceTradesButton.title = executeBalanceTradesButtonTitle;
    self.executeBalanceTradesButton.enabled = NO;
    self.executeBalanceTrades = NO;

    self.useMaxReservationButton.state = NSOffState;
    self.useMaxReservationButton.title = useMaxReservationButtonTitle;

    self.clearLogButton.title = clearLogButtonTitle;

    self.statusTextField.stringValue = @"";

    self.maxInvestmentDescriptionTextField.stringValue  = maxInvestmentDescriptionText;

    self.maxInvestmentTextField.objectValue             = [NSDecimalNumber decimalNumberWithString:maxInvestmentText];
    NSNumberFormatter *formatter                        = self.maxInvestmentTextField.formatter;
    formatter.minimum                                   = [NSDecimalNumber zero];
    formatter.maximum                                   = [NSDecimalNumber decimalNumberWithString:@"100000"];

    self.minInterestDescriptionTextField.stringValue = minInterestDescriptionText;
    self.minInterestTextField.objectValue            = [NSDecimalNumber decimalNumberWithString:minInterestText];
    NSNumberFormatter *formatter2                    = self.minInterestTextField.formatter;
    formatter2.minimum                               = [NSDecimalNumber decimalNumberWithString:minInterestText];
    formatter2.maximum                               = [NSDecimalNumber decimalNumberWithString:@"100"];

    self.logDescriptionTextField.stringValue = @"Log output";
    self.logTextView.string                  = @"";
}

- (void)startAutomaticTrading {
    NSDecimalNumber *maximalFidorAmount = self.maxInvestmentTextField.objectValue;
    NSDecimalNumber *interestRate = self.minInterestTextField.objectValue;

    SOXAutomaticTrading_BitcoinDE_Core *core = [SOXAutomaticTradingCoreManager coreForBitcoinCurrency:self.bitcoinCurrencyType];
    switch (self.orderType) {
        case BitcoinDE_BuyOrderType:
            [core setBuyMaximalFidorAmount:maximalFidorAmount];
            [core setBuyInterestRate:interestRate];
            break;
        case BitcoinDE_SellOrderType:
            [core setSellMaximalBTCAmount:maximalFidorAmount];
            [core setSellInterestRate:interestRate];
            break;
        default:
            return;
            break;
    }

    [core registerController:self forUpdatesForOrderType:self.orderType];
}

- (void)stopAutomaticTrading {
    if (self.orderType) {
        SOXAutomaticTrading_BitcoinDE_Core *core = [SOXAutomaticTradingCoreManager coreForBitcoinCurrency:self.bitcoinCurrencyType];
        [core deRegisterController:self forUpdatesForOrderType:self.orderType];
    }
    else {
        DDLogInfo(@"ERROR - no orderType set");
    }
}

#pragma mark - Action methods
- (IBAction)showAutomaticTradingAreaAction:(NSButton *)sender {
    self.automaticBackgroundView.hidden = !sender.state;
    self.executeTradesButton.hidden = !sender.state;
    
    if (self.automaticTradingIsRunning == YES
        && sender.state == NO) {
       // [self.tradingCore startAutomaticTrading];
    }
}

- (IBAction)executeTradesAction:(NSButton *)sender {
    self.executeTrades = !self.executeTrades;
    SOXAutomaticTrading_BitcoinDE_Core *core = [SOXAutomaticTradingCoreManager coreForBitcoinCurrency:self.bitcoinCurrencyType];
    [core executeTrades:self.executeTrades forOrderType:self.orderType];
}

- (IBAction)executeAutomaticTradesAction:(NSButton *)sender {
    self.executeAutomaticTrades = !self.executeAutomaticTrades;

    SOXAutomaticTrading_BitcoinDE_Core *core = [SOXAutomaticTradingCoreManager coreForBitcoinCurrency:self.bitcoinCurrencyType];
    if (self.executeAutomaticTrades) {

    }
    else {
        self.executeBalanceTrades = NO;
        [core executeBalanceTrades:NO forOrderType:self.orderType];
    }
    [core executeAutomaticTrades:self.executeAutomaticTrades forOrderType:self.orderType];
}

- (IBAction)executeBalanceTradesAction:(NSButton *)sender {
    self.executeBalanceTrades = !self.executeBalanceTrades;
    
    SOXAutomaticTrading_BitcoinDE_Core *core = [SOXAutomaticTradingCoreManager coreForBitcoinCurrency:self.bitcoinCurrencyType];
    [core executeBalanceTrades:self.executeBalanceTrades forOrderType:self.orderType];
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
    NSTextField* valueField           = notification.object;
    NSNumberFormatter* fieldFormatter = valueField.formatter;
    NSText* fieldEditor               = valueField.currentEditor;
    
    id newValue = ( fieldEditor != nil ? [fieldFormatter numberFromString:fieldEditor.string] : valueField.objectValue );
    DDLogInfo(@"newValue: %@", newValue);

    SOXAutomaticTrading_BitcoinDE_Core *core = [SOXAutomaticTradingCoreManager coreForBitcoinCurrency:self.bitcoinCurrencyType];
    if (valueField == self.minInterestTextField) { // %
        switch (self.orderType) {
            case BitcoinDE_BuyOrderType:
                [core setBuyInterestRate:newValue];
                break;
            case BitcoinDE_SellOrderType:
                [core setSellInterestRate:newValue];
            default:
                break;
        }
    }
    else if (valueField == self.maxInvestmentTextField) { // €
        switch (self.orderType) {
            case BitcoinDE_BuyOrderType:
                [core setBuyMaximalFidorAmount:newValue];
                break;
            case BitcoinDE_SellOrderType:
                [core setSellMaximalBTCAmount:newValue];
            default:
                break;
        }
    }
    
}

#pragma mark - SOXAutomaticTradingCoreProtocol
- (void)logLine:(NSString *)line {
    self.log = [self.log stringByAppendingString:@"\n"];
    NSString *lineWithDate = [NSString stringWithFormat:@"%@: %@"
                              , [SOXFormatters shortDateLongTimeStringForDate:[NSDate date]]
                              , line];
    self.log = [self.log stringByAppendingString:lineWithDate];
    
    self.logTextView.string = self.log;
    NSPoint pt = NSMakePoint(0.0, [[self.logTextScrollView documentView]
                                   bounds].size.height);
    [self.logTextScrollView.documentView scrollPoint:pt];
}

- (void)statusUpdate:(NSString *)status {
    self.statusTextField.stringValue = status;
}

- (void)automaticTradingDidBegin {
    self.statusTextField.stringValue = @"Automatic trading started";
}
- (void)automaticTradingDidStop {
    self.statusTextField.stringValue = @"Automatic trading did stop";
}

@end
