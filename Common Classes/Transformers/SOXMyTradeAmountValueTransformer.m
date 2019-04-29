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
    NSDecimalNumber *ownCalc_amountAfterFee = nil;
    NSString *tradingPair                   = nil;

    if ([value isKindOfClass:[SOXMyTrades_BitcoinDE_Data class]]) {
        SOXMyTrades_BitcoinDE_Data *myTradeData = value;
        ownCalc_amountAfterFee = myTradeData.ownCalc_amountAfterFee;
        tradingPair            = myTradeData.trading_pair;
    }

    if (ownCalc_amountAfterFee && tradingPair) {
        BitcoinDE_CurrencyType currencyType = [SOXMarket_BitcoinDE_DefTypes currencyTypeForTradingPairString:tradingPair];
        NSString *shortCurrencyString       = [SOXMarket_BitcoinDE_DefTypes tradingPairShortStringUpperCaseForCurrencyType:currencyType];

        NSString *result = [NSString stringWithFormat:@"%@ %@"
                            , [[SOXFormatters bitcoinNumberWithoutCurrencySymbolFormatter] stringFromNumber:ownCalc_amountAfterFee]
                            , shortCurrencyString];
        return result;
    }
    else if (tradingPair) {
        return @"-";
    }

    return @"Error";
}

@end
