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
+ (void)executeAutomaticTrades:(BOOL)executeAutomaticTrades forOrderType:(BitcoinDE_OrderType)orderType;
+ (void)executeBalanceTrades:(BOOL)executeBalanceTrades forOrderType:(BitcoinDE_OrderType)orderType;

+ (void)registerController:(id <SOXAutomaticTradingCoreProtocol>)controller
    forUpdatesForOrderType:(BitcoinDE_OrderType)orderType;
+ (void)deRegisterController:(id)controller
      forUpdatesForOrderType:(BitcoinDE_OrderType)orderType;



@end
