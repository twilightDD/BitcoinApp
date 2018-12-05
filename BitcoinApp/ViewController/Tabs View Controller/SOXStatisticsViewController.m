//
//  SOXStatisticsViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 05.12.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXStatisticsViewController.h"
#import "SOXAbstractViewController_Private.h"

#import "SOXMarket_BitcoinDE_DefTypes.h"

#import "SOXAccountLedger_BitcoinDE_Data.h"
#import "SOXDataStatistics.h"
#import "SOXPage_BitcoinDE_Data.h"

@interface SOXStatisticsViewController () <SOXMarketCoreServerRequestProtocol>

#pragma mark | IBOutlets

@property (strong) IBOutlet NSTextView *textView;
@property (strong) IBOutlet NSButton *button;


#pragma mark | Properties

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

}

#pragma mark - Private Methods
- (void)requestServerData {
    self.arrayControllerDatas = [NSMutableArray array];
    self.requestQueue = [NSMutableArray array];
    self.textFieldString = @"";
    self.bitcoinFeeSum = [NSDecimalNumber zero];
    self.startDate = [SOXFormatters dateFirstDayOfMonth:11];
    self.endDate = [SOXFormatters dateLastDayOfMonth:11];
    
    for (BitcoinDE_CurrencyType currencyType = BitcoinDE_CurrencyTypeUnknown + 1;
         currencyType < BitcoinDE_CurrencyType_EndOfType;
         currencyType++) {
        [self updateTextFieldWithString:[NSString stringWithFormat:
                                         @"Add Request type %@"
                                         , [SOXMarket_BitcoinDE_DefTypes tradingPairStringForCurrencyType:currencyType]
                                         ]];
        NSDictionary *parameter = [SOXAccountLedger_BitcoinDE_Data parameterForOrderType:BitcoinDE_AccountLedgerParameter_AllOrderType
                                                                         forCurrencyType:currencyType
                                                                               startDate:self.startDate
                                                                                 endDate:self.endDate
                                                                                    page:1];

        [self.requestQueue addObject:parameter];
    }
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
    }

}
- (void)updateTextFieldWithString:(NSString *)string {
    self.textFieldString = [self.textFieldString stringByAppendingString:@"\n"];
    self.textFieldString = [self.textFieldString stringByAppendingString:string];
    self.textView.string = self.textFieldString;
}

#pragma mark - Action Methods
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
        NSMutableArray *accountLedgerDatas = [SOXAccountLedger_BitcoinDE_Data accountLedgerDataArrayForAccountLedgerDictionary:payloadDictionary
                                                                                                               forCurrencyType:currencyType];
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
            [self.arrayControllerDatas addObjectsFromArray:accountLedgerDatas];
            SOXPage_BitcoinDE_Data *pageData = [SOXPage_BitcoinDE_Data pageDataForPayloadDictionary:payloadDictionary];
            [self updateTextFieldWithString:[NSString stringWithFormat:
                                             @"pageData: current: %ti, last: %ti"
                                             , pageData.pageCurrent
                                             , pageData.pageLast]];
            if (pageData.pageLast > pageData.pageCurrent) {
                for (NSInteger page = pageData.pageCurrent + 1;
                     page <= pageData.pageLast;
                     page++) {
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
        }
    }
    [self requestNextServerData];

}
@end
