//
//  SOXTradeJob_BitcoinDE_Data.h
//  BitcoinApp
//
//  Created by Peter Hauke on 14.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SOXMarket_BitcoinDE_DefTypes.h"

@interface SOXTradeJob_BitcoinDE_Data : NSObject

@property (strong, nonatomic) NSString *orderID;
@property (nonatomic) BitcoinDE_OrderType orderType;
@property (strong, nonatomic) NSNumber *bitcoinAmount;

+ (NSDictionary *)parameterForOrderID:(NSString *)orderID
                            orderType:(BitcoinDE_OrderType)orderType
                          bitcoinAmount:(NSNumber *)bitcoinAmount;

+ (NSDictionary *)parameterAutomaticTradingForOrderID:(NSString *)orderID
                                            orderType:(BitcoinDE_OrderType)orderType
                                        bitcoinAmount:(NSNumber *)bitcoinAmount
                                                price:(NSDecimalNumber *)price;

@end
