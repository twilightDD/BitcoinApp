//
//  SOXMarket_DefTypes.m
//  BitcoinApp
//
//  Created by Peter Hauke on 11.11.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXMarket_DefTypes.h"

@implementation SOXMarket_DefTypes

+ (NSString *)stringForCurrencyType:(SOXMarket_CurrencyType )currencyType {
    static NSDictionary    *stringsForCurrencyType;

    static dispatch_once_t pred;

    dispatch_once(&pred, ^{
        stringsForCurrencyType = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"Unknown", @(SOXMarket_CurrencyTypeUnknown)
                                    , @"Bitcoin", @(SOXMarket_CurrencyTypeBitcoin)
                                    , @"Bitcoin Cash", @(SOXMarket_CurrencyTypeBitcoinCash)
                                    , @"Ethereum", @(SOXMarket_CurrencyTypeEthereum)
                                    , @"All", @(SOXMarket_CurrencyTypeAll)
                                    , nil];
    });

    return [stringsForCurrencyType objectForKey:@(currencyType)];
}

+ (NSString *)shortStringForCurrencyType:(SOXMarket_CurrencyType )currencyType {
    static NSDictionary    *shortStringsForCurrencyType;

    static dispatch_once_t pred;

    dispatch_once(&pred, ^{
        shortStringsForCurrencyType = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"???", @(SOXMarket_CurrencyTypeUnknown)
                                  , @"BTC", @(SOXMarket_CurrencyTypeBitcoin)
                                  , @"BCH", @(SOXMarket_CurrencyTypeBitcoinCash)
                                  , @"ETH", @(SOXMarket_CurrencyTypeEthereum)
                                  , @"all", @(SOXMarket_CurrencyTypeAll)
                                  , nil];
    });

    return [shortStringsForCurrencyType objectForKey:@(currencyType)];
}

@end
