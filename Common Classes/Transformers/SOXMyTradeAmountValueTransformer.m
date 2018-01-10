//
//  SOXMyTradeAmountValueTransformer.m
//  BitcoinApp
//
//  Created by Peter Hauke on 10.01.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXMyTradeAmountValueTransformer.h"

#import "SOXMarket_BitcoinDE_DefTypes.h"

#import "SOXFormatters.h"

#import "SOXMyTrades_BitcoinDE_Data.h"

@implementation SOXMyTradeAmountValueTransformer


+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    NSDecimalNumber *amount = nil;
    NSString *tradingPair = nil;

    if ([value isKindOfClass:[SOXMyTrades_BitcoinDE_Data class]]) {
        SOXMyTrades_BitcoinDE_Data *myTradeData = value;
        amount = myTradeData.amount;
        tradingPair = myTradeData.trading_pair;
    }

    if (amount && tradingPair) {
        BitcoinDE_CurrencyType currencyType = [SOXMarket_BitcoinDE_DefTypes currencyTypeForTradingPairString:tradingPair];
        NSString *shortCurrencyString = [SOXMarket_BitcoinDE_DefTypes tradingPairShortStringUpperCaseForCurrencyType:currencyType];

        NSString *result = [NSString stringWithFormat:@"%@ %@"
                            , [[SOXFormatters bitcoinNumberWithoutCurrencySymbolFormatter] stringFromNumber:amount]
                            , shortCurrencyString];
        return result;
    }
    else if (tradingPair) {
        return @"-";

    }

    return @"Error";
}

@end
