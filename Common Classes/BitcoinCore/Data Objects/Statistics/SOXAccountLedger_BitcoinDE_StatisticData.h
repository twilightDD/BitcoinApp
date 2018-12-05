//
//  SOXAccountLedger_BitcoinDE_StatisticData.h
//  BitcoinApp
//
//  Created by Peter Hauke on 05.12.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SOXMarket_BitcoinDE_DefTypes.h"

@class SOXAccountLedger_BitcoinDE_Data;

@interface SOXAccountLedger_BitcoinDE_StatisticData : NSObject
@property (nonatomic, readonly) BitcoinDE_CurrencyType currencyType;
@property (strong, nonatomic, readonly) NSDecimalNumber *coinSum;
@property (strong, nonatomic, readonly) NSDecimalNumber *winLostSum;
@property (strong, nonatomic, readonly) NSDecimalNumber *feeVolumeSum;
@property (strong, nonatomic, readonly) NSDecimalNumber *kickbackSum;
@property (strong, nonatomic, readonly) NSMutableArray <SOXAccountLedger_BitcoinDE_Data *> *accountLedgerDatas;

@property (nonatomic) BOOL isLoading;

- (instancetype)initWithCurrencyType:(BitcoinDE_CurrencyType)currencyType;

@end
