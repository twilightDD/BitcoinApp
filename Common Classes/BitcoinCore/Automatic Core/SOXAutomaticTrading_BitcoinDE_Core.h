//
//  SOXAutomaticTrading_BitcoinDE_Core.h
//  BitcoinApp
//
//  Created by Peter Hauke on 11.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "SOXAutomaticTradingCore.h"
#import "SOXMarket_BitcoinDE_DefTypes.h"

@interface SOXAutomaticTrading_BitcoinDE_Core : NSObject
@property (nonatomic) double buyLowestPrice;
@property (nonatomic) double sellHighestPrice;
@property (nonatomic) double buyInterestRate;
@property (nonatomic) double sellInterestRate;

@property (nonatomic) double freeReservation;
@property (nonatomic) double freeBitcoins;

@property (nonatomic) BitcoinDE_OrderType orderType;

+ (void)registerController:(id <SOXAutomaticTradingCoreProtocol>)controller
    forUpdatesForOrderType:(BitcoinDE_OrderType)orderType;

+ (void)unRegisterController:(id)controller
      forUpdatesForOrderType:(BitcoinDE_OrderType)orderType;

@end
