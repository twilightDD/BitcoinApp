//
//  SOXMarket_DefTypes.m
//  BitcoinApp
//
//  Created by Peter Hauke on 21.08.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXMarket_DefTypes.h"

@implementation SOXMarket_DefTypes

+ (NSString *)apiStringForBitcoinCurrencyType:(BitcoinCurrencyType)bitcoinCurrencyType {
    switch (bitcoinCurrencyType) {
        case Bitcoin_UnknownCurrency:
            return nil;
            break;
        case Bitcoin_BitcoinDE_BitcoinOriginal_CurrencyType:
            return @"btceur";
            break;
        case Bitcoin_BitcoinDE_BitcoinCash_CurrencyType:
            return @"bcheur";
            break;
        default:
            return nil;
            break;
    }
}

@end
