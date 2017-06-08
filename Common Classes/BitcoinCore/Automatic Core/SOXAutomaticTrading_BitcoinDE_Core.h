//
//  SOXAutomaticTrading_BitcoinDE_Core.h
//  BitcoinApp
//
//  Created by Peter Hauke on 07.06.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXAutomaticTradingCore.h"
#import "SOXMarket_BitcoinDE_DefTypes.h"

@interface SOXAutomaticTrading_BitcoinDE_Core : SOXAutomaticTradingCore

+ (void)executeTrades:(BOOL)executeTrades forOrderType:(BitcoinDE_OrderType)orderType;

+ (void)registerController:(id <SOXAutomaticTradingCoreProtocol>)controller
    forUpdatesForOrderType:(BitcoinDE_OrderType)orderType;

+ (void)setBuyInterestRate:(NSDecimalNumber *)buyInterestRate;
+ (void)setSellInterestRate:(NSDecimalNumber *)sellInterestRate;
+ (void)setBuyMaximalEuro:(NSDecimalNumber *)buyMaximalEuro;
+ (void)setSellMaximalBTC:(NSDecimalNumber *)sellMaximalBTC;

@end
