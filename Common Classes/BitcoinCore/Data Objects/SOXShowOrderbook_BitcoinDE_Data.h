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

+ (double)highestPriceOfOrderBookDatas:(NSMutableArray <SOXShowOrderbook_BitcoinDE_Data *> *)orderbook;
+ (double)lowestPriceOfOrderBookDatas:(NSMutableArray <SOXShowOrderbook_BitcoinDE_Data *> *)orderbook;

- (void)updateOrderbookDataWith:(NSDictionary *)changes;
@end
