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
                        bitcoinAmount:(NSNumber *)bitcoinAmount{
    if (!orderID
        || orderID.length == 0
        || (orderType != BitcoinDE_BuyOrderType && orderType != BitcoinDE_SellOrderType)) {
        return nil;
    }
    
    NSString *orderTypeString = [SOXMarket_BitcoinDE_DefTypes orderTypeStringForOrderType:orderType];
    NSDictionary *parameter = [NSDictionary dictionaryWithObjectsAndKeys:
                               orderID, BitcoinDE_ExecuteTrade_OrderID
                               ,orderTypeString, BitcoinDE_ExecuteTrade_Type
                               , bitcoinAmount, BitcoinDE_ExecuteTrade_BitcoinAmount
                               , nil];
    
    return parameter;
}

+ (NSDictionary *)parameterAutomaticTradingForOrderID:(NSString *)orderID
                                            orderType:(BitcoinDE_OrderType)orderType
                                        bitcoinAmount:(NSNumber *)bitcoinAmount
                                                price:(NSDecimalNumber *)price {
    NSDictionary *parameters = [self parameterForOrderID:orderID
                                               orderType:orderType
                                          bitcoinAmount:bitcoinAmount];
    NSMutableDictionary *parameterAutomaticTrading = [parameters mutableCopy];
    [parameterAutomaticTrading setObject:@YES forKey:BitcoinDE_ExecuteTrade_IsAutomaticTrade];
    [parameterAutomaticTrading setObject:price forKey:BitcoinDE_ExecuteTrade_Price];

    return [parameterAutomaticTrading copy];
}

+ (NSDictionary *)parameterBalanceTradingForOrderID:(NSString *)orderID
                                          orderType:(BitcoinDE_OrderType)orderType
                                      bitcoinAmount:(NSNumber *)bitcoinAmount
                                              price:(NSDecimalNumber *)price
                                automaticTradePrice:(NSDecimalNumber *)automaticTradePrice {
    NSDictionary *parameters = [self parameterForOrderID:orderID
                                               orderType:orderType
                                           bitcoinAmount:bitcoinAmount];
    NSMutableDictionary *parameterAutomaticTrading = [parameters mutableCopy];
    [parameterAutomaticTrading setObject:@NO forKey:BitcoinDE_ExecuteTrade_IsAutomaticTrade];
    [parameterAutomaticTrading setObject:price forKey:BitcoinDE_ExecuteTrade_Price];
    [parameterAutomaticTrading setObject:automaticTradePrice forKey:BitcoinDE_ExecuteTrade_AutomaticTradePrice];

    return [parameterAutomaticTrading copy];
}

@end
