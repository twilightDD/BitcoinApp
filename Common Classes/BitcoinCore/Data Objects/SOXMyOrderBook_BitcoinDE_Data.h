//
//  SOXMyOrderBook_BitcoinDE_Data.h
//  BitcoinApp
//
//  Created by Peter Hauke on 27.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXMyOrderBookData.h"

@interface SOXMyOrderBook_BitcoinDE_Data : SOXMyOrderBookData

+ (NSMutableArray *)myOrderbookDataArrayForMyOrderbookDictionary:(NSDictionary *)payloadDictionary;

@end
