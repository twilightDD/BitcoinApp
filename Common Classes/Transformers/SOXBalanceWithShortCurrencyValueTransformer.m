//
//  SOXBalanceWithShortCurrencyValueTransformer.m
//  BitcoinApp
//
//  Created by Peter Hauke on 28.02.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXBalanceWithShortCurrencyValueTransformer.h"

#import "SOXFormatters.h"

#import "SOXAccountLedger_BitcoinDE_Data.h"

@implementation SOXBalanceWithShortCurrencyValueTransformer

+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    NSDecimalNumber *balance = nil;
    NSString *tradingPair = nil;

    if ([value isKindOfClass:[SOXAccountLedger_BitcoinDE_Data class]]) {
        SOXAccountLedger_BitcoinDE_Data *accountLedgerData = value;
        balance = accountLedgerData.positionDetails_Balance;
        tradingPair = accountLedgerData.tradeDetails_trading_pair;
    }

    if (balance && tradingPair) {
        BitcoinDE_CurrencyType currencyType = [SOXMarket_BitcoinDE_DefTypes currencyTypeForTradingPairString:tradingPair];
        NSString *shortCurrencyString = [SOXMarket_BitcoinDE_DefTypes tradingPairShortStringUpperCaseForCurrencyType:currencyType];

        NSString *result = [NSString stringWithFormat:@"%@ %@"
                            , [[SOXFormatters bitcoinNumberWithoutCurrencySymbolFormatter] stringFromNumber:balance]
                            , shortCurrencyString];
        return result;
    }
    else if (balance) {
        return balance;
    }

    return @"Error";
}

@end
