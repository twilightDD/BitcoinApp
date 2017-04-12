//
//  SOXShowOrderbook_BitcoinDE_Data.h
//  BitcoinApp
//
//  Created by Peter Hauke on 21.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXShowOrderbookData.h"
#import "SOXMarket_BitcoinDE_DefTypes.h"

@interface SOXShowOrderbook_BitcoinDE_Data : SOXShowOrderbookData

+ (NSMutableArray *)orderbookDataArrayForShowOrderbookDictionary:(NSDictionary *)payloadDictionary;

+ (instancetype)orderBookDataForSocketIODictionary:(NSDictionary *)addOrderSocketIODictionary;
+ (double)currentAutomaticPriceLimitOfOrderBook:(NSMutableArray *)orderbook forOrderType:(BitcoinDE_OrderType)orderType;

- (void)updateOrderbookDataWith:(NSDictionary *)changes;
@end
