//
//  SOXMarket_BitcoinDE_DefTypes.m
//  BitcoinApp
//
//  Created by Peter Hauke on 11.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXMarket_BitcoinDE_DefTypes.h"

@implementation SOXMarket_BitcoinDE_DefTypes

+ (NSString *)orderTypeStringForOrderType:(BitcoinDE_OrderType)orderType {
    switch (orderType) {
        case  BitcoinDE_BuyOrderType:
            return @"buy";
            break;
        case  BitcoinDE_SellOrderType:
            return @"sell";
            break;
        default:
            return nil;
            break;
    }
}

+ (BitcoinDE_OrderType)orderTypeForOrderTypeString:(NSString *)orderTypeString {
    BitcoinDE_OrderType orderType = BitcoinDE_UnknownOrderType;
    if ([orderTypeString isEqualToString:@"buy"]) {
        orderType = BitcoinDE_BuyOrderType;
    }
    else if ([orderTypeString isEqualToString:@"sell"]) {
        orderType = BitcoinDE_SellOrderType;
    }

    return orderType;
}

+ (NSString *)paymentOptionStringForPaymentOption:(BitcoinDE_PaymentOption)paymentOption {
    static NSDictionary    *paymentOptionDescription;
    
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        paymentOptionDescription = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"Unknown", @(BitcoinDE_PaymentOptionUnknown)
                                    , @"Express", @(BitcoinDE_PaymentOptionExpressOnly)
                                    , @"SEPA", @(BitcoinDE_PaymentOptionSEPAOnly)
                                    , @"Express/SEPA", @(BitcoinDE_PaymentOptionExpressAndSepa)
                                    , nil];
    });
    
    return [paymentOptionDescription objectForKey:@(paymentOption)];
}

+ (NSString *)trustLevelStringForTrustLevel:(BitcoinDE_TrustLevel)trustLevel {
    static NSDictionary    *trustLevelDescription;
    
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        trustLevelDescription = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"Unknown", @(BitcoinDE_TrustLevelUnknown)
                                    , @"bronze", @(BitcoinDE_TrustLevelBronze)
                                    , @"silver", @(BitcoinDE_TrustLevelSilver)
                                    , @"gold", @(BitcoinDE_TrustLevelGold)
                                    , nil];
    });
    
    return [trustLevelDescription objectForKey:@(trustLevel)];
}

+ (BitcoinDE_TrustLevel)trustLevelForTrustLevelString:(NSString *)trustLevelString {
    static NSDictionary    *trustLevelDescription;

    static dispatch_once_t pred;

    dispatch_once(&pred, ^{
        trustLevelDescription = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @(BitcoinDE_TrustLevelUnknown), @"Unknown"
                                 , @(BitcoinDE_TrustLevelBronze), @"bronze"
                                 , @(BitcoinDE_TrustLevelSilver), @"silver"
                                 , @(BitcoinDE_TrustLevelGold), @"gold"
                                 , nil];
    });

    return [[trustLevelDescription objectForKey:trustLevelString] unsignedIntegerValue];
}

+ (NSString *)tradingPairStringForCurrencyType:(BitcoinDE_CurrencyType)currencyType {
    NSString *tradingPairStringForCurrencyType = [[self tradingPairCurrencyTypeDictionary] objectForKey:@(currencyType)];
    return tradingPairStringForCurrencyType;
}

+ (NSString *)tradingPairShortStringLowerCaseForCurrencyType:(BitcoinDE_CurrencyType)currencyType {
    static NSDictionary    *tradingPairShortStringsForCurrencyType;

    static dispatch_once_t pred;

    dispatch_once(&pred, ^{
        tradingPairShortStringsForCurrencyType = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  @"???", @(BitcoinDE_CurrencyTypeUnknown)
                                                  , @"btc", @(BitcoinDE_CurrencyTypeBitcoin)
                                                  , @"bch", @(BitcoinDE_CurrencyTypeBitcoinCash)
                                                  , @"eth", @(BitcoinDE_CurrencyTypeEthereum)
                                                  , nil];
    });

    NSString *tradingPairShortStringForCurrencyType = [tradingPairShortStringsForCurrencyType objectForKey:@(currencyType)];
    return tradingPairShortStringForCurrencyType;
}

+ (NSString *)tradingPairShortStringUpperCaseForCurrencyType:(BitcoinDE_CurrencyType)currencyType {
    static NSDictionary    *tradingPairShortStringsForCurrencyType;

    static dispatch_once_t pred;

    dispatch_once(&pred, ^{
        tradingPairShortStringsForCurrencyType = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  @"???", @(BitcoinDE_CurrencyTypeUnknown)
                                                  , @"BTC", @(BitcoinDE_CurrencyTypeBitcoin)
                                                  , @"BCH", @(BitcoinDE_CurrencyTypeBitcoinCash)
                                                  , @"ETH", @(BitcoinDE_CurrencyTypeEthereum)
                                                  , nil];
    });

    NSString *tradingPairShortStringForCurrencyType = [tradingPairShortStringsForCurrencyType objectForKey:@(currencyType)];
    return tradingPairShortStringForCurrencyType;
}

+ (NSString *)tradingPairNaturalStringForCurrencyType:(BitcoinDE_CurrencyType)currencyType {
    static NSDictionary    *tradingPairNaturalStringsForCurrencyType;

    static dispatch_once_t pred;

    dispatch_once(&pred, ^{
        tradingPairNaturalStringsForCurrencyType = [NSDictionary dictionaryWithObjectsAndKeys:
                                                    @"Unbekannt", @(BitcoinDE_CurrencyTypeUnknown)
                                                    , @"Bitcoin", @(BitcoinDE_CurrencyTypeBitcoin)
                                                    , @"Bitcoin Cash", @(BitcoinDE_CurrencyTypeBitcoinCash)
                                                    , @"Ethereum", @(BitcoinDE_CurrencyTypeEthereum)
                                                    , nil];
    });

    NSString *tradingPairNaturalStringForCurrencyType = [tradingPairNaturalStringsForCurrencyType objectForKey:@(currencyType)];
    return tradingPairNaturalStringForCurrencyType;
}


+ (BitcoinDE_CurrencyType)currencyTypeForTradingPairString:(NSString *)tradingPairString {
    NSArray *currencyTypes = [[self tradingPairCurrencyTypeDictionary] allKeysForObject:tradingPairString];
    NSAssert(currencyTypes.count < 2, @"more than one key for given object");

    NSNumber *currencyTypeNumber = currencyTypes.firstObject;
    BitcoinDE_CurrencyType currencyType = currencyTypeNumber.integerValue;

    return currencyType;
}

+ (NSDictionary *)tradingPairCurrencyTypeDictionary {
    static NSDictionary    *tradingPairStringsForCurrencyTyp;

    static dispatch_once_t pred;

    dispatch_once(&pred, ^{
        tradingPairStringsForCurrencyTyp = [NSDictionary dictionaryWithObjectsAndKeys:
                                            @"btceur", @(BitcoinDE_CurrencyTypeBitcoin)
                                            , @"bcheur", @(BitcoinDE_CurrencyTypeBitcoinCash)
                                            , @"etheur", @(BitcoinDE_CurrencyTypeEthereum)
                                            , nil];
    });

    return tradingPairStringsForCurrencyTyp;
}

@end
