//
//  SOXAccountLedger_BitcoinDE_StatisticData.m
//  BitcoinApp
//
//  Created by Peter Hauke on 05.12.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXAccountLedger_BitcoinDE_StatisticData.h"
#import "SOXAccountLedger_BitcoinDE_Data.h"

#import "SOXDataStatistics.h"

#pragma mark -
@interface SOXAccountLedger_BitcoinDE_StatisticData ()
#pragma mark | Public Properties
@property (nonatomic, readwrite) BitcoinDE_CurrencyType currencyType;
@property (strong, nonatomic, readwrite) NSDecimalNumber *coinSum;
@property (strong, nonatomic, readwrite) NSDecimalNumber *winLostSum;
@property (strong, nonatomic, readwrite) NSDecimalNumber *feeVolumeSum;
@property (strong, nonatomic, readwrite) NSDecimalNumber *kickbackSum;
@property (strong, nonatomic, readwrite) NSMutableArray <SOXAccountLedger_BitcoinDE_Data *> *accountLedgerDatas;

#pragma mark | Private Properties
@end

#pragma mark -
@implementation SOXAccountLedger_BitcoinDE_StatisticData

#pragma mark Init & Co.
- (instancetype)initWithCurrencyType:(BitcoinDE_CurrencyType)currencyType {
    self = [super self];
    if (self) {
        self.currencyType = currencyType;
        self.accountLedgerDatas = [NSMutableArray array];
        self.coinSum = [NSDecimalNumber zero];
        self.winLostSum = [NSDecimalNumber zero];
        self.feeVolumeSum = [NSDecimalNumber zero];
        self.kickbackSum = [NSDecimalNumber zero];
    }

    return self;
}
#pragma mark - Public Methods
- (void)addAccountLedgerDatas:(NSMutableArray *)accountLedgerDatas {
    if (accountLedgerDatas.count > 0) {
        [self.accountLedgerDatas addObjectsFromArray:accountLedgerDatas];
    }
    [self updateProperties];

}

#pragma mark - Private Methods
- (void)updateProperties {
    NSDictionary *statistic = [SOXDataStatistics statisticsForAccountLedgerDatas:self.accountLedgerDatas];
    self.coinSum = [statistic objectForKey:@"coinSum"];
    self.winLostSum = [statistic objectForKey:@"winLostSum"];
    self.feeVolumeSum = [statistic objectForKey:@"feeVolumeSum"];
    self.kickbackSum = [statistic objectForKey:@"kickbackSum"];
}

@end
