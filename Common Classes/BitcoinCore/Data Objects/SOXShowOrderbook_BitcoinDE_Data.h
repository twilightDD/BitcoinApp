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

+ (NSDictionary *)parametersForAutoTradingForOrderType:(BitcoinDE_OrderType)orderType;

+ (NSDictionary *)parametersForOrderType:(BitcoinDE_OrderType)orderType
                onlyExpressPaymentOption:(BOOL)onlyExpressPaymentOption;

+ (NSDictionary *)parametersForOrderType:(BitcoinDE_OrderType)orderType
                           bitcoinAmount:(NSDecimalNumber *)bitcoinAmount
                                   price:(NSDecimalNumber *)price
             orderRequirementsFullfilled:(BOOL)orderRequirementsFullfilled
                             onlyKYCFull:(BOOL)onlyKYCFull
                onlyExpressPaymentOption:(BOOL)onlyExpressPaymentOption
                       onlySameBankGroup:(BOOL)onlySameBankGroup
                             onlySameBIC:(BOOL)onlySameBIC
                              seatOfBank:(NSArray *)seatsOfBank;

+ (NSMutableArray *)orderbookDataArrayForShowOrderbookDictionary:(NSDictionary *)payloadDictionary;

+ (instancetype)orderBookDataForSocketIODictionary:(NSDictionary *)addOrderSocketIODictionary;

- (void)updateOrderbookDataWith:(NSDictionary *)changes;

@end
