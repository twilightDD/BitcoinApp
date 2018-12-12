//
//  SOXAccountLedger_BitcoinDE_StatisticData.h
//  BitcoinApp
//
//  Created by Peter Hauke on 05.12.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SOXMarket_BitcoinDE_DefTypes.h"

@class SOXAccountLedger_BitcoinDE_Data, SOXPageData;

typedef NS_ENUM (NSUInteger, SOXStatisticData_StateType) {
    SOXStatisticData_StateType_New = 0
    , SOXStatisticData_StateType_WaitingForLoading
    , SOXStatisticData_StateType_IsLoadingFirstPage
    , SOXStatisticData_StateType_IsLoadingMorePages
    , SOXStatisticData_StateType_FullyLoaded
};


@interface SOXAccountLedger_BitcoinDE_StatisticData : NSObject

@property (nonatomic, readonly) BitcoinDE_CurrencyType currencyType;
@property (strong, nonatomic, readonly) NSDecimalNumber *coinSum;
@property (strong, nonatomic, readonly) NSDecimalNumber *winLostSum;
@property (strong, nonatomic, readonly) NSDecimalNumber *feeVolumeSum;
@property (strong, nonatomic, readonly) NSDecimalNumber *kickbackSum;
@property (strong, nonatomic, readonly) NSNumber *kickbackCount;
@property (strong, nonatomic, readonly) NSMutableArray <SOXAccountLedger_BitcoinDE_Data *> *accountLedgerDatas;

@property (nonatomic) SOXStatisticData_StateType state;
//@property (nonatomic) BOOL isLoading;
//@property (nonatomic) BOOL isWaiting;
//@property (nonatomic) BOOL isActive;
@property (nonatomic, readonly) NSInteger currentPage;
@property (nonatomic, readonly) NSInteger lastPage;
@property (strong, nonatomic, readonly) NSColor *textColor;

- (instancetype)initWithCurrencyType:(BitcoinDE_CurrencyType)currencyType;
- (void)addAccountLedgerDatas:(NSMutableArray *)accountLedgerDatas;
- (void)updatedWithPageData:(SOXPageData *)pageData;


@end
