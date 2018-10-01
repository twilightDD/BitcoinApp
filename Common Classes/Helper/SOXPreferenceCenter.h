//
//  SOXPreferenceCenter.h
//  BitcoinApp
//
//  Created by Peter Hauke on 10.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SOXMarket_BitcoinDE_DefTypes.h"

@interface SOXPreferenceCenter : NSObject

+ (BOOL)defaultKYCOnly;
+ (BOOL)new_order_for_remaining_amount;
+ (BitcoinDE_TrustLevel)defaultTrustLevelBuyOrder;
+ (BitcoinDE_TrustLevel)defaultTrustLevelNewOrder;
+ (BitcoinDE_PaymentOption)defaultPaymentOptionForCreateOrder;
+ (BitcoinDE_PaymentOption)defaultPaymentOptionForExecuteTrade;
+ (NSArray *)defaultTradingCountries;
+ (NSControlStateValue )sepaPaymentOptionStateForOrderType:(BitcoinDE_OrderType)orderType
                                              currencyType:(BitcoinDE_CurrencyType)currencyType;
+ (void)setSepaPaymentFilterOption:(NSControlStateValue )state
                      forOrderType:(BitcoinDE_OrderType)orderType
                      currencyType:(BitcoinDE_CurrencyType)currencyType;
+ (BOOL)secureExecuteTrade;

+ (NSArray <NSString *> *)supportedCountryCodes;
+ (NSArray <NSString *> *)activeCountryCodes;

@end
