//
//  SOXMarket_BitcoinDE_OrderTypes.h
//  BitcoinApp
//
//  Created by Peter Hauke on 11.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, BitcoinDE_ServerCommandType) {
    UnknownCommand = 0
    , BitcoinDE_ShowBuyOrderbookCommandType  //"buy" liefert Verkaufsangebote
    , BitcoinDE_ShowSellOrderbookCommandType //"sell" liefert Kaufangebote
    , BitcoinDE_ShowMyOrdersCommandType
    , BitcoinDE_ShowMyOrderDetailsCommandType
    , BitcoinDE_ShowAccountInfoCommandType
    , BitcoinDE_ShowOrderbookCompactCommandType
    , BitcoinDE_ShowPublicTradeHistoryCommandType
    , BitcoinDE_ShowRatesCommandType
    , BitcoinDE_ShowMyTradesType
    , BitcoinDE_ShowAccountLedgerType
    , BitcoinDE_RemoveOrderType
    , BitcoinDE_CreateOrderType
    , BitcoinDE_ExecuteTrade
};

typedef NS_ENUM (NSUInteger, BitcoinDE_OrderType) {
    BitcoinDE_UnknownOrderType
    , BitcoinDE_BuyOrderType
    , BitcoinDE_SellOrderType
};

typedef NS_ENUM (NSUInteger, BitcoinDE_MinimalTrustLevel) {
    BitcoinDE_UnknownMinimalTrustLevel = 0
    , BitcoinDE_BronzeMinimalTrustLevel = 1
    , BitcoinDE_SilverMinimalTrustLevel = 2
    , BitcoinDE_GoldMinimalTrustLevel = 3
};

typedef NS_ENUM (NSUInteger, BitcoinDE_PaymentOption) {
    BitcoinDE_PaymentOptionUnknown          = 0
    , BitcoinDE_PaymentOptionExpressOnly    = 1
    , BitcoinDE_PaymentOptionSEPAOnly       = 2
    , BitcoinDE_PaymentOptionExpressAndSepa = 3
};

typedef NS_ENUM (NSUInteger, BitcoinDE_UpdateType) {
    UnknownType = 0
    , BitcoinDE_UpdateType_AllOrderChanges
    , BitcoinDE_UpdateType_BuyOrderChanges
    , BitcoinDE_UpdateType_SellOrderChanges
    , BitcoinDE_UpdateType_RemoveOrderChanges
};


@interface SOXMarket_BitcoinDE_DefTypes : NSObject

+ (NSString *)orderTypeStringForOrderType:(BitcoinDE_OrderType)orderType;

@end
