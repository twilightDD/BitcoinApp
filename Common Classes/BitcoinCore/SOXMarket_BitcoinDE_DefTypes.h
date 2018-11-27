//
//  SOXMarket_BitcoinDE_DefTypes.h
//  BitcoinApp
//
//  Created by Peter Hauke on 11.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXMarket_DefTypes.h"

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
    BitcoinDE_OrderTypeUnknown
    , BitcoinDE_OrderTypeBuy
    , BitcoinDE_OrderTypeSell
    , BitcoinDE_OrderType_EndOfType
};

typedef NS_ENUM (NSUInteger, BitcoinDE_TrustLevel) {
    BitcoinDE_TrustLevelUnknown = 0
    , BitcoinDE_TrustLevelBronze = 1
    , BitcoinDE_TrustLevelSilver = 2
    , BitcoinDE_TrustLevelGold = 3
};

typedef NS_ENUM (NSUInteger, BitcoinDE_PaymentOption) {
    BitcoinDE_PaymentOptionUnknown          = 0
    , BitcoinDE_PaymentOptionExpressOnly    = 1
    , BitcoinDE_PaymentOptionSEPAOnly       = 2
    , BitcoinDE_PaymentOptionExpressAndSepa = 3
};

typedef NS_ENUM (NSUInteger, BitcoinDE_SocketUpdateType) {
    BitcoinDE_SocketUpdateType_Unknown = 0
    , BitcoinDE_SocketUpdateType_BuyOrderChanges
    , BitcoinDE_SocketUpdateType_SellOrderChanges
    , BitcoinDE_SocketUpdateType_RemoveOrderChanges
};

typedef NS_ENUM (NSInteger, BitcoinDE_CurrencyType) {
    BitcoinDE_CurrencyTypeUnknown = 0
    , BitcoinDE_CurrencyTypeBitcoin = 1
    , BitcoinDE_CurrencyTypeBitcoinCash = 2
    , BitcoinDE_CurrencyTypeBitcoinCashSV = 3
    , BitcoinDE_CurrencyTypeBitcoinGold = 4
    , BitcoinDE_CurrencyTypeEthereum = 5
    , BitcoinDE_CurrencyType_EndOfType = 6
};

typedef NS_ENUM (NSInteger, BitcoinDE_OrderStateType) {
    BitcoinDE_OrderStateTypeUnknown = 1
    , BitcoinDE_OrderStateTypePending = 0 // 0 => auf Markt verfügbar
    , BitcoinDE_OrderStateTypeCancelled = -1// -1 => abgebrochen
    , BitcoinDE_OrderStateTypeExpired = -2// -2 => ausgelaufen
    , BitcoinDE_OrderStateType_EndOfType = -3
};

@interface SOXMarket_BitcoinDE_DefTypes : SOXMarket_DefTypes

#pragma mark - Magic Numbers
+ (NSDecimalNumber *)bitcoindDE_feeFactor;
+ (NSDecimalNumber *)fidor_feeFactorStarting20180221;

#pragma mark - Helper Methods
+ (NSString *)naturalStringForOrderType:(BitcoinDE_OrderType)orderType;
+ (NSString *)orderTypeStringForOrderType:(BitcoinDE_OrderType)orderType;
+ (BitcoinDE_OrderType)orderTypeForOrderTypeString:(NSString *)orderTypeString;
+ (NSString *)paymentOptionStringForPaymentOption:(BitcoinDE_PaymentOption)paymentOption;
+ (NSString *)trustLevelStringForTrustLevel:(BitcoinDE_TrustLevel)trustLevel;
+ (BitcoinDE_TrustLevel)trustLevelForTrustLevelString:(NSString *)trustLevelString;

+ (NSString *)tradingPairStringForCurrencyType:(BitcoinDE_CurrencyType)currencyType;
+ (NSString *)tradingPairShortStringLowerCaseForCurrencyType:(BitcoinDE_CurrencyType)currencyType;
+ (NSString *)tradingPairShortStringUpperCaseForCurrencyType:(BitcoinDE_CurrencyType)currencyType;
+ (NSString *)tradingPairNaturalStringForCurrencyType:(BitcoinDE_CurrencyType)currencyType;
+ (BitcoinDE_CurrencyType)currencyTypeForTradingPairString:(NSString *)tradingPairString;

+ (NSString *)orderStateTypeStringForOrderstateType:(BitcoinDE_OrderStateType)orderStateType; 

@end
