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
@property (weak) IBOutlet NSButton *tradeStateSuccessfulRadioButton;
@property (weak) IBOutlet NSButton *tradeStatePendingRadioButton;
@property (weak) IBOutlet NSButton *tradeStateCancelledRadioButton;
// - start date
@property (weak) IBOutlet NSTextField *startDateTextField;
@property (weak) IBOutlet NSDatePicker *startDateDatePicker;
// - end date
@property (weak) IBOutlet NSTextField *endDateTextField;
@property (weak) IBOutlet NSDatePicker *endDateDatePicker;

// Array controller
@property (strong) IBOutlet NSArrayController *myTradesArrayController;

#pragma mark Properties
@property (nonatomic) NSInteger selectedOrderType;
@property (nonatomic) NSInteger selectedTradeStateType;
@property (strong, nonatomic) NSDate *selectedStartDate;
@property (strong, nonatomic) NSDate *selectedEndDate;
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
    
    self.selectedOrderType      = 0;
    self.selectedTradeStateType = 1;
    self.selectedStartDate      = [NSDate dateWithTimeInterval:-1*60*60*24*7 sinceDate:[NSDate date]];
    self.selectedEndDate        = [NSDate date];
    
    [self setupUI];
    [self requestServerData];
}

#pragma mark - Private methods
- (void)setupUI {
    self.pageContainerView.hidden = YES;
    
    { // Radio buttons
        self.orderTypeTextField.stringValue     = @"Order type";
        self.orderTypeBuyRadioButton.title      = @"Buy";
        self.orderTypeBuyRadioButton.state      = NSOnState;
        self.orderTypeSellRadioButton.title     = @"Sell";
        
        self.tradeStateTextField.stringValue        = @"Trade state";
        self.tradeStateSuccessfulRadioButton.title  = @"Successful";
        self.tradeStateSuccessfulRadioButton.state  = NSOnState;
        self.tradeStatePendingRadioButton.title     = @"Pending";
        self.tradeStateCancelledRadioButton.title   = @"Cancelled";
    }
    
    { // date picker
        self.startDateTextField.stringValue = @"Start date";
        self.startDateDatePicker.dateValue  = self.selectedStartDate;
        
        self.endDateTextField.stringValue   = @"End date";
        self.endDateDatePicker.dateValue    = self.selectedEndDate;
    }
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
    NSLog(@"tag: %ti", sender.tag);
    self.selectedOrderType = sender.tag;
}

- (IBAction)tradeStateButtonAction:(NSButton *)sender {
    NSLog(@"tag: %ti", sender.tag);
    self.selectedTradeStateType = sender.tag;
}


@end
