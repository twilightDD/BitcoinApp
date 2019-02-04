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

#import "SOXKeys_BitcoinDE.h"

#import "MacAppDelegate.h"

#import "SOXFormatters.h"
#import "SOXLogWindowController.h"

#pragma mark - Interface
@interface SOXAutomaticTradingViewController () <SOXAutomaticTradingCoreProtocol>

#pragma mark IBOutlets
@property (weak) IBOutlet NSButton *showAutomaticTradingAreaButton;

@property (weak) IBOutlet NSButton *executeTradesButton;
@property (weak) IBOutlet NSButton *executeAutomaticTradesButton;
@property (weak) IBOutlet NSButton *executeBalanceTradesButton;
@property (weak) IBOutlet NSButton *disableLogOutputButton;

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
@property (nonatomic, strong) SOXAutomaticTrading_BitcoinDE_Core *tradingCore;

//@property (nonatomic) BitcoinDE_OrderType orderType;

@property (nonatomic) BOOL automaticTradingIsRunning;
@property (nonatomic) BOOL executeTrades;
@property (nonatomic) BOOL executeAutomaticTrades;
@property (nonatomic) BOOL executeBalanceTrades;
@property (nonatomic) BOOL logLogOutput;

@property (strong, nonatomic) NSString *log;

@property (nonatomic) double currentLimit;

#pragma mark Notifications
@property (strong, nonatomic) id requestShowAccountInfoNotification;

@end

@implementation SOXAutomaticTradingViewController

#pragma mark - Init&Co.
- (void)viewDidLoad {
    [super viewDidLoad];

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
                                                                                                usingBlock:^(NSNotification *_Nonnull note) {
                                                                                                    strongify(self)
                                                                                                        [self updateMaxInvestment];
                                                                                                }];
}

#pragma mark - Private methods
- (void)setupUI {
    {                                                // On startup hide view
        self.automaticBackgroundView.hidden = YES;   // disable on startup
        self.executeTradesButton.hidden     = YES;
        self.disableLogOutputButton.hidden  = YES;
    }

    NSString *showAutomaticTradingAreaButtonTitle = @"Buy automatically";
    NSString *startAutomaticButtonTitle           = @"Start Automatic Buy";
    NSString *executeTradesButtonTitle            = @"Execute trades";
    NSString *disableLogOutputButtonTitle         = @"Enable log output";
    NSString *executeAutomaticTradesButtonTitle   = @"Execute Automatic Trades";
    NSString *executeBalanceTradesButtonTitle     = @"Execute Balance Trades";
    NSString *useMaxReservationButtonTitle        = @"Use max";
    NSString *clearLogButtonTitle                 = @"Clear log";

    NSString *maxInvestmentText            = @"200";
    NSString *maxInvestmentDescriptionText = @"Max. Investment";
    NSString *minInterestText              = @"4";
    NSString *minInterestDescriptionText   = @"Min. Interest Rate [%]";

    self.showAutomaticTradingAreaButton.state = 0;
    self.showAutomaticTradingAreaButton.title = showAutomaticTradingAreaButtonTitle;

    self.startAutomaticButton.title = startAutomaticButtonTitle;

    self.executeTradesButton.state = NSOffState;
    self.executeTradesButton.title = executeTradesButtonTitle;
    self.executeTrades             = NO;

    self.logLogOutput                 = YES;
    self.disableLogOutputButton.state = self.logLogOutput;
    self.disableLogOutputButton.title = disableLogOutputButtonTitle;

    self.executeAutomaticTradesButton.state   = NSOffState;
    self.executeAutomaticTradesButton.title   = executeAutomaticTradesButtonTitle;
    self.executeAutomaticTradesButton.enabled = NO;
    self.executeAutomaticTrades               = NO;

    self.executeBalanceTradesButton.state   = NSOffState;
    self.executeBalanceTradesButton.title   = executeBalanceTradesButtonTitle;
    self.executeBalanceTradesButton.enabled = NO;
    self.executeBalanceTrades               = NO;

    self.useMaxReservationButton.state = NSOffState;
    self.useMaxReservationButton.title = useMaxReservationButtonTitle;

    self.clearLogButton.title = clearLogButtonTitle;

    self.statusTextField.stringValue = @"";

    self.maxInvestmentDescriptionTextField.stringValue = maxInvestmentDescriptionText;

    self.maxInvestmentTextField.objectValue = [NSDecimalNumber decimalNumberWithString:maxInvestmentText];
    NSNumberFormatter *formatter            = self.maxInvestmentTextField.formatter;
    formatter.minimum                       = [NSDecimalNumber decimalNumberWithString:@"60"];
    formatter.maximum                       = [NSDecimalNumber decimalNumberWithString:@"25000"];

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
    NSDecimalNumber *interestRate       = self.minInterestTextField.objectValue;

    [self.tradingCore setBuyMaximalFidorAmount:maximalFidorAmount];
    [self.tradingCore setBuyInterestRate:interestRate];

    [self.tradingCore registerControllerForUpdates:self];
}

- (void)stopAutomaticTrading {
    [self.tradingCore deRegisterControllerForUpdates:self];
}

- (void)updateMaxInvestment {
    if (self.useMaxReservationButton.state == NSControlStateValueOn) {
        NSDecimalNumber *availableFidorAmount   = [SOXMarket_BitcoinDE_Core allocationMaxEurVolumeForCurrency:self.currencyType];
        self.maxInvestmentTextField.objectValue = availableFidorAmount;
    }
}

#pragma mark - Action methods
- (IBAction)showAutomaticTradingAreaAction:(NSButton *)sender {
    self.automaticBackgroundView.hidden = !sender.state;
    self.executeTradesButton.hidden     = !sender.state;
    self.disableLogOutputButton.hidden  = !sender.state;

    if (self.automaticTradingIsRunning == YES && sender.state == NO) {
        // [self.tradingCore startAutomaticTrading];
    }
}

- (IBAction)executeTradesAction:(NSButton *)sender {
    self.executeTrades = !self.executeTrades;
    [self.tradingCore executeTrades:self.executeTrades];
}

- (IBAction)executeAutomaticTradesAction:(NSButton *)sender {
    self.executeAutomaticTrades = !self.executeAutomaticTrades;

    // disable balance, if autoTrade is turned off
    if (self.executeAutomaticTrades) {
    }
    else {
        self.executeBalanceTrades = NO;
        [self.tradingCore executeBalanceTrades:NO];
    }

    [self.tradingCore executeAutomaticTrades:self.executeAutomaticTrades];
}

- (IBAction)executeBalanceTradesAction:(NSButton *)sender {
    self.executeBalanceTrades = !self.executeBalanceTrades;
    [self.tradingCore executeBalanceTrades:self.executeBalanceTrades];
}

- (IBAction)startAutomaticAction:(NSButton *)sender {
    self.automaticTradingIsRunning = !self.automaticTradingIsRunning;
    if (self.automaticTradingIsRunning) {
        sender.title                     = @"Stop";
        self.statusTextField.stringValue = @"Fetching base data ...";
        [self startAutomaticTrading];
    }
    else {
        sender.title                     = @"Start";
        self.statusTextField.stringValue = @"Automatic trading stopped";
        [self stopAutomaticTrading];
    }
}

- (IBAction)useMaxReservation:(NSButton *)sender {
    if (sender.state == NSControlStateValueOn) {
        NSDecimalNumber *availableFidorAmount   = [SOXMarket_BitcoinDE_Core allocationMaxEurVolumeForCurrency:self.currencyType];
        self.maxInvestmentTextField.objectValue = availableFidorAmount;
    }
    self.maxInvestmentTextField.enabled = !sender.state;
}

- (IBAction)clearLogAction:(NSButton *)sender {
}

- (IBAction)disableLogOutputAction:(NSButton *)sender {
    if (sender.state == NSControlStateValueOff) {
        [self logLine:@"#### DISABLE LOG OUTPUT NOW ####"];
    }
    else {
        [self logLine:@"#### ENABLE LOG OUTPUT NOW ####"];
    }

    self.logLogOutput = sender.state;
}

#pragma mark - NSControlTextEditingDelegate
- (void)controlTextDidEndEditing:(NSNotification *)notification {
    NSTextField *valueField           = notification.object;
    NSNumberFormatter *fieldFormatter = valueField.formatter;
    NSText *fieldEditor               = valueField.currentEditor;

    id newValue = (fieldEditor != nil ? [fieldFormatter numberFromString:fieldEditor.string] : valueField.objectValue);
    DDLogInfo(@"newValue: %@", newValue);

    if (valueField == self.minInterestTextField) {   // %
        [self.tradingCore setBuyInterestRate:newValue];
    }
    else if (valueField == self.maxInvestmentTextField) {   // €
        [self.tradingCore setBuyMaximalFidorAmount:newValue];
    }
}

#pragma mark - SOXAutomaticTradingCoreProtocol
- (void)logLine:(NSString *)line {
    if (self.logLogOutput == NO) {
        return;
    }

    self.log               = [self.log stringByAppendingString:@"\n"];
    NSString *lineWithDate = [NSString stringWithFormat:@"%@: %@", [SOXFormatters shortDateLongTimeStringForDate:[NSDate date]], line];
    self.log               = [self.log stringByAppendingString:lineWithDate];

    self.logTextView.string = self.log;
    NSPoint pt              = NSMakePoint(0.0, [[self.logTextScrollView documentView]
                                      bounds]
                                      .size.height);
    [self.logTextScrollView.documentView scrollPoint:pt];
}

- (void)logEventLine:(NSString *)line {
    MacAppDelegate *appDelegate                   = (MacAppDelegate *)[[NSApplication sharedApplication] delegate];
    SOXLogWindowController *errorWindowController = appDelegate.eventWindowController;
    [errorWindowController performSelectorOnMainThread:@selector(showMessage:)
                                            withObject:line
                                         waitUntilDone:NO];
}

- (void)statusUpdate:(NSString *)status {
    self.statusTextField.stringValue = status;
}

- (void)flushLogView {
    self.log = @"";
    [self logLine:@"Log view flushed"];
}

- (void)automaticTradingDidBegin {
    self.statusTextField.stringValue = @"Automatic trading started";
}
- (void)automaticTradingDidStop {
    self.statusTextField.stringValue = @"Automatic trading did stop";
}

@end
