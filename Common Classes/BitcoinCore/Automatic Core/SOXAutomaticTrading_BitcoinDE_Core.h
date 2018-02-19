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

- (instancetype)initForCurrencyTyp:(BitcoinDE_CurrencyType)currencyType;

- (void)registerControllerForUpdates:(id <SOXAutomaticTradingCoreProtocol>)controller;
- (void)deRegisterControllerForUpdates:(id)controller;

- (void)executeTrades:(BOOL)executeTrades;
- (void)executeAutomaticTrades:(BOOL)executeAutomaticTrades;
- (void)executeBalanceTrades:(BOOL)executeBalanceTrades;






@end
