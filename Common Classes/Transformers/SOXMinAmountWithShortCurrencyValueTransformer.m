//
//  SOXMinAmountWithShortCurrencyValueTransformer.m
//  BitcoinApp
//
//  Created by Peter Hauke on 08.01.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXMinAmountWithShortCurrencyValueTransformer.h"

#import "SOXMarket_BitcoinDE_DefTypes.h"

#import "SOXFormatters.h"

#import "SOXMyOrderBookData.h"
#import "SOXShowOrderbookData.h"

@implementation SOXMinAmountWithShortCurrencyValueTransformer
+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    NSNumber *minAmount = nil;
    NSString *tradingPair = nil;

    if ([value isKindOfClass:[SOXShowOrderbookData class]]) {
        SOXShowOrderbookData *orderbookData = value;
        minAmount = [orderbookData orderInformation_minAmount];
        tradingPair = orderbookData.orderInformation_tradingPair;
    }
    else if ([value isKindOfClass:[SOXMyOrderBookData class]]) {
        SOXMyOrderBookData *myOrderBookData = value;
        minAmount = [myOrderBookData orderInformation_minAmount];
        tradingPair = myOrderBookData.orderInformation_tradingPair;
    }

    if (minAmount && tradingPair) {
        BitcoinDE_CurrencyType currencyType = [SOXMarket_BitcoinDE_DefTypes currencyTypeForTradingPairString:tradingPair];
        NSString *shortCurrencyString = [SOXMarket_BitcoinDE_DefTypes tradingPairShortStringForCurrencyType:currencyType];

        NSString *result = [NSString stringWithFormat:@"%@ %@"
                            , [[SOXFormatters bitcoinNumberWithoutCurrencySymbolFormatter] stringFromNumber:minAmount]
                            , shortCurrencyString];
        return result;
    }

    return @"Error";
}

@end
