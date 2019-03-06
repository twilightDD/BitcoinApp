//
//  SOXMyTrades_BitcoinDE_StatisticData.m
//  BitcoinApp
//
//  Created by Peter Hauke on 06.03.19.
//  Copyright © 2019 2sox / Peter Hauke. All rights reserved.
//

#import "SOXMyTrades_BitcoinDE_StatisticData.h"

#import "SOXMyTrades_BitcoinDE_Data.h"
#import "SOXMyTrades_BitcoinDE_Data_Private.h"

#import "SOXPageData.h"

#pragma mark - Interface
@interface SOXMyTrades_BitcoinDE_StatisticData ()

#pragma mark | Public Properties
@property (nonatomic, readwrite) BitcoinDE_CurrencyType currencyType;
@property (strong, nonatomic, readwrite) NSString *currencyName;
@property (strong, nonatomic, readwrite) NSDecimalNumber *coinSum;
@property (strong, nonatomic, readwrite) NSDecimalNumber *volumeBuySum;
@property (strong, nonatomic, readwrite) NSDecimalNumber *volumeSellSum;
@property (strong, nonatomic, readwrite) NSDecimalNumber *bitcoinFeeVolumeSum;
@property (strong, nonatomic, readwrite) NSDecimalNumber *cashFlowVolumeSum;
@property (strong, nonatomic, readwrite) NSDecimalNumber *fidorFeeVolumeSum;
@property (strong, nonatomic, readwrite) NSDecimalNumber *appFeeVolumeSum;
@property (strong, nonatomic, readwrite) NSDecimalNumber *incomeVolumeSum;
@property (strong, nonatomic, readwrite) NSDecimalNumber *kickbackSum;
@property (strong, nonatomic, readwrite) NSNumber *kickbackCount;
@property (strong, nonatomic, readwrite) NSMutableArray<SOXMyTrades_BitcoinDE_Data *> *myTradesDatas;

@property (strong, nonatomic, readwrite) NSString *stateDescription;

@property (nonatomic, readwrite) NSInteger currentPage;
@property (nonatomic, readwrite) NSInteger lastPage;
@property (strong, nonatomic, readwrite) NSColor *textColor;

#pragma mark | Private Properties


@end

#pragma mark - Implementation

@implementation SOXMyTrades_BitcoinDE_StatisticData

#pragma mark Init & Co.
- (instancetype)init {
    self = [super self];

    if (self) {
        _currencyName        = @"Sum";
        _volumeBuySum        = [NSDecimalNumber zero];
        _volumeSellSum       = [NSDecimalNumber zero];
        _bitcoinFeeVolumeSum = [NSDecimalNumber zero];
        _cashFlowVolumeSum   = [NSDecimalNumber zero];
        _fidorFeeVolumeSum   = [NSDecimalNumber zero];
        _appFeeVolumeSum     = [NSDecimalNumber zero];
        _incomeVolumeSum     = [NSDecimalNumber zero];
        _myTradesDatas       = [NSMutableArray array];

        _coinSum       = [NSDecimalNumber zero];
        _kickbackSum   = [NSDecimalNumber zero];
        _kickbackCount = 0;

        _state       = SOXStatisticData_StateType_New;
        _currentPage = 0;
        _lastPage    = 0;
    }

    return self;
}

- (instancetype)initWithCurrencyType:(BitcoinDE_CurrencyType)currencyType {
    self = [self init];

    if (self) {
        _currencyType = currencyType;
        _currencyName = [SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:currencyType];
    }

    return self;
}

#pragma mark - Public Methods
- (void)addMyTradesDatas:(NSMutableArray<SOXMyTrades_BitcoinDE_Data *> *)myTradesDatas {
    if (myTradesDatas.count > 0) {
        [self.myTradesDatas addObjectsFromArray:myTradesDatas];
    }

    [self updateProperties];
}

- (void)updatedWithPageData:(SOXPageData *)pageData {
    self.currentPage = pageData.pageCurrent;
    self.lastPage    = pageData.pageLast;
    if (pageData.pageCurrent == pageData.pageLast) {
        self.state = SOXStatisticData_StateType_FullyLoaded;
    }
}

#pragma mark - Manual Setter and Getter
- (NSString *)stateDescription {
    return [NSString stringWithFormat:@"%lu", (unsigned long)self.state];
}

#pragma mark - Private Methods
- (void)updateProperties {
    self.volumeBuySum        = [NSDecimalNumber zero];
    self.volumeSellSum       = [NSDecimalNumber zero];
    self.bitcoinFeeVolumeSum = [NSDecimalNumber zero];
    self.cashFlowVolumeSum   = [NSDecimalNumber zero];
    self.fidorFeeVolumeSum   = [NSDecimalNumber zero];
    self.appFeeVolumeSum     = [NSDecimalNumber zero];
    self.incomeVolumeSum     = [NSDecimalNumber zero];
    self.coinSum             = [NSDecimalNumber zero];
    self.kickbackSum         = [NSDecimalNumber zero];

    for (SOXMyTrades_BitcoinDE_Data *myTradesData in self.myTradesDatas) {
        if ([myTradesData.type isEqualToString:MyTradeHistoryParameter_OrderTypeBuyKey]) {
            self.coinSum      = [self.coinSum decimalNumberByAdding:myTradesData.amount];
            self.volumeBuySum = [self.volumeBuySum decimalNumberByAdding:myTradesData.ownCalc_bookingVolume];
        }
        else if ([myTradesData.type isEqualToString:MyTradeHistoryParameter_OrderTypeSellKey]) {
            self.coinSum       = [self.coinSum decimalNumberBySubtracting:myTradesData.amount];
            self.volumeSellSum = [self.volumeSellSum decimalNumberByAdding:myTradesData.ownCalc_bookingVolume];
        }
        else {
            NSAssert(NO, @"no valid type");
        }

        self.bitcoinFeeVolumeSum = [self.bitcoinFeeVolumeSum decimalNumberByAdding:myTradesData.feeEur];
        self.fidorFeeVolumeSum   = [self.fidorFeeVolumeSum decimalNumberByAdding:myTradesData.ownCalc_fidorFee];
        self.appFeeVolumeSum     = [self.appFeeVolumeSum decimalNumberByAdding:myTradesData.ownCalc_fidorFee];
    }

    self.cashFlowVolumeSum = [self.volumeSellSum decimalNumberByAdding:self.volumeBuySum];
    // over all income: cashFlow - fidorFee - appFee
    self.incomeVolumeSum = [self.cashFlowVolumeSum decimalNumberBySubtracting:self.fidorFeeVolumeSum];
    self.incomeVolumeSum = [self.incomeVolumeSum decimalNumberBySubtracting:self.appFeeVolumeSum];
}

- (NSColor *)textColor {
    if (self.state == SOXStatisticData_StateType_FullyLoaded) {
        return [NSColor textColor];
    }
    else {
        return [NSColor lightGrayColor];
    }
}
@end
