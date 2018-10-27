//
//  SOXMyTradesViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 28.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXMyTradeHistoryViewController.h"
#import "SOXAbstractViewController_Private.h"
#import "SOXPagingAbstractViewController_Private.h"
#import "SOXStatisticsAbstractViewController_Private.h"

#import "SOXMyOrderDetailsViewController.h"
#import "SOXPagingViewController.h"

#import "SOXMarket_BitcoinDE_Core.h"
#import "SOXMyTrades_BitcoinDE_Data.h"

#import "SOXKeys_BitcoinDE.h"
#import "SOXMarket_BitcoinDE_DefTypes.h"

#pragma mark - Interface
@interface SOXMyTradeHistoryViewController () <SOXMarketCoreServerRequestProtocol>

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
        // currency selection
        self.currencyTypeSelectionPopUpButton = self.pagingViewController.firstSelectionPopUpButton;
        [self.currencyTypeSelectionPopUpButton removeAllItems];
        for (BitcoinDE_CurrencyType idx = BitcoinDE_CurrencyTypeUnknown
             ; idx < BitcoinDE_CurrencyType_EndOfType
             ; idx++) {
            [self.currencyTypeSelectionPopUpButton addItemWithTitle:[SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:idx]];
        }
        
        // orderType selection
        self.orderTypeSelectionPopUpButton = self.pagingViewController.secondSelectionPopUpButton;
        [self.orderTypeSelectionPopUpButton removeAllItems];
        for (BitcoinDE_MyTradeHistoryParameter_OrderType idx = BitcoinDE_MyTradeHistoryParameter_UnknownOrderType + 1
             ; idx < BitcoinDE_MyTradeHistoryParameter_EndOfOrderType
             ; idx++) {
            [self.orderTypeSelectionPopUpButton addItemWithTitle:[SOXMyTrades_BitcoinDE_Data titleForOrderType:idx]];
        }
        
        // tradeState selection
        self.tradeStateTypeSelectionPopUpButton = self.pagingViewController.thirdSelectionPopUpButton;
        [self.tradeStateTypeSelectionPopUpButton removeAllItems];
        for (BitcoinDE_MyTradeHistoryParameter_TradeStateType idx = BitcoinDE_MyTradeHistoryParameter_UnknownTradeStateType + 1
             ; idx < BitcoinDE_MyTradeHistoryParameter_EndOfTradeStateType
             ; idx++) {
            [self.tradeStateTypeSelectionPopUpButton addItemWithTitle:[SOXMyTrades_BitcoinDE_Data titleForTradeStateType:idx]];
        }
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

#pragma mark - SOXMarketCoreServerRequestProtocol
- (void)answerOfServerRequest:(NSDictionary * _Nonnull)answerOfServerRequest {
    if ([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ShowMyTradesType)]) {
        NSDictionary *payloadDictionary = [answerOfServerRequest objectForKey:ServerAnswerPayloadKey];
        
        NSMutableArray *myTrades = [SOXMyTrades_BitcoinDE_Data myTradesDataArrayForMyTradeHistoryDictionary:payloadDictionary];
        [self updateControllerDatasWithDataObjects:myTrades
                              andPayloadDictionary:payloadDictionary];
        
    }
}

#pragma mark - Pasteboard handling
- (void)copy:(id)sender {
    NSArray <SOXMyTrades_BitcoinDE_Data *> *selectedTrades = self.arrayController.selectedObjects;
    
    NSString *pasteboardString = [SOXMyTrades_BitcoinDE_Data pasteboardStringForTrades:selectedTrades];
    [self addToPasteBoard:pasteboardString];
}

#pragma mark - SOXPagingViewControllerProtocol
- (void)popupButtonAction:(NSPopUpButton *)sender {
    // currency selection
    if (sender == self.currencyTypeSelectionPopUpButton) {
        BitcoinDE_CurrencyType newCurrencyType = sender.indexOfSelectedItem;
        if (newCurrencyType != self.selectedCurrencyType) {
            self.selectedCurrencyType = newCurrencyType;
            [self resetTradeDatas];
        }
    }
    // orderType selection
    else if (sender == self.orderTypeSelectionPopUpButton) {
        BitcoinDE_MyTradeHistoryParameter_OrderType newOrderType = sender.indexOfSelectedItem + 1;
        if (newOrderType != self.selectedTradeHistoryOrderType) {
            self.selectedTradeHistoryOrderType = newOrderType;
            [self resetTradeDatas];
        }
    }
    // tradeState selection
    else if (sender == self.tradeStateTypeSelectionPopUpButton) {
        BitcoinDE_MyTradeHistoryParameter_TradeStateType newTradeStateType = sender.indexOfSelectedItem + 1;
        if (newTradeStateType != self.selectedTradeStateType) {
            self.selectedTradeStateType = newTradeStateType;
            [self resetTradeDatas];
        }
    }
}

@end
