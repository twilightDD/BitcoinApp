//
//  SOXStatisticsViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 05.12.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXStatisticsViewController.h"
#import "SOXAbstractViewController_Private.h"

#import "SOXPreferenceCenter.h"

#import "SOXMarket_BitcoinDE_DefTypes.h"

#import "SOXDataStatistics.h"

#import "SOXAccountLedger_BitcoinDE_Data_Private.h"
#import "SOXAccountLedger_BitcoinDE_StatisticData.h"
#import "SOXPage_BitcoinDE_Data.h"

#pragma mark - Interface
@interface SOXStatisticsViewController () <SOXMarketCoreServerRequestProtocol>

#pragma mark | IBOutlets

@property (strong) IBOutlet NSTextField *emptyDescriptionTextField;
@property (strong) IBOutlet NSTextField *loadDescriptionTextField;

@property (strong) IBOutlet NSTextField *btcDescriptionTextField;
@property (strong) IBOutlet NSButton *btcLoadButton;

@property (strong) IBOutlet NSTextField *bchDescriptionTextField;
@property (strong) IBOutlet NSButton *bchLoadButton;

@property (strong) IBOutlet NSTextField *bsvDescriptionTextField;
@property (strong) IBOutlet NSButton *bsvLoadButton;

@property (strong) IBOutlet NSTextField *btgDescriptionTextField;
@property (strong) IBOutlet NSButton *btgLoadButton;

@property (strong) IBOutlet NSTextField *ethDescriptionTextField;
@property (strong) IBOutlet NSButton *ethLoadButton;

@property (strong) IBOutlet NSButton *requestDataButton;

#pragma mark | Properties
@property (strong, nonatomic) NSNumber *startMonth;
@property (strong, nonatomic) NSNumber *startYear;
@property (strong, nonatomic) NSNumber *endMonth;
@property (strong, nonatomic) NSNumber *endYear;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;

@property (strong, nonatomic) NSMutableArray *requestQueue;

@property (strong, nonatomic) NSTableColumn *fetchingTableColumn;

@property (copy, nonatomic) NSString *requestDataButtonTitle;

@property (nonatomic) BOOL isFetching;
@end

#pragma mark - Implementation
@implementation SOXStatisticsViewController

#pragma mark Init&Co.
- (void)viewDidLoad {
    [super viewDidLoad];

    for (NSTableColumn *column in self.tableView.tableColumns) {
        if ([column.identifier isEqualToString:@"fetchingTableColumn"]) {
            self.fetchingTableColumn = column;
            break;
        }
    }

    self.isFetching = NO;

    [self setupUI];
}

#pragma mark - Private Methods
#pragma mark | Setup
- (void)setupUI {
    [self setupStartAndEndDate];
    [self setupCurrencyButtons];
}

- (void)setupStartAndEndDate {
    NSNumber *currentMonth = [SOXFormatters currentMonth];
    NSNumber *currentYear = [SOXFormatters currentYear];

    NSNumber *monthToUse;
    NSNumber *yearToUse = currentYear;
    if (currentMonth.integerValue == 1) {
        // On january use december last year
        monthToUse = @12;
        yearToUse = @(currentYear.integerValue - 1);
    }
    else {
        // Use "Last month" as default.
        monthToUse = @(currentMonth.integerValue - 1);
    }

    self.startMonth = monthToUse;
    self.startYear = yearToUse;
    self.endMonth = monthToUse;
    self.endYear = yearToUse;
}

- (void)setupCurrencyButtons {
    self.emptyDescriptionTextField.stringValue = @"";
    self.loadDescriptionTextField.stringValue = @"Load";

    // BTC
    self.btcDescriptionTextField.stringValue = [SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:BitcoinDE_CurrencyTypeBitcoin];
    self.btcLoadButton.state = [SOXPreferenceCenter controlStateForLoadStatisticsForCurrencyType:BitcoinDE_CurrencyTypeBitcoin];

    // BCH
    self.bchDescriptionTextField.stringValue = [SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:BitcoinDE_CurrencyTypeBitcoinCash];
    self.bchLoadButton.state = [SOXPreferenceCenter controlStateForLoadStatisticsForCurrencyType:BitcoinDE_CurrencyTypeBitcoinCash];

    // BSV
    self.bsvDescriptionTextField.stringValue = [SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:BitcoinDE_CurrencyTypeBitcoinCashSV];
    self.bsvLoadButton.state = [SOXPreferenceCenter controlStateForLoadStatisticsForCurrencyType:BitcoinDE_CurrencyTypeBitcoinCashSV];

    // BTG
    self.btgDescriptionTextField.stringValue = [SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:BitcoinDE_CurrencyTypeBitcoinGold];
    self.btgLoadButton.state = [SOXPreferenceCenter controlStateForLoadStatisticsForCurrencyType:BitcoinDE_CurrencyTypeBitcoinGold];

    // ETH
    self.ethDescriptionTextField.stringValue = [SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:BitcoinDE_CurrencyTypeEthereum];
    self.ethLoadButton.state = [SOXPreferenceCenter controlStateForLoadStatisticsForCurrencyType:BitcoinDE_CurrencyTypeEthereum];
}

#pragma mark | Request methods
- (void)requestServerData {
    self.isFetching = YES;

    // reset content and values
    self.arrayControllerDatas = [NSMutableArray array];
    self.requestQueue = [NSMutableArray array];
    [self.arrayController rearrangeObjects];

    self.startDate = [SOXFormatters dateFirstDayOfMonth:self.startMonth year:self.startYear];
    self.endDate = [SOXFormatters dateLastDayOfMonth:self.endMonth year:self.endYear];

    // setup first page of requests
    for (BitcoinDE_CurrencyType currencyType = BitcoinDE_CurrencyTypeUnknown + 1;
         currencyType < BitcoinDE_CurrencyType_EndOfType;
         currencyType++) {
        SOXAccountLedger_BitcoinDE_StatisticData *accountLedgerStatisticsData;
        accountLedgerStatisticsData = [[SOXAccountLedger_BitcoinDE_StatisticData alloc] initWithCurrencyType:currencyType];
        [self.arrayControllerDatas addObject:accountLedgerStatisticsData];

        // page request for selected currencies only
        if ([SOXPreferenceCenter loadStatisticsForCurrencyType:currencyType]) {
            accountLedgerStatisticsData.state = SOXStatisticData_StateType_WaitingForLoading;

            NSDictionary *parameter = [SOXAccountLedger_BitcoinDE_Data parameterForOrderType:BitcoinDE_AccountLedgerParameter_AllOrderType
                                                                             forCurrencyType:currencyType
                                                                                   startDate:self.startDate
                                                                                     endDate:self.endDate
                                                                                        page:1];

            [self.requestQueue addObject:parameter];
        }
        else {

        }
    }

    [self requestNextServerData];
}

- (void)requestNextServerData {
    // If user clicks "Cancel" button, isFetching will be NO
    if (self.isFetching == NO) {
        return;
    }

    NSDictionary *parameter = [self.requestQueue lastObject];
    if (parameter) {
        SOXAccountLedger_BitcoinDE_StatisticData *accountLedgerStatisticData = [self accountLedgerStatisticsDataForServerRequestParameters:parameter];
        if (accountLedgerStatisticData.currentPage == 0) {
            accountLedgerStatisticData.state = SOXStatisticData_StateType_IsLoadingFirstPage;
        }
        else {
            accountLedgerStatisticData.state = SOXStatisticData_StateType_IsLoadingMorePages;
        }

        [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowAccountLedgerType
                                                withParameter:parameter
                                                    respondTo:self];
    }
    else {
        self.isFetching = NO;

        // Create statistics
    }
}

#pragma mark | Helper methods
- (SOXAccountLedger_BitcoinDE_StatisticData *)accountLedgerStatisticsDataForServerRequestParameters:(NSDictionary *)parameter {
    SOXAccountLedger_BitcoinDE_StatisticData *accountLedgerStatisticData;

    NSString *currencyString = [parameter objectForKey:AccountLedgerParameter_Currency];
    currencyString = [currencyString stringByAppendingString:@"eur"];
    BitcoinDE_CurrencyType currencyType = [SOXMarket_BitcoinDE_DefTypes currencyTypeForTradingPairString:currencyString];

    for (SOXAccountLedger_BitcoinDE_StatisticData *statisticData in self.arrayControllerDatas) {
        if (statisticData.currencyType == currencyType) {
            accountLedgerStatisticData = statisticData;
            break;
        }
    }

    return accountLedgerStatisticData;
}

#pragma mark - Manual setters
- (void)setIsFetching:(BOOL)isFetching {
    _isFetching = isFetching;

    if (isFetching) {
        self.requestDataButtonTitle = @"Cancel";
    }
    else {
        self.requestDataButtonTitle = @"Fetch";
    }

    // Show column only while fetching
    self.fetchingTableColumn.hidden = !isFetching;
}

#pragma mark - Action Methods
- (IBAction)selectCurrencyTypeLoadActions:(NSButton *)sender {
    BOOL loadCurrencyType = sender.state;
    BitcoinDE_CurrencyType currencyType = sender.tag;
    [SOXPreferenceCenter setLoadStatistics:loadCurrencyType
                           forCurrencyType:currencyType];
}

- (IBAction)requestDataButtonAction:(NSButton *)sender {
    self.isFetching = !self.isFetching;
    if (self.isFetching) {
        [self requestServerData];
    }
}

#pragma mark - SOXMarketCoreServerRequestProtocol
- (void)answerOfServerRequest:(NSDictionary *)answerOfServerRequest {
    if ([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ShowAccountLedgerType)]) {
        NSDictionary *payloadDictionary = [answerOfServerRequest objectForKey:ServerAnswerPayloadKey];

        // parameter for answer
        NSDictionary *parameter = [self.requestQueue lastObject];
        [self.requestQueue removeLastObject];

        // reconstruct currencyType
        NSString  *currencyString = [parameter objectForKey:AccountLedgerParameter_Currency];
        currencyString = [currencyString stringByAppendingString:@"eur"];
        BitcoinDE_CurrencyType currencyType = [SOXMarket_BitcoinDE_DefTypes currencyTypeForTradingPairString:currencyString];

        // create SOXAccountLedger_BitcoinDE_StatisticData
        NSMutableArray *accountLedgerDatas =
        [SOXAccountLedger_BitcoinDE_Data accountLedgerDataArrayForAccountLedgerDictionary:payloadDictionary
                                                                          forCurrencyType:currencyType];

        SOXAccountLedger_BitcoinDE_StatisticData *accountLedgerStatisticData = [self accountLedgerStatisticsDataForServerRequestParameters:parameter];
        [accountLedgerStatisticData addAccountLedgerDatas:accountLedgerDatas];
        [self.arrayController rearrangeObjects];

        // PageData: Look up for more pages to load
        if (accountLedgerDatas.count > 0) {
            SOXPage_BitcoinDE_Data *pageData = [SOXPage_BitcoinDE_Data pageDataForPayloadDictionary:payloadDictionary];
            [accountLedgerStatisticData updatedWithPageData:pageData];

            // create more serverRequests if needed
            if (pageData.pageCurrent == 1
                && pageData.pageLast > pageData.pageCurrent) {
                for (NSInteger page = pageData.pageLast;
                     page > 1;
                     page--) {
                    NSDictionary *parameter = [SOXAccountLedger_BitcoinDE_Data parameterForOrderType:BitcoinDE_AccountLedgerParameter_AllOrderType
                                                                                     forCurrencyType:currencyType
                                                                                           startDate:self.startDate
                                                                                             endDate:self.endDate
                                                                                                page:page];
                    [self.requestQueue addObject:parameter];
                }
            }
        }
    }

    // fire next request
    [self requestNextServerData];
}

@end
