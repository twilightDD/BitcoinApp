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

- (void)startAutomaticTrading {
    
    if (self.orderType == BitcoinDE_BuyOrderType) {
        [SOXAutomaticTrading_BitcoinDE_Core registerController:self
                                        forUpdatesForOrderType:BitcoinDE_BuyOrderType];
    }
    else if (self.orderType == BitcoinDE_SellOrderType) {
        [SOXAutomaticTrading_BitcoinDE_Core registerController:self
                                        forUpdatesForOrderType:BitcoinDE_SellOrderType];
    }
    else {
        NSLog(@"An error occured: no orderType");
    }

    return;
    
    
//    if (self.orderType == BitcoinDE_BuyOrderType) {
//        // we want to compare buy price with highest sell price - BuyOrderType vs. SellOrderBook ist richtig!
//        [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowSellOrderbookCommandType
//                                                    respondTo:self];
//    }
//    else if (self.orderType == BitcoinDE_SellOrderType) {
//        // we want to compare sell price with lowest buy price - SellOrderType vs. BuyOrderBook ist richtig!
//        [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowBuyOrderbookCommandType
//                                                    respondTo:self];
//    }
//    else {
//        NSLog(@"ERROR - no orderType set");
//    }
}

- (void)stopAutomaticTrading {
    if (self.orderType == BitcoinDE_BuyOrderType) {
        [SOXAutomaticTrading_BitcoinDE_Core unRegisterController:self
                                          forUpdatesForOrderType:BitcoinDE_BuyOrderType];
    }
    else if (self.orderType == BitcoinDE_SellOrderType) {
        [SOXAutomaticTrading_BitcoinDE_Core unRegisterController:self
                                          forUpdatesForOrderType:BitcoinDE_SellOrderType];
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

#pragma mark - SOXMarketCoreServerRequestProtocol
//- (void)answerOfServerRequest:(NSDictionary *)answerOfServerRequest {
//    NSDictionary *payloadDictionary = [answerOfServerRequest objectForKey:ServerAnswerPayloadKey];
//    NSMutableArray *orderBook = [SOXShowOrderbook_BitcoinDE_Data orderbookDataArrayForShowOrderbookDictionary:payloadDictionary];
//    if (orderBook) {
//        self.currentLimit = [SOXShowOrderbook_BitcoinDE_Data currentAutomaticPriceLimitOfOrderBook:orderBook
//                                                                                      forOrderType:self.orderType];
//        self.statusTextField.stringValue = [NSString stringWithFormat:@"Running with limit: %f",self.currentLimit];
//        if (self.orderType == BitcoinDE_BuyOrderType) {
//            [SOXAutomaticTrading_BitcoinDE_Core registerController:self
//                                            forUpdatesForOrderType:BitcoinDE_BuyOrderType];
//        }
//        else if (self.orderType == BitcoinDE_SellOrderType) {
//            [SOXAutomaticTrading_BitcoinDE_Core registerController:self
//                                            forUpdatesForOrderType:BitcoinDE_SellOrderType];
//        }
//        else {
//            NSLog(@"An error occured: no orderType");
//        }
//    }
//    else {
//        self.currentLimit = 0;
//        NSLog(@"An error occured: no limit");
//    }
//}

#pragma mark - SOXAutomaticTradingCoreProtocol
- (void)executedTrade:(NSString *)tradeLine {
    
    self.log = [self.log stringByAppendingString:@"\n"];
    self.log = [self.log stringByAppendingString:tradeLine];
    
    self.logTextView.string = self.log;
}

- (void)currentLimitHasChangedTo:(NSNumber *)newLimit {
    NSLog(@"currentLimitHasChangedTo %@ - orderType: %tu", newLimit, self.orderType);
    self.statusTextField.stringValue = [NSString stringWithFormat:@"Limit: %0.3f (%@)", newLimit.doubleValue, [[NSDate date] description]];
}

@end
