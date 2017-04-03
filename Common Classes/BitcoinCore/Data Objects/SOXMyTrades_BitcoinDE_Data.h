//
//  SOXMyTrades_BitcoinDE_Data.h
//  BitcoinApp
//
//  Created by Peter Hauke on 03.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, BitcoinDE_MyTradeHistoryParameter_OrderType) {
    BitcoinDE_MyTradeHistoryParameter_UnknownOrderType = 0
    , BitcoinDE_MyTradeHistoryParameter_BuyOrderType   = 1
    , BitcoinDE_MyTradeHistoryParameter_SellOrderType  = 2
};

typedef NS_ENUM (NSUInteger, BitcoinDE_MyTradeHistoryParameter_TradeStateType) {
    BitcoinDE_MyTradeHistoryParameter_UnknownTradeStateType       = 0
    , BitcoinDE_MyTradeHistoryParameter_SuccessfulTradeStateType  = 1
    , BitcoinDE_MyTradeHistoryParameter_PendingTradeStateType     = 2
    , BitcoinDE_MyTradeHistoryParameter_CancelledTradeStateType   = 3
};


@interface SOXMyTrades_BitcoinDE_Data : NSObject

+ (NSDictionary *)parameterForOrderType:(BitcoinDE_MyTradeHistoryParameter_OrderType)orderType
                             tradeState:(BitcoinDE_MyTradeHistoryParameter_TradeStateType)tradeState
                              startDate:(NSDate *)startDate
                                endDate:(NSDate *)endDate
                                   page:(NSInteger)page;

@end
