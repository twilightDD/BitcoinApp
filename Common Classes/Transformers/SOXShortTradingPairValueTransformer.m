//
//  SOXShortTradingPairValueTransformer.m
//  BitcoinApp
//
//  Created by Peter Hauke on 11.11.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXShortTradingPairValueTransformer.h"
#import "SOXMarket_BitcoinDE_DefTypes.h"

@implementation SOXShortTradingPairValueTransformer

+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    if ([value isKindOfClass:[NSNumber class]]) {
        NSNumber *currencyTypeNumber = value;
        SOXMarket_CurrencyType currencyType = currencyTypeNumber.integerValue;
        NSString *transformedValue = [SOXMarket_BitcoinDE_DefTypes tradingPairShortStringForCurrencyType:currencyType];
        return transformedValue;
    }

    return @"Error";
}

@end
