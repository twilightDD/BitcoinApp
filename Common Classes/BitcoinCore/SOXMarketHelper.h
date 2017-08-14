//
//  SOXMarketHelper.h
//  BitcoinApp
//
//  Created by Peter Hauke on 14.08.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SOXShowOrderbookData;

@interface SOXMarketHelper : NSObject

+ (BOOL)existOrderBookData:(SOXShowOrderbookData *)addOrderData
               inOrderBook:(NSArray <SOXShowOrderbookData *>*)orderbook;

@end
