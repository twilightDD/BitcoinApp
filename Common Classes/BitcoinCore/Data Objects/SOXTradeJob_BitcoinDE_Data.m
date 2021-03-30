//
//  SOXTradeJob_BitcoinDE_Data.m
//  BitcoinApp
//
//  Created by Peter Hauke on 14.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXTradeJob_BitcoinDE_Data.h"

#import "SOXKeys_BitcoinDE.h"
@implementation SOXTradeJob_BitcoinDE_Data

+ (NSDictionary *)parameterForOrderID:(NSString *)orderID
                            orderType:(BitcoinDE_OrderType)orderType
                        bitcoinAmount:(NSNumber *)bitcoinAmount
                      forCurrencyType:(BitcoinDE_CurrencyType)currencyType {
    if (!orderID || orderID.length == 0 || (orderType != BitcoinDE_OrderTypeBuy && orderType != BitcoinDE_OrderTypeSell)) {
        return nil;
    }

    // currencyType
    NSString *currencyTypeString = [SOXMarket_BitcoinDE_DefTypes tradingPairStringForCurrencyType:currencyType];

    NSString *orderTypeString = [SOXMarket_BitcoinDE_DefTypes orderTypeStringForOrderType:orderType];
    NSDictionary *parameter   = [NSDictionary dictionaryWithObjectsAndKeys:
                                 orderID, BitcoinDE_ExecuteTrade_OrderID,
                                 orderTypeString, BitcoinDE_ExecuteTrade_Type,
                                 bitcoinAmount, BitcoinDE_ExecuteTrade_Amount_currency_to_trade,
                                 currencyTypeString, BitcoinDE_ShowOrderbook_TradingPair,
                                 nil];

    return parameter;
}

+ (NSDictionary *)parameterAutomaticTradingForOrderID:(NSString *)orderID
                                            orderType:(BitcoinDE_OrderType)orderType
                                        bitcoinAmount:(NSNumber *)bitcoinAmount
                                                price:(NSDecimalNumber *)price
                                      forCurrencyType:(BitcoinDE_CurrencyType)currencyType {
    NSDictionary *parameters = [self parameterForOrderID:orderID
                                               orderType:orderType
                                           bitcoinAmount:bitcoinAmount
                                         forCurrencyType:currencyType];

    NSMutableDictionary *parameterAutomaticTrading = [parameters mutableCopy];
    [parameterAutomaticTrading setObject:@YES forKey:BitcoinDE_ExecuteTrade_IsAutomaticTrade];
    [parameterAutomaticTrading setObject:price forKey:BitcoinDE_ExecuteTrade_Price];
    [parameterAutomaticTrading setObject:price forKey:BitcoinDE_ExecuteTrade_AutomaticTradePrice];

    return [parameterAutomaticTrading copy];
}

+ (NSDictionary *)parameterBalanceTradingForOrderID:(NSString *)orderID
                                          orderType:(BitcoinDE_OrderType)orderType
                                      bitcoinAmount:(NSNumber *)bitcoinAmount
                                              price:(NSDecimalNumber *)price
                                automaticTradePrice:(NSDecimalNumber *)automaticTradePrice
                                    forCurrencyType:(BitcoinDE_CurrencyType)currencyType {

    NSDictionary *parameters = [self parameterForOrderID:orderID
                                               orderType:orderType
                                           bitcoinAmount:bitcoinAmount
                                         forCurrencyType:currencyType];

    NSMutableDictionary *parameterAutomaticTrading = [parameters mutableCopy];
    [parameterAutomaticTrading setObject:@NO forKey:BitcoinDE_ExecuteTrade_IsAutomaticTrade];
    [parameterAutomaticTrading setObject:price forKey:BitcoinDE_ExecuteTrade_Price];
    [parameterAutomaticTrading setObject:automaticTradePrice forKey:BitcoinDE_ExecuteTrade_AutomaticTradePrice];

    return [parameterAutomaticTrading copy];
}

@end
