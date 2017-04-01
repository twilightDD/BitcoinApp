//
//  SOXShowOrderbook_BitcoinDE_Data.h
//  BitcoinApp
//
//  Created by Peter Hauke on 21.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXShowOrderbookData.h"

@interface SOXShowOrderbook_BitcoinDE_Data : SOXShowOrderbookData

+ (NSMutableArray *)orderbookDataArrayForShowOrderbookDictionary:(NSDictionary *)payloadDictionary;

+ (instancetype)orderBookDataForSocketIODictionary:(NSDictionary *)addOrderSocketIODictionary;

- (void)updateOrderbookDataWith:(NSDictionary *)changes;
@end
