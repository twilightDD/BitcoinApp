//
//  SOXMyOrderBook_BitcoinDE_Data.h
//  BitcoinApp
//
//  Created by Peter Hauke on 27.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXMyOrderBookData.h"
#import "SOXMarket_BitcoinDE_DefTypes.h"

@interface SOXMyOrderBook_BitcoinDE_Data : SOXMyOrderBookData

+ (NSMutableArray *)myOrderbookDataArrayForMyOrderbookDictionary:(NSDictionary *)payloadDictionary;
+ (NSDictionary *)myOrderBookDataForCreateInfoDictionary:(NSDictionary *)payloadDictionary;

#pragma mark - Parameter methods
#pragma mark | Create new order
+ (NSDictionary *)parameterForNewOrderWithOrderType:(BitcoinDE_OrderType)orderType
                                       currencyType:(BitcoinDE_CurrencyType)currencyType
                                         max_amount:(NSNumber *)max_amount
                                         min_amount:(NSNumber *)min_amount
                                              price:(NSNumber *)price
                                       end_datetime:(NSDate *)end_datetime
                     new_order_for_remaining_amount:(BOOL)new_order_for_remaining_amount
                                    min_trust_level:(BitcoinDE_TrustLevel)min_trust_level
                                      only_kyc_full:(BOOL)only_kyc_full
                                     payment_option:(BitcoinDE_PaymentOption)payment_option
                                       seat_of_bank:(NSArray<NSString *> *)seat_of_bank;

#pragma mark | Delete Orders
//+ (NSDictionary *)parameterForDeletingOrderWithOrderID:(NSString *)orderID;
+ (NSDictionary *)parameterForDeletingOrderWithOrderBookData:(SOXMyOrderBook_BitcoinDE_Data *)myOrderBookData;
+ (NSArray<NSDictionary *> *)parametersForDeletingMyOrderBookDatas:(NSArray<SOXMyOrderBook_BitcoinDE_Data *> *)myOrderBookDatas;

+ (NSDictionary *)parameterForOrderType:(BitcoinDE_OrderType)orderType
                           currencyType:(BitcoinDE_CurrencyType)currencyType
                             orderState:(BitcoinDE_OrderStateType)orderState
                              startDate:(NSDate *)startDate
                                endDate:(NSDate *)endDate
                                   page:(NSInteger)page;
@end
