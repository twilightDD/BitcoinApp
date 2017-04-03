//
//  SOXMyTrades_BitcoinDE_Data.m
//  BitcoinApp
//
//  Created by Peter Hauke on 03.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXMyTrades_BitcoinDE_Data.h"

#import "SOXDateFormatter.h"

@implementation SOXMyTrades_BitcoinDE_Data

+ (NSDictionary *)parameterFor {
    NSString *dateStart = [SOXDateFormatter rfc3339DateTimeStringDate:[NSDate dateWithTimeInterval:-86400*7
                                                                                         sinceDate:[NSDate date]]];
    NSString *dateEnd = [SOXDateFormatter rfc3339DateTimeStringDate:[NSDate date]];
    
    NSLog(@"SOXMyTrades_BitcoinDE_Data dateStart %@", dateStart);
    NSLog(@"SOXMyTrades_BitcoinDE_Data dateEnd   %@", dateEnd);
    
    NSDictionary *parameterDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"buy", @"type"
                                   , @(1), @"state"
                                   , dateStart, @"date_start"
                                   , dateEnd, @"date_end"
                                   , @(1), @"page"
                                   , nil];
    
    return parameterDict;
}

+ (NSDictionary *)parameterForOrderType:(BitcoinDE_MyTradeHistoryParameter_OrderType)orderType
                             tradeState:(BitcoinDE_MyTradeHistoryParameter_TradeStateType)tradeState
                              startDate:(NSDate *)startDate
                                endDate:(NSDate *)endDate
                                   page:(NSInteger)page {

    NSString *orderTypeString;
    switch (orderType) {
        case BitcoinDE_MyTradeHistoryParameter_BuyOrderType:
            orderTypeString = @"buy";
            break;
        case BitcoinDE_MyTradeHistoryParameter_SellOrderType:
            orderTypeString = @"sell";
        default:
            break;
    }
    
    NSNumber *tradeStateNumber;
    switch (tradeState) {
        case BitcoinDE_MyTradeHistoryParameter_CancelledTradeStateType:
            tradeStateNumber = @(-1);
            break;
        case BitcoinDE_MyTradeHistoryParameter_PendingTradeStateType:
            tradeStateNumber = @(0);
            break;
        case BitcoinDE_MyTradeHistoryParameter_SuccessfulTradeStateType:
            tradeStateNumber = @(1);
            break;
        default:
            break;
    }
    
    NSString *startDateString = [SOXDateFormatter rfc3339DateTimeStringDate:startDate];
    NSString *endDateString   = [SOXDateFormatter rfc3339DateTimeStringDate:endDate];
    
    NSNumber *pageNumber = @(page);
    
    return [self parameterDictionaryForOrderType:orderTypeString
                                      tradeState:tradeStateNumber
                                       startDate:startDateString
                                         endDate:endDateString
                                            page:pageNumber];
}

#pragma mark - Private class methods
+ (NSDictionary *)parameterDictionaryForOrderType:(NSString *)orderType
                                       tradeState:(NSNumber *)tradeState
                                        startDate:(NSString *)startDate
                                          endDate:(NSString *)endDate
                                             page:(NSNumber *)page {
    NSDictionary *parameterDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   orderType, @"type"
                                   , tradeState, @"state"
                                   , startDate, @"date_start"
                                   , endDate, @"date_end"
                                   , @(1), @"page"
                                   , nil];
    
    return parameterDict;
}

@end
