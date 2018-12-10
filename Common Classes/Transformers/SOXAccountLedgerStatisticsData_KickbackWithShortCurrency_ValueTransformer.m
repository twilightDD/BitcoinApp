//
//  SOXAccountLedgerStatisticsData_KickbackWithShortCurrency_ValueTransformer.m
//  BitcoinApp
//
//  Created by Peter Hauke on 10.12.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXAccountLedgerStatisticsData_KickbackWithShortCurrency_ValueTransformer.h"

#import "SOXFormatters.h"

#import "SOXMarket_BitcoinDE_DefTypes.h"

#import "SOXAccountLedger_BitcoinDE_StatisticData.h"

@implementation SOXAccountLedgerStatisticsData_KickbackWithShortCurrency_ValueTransformer

+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    NSDecimalNumber *kickbackSum;
    BitcoinDE_CurrencyType currencyType = BitcoinDE_CurrencyTypeUnknown;

    if ([value isKindOfClass:[SOXAccountLedger_BitcoinDE_StatisticData class]]) {
        SOXAccountLedger_BitcoinDE_StatisticData *accountLedgerStatisticData = value;
        kickbackSum = accountLedgerStatisticData.kickbackSum;
        currencyType = accountLedgerStatisticData.currencyType;
    }
    else {
        NSAssert(NO, @"Unknown value class");
    }

    if (kickbackSum
        && currencyType != BitcoinDE_CurrencyTypeUnknown) {
        NSString *shortCurrencyString = [SOXMarket_BitcoinDE_DefTypes tradingPairShortStringUpperCaseForCurrencyType:currencyType];

        NSString *result = [NSString stringWithFormat:@"%@ %@"
                            , [[SOXFormatters bitcoinNumberWithoutCurrencySymbolFormatter] stringFromNumber:kickbackSum]
                            , shortCurrencyString];
        return result;
    }


    return @"Error";
}

@end
