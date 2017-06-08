//
//  SOXAutomaticTrading_BitcoinDE_Core.h
//  BitcoinApp
//
//  Created by Peter Hauke on 11.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "SOXMarket_BitcoinDE_DefTypes.h"

@protocol SOXAutomaticTradingCoreProtocol <NSObject>

- (void)currentLimitHasChangedTo:(NSNumber *)newLimit;
- (void)logLine:(NSString *)tradeLine;

@end

@interface SOXAutomaticTrading_BitcoinDE_Core_OLD : NSObject



+ (void)registerController:(id <SOXAutomaticTradingCoreProtocol>)controller
    forUpdatesForOrderType:(BitcoinDE_OrderType)orderType;

+ (void)unRegisterController:(id)controller
      forUpdatesForOrderType:(BitcoinDE_OrderType)orderType;

+ (void)setBuyInterestRate:(NSNumber *)buyInterestRate;
+ (void)setSellInterestRate:(NSNumber *)sellInterestRate;
+ (void)setBuyMaximalEuro:(NSNumber *)buyMaximalEuro;
+ (void)setSellMaximalBTC:(NSNumber *)sellMaximalBTC;

@end
