//
//  SOXAutomaticTradingViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 11.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXAutomaticTradingViewController.h"

#import "SOXAccountInfo_BitcoinDE_Data.h"
#import "SOXMarket_BitcoinDE_Core.h"
#import "SOXAutomaticTrading_BitcoinDE_Core.h"
#import "SOXShowOrderbook_BitcoinDE_Data.h"

#import "SOXKeys_BitcoinDE.h"

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
@property (nonatomic) BitcoinDE_OrderType orderType;

@property (nonatomic, strong) SOXAutomaticTrading_BitcoinDE_Core *tradingCore;

@property (nonatomic) BOOL automaticTradingIsRunning;
@property (nonatomic) BOOL executeTrades;
@property (nonatomic) BOOL executeAutomaticTrades;
@property (nonatomic) BOOL executeBalanceTrades;

@property (strong, nonatomic) NSString *log;

@property (nonatomic) double currentLimit;

#pragma mark Notifications
@property (strong, nonatomic) id requestShowAccountInfoNotification;

@end

@implementation SOXAutomaticTradingViewController

#pragma mark - Init&Co.
- (void)viewDidLoad {
    [super viewDidLoad];

    self.orderType = BitcoinDE_BuyOrderType;

    [self setupUI];
    [self registerOberservers];

    self.log = @"";
}

- (void)viewWillAppear {
    [super viewWillAppear];
    [[NSNotificationCenter defaultCenter] postNotificationName:BitcoinDE_Notification_PresentBannerInformationForCurrency
                                                        object:@(self.currencyType)];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.requestShowAccountInfoNotification];
}

#pragma mark - Notification methods
- (void)registerOberservers {
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];

    weakify(self)
    self.requestShowAccountInfoNotification = [[NSNotificationCenter defaultCenter] addObserverForName:BitcoinDE_Notification_RequestShowAccountInfo
                                                                                                object:nil
                                                                                                 queue:mainQueue
                                                                                            usingBlock:^(NSNotification * _Nonnull note) {
                                                                                                strongify(self)
                                                                                                [self updateMaxInvestment];
                                                                                            }
                                               ];
}

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
    NSString *minInterestText                   = @"4";
    NSString *minInterestDescriptionText        = @"Min. Interest Rate [%]";

    if (self.orderType == BitcoinDE_BuyOrderType) {
        showAutomaticTradingAreaButtonTitle = @"Buy automatically";
        startAutomaticButtonTitle           = @"Start Automatic Buy";
        useMaxReservationButtonTitle        = @"Use max";
        maxInvestmentText                   = @"200";
        maxInvestmentDescriptionText        = @"Max. Investment";

    }
    else if (self.orderType == BitcoinDE_SellOrderType) {
        showAutomaticTradingAreaButtonTitle = @"Sell automatically";
        startAutomaticButtonTitle           = @"Start Automatic Sell";
        useMaxReservationButtonTitle        = @"Use Max";
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
    formatter.minimum                                   = [NSDecimalNumber decimalNumberWithString:@"60"];
    formatter.maximum                                   = [NSDecimalNumber decimalNumberWithString:@"25000"];

    self.minInterestDescriptionTextField.stringValue = minInterestDescriptionText;
    self.minInterestTextField.objectValue            = [NSDecimalNumber decimalNumberWithString:minInterestText];
    NSNumberFormatter *formatter2                    = self.minInterestTextField.formatter;
    formatter2.minimum                               = [NSDecimalNumber decimalNumberWithString:@"1"];
    formatter2.maximum                               = [NSDecimalNumber decimalNumberWithString:@"100"];

    self.logDescriptionTextField.stringValue = @"Log output";
    self.logTextView.string                  = @"";
}

- (void)startAutomaticTrading {
    self.tradingCore = [[SOXAutomaticTrading_BitcoinDE_Core alloc] initForCurrencyTyp:self.currencyType];

    NSDecimalNumber *maximalFidorAmount = self.maxInvestmentTextField.objectValue;
    NSDecimalNumber *interestRate = self.minInterestTextField.objectValue;
    switch (self.orderType) {
        case BitcoinDE_BuyOrderType:
            [self.tradingCore setBuyMaximalFidorAmount:maximalFidorAmount];
            [self.tradingCore setBuyInterestRate:interestRate];
            break;
        default:
            NSAssert(NO, @"wrong orderType");
            return;
            break;
    }

    [self.tradingCore registerController:self
                  forUpdatesForOrderType:self.orderType];

}

- (void)stopAutomaticTrading {
    if (self.orderType) {
        [self.tradingCore deRegisterController:self
                        forUpdatesForOrderType:self.orderType];
    }
    else {
        DDLogInfo(@"ERROR - no orderType set");
    }
}

- (void)updateMaxInvestment {
    if (self.useMaxReservationButton.state == NSControlStateValueOn) {
        NSDecimalNumber *availableFidorAmount = [SOXMarket_BitcoinDE_Core allocationMaxEurVolumeForCurrency:self.currencyType];
        self.maxInvestmentTextField.objectValue = availableFidorAmount;
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
    [self.tradingCore executeTrades:self.executeTrades
                       forOrderType:self.orderType];
}

- (IBAction)executeAutomaticTradesAction:(NSButton *)sender {
    self.executeAutomaticTrades = !self.executeAutomaticTrades;

    if (self.executeAutomaticTrades) {}
    else {
        self.executeBalanceTrades = NO;
        [self.tradingCore executeBalanceTrades:NO
                                  forOrderType:self.orderType];
    }
    [self.tradingCore executeAutomaticTrades:self.executeAutomaticTrades
                                forOrderType:self.orderType];
}

- (IBAction)executeBalanceTradesAction:(NSButton *)sender {
    self.executeBalanceTrades = !self.executeBalanceTrades;
    [self.tradingCore executeBalanceTrades:self.executeBalanceTrades
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
    if (sender.state == NSControlStateValueOn) {
        NSDecimalNumber *availableFidorAmount = [SOXMarket_BitcoinDE_Core allocationMaxEurVolumeForCurrency:self.currencyType];
        self.maxInvestmentTextField.objectValue = availableFidorAmount;
    }
    self.maxInvestmentTextField.enabled = !sender.state;
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
    DDLogInfo(@"newValue: %@", newValue);
    if (valueField == self.minInterestTextField) { // %
        switch (self.orderType) {
            case BitcoinDE_BuyOrderType:
                [self.tradingCore setBuyInterestRate:newValue];
                break;
            default:
                NSAssert(NO, @"wrong orderType");
                break;
        }
    }
    else if (valueField == self.maxInvestmentTextField) { // €
        switch (self.orderType) {
            case BitcoinDE_BuyOrderType:
                [self.tradingCore setBuyMaximalFidorAmount:newValue];
                break;
            default:
                NSAssert(NO, @"wrong orderType");
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
