//
//  SOXMarket_DefTypes.h
//  BitcoinApp
//
//  Created by Peter Hauke on 11.11.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, SOXMarket_CurrencyType) {
    SOXMarket_CurrencyTypeUnknown = 0
    , SOXMarket_CurrencyTypeBitcoin = 1000
    , SOXMarket_CurrencyTypeBitcoinCash = 1100
    , SOXMarket_CurrencyTypeEthereum = 2000
    , SOXMarket_CurrencyTypeAll = 100000
};

@interface SOXMarket_DefTypes : NSObject

+ (NSString *)stringForCurrencyType:(SOXMarket_CurrencyType)currencyType;
+ (NSString *)shortStringForCurrencyType:(SOXMarket_CurrencyType)currencyType;

@end
