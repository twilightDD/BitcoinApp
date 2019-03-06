//
//  SOXMyTrades_BitcoinDE_StatisticData.h
//  BitcoinApp
//
//  Created by Peter Hauke on 06.03.19.
//  Copyright © 2019 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SOXMarket_BitcoinDE_DefTypes.h"

NS_ASSUME_NONNULL_BEGIN

@class SOXMyTrades_BitcoinDE_Data, SOXPageData;

typedef NS_ENUM(NSUInteger, SOXStatisticData_StateType) {
    SOXStatisticData_StateType_New = 0,
    SOXStatisticData_StateType_Sum,
    SOXStatisticData_StateType_WaitingForLoading,
    SOXStatisticData_StateType_IsLoadingFirstPage,
    SOXStatisticData_StateType_IsLoadingMorePages,
    SOXStatisticData_StateType_FullyLoaded
};

@interface SOXMyTrades_BitcoinDE_StatisticData : NSObject

@property (nonatomic, readonly) BitcoinDE_CurrencyType currencyType;
@property (strong, nonatomic, readonly) NSString *currencyName;
@property (strong, nonatomic, readonly) NSDecimalNumber *coinSum;
@property (strong, nonatomic, readonly) NSDecimalNumber *volumeBuySum;
@property (strong, nonatomic, readonly) NSDecimalNumber *volumeSellSum;
@property (strong, nonatomic, readonly) NSDecimalNumber *bitcoinFeeVolumeSum;
@property (strong, nonatomic, readonly) NSDecimalNumber *cashFlowVolumeSum;
@property (strong, nonatomic, readonly) NSDecimalNumber *fidorFeeVolumeSum;
@property (strong, nonatomic, readonly) NSDecimalNumber *appFeeVolumeSum;
@property (strong, nonatomic, readonly) NSDecimalNumber *incomeVolumeSum;
@property (strong, nonatomic, readonly) NSDecimalNumber *kickbackSum;
@property (strong, nonatomic, readonly) NSNumber *kickbackCount;
@property (strong, nonatomic, readonly) NSMutableArray<SOXMyTrades_BitcoinDE_Data *> *myTradesDatas;

@property (nonatomic) SOXStatisticData_StateType state;
@property (strong, nonatomic, readonly) NSString *stateDescription;

@property (nonatomic, readonly) NSInteger currentPage;
@property (nonatomic, readonly) NSInteger lastPage;
@property (strong, nonatomic, readonly) NSColor *textColor;

- (instancetype)initWithCurrencyType:(BitcoinDE_CurrencyType)currencyType;
- (void)addMyTradesDatas:(NSMutableArray<SOXMyTrades_BitcoinDE_Data *> *)myTradesDatas;
- (void)updatedWithPageData:(SOXPageData *)pageData;


@end

NS_ASSUME_NONNULL_END
