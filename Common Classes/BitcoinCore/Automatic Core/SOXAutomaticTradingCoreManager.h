//
//  SOXAutomaticTradingCoreManager.h
//  BitcoinApp
//
//  Created by Peter Hauke on 21.08.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOXMarket_DefTypes.h"


@interface SOXAutomaticTradingCoreManager : NSObject

+ (id)coreForBitcoinCurrency:(BitcoinCurrencyType)bitcoinCurrencyType;

@end
