//
//  SOXMyOrderBook_BitcoinDE_Data.h
//  BitcoinApp
//
//  Created by Peter Hauke on 27.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXMyOrderBookData.h"
#import "SOXMarket_BitcoinDE_Core.h"

@interface SOXMyOrderBook_BitcoinDE_Data : SOXMyOrderBookData

+ (NSMutableArray *)myOrderbookDataArrayForMyOrderbookDictionary:(NSDictionary *)payloadDictionary;
+ (NSDictionary *)myOrderBookDataForCreateInfoDictionary:(NSDictionary *)payloadDictionary;

+ (NSDictionary *)parameterForDeletingOrderWithOrderID:(NSString *)orderID;

+ (NSArray <NSDictionary *> *)parametersForDeletingMyOrderBookDatas:(NSArray <SOXMyOrderBook_BitcoinDE_Data *>*)myOrderBookDatas;

+ (NSDictionary *)parameterForNewOrderWithOrderType:(BitcoinDE_OrderType )type
                                         max_amount:(NSNumber *)max_amount
                                              price:(NSNumber *)price
                                         min_amount:(NSNumber *)min_amount
                                       end_datetime:(NSDate *)end_datetime
                     new_order_for_remaining_amount:(BOOL)new_order_for_remaining_amount
                                    min_trust_level:(BitcoinDE_MinimalTrustLevel )min_trust_level
                                      only_kyc_full:(BOOL)only_kyc_full
                                     payment_option:(BitcoinDE_PaymentOption )payment_option
                                       seat_of_bank:(NSArray <NSString *> *)seat_of_bank;


@end
