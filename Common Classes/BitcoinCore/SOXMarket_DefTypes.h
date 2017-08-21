//
//  SOXMarket_DefTypes.h
//  BitcoinApp
//
//  Created by Peter Hauke on 21.08.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, BitcoinCurrencyType) {
    Bitcoin_UnknownCurrency = 0
    , Bitcoin_BitcoinDE_BitcoinOriginal_CurrencyType = 1
    , Bitcoin_BitcoinDE_BitcoinCash_CurrencyType = 2
};

@interface SOXMarket_DefTypes : NSObject

+ (NSString *)apiStringForBitcoinCurrencyType:(BitcoinCurrencyType)bitcoinCurrencyType;

@end
