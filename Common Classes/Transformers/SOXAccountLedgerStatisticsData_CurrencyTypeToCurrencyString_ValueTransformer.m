//
//  SOXAccountLedgerStatisticsData_CurrencyTypeToCurrencyString_ValueTransformer.m
//  BitcoinApp
//
//  Created by Peter Hauke on 10.12.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXAccountLedgerStatisticsData_CurrencyTypeToCurrencyString_ValueTransformer.h"

#import "SOXMarket_BitcoinDE_DefTypes.h"

#import "SOXAccountLedger_BitcoinDE_StatisticData.h"

@implementation SOXAccountLedgerStatisticsData_CurrencyTypeToCurrencyString_ValueTransformer

+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    BitcoinDE_CurrencyType currencyType = BitcoinDE_CurrencyTypeUnknown;

    if ([value isKindOfClass:[SOXAccountLedger_BitcoinDE_StatisticData class]]) {
        SOXAccountLedger_BitcoinDE_StatisticData *accountLedgerStatisticData = value;
        currencyType = accountLedgerStatisticData.currencyType;
    }
    else {
        NSAssert(NO, @"Unknown value class");
    }

    if (currencyType != BitcoinDE_CurrencyTypeUnknown) {
        NSString *currencyString = [SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:currencyType];
        return currencyString;
    }
    
    return @"Error";
}

@end
