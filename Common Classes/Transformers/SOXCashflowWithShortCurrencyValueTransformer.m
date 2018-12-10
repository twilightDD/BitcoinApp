//
//  SOXCashflowWithShortCurrencyValueTransformer.m
//  BitcoinApp
//
//  Created by Peter Hauke on 28.02.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXCashflowWithShortCurrencyValueTransformer.h"

#import "SOXFormatters.h"

#import "SOXMarket_BitcoinDE_DefTypes.h"

#import "SOXAccountLedger_BitcoinDE_Data.h"
#import "SOXAccountLedger_BitcoinDE_StatisticData.h"

@implementation SOXCashflowWithShortCurrencyValueTransformer


+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    NSDecimalNumber *cashflow = nil;
    BitcoinDE_CurrencyType currencyType = BitcoinDE_CurrencyTypeUnknown;


    if ([value isKindOfClass:[SOXAccountLedger_BitcoinDE_Data class]]) {
        SOXAccountLedger_BitcoinDE_Data *accountLedgerData = value;
        cashflow = accountLedgerData.positionDetails_Cashflow;
        NSString *tradingPair = accountLedgerData.tradeDetails_trading_pair;
        currencyType = [SOXMarket_BitcoinDE_DefTypes currencyTypeForTradingPairString:tradingPair];
    }
    else if ([value isKindOfClass:[SOXAccountLedger_BitcoinDE_StatisticData class]]) {
        SOXAccountLedger_BitcoinDE_StatisticData *accountLedgerStatisticData = value;
        cashflow = accountLedgerStatisticData.coinSum;
        currencyType = accountLedgerStatisticData.currencyType;
    }

    if (cashflow
        && currencyType != BitcoinDE_CurrencyTypeUnknown) {
        NSString *shortCurrencyString = [SOXMarket_BitcoinDE_DefTypes tradingPairShortStringUpperCaseForCurrencyType:currencyType];

        NSString *result = [NSString stringWithFormat:@"%@ %@"
                            , [[SOXFormatters bitcoinNumberWithoutCurrencySymbolFormatter] stringFromNumber:cashflow]
                            , shortCurrencyString];
        return result;
    }
    else if (cashflow) {
        return cashflow;
    }

    return @"Error";
}

@end
