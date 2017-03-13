//
//  SOXMarket_BitcoinDE_Core.h
//  BitcoinApp
//
//  Created by Peter Hauke on 13.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXMarketCore.h"
typedef NS_ENUM (NSUInteger, BitcoinDE_ServerCommandType) {
    UnknownCommand = 0
    , BitcoinDE_ShowOrderbookCommandType
    , BitcoinDE_ShowMyOrdersCommandType
    , BitcoinDE_ShowMyOrderDetailsCommandType
    , BitcoinDE_ShowAccountInfoCommandType
    , BitcoinDE_ShowOrderbookCompactCommandType
    , BitcoinDE_ShowPublicTradeHistoryCommandType
    , BitcoinDE_ShowRatesCommandType
};

@interface SOXMarket_BitcoinDE_Core : SOXMarketCore

+ (NSURLRequest * _Nullable)urlRequestForServerCommandType:(BitcoinDE_ServerCommandType)serverCommandType;

+ (NSArray * _Nonnull)serverCommandsKeys;
+ (NSString * _Nonnull)descriptionForServerCommandType:(BitcoinDE_ServerCommandType)serverCommandType;

@end
