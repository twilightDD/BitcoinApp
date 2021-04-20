//
//  SOXMyTradeHistoryFeeCoinsValueTransformer.m
//  BitcoinApp
//
//  Created by Peter Hauke on 21.04.21.
//  Copyright © 2021 2sox / Peter Hauke. All rights reserved.
//

#import "SOXMyTradeHistoryFeeCoinsValueTransformer.h"

#import "SOXMarket_BitcoinDE_DefTypes.h"

#import "SOXFormatters.h"

#import "SOXMyTrades_BitcoinDE_Data.h"

@implementation SOXMyTradeHistoryFeeCoinsValueTransformer

+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    NSDecimalNumber *fee_Currency_To_Trade = nil;
    NSString *tradingPair                   = nil;
    
    if ([value isKindOfClass:[SOXMyTrades_BitcoinDE_Data class]]) {
        SOXMyTrades_BitcoinDE_Data *myTradeData = value;
        fee_Currency_To_Trade  = myTradeData.fee_Currency_To_Trade;
        tradingPair            = myTradeData.trading_pair;
    }
    
    if (fee_Currency_To_Trade && tradingPair) {
        BitcoinDE_CurrencyType currencyType = [SOXMarket_BitcoinDE_DefTypes currencyTypeForTradingPairString:tradingPair];
        NSString *shortCurrencyString       = [SOXMarket_BitcoinDE_DefTypes tradingPairShortStringUpperCaseForCurrencyType:currencyType];
        
        NSString *result = [NSString stringWithFormat:@"%@ %@"
                            , [[SOXFormatters bitcoinNumberWithoutCurrencySymbolFormatter] stringFromNumber:fee_Currency_To_Trade]
                            , shortCurrencyString];
        return result;
    }
    else if (tradingPair) {
        return @"-";
    }
    
    return @"Error";
}

@end
