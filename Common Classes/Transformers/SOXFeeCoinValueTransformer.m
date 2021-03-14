//
//  SOXFeeCoinValueTransformer.m
//  BitcoinApp
//
//  Created by Peter Hauke on 08.01.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXFeeCoinValueTransformer.h"

#import "SOXMarket_BitcoinDE_DefTypes.h"

#import "SOXFormatters.h"

#import "SOXMyTrades_BitcoinDE_Data.h"

@implementation SOXFeeCoinValueTransformer

+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    NSNumber *feeAmount   = nil;
    NSString *tradingPair = nil;

    if ([value isKindOfClass:[SOXMyTrades_BitcoinDE_Data class]]) {
        SOXMyTrades_BitcoinDE_Data *myTradeData = value;
//        feeAmount                               = myTradeData.feeBTC;
        feeAmount                               = myTradeData.fee_Currency_To_Trade;
        tradingPair                             = myTradeData.trading_pair;
    }

    if (feeAmount && tradingPair) {
        BitcoinDE_CurrencyType currencyType = [SOXMarket_BitcoinDE_DefTypes currencyTypeForTradingPairString:tradingPair];
        NSString *shortCurrencyString       = [SOXMarket_BitcoinDE_DefTypes tradingPairShortStringUpperCaseForCurrencyType:currencyType];

        NSString *result = [NSString stringWithFormat:@"%@ %@", [[SOXFormatters bitcoinNumberWithoutCurrencySymbolFormatter] stringFromNumber:feeAmount], shortCurrencyString];
        return result;
    }
    else if (tradingPair) {
        return @"-";
    }

    return @"Error";
}

@end
