//
//  SOXMarketHelper.m
//  BitcoinApp
//
//  Created by Peter Hauke on 14.08.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXMarketHelper.h"

#import "SOXShowOrderbookData.h"

@implementation SOXMarketHelper

+ (BOOL)existOrderBookData:(SOXShowOrderbookData *)addOrderData
               inOrderBook:(NSArray<SOXShowOrderbookData *> *)orderbook {
    NSString *newOrderDataOrderID = addOrderData.orderInformation_orderID;

    __block BOOL existOrderBookData = NO;
    [orderbook enumerateObjectsUsingBlock:^(SOXShowOrderbookData *_Nonnull orderData, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([orderData.orderInformation_orderID isEqualToString:newOrderDataOrderID]) {
            existOrderBookData = YES;
            *stop              = YES;
        }
    }];

    return existOrderBookData;
}

@end
