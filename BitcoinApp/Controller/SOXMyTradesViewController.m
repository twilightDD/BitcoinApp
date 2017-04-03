//
//  SOXMyTradesViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 28.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXMyTradesViewController.h"

#import "SOXMarket_BitcoinDE_Core.h"
#import "SOXMyTrades_BitcoinDE_Data.h"



#pragma mark - Interface
@interface SOXMyTradesViewController () <SOXMarketCoreServerRequestProtocol>

#pragma mark IBOutlets
@property (weak) IBOutlet NSTableView *tableView;

// Page selector
@property (weak) IBOutlet NSView *pageContainerView;
@property (weak) IBOutlet NSButton *pageBackwardButton;
@property (weak) IBOutlet NSButton *pageForwardButton;
@property (weak) IBOutlet NSTextField *pageIndicatorTextField;

// Parameter
// - order type
@property (weak) IBOutlet NSTextField *orderTypeTextField;
@property (weak) IBOutlet NSButton *orderTypeBuyRadioButton;
@property (weak) IBOutlet NSButton *orderTypeSellRadioButton;
// - trade state
@property (weak) IBOutlet NSTextField *tradeStateTextField;
@property (weak) IBOutlet NSButton *tradeStateCancelledRadioButton;
@property (weak) IBOutlet NSButton *tradeStatePendingRadioButton;
@property (weak) IBOutlet NSButton *tradeStateSuccessfulRadioButton;
// - start date
@property (weak) IBOutlet NSTextField *startDateTextField;
@property (weak) IBOutlet NSDatePicker *startDateDatePicker;
// - end date
@property (weak) IBOutlet NSTextField *endDateTextField;
@property (weak) IBOutlet NSDatePicker *endDateDatePicker;

// Array controller
@property (strong) IBOutlet NSArrayController *myTradesArrayController;

#pragma mark Properties

@end

#pragma mark - Implementation
@implementation SOXMyTradesViewController

#pragma mark Init&Co.
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)viewWillAppear {
    [super viewWillAppear];
    
    [self setupUI];
    [self requestServerData];
}

#pragma mark - Private methods
- (void)setupUI {
    self.pageContainerView.hidden = YES;
}


- (void)requestServerData {
    NSDictionary *parameterDictionary = [SOXMyTrades_BitcoinDE_Data parameterFor];
    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowMyTradesType
                                            withParameter:parameterDictionary
                                                respondTo:self];
}

#pragma mark - SOXMarketCoreServerRequestProtocol
- (void)answerOfServerRequest:(NSDictionary * _Nonnull)answerOfServerRequest {
    NSLog(@"BitcoinDE_ShowMyTradesType \n%@",answerOfServerRequest);
    if ([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ShowMyTradesType)]) {
//        NSDictionary *payloadDictionary = [answerOfServerRequest objectForKey:ServerAnswerPayloadKey];
//        NSMutableArray *orderBook = [SOXShowOrderbook_BitcoinDE_Data orderbookDataArrayForShowOrderbookDictionary:payloadDictionary];
//        self.orderBook = orderBook;
//        
//        [self.circularProgressIndicator stopAnimation:nil];
//        self.spinningBackgroundView.hidden = YES;
    }
}

- (IBAction)orderTypeButtonAction:(NSButton *)sender {
}

- (IBAction)tradeStateButtonAction:(NSButton *)sender {
}


@end
