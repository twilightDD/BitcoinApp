//
//  SOXCashflowWithShortCurrencyValueTransformer.m
//  BitcoinApp
//
//  Created by Peter Hauke on 28.02.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXCashflowWithShortCurrencyValueTransformer.h"

#import "SOXFormatters.h"

#import "SOXAccountLedger_BitcoinDE_Data.h"

@implementation SOXCashflowWithShortCurrencyValueTransformer


+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    NSDecimalNumber *cashflow = nil;
    NSString *tradingPair = nil;

    if ([value isKindOfClass:[SOXAccountLedger_BitcoinDE_Data class]]) {
        SOXAccountLedger_BitcoinDE_Data *accountLedgerData = value;
        cashflow = accountLedgerData.positionDetails_Cashflow;
        tradingPair = accountLedgerData.tradeDetails_trading_pair;
    }

    if (cashflow && tradingPair) {
        BitcoinDE_CurrencyType currencyType = [SOXMarket_BitcoinDE_DefTypes currencyTypeForTradingPairString:tradingPair];
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
