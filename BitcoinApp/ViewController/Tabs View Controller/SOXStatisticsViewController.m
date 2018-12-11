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

#import "SOXAccountLedger_BitcoinDE_Data.h"
#import "SOXAccountLedger_BitcoinDE_StatisticData.h"
#import "SOXAccountLedger_BitcoinDE_StatisticData.h"
#import "SOXPage_BitcoinDE_Data.h"

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

@property (strong) IBOutlet NSTextView *textView;
@property (strong) IBOutlet NSButton *button;

#pragma mark | Properties
@property (strong, nonatomic) NSNumber *startMonth;
@property (strong, nonatomic) NSNumber *startYear;
@property (strong, nonatomic) NSNumber *endMonth;
@property (strong, nonatomic) NSNumber *endYear;

@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@property (strong, nonatomic) NSMutableArray *requestQueue;
@property (strong, nonatomic) NSString *textFieldString;
@property (strong, nonatomic) NSDecimalNumber *bitcoinFeeSum;
@end

@implementation SOXStatisticsViewController

#pragma mark Init&Co.
- (void)viewDidLoad {
    [super viewDidLoad];
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

- (void)requestServerData {
    self.arrayControllerDatas = [NSMutableArray array];
    self.requestQueue = [NSMutableArray array];
    self.textFieldString = @"";
    self.bitcoinFeeSum = [NSDecimalNumber zero];
    self.startDate = [SOXFormatters dateFirstDayOfMonth:self.startMonth year:self.startYear];
    self.endDate = [SOXFormatters dateLastDayOfMonth:self.endMonth year:self.endYear];
    
    for (BitcoinDE_CurrencyType currencyType = BitcoinDE_CurrencyTypeUnknown + 1;
         currencyType < BitcoinDE_CurrencyType_EndOfType;
         currencyType++) {
        SOXAccountLedger_BitcoinDE_StatisticData *accountLedgerStatisticsData;
        accountLedgerStatisticsData = [[SOXAccountLedger_BitcoinDE_StatisticData alloc] initWithCurrencyType:currencyType];
        [self.arrayControllerDatas addObject:accountLedgerStatisticsData];

        if ([SOXPreferenceCenter loadStatisticsForCurrencyType:currencyType]) {
            NSDictionary *parameter = [SOXAccountLedger_BitcoinDE_Data parameterForOrderType:BitcoinDE_AccountLedgerParameter_AllOrderType
                                                                             forCurrencyType:currencyType
                                                                                   startDate:self.startDate
                                                                                     endDate:self.endDate
                                                                                        page:1];

            [self.requestQueue addObject:parameter];
            [self updateTextFieldWithString:[NSString stringWithFormat:
                                            @"Add Request type %@"
                                            , [SOXMarket_BitcoinDE_DefTypes tradingPairStringForCurrencyType:currencyType]
                                            ]];
        }
        else {
            [self updateTextFieldWithString:[NSString stringWithFormat:
                                            @"Disabled: %@"
                                            , [SOXMarket_BitcoinDE_DefTypes tradingPairStringForCurrencyType:currencyType]
                                            ]];
        }


    }
    [self.arrayController rearrangeObjects];
    [self requestNextServerData];
}

- (void)requestNextServerData {
    [self updateTextFieldWithString:@"---------------------------------------------"];
    NSDictionary *parameter = [self.requestQueue lastObject];
    if (parameter) {
        [self updateTextFieldWithString:[NSString stringWithFormat:
                                         @"Start next request - type: %@ - currency: %@ - page: %@"
                                         , [parameter objectForKey:@"type"]
                                         , [parameter objectForKey:@"currency"]
                                         , [parameter objectForKey:@"page"]
                                         ]];

        [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowAccountLedgerType
                                                withParameter:parameter
                                                    respondTo:self];
    }
    else {
        [self updateTextFieldWithString:[NSString stringWithFormat:
                                         @"No more requests: %tu - got %tu accountDatas"
                                         , self.requestQueue.count
                                         , self.arrayControllerDatas.count
                                         ]];
        [self updateTextFieldWithString:[NSString stringWithFormat:@"Final feeSum: %@"
                                         , self.bitcoinFeeSum]];
        for (SOXAccountLedger_BitcoinDE_StatisticData *data in self.arrayControllerDatas) {
            data.isLoading = NO;
            NSLog(@"%ti - %@ - %@ - %@ - %@"
                  , data.currencyType
                  , data.coinSum
                  , data.winLostSum
                  , data.feeVolumeSum
                  , data.kickbackSum);
        }


    }

}
- (void)updateTextFieldWithString:(NSString *)string {
    self.textFieldString = [self.textFieldString stringByAppendingString:@"\n"];
    self.textFieldString = [self.textFieldString stringByAppendingString:string];
    self.textView.string = self.textFieldString;
}

#pragma mark - Action Methods
- (IBAction)selectCurrencyTypeLoadActions:(NSButton *)sender {
    BOOL loadCurrencyType = sender.state;
    BitcoinDE_CurrencyType currencyType = sender.tag;
    [SOXPreferenceCenter setLoadStatistics:loadCurrencyType
                           forCurrencyType:currencyType];
}

- (IBAction)buttonAction:(NSButton *)sender {
    [self requestServerData];
}

#pragma mark - SOXMarketCoreServerRequestProtocol
- (void)answerOfServerRequest:(NSDictionary *)answerOfServerRequest {
    if ([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ShowAccountLedgerType)]) {
        NSDictionary *payloadDictionary = [answerOfServerRequest objectForKey:ServerAnswerPayloadKey];
        NSDictionary *parameter = [self.requestQueue lastObject];
        NSString  *currencyString = [parameter objectForKey:@"currency"];
        currencyString = [currencyString stringByAppendingString:@"eur"];

        [self.requestQueue removeLastObject];

        BitcoinDE_CurrencyType currencyType = [SOXMarket_BitcoinDE_DefTypes currencyTypeForTradingPairString:currencyString];
        NSMutableArray *accountLedgerDatas =
        [SOXAccountLedger_BitcoinDE_Data accountLedgerDataArrayForAccountLedgerDictionary:payloadDictionary
                                                                          forCurrencyType:currencyType];

        SOXAccountLedger_BitcoinDE_StatisticData *accountLedgerStatisticData;
        for (SOXAccountLedger_BitcoinDE_StatisticData *statisticData in self.arrayControllerDatas) {
            if (statisticData.currencyType == currencyType) {
                accountLedgerStatisticData = statisticData;
                break;
            }
        }
        [accountLedgerStatisticData addAccountLedgerDatas:accountLedgerDatas];
        [self.arrayController rearrangeObjects];

        [self updateTextFieldWithString:[NSString stringWithFormat:
                                         @"answer: currency: %@, countOfData: %tu"
                                         , [SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:currencyType]
                                         , accountLedgerDatas.count]];
        NSDictionary *statistic = [SOXDataStatistics statisticsForAccountLedgerDatas:accountLedgerDatas];
        [self updateTextFieldWithString:[NSString stringWithFormat:
                                         @"coinSum: %@, winLost: %@, feeVolume: %@, kickbackSum: %@",
                                         [statistic objectForKey:@"coinSum"],
//                                         [statistic objectForKey:@"volumeBuySum"],
                                         [statistic objectForKey:@"winLostSum"],
                                         [statistic objectForKey:@"feeVolumeSum"],
                                         [statistic objectForKey:@"kickbackSum"]
                                         ]
         ];
        NSDecimalNumber *feeVolumesum = [statistic objectForKey:@"feeVolumeSum"];
        self.bitcoinFeeSum = [self.bitcoinFeeSum decimalNumberByAdding:feeVolumesum];



        if (accountLedgerDatas.count > 0) {
//            [self.arrayControllerDatas addObjectsFromArray:accountLedgerDatas];
            SOXPage_BitcoinDE_Data *pageData = [SOXPage_BitcoinDE_Data pageDataForPayloadDictionary:payloadDictionary];
            [self updateTextFieldWithString:[NSString stringWithFormat:
                                             @"pageData: current: %ti, last: %ti"
                                             , pageData.pageCurrent
                                             , pageData.pageLast]];
            if (pageData.pageCurrent == 1
                && pageData.pageLast > pageData.pageCurrent) {
                for (NSInteger page = pageData.pageLast;
                     page > 1;
                     page--) {
                    [self updateTextFieldWithString:[NSString stringWithFormat:
                                                     @"Add Request type %@ (page %ti)"
                                                     , [SOXMarket_BitcoinDE_DefTypes tradingPairStringForCurrencyType:currencyType]
                                                     , page
                                                     ]];
                    NSDictionary *parameter = [SOXAccountLedger_BitcoinDE_Data parameterForOrderType:BitcoinDE_AccountLedgerParameter_AllOrderType
                                                                                     forCurrencyType:currencyType
                                                                                           startDate:self.startDate
                                                                                             endDate:self.endDate
                                                                                                page:page];

                    [self.requestQueue addObject:parameter];
                }
            }
            else if (pageData.pageCurrent == pageData.pageLast){
                accountLedgerStatisticData.isLoading = NO;
            }
        }
    }
    [self requestNextServerData];

}
@end
