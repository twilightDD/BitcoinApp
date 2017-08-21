//
//  SOXAutomaticTradingCoreManager.m
//  BitcoinApp
//
//  Created by Peter Hauke on 21.08.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXAutomaticTradingCoreManager.h"

#import "SOXAutomaticTrading_BitcoinDE_Core.h"

@interface SOXAutomaticTradingCoreManager ()

@property (strong, nonatomic) NSMutableDictionary *automaticTradingCores;

@end

@implementation SOXAutomaticTradingCoreManager

+ (instancetype)sharedManager {
    static SOXAutomaticTradingCoreManager *sharedManager;

    static dispatch_once_t pred;

    dispatch_once(&pred, ^{
        sharedManager = [[SOXAutomaticTradingCoreManager alloc] init];
        [sharedManager setup];
    });

    return sharedManager;
}

- (void)setup {
    self.automaticTradingCores = [NSMutableDictionary dictionary];
}

+ (id)coreForBitcoinCurrency:(BitcoinCurrencyType)bitcoinCurrencyType {
    // get manager singleton (singleton = unique object!).
    SOXAutomaticTradingCoreManager *manager = [SOXAutomaticTradingCoreManager sharedManager];

    // look up in cache for an autoTradingCore for given bitcoinCurrencyType.
    id coreForBitcoinCurrency = [manager.automaticTradingCores objectForKey:@(bitcoinCurrencyType)];

    // if there was an autoTradingCore for given bitcoinCurrencyType: return it.
    if (coreForBitcoinCurrency) {
        return coreForBitcoinCurrency;
    }

    // otherwise create an autoTradingCore, depending on given bitcoinCurrencyType ...
    // ... and set the bitcoinCurrencyType on new core.
    switch (bitcoinCurrencyType) {
        case Bitcoin_BitcoinDE_BitcoinOriginal_CurrencyType:
        case Bitcoin_BitcoinDE_BitcoinCash_CurrencyType:
            coreForBitcoinCurrency = [[SOXAutomaticTrading_BitcoinDE_Core alloc] init];
            [(SOXAutomaticTrading_BitcoinDE_Core *)coreForBitcoinCurrency setupProperties];
            [(SOXAutomaticTrading_BitcoinDE_Core *)coreForBitcoinCurrency setBitcoinCurrencyType:bitcoinCurrencyType];
            break;

        default:
            break;
    }

    // if a new autoTradingCore was created, add it to the cache.
    if (coreForBitcoinCurrency) {
        [manager.automaticTradingCores setObject:coreForBitcoinCurrency
                                          forKey:@(bitcoinCurrencyType)];
    }

    // and return the new autoTradingCore.
    return coreForBitcoinCurrency;
}


@end
