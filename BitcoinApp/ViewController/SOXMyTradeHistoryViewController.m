//
//  SOXMyTradesViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 28.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXMyTradeHistoryViewController.h"
#import "SOXAbstractViewController_Private.h"

#import "SOXMyOrderDetailsViewController.h"

#import "SOXMarket_BitcoinDE_Core.h"
#import "SOXMyTrades_BitcoinDE_Data.h"

#import "SOXKeys_BitcoinDE.h"
#import "SOXMarket_BitcoinDE_DefTypes.h"

#pragma mark - Interface
@interface SOXMyTradeHistoryViewController () <SOXMarketCoreServerRequestProtocol>

#pragma mark IBOutlets
@property (weak) IBOutlet NSTableView *tableView;


//// Page selector
//@property (strong) IBOutlet NSButton *loadMoreTradeDatasButton;
//@property (strong) IBOutlet NSButton *loadAllTradeDatasButton;


// Parameter
@property (weak) IBOutlet NSPopUpButton *tradeHistoryOrderTypeSelectionPopUpButton;
@property (weak) IBOutlet NSPopUpButton *stateTypeSelectionPopUpButton;

@property (nonatomic) BitcoinDE_MyTradeHistoryParameter_OrderType selectedTradeHistoryOrderType;
@property (nonatomic) BitcoinDE_MyTradeHistoryParameter_TradeStateType selectedTradeStateType;

@end

#pragma mark - Implementation
@implementation SOXMyTradeHistoryViewController

#pragma mark Init&Co.
- (void)viewDidLoad {
    [super viewDidLoad];

    // Defaults for types
    self.selectedTradeHistoryOrderType = BitcoinDE_MyTradeHistoryParameter_AllOrderType;
    self.selectedTradeStateType = BitcoinDE_MyTradeHistoryParameter_SuccessfulTradeStateType;
}

#pragma mark - Private methods
- (void)setupUI {
    [super setupUI];

    { // buttons

        // tradeHistoryOrderType selection
        [self.tradeHistoryOrderTypeSelectionPopUpButton removeAllItems];
        for (BitcoinDE_MyTradeHistoryParameter_OrderType idx = BitcoinDE_MyTradeHistoryParameter_UnknownOrderType + 1
             ; idx < BitcoinDE_MyTradeHistoryParameter_EndOfOrderType
             ; idx++) {
            [self.tradeHistoryOrderTypeSelectionPopUpButton addItemWithTitle:[SOXMyTrades_BitcoinDE_Data titleForOrderType:idx]];
        }

        // state selection
        [self.stateTypeSelectionPopUpButton removeAllItems];
        for (BitcoinDE_MyTradeHistoryParameter_TradeStateType idx = BitcoinDE_MyTradeHistoryParameter_UnknownTradeStateType + 1
             ; idx < BitcoinDE_MyTradeHistoryParameter_EndOfTradeStateType
             ; idx++) {
            [self.stateTypeSelectionPopUpButton addItemWithTitle:[SOXMyTrades_BitcoinDE_Data titleForTradeStateType:idx]];
        }
    }
}

#pragma mark - Action methods
#pragma mark | Settings
- (IBAction)tradeHistoryOrderTypePopUpButtonAction:(NSPopUpButton *)sender {
    BitcoinDE_MyTradeHistoryParameter_OrderType newOrderType = sender.indexOfSelectedItem + 1;
    if (newOrderType != self.selectedTradeHistoryOrderType) {
        self.selectedTradeHistoryOrderType = newOrderType;
        [self resetTradeDatas];
    }
}

- (IBAction)statePopUpButtonAction:(NSPopUpButton *)sender {
    BitcoinDE_MyTradeHistoryParameter_TradeStateType newTradeState = sender.indexOfSelectedItem + 1;
    if (newTradeState != self.selectedTradeStateType) {
        self.selectedTradeStateType = newTradeState;
        [self resetTradeDatas];
    }
}

#pragma mark - SOXMarketCoreServerRequestProtocol
- (void)answerOfServerRequest:(NSDictionary * _Nonnull)answerOfServerRequest {
    if ([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ShowMyTradesType)]) {
        NSDictionary *payloadDictionary = [answerOfServerRequest objectForKey:ServerAnswerPayloadKey];

        NSMutableArray *myTrades = [SOXMyTrades_BitcoinDE_Data myTradesDataArrayForMyTradeHistoryDictionary:payloadDictionary];
        [self.arrayControllerDatas addObjectsFromArray:myTrades];
        [self.arrayController rearrangeObjects];

        // Page information
        [self updatePagingButtons:payloadDictionary];
    }
}

- (void)loadNextPage {
    [super loadNextPage];

    NSDictionary *parameterDictionary = [SOXMyTrades_BitcoinDE_Data parameterForOrderType:self.selectedTradeHistoryOrderType
                                                                               tradeState:self.selectedTradeStateType
                                                                             currencyType:self.selectedCurrencyType
                                                                                startDate:self.selectedStartDate
                                                                                  endDate:self.selectedEndDate
                                                                                     page:self.currentPage];
    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowMyTradesType
                                            withParameter:parameterDictionary
                                                respondTo:self];
}

@end
