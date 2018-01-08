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

#import "SOXShowOrderbookData.h"

@implementation SOXMinAmountWithShortCurrencyValueTransformer
+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    if ([value isKindOfClass:[SOXShowOrderbookData class]]) {
        SOXShowOrderbookData *orderbookData = value;
        NSDecimalNumber *minAmount = [orderbookData orderInformation_minAmount];
        BitcoinDE_CurrencyType currencyType = [SOXMarket_BitcoinDE_DefTypes currencyTypeForTradingPairString:orderbookData.orderInformation_tradingPair];
        NSString *shortCurrencyString = [SOXMarket_BitcoinDE_DefTypes tradingPairShortStringForCurrencyType:currencyType];

        NSString *result = [NSString stringWithFormat:@"%@ %@"
                            , [[SOXFormatters bitcoinNumberWithoutCurrencySymbolFormatter] stringFromNumber:minAmount]
                            , shortCurrencyString];
        return result;
    }

    return @"Error";
}
@end
