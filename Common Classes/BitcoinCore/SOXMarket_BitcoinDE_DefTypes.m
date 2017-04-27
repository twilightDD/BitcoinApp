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

@end
