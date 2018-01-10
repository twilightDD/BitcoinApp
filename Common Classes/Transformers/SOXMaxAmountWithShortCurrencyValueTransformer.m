//
//  SOXMaxAmountWithShortCurrencyValueTransformer.m
//  BitcoinApp
//
//  Created by Peter Hauke on 08.01.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXMaxAmountWithShortCurrencyValueTransformer.h"

#import "SOXMarket_BitcoinDE_DefTypes.h"

#import "SOXFormatters.h"

#import "SOXMyOrderBookData.h"
#import "SOXShowOrderbookData.h"

@implementation SOXMaxAmountWithShortCurrencyValueTransformer

+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    NSNumber *maxAmount = nil;
    NSString *tradingPair = nil;

    if ([value isKindOfClass:[SOXShowOrderbookData class]]) {
        SOXShowOrderbookData *orderbookData = value;
        maxAmount = [orderbookData orderInformation_maxAmount];
        tradingPair = orderbookData.orderInformation_tradingPair;
    }
    else if ([value isKindOfClass:[SOXMyOrderBookData class]]) {
        SOXMyOrderBookData *myOrderBookData = value;
        maxAmount = [myOrderBookData orderInformation_maxAmount];
        tradingPair = myOrderBookData.orderInformation_tradingPair;
    }

    if (maxAmount && tradingPair) {
        BitcoinDE_CurrencyType currencyType = [SOXMarket_BitcoinDE_DefTypes currencyTypeForTradingPairString:tradingPair];
        NSString *shortCurrencyString = [SOXMarket_BitcoinDE_DefTypes tradingPairShortStringUpperCaseForCurrencyType:currencyType];

        NSString *result = [NSString stringWithFormat:@"%@ %@"
                            , [[SOXFormatters bitcoinNumberWithoutCurrencySymbolFormatter] stringFromNumber:maxAmount]
                            , shortCurrencyString];
        return result;
    }

    return @"Error";
}

@end
