//
//  SOXMarket_BitcoinDE_OrderTypes.m
//  BitcoinApp
//
//  Created by Peter Hauke on 11.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXMarket_BitcoinDE_DefTypes.h"

@implementation SOXMarket_BitcoinDE_DefTypes

+ (NSString *)orderTypeStringForOrderType:(BitcoinDE_OrderType)orderType {
    switch (orderType) {
        case  BitcoinDE_BuyOrderType:
            return @"buy";
            break;
        case  BitcoinDE_SellOrderType:
            return @"sell";
            break;
        default:
            return nil;
            break;
    }
}

@end
