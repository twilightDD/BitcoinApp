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
#pragma mark - Interface
@interface SOXAutomaticTradingViewController () <SOXAutomaticTradingCoreProtocol>

#pragma mark IBOutlets
@property (weak) IBOutlet NSButton *runAutomaticButton;
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
@property (strong, nonatomic) SOXAutomaticTrading_BitcoinDE_Core *tradingCore;
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
    // TextFields in separate automaticBackgroundView
    {
        self.maxInvestmentDescriptionTextField.stringValue  = @"Max. Investment";
        self.maxInvestmentTextField.doubleValue             = 0;
        
        self.useMaxReservationButton.title = @"Use maximal reservation";
        self.useMaxReservationButton.state = 0;
        
        self.minInterestDescriptionTextField.stringValue = @"Min. Investment [%]";
        self.minInterestTextField.doubleValue            = 0;
        
        self.startAutomaticButton.title = startAutomaticButtonTitle;
        
        self.logDescriptionTextField.stringValue = @"Log output";
        self.logTextView.string                  = @"";
        self.clearLogButton.title                = @"Clear Log";
    }
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
        [SOXAutomaticTrading_BitcoinDE_Core unRegisterController:self
                                          forUpdatesForOrderType:self.orderType];
    }
    else {
        NSLog(@"ERROR - no orderType set");
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
- (void)controlTextDidChange:(NSNotification *)notification {
    NSTextField* valueField           = notification.object;
    NSNumberFormatter* fieldFormatter = valueField.formatter;
    NSText* fieldEditor               = valueField.currentEditor;
    
    id newValue = ( fieldEditor != nil ? [fieldFormatter numberFromString:fieldEditor.string] : valueField.objectValue );
    
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
    self.log = [self.log stringByAppendingString:line];
    
    self.logTextView.string = self.log;
}

- (void)currentLimitHasChangedTo:(NSNumber *)newLimit {
    NSLog(@"currentLimitHasChangedTo %@ - orderType: %tu", newLimit, self.orderType);
    self.statusTextField.stringValue = [NSString stringWithFormat:@"Limit: %0.3f (%@)", newLimit.doubleValue, [[NSDate date] description]];
}

@end
