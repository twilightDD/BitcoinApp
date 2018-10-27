//
//  SOXMyAccountLedgerViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 28.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXMyAccountLedgerViewController.h"
#import "SOXAbstractViewController_Private.h"
#import "SOXPagingAbstractViewController_Private.h"
#import "SOXStatisticsAbstractViewController_Private.h"

#import "SOXMarket_BitcoinDE_Core.h"
#import "SOXAccountLedger_BitcoinDE_Data.h"

#import "SOXFormatters.h"

#import "SOXKeys_BitcoinDE.h"
#import "SOXMarket_BitcoinDE_DefTypes.h"

#pragma mark - Interface
@interface SOXMyAccountLedgerViewController () <SOXMarketCoreServerRequestProtocol>

@end

#pragma mark - Implementation
@implementation SOXMyAccountLedgerViewController

#pragma mark Init&Co.
- (void)viewDidLoad {
    [super viewDidLoad];

    self.selectedCurrencyType = BitcoinDE_CurrencyTypeBitcoin;
    self.selectedAccountLedgerOrderType = BitcoinDE_AccountLedgerParameter_AllOrderType;


}

- (void)viewWillAppear {
    [super viewWillAppear];

    [[NSNotificationCenter defaultCenter] postNotificationName:BitcoinDE_Notification_PresentBannerInformationForCurrency
                                                        object:@(self.selectedCurrencyType)];
}

#pragma mark - Segue handling
- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender]; // call superClass!

    [self.pagingViewController setSeparateEndDate:[SOXFormatters dateBeforeMidnightForDate:[NSDate dateWithTimeIntervalSinceNow:-86400]]];
}

#pragma mark - Private methods
- (void)setupUI {    
    [super setupUI];

    { // buttons
        // currency selection
        self.currencyTypeSelectionPopUpButton = self.pagingViewController.firstSelectionPopUpButton;
        [self.currencyTypeSelectionPopUpButton removeAllItems];
        for (BitcoinDE_CurrencyType idx = BitcoinDE_CurrencyTypeBitcoin
             ; idx < BitcoinDE_CurrencyType_EndOfType
             ; idx++) {
            [self.currencyTypeSelectionPopUpButton addItemWithTitle:[SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:idx]];
        }

        // accountLedgerOrderType selection
        self.accountLedgerOrderTypePopUpButton = self.pagingViewController.secondSelectionPopUpButton;
        [self.accountLedgerOrderTypePopUpButton removeAllItems];
        for (BitcoinDE_AccountLedgerParameter_OrderType idx = BitcoinDE_AccountLedgerParameter_UnknownOrderType + 1
             ; idx < BitcoinDE_AccountLedgerParameter_EndOfType
             ; idx++) {
            [self.accountLedgerOrderTypePopUpButton addItemWithTitle:[SOXAccountLedger_BitcoinDE_Data titleForAccountLedgerOrderType:idx]];
        }

        // no third selection
        self.pagingViewController.thirdSelectionPopUpButton.hidden = YES;
    }

    // AccountLedger allows no date in future or today
    {
//        self.selectedEndDate = [SOXFormatters dateBeforeMidnightForDate:[NSDate dateWithTimeIntervalSinceNow:-86400]];
//        self.pagingViewController.endDateDatePicker.maxDate = self.selectedEndDate;
    }
}

#pragma mark - Action methods
- (IBAction)accountLedgerOrderTypePopUpButtonAction:(NSPopUpButton *)sender {
    BitcoinDE_AccountLedgerParameter_OrderType newAccountLedgerOrderType = sender.indexOfSelectedItem + 1;

    if (newAccountLedgerOrderType != self.selectedAccountLedgerOrderType) {
        self.selectedAccountLedgerOrderType = newAccountLedgerOrderType;
        [self resetTradeDatas];
    }
}

#pragma mark - Next Page Data
- (void)loadNextPage {
    [super loadNextPage];
    
    NSDictionary *parameter = [SOXAccountLedger_BitcoinDE_Data parameterForOrderType:self.selectedAccountLedgerOrderType
                                                                     forCurrencyType:self.selectedCurrencyType
                                                                           startDate:self.selectedStartDate
                                                                             endDate:self.selectedEndDate
                                                                                page:self.currentPage];
    
    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowAccountLedgerType
                                            withParameter:parameter
                                                respondTo:self];
}

#pragma mark - SOXMarketCoreServerRequestProtocol
- (void)answerOfServerRequest:(NSDictionary * _Nonnull)answerOfServerRequest {
    if ([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ShowAccountLedgerType)]) {
        NSDictionary *payloadDictionary = [answerOfServerRequest objectForKey:ServerAnswerPayloadKey];
        NSMutableArray *accountLedgerDatas = [SOXAccountLedger_BitcoinDE_Data accountLedgerDataArrayForAccountLedgerDictionary:payloadDictionary
                                              forCurrencyType:self.selectedCurrencyType];
        [self updateControllerDatasWithDataObjects:accountLedgerDatas
                              andPayloadDictionary:payloadDictionary];
    }
}

#pragma mark - SOXPagingViewControllerProtocol
- (void)popupButtonAction:(NSPopUpButton *)sender {
    // currency selection
    if (sender == self.currencyTypeSelectionPopUpButton) {
        BitcoinDE_CurrencyType newCurrencyType = sender.indexOfSelectedItem + 1;
        if (newCurrencyType != self.selectedCurrencyType) {
            self.selectedCurrencyType = newCurrencyType;
            [self resetTradeDatas];
        }
    }
    // orderType selection
    else if (sender == self.accountLedgerOrderTypePopUpButton) {
        BitcoinDE_AccountLedgerParameter_OrderType newSelectedAccountLedgerOrderType = sender.indexOfSelectedItem + 1;
        if (newSelectedAccountLedgerOrderType != self.selectedAccountLedgerOrderType) {
            self.selectedAccountLedgerOrderType = newSelectedAccountLedgerOrderType;
            [self resetTradeDatas];
        }
    }

}

@end
