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
#pragma mark IBOutlets
@property (weak) IBOutlet NSPopUpButton *accountLedgerOrderTypePopUpButton;

#pragma mark Properties
@property (nonatomic) BitcoinDE_AccountLedgerParameter_OrderType selectedAccountLedgerOrderType;

@end

#pragma mark - Implementation
@implementation SOXMyAccountLedgerViewController

#pragma mark Init&Co.
- (void)viewDidLoad {
    [super viewDidLoad];

    self.selectedCurrencyType = BitcoinDE_CurrencyTypeBitcoin;
    self.selectedAccountLedgerOrderType = BitcoinDE_AccountLedgerParameter_AllOrderType;

    // AccountLedger allows no date in future or today
    self.selectedEndDate = [SOXFormatters dateBeforeMidnightForDate:[NSDate dateWithTimeIntervalSinceNow:-86400]];
}

- (void)viewWillAppear {
    [super viewWillAppear];

    [[NSNotificationCenter defaultCenter] postNotificationName:BitcoinDE_Notification_PresentBannerInformationForCurrency
                                                        object:@(self.selectedCurrencyType)];
}

#pragma mark - Private methods
- (void)setupUI {    
    [super setupUI];

    // Manipulate currency Selection - AccountLedger don't allows "all currency"
    {
        [self.currencyTypeSelectionPopUpButton removeItemAtIndex:0];
    }
    // Type Selection
    {
        [self.accountLedgerOrderTypePopUpButton removeAllItems];
        for (BitcoinDE_AccountLedgerParameter_OrderType idx = BitcoinDE_AccountLedgerParameter_UnknownOrderType + 1
             ; idx < BitcoinDE_AccountLedgerParameter_EndOfType
             ; idx++) {
            [self.accountLedgerOrderTypePopUpButton addItemWithTitle:[SOXAccountLedger_BitcoinDE_Data titleForAccountLedgerOrderType:idx]];
        }
    }

    // AccountLedger allows no date in future or today
    {
        self.pagingViewController.endDateDatePicker.maxDate = [SOXFormatters dateBeforeMidnightForDate:[NSDate dateWithTimeIntervalSinceNow:-86400]];
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

        [self.arrayControllerDatas addObjectsFromArray:accountLedgerDatas];
        [self.arrayController rearrangeObjects];

        [self disableSpinningWheel];

        [self updatePagingButtons:payloadDictionary];

        [self updateTradeStatistics];
    }
}

@end
