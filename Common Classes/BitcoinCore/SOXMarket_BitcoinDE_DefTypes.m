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

@end
