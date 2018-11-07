//
//  SOXPreferenceCenter.h
//  BitcoinApp
//
//  Created by Peter Hauke on 10.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SOXMarket_BitcoinDE_DefTypes.h"

static NSString *ActiveCountryCodesPreferencesDidChangeNotification = @"ActiveCountryCodesPreferencesDidChangeNotification";
static NSString *ShowNoSepaOrdersPreferencesDidChangeNotification = @"ShowNoSepaOrdersPreferencesDidChangeNotification";

@interface SOXPreferenceCenter : NSObject
#pragma mark - General
+ (void)resetAllSettings;
+ (BOOL)isVeryFirstAppStart;
+ (void)firstAppStartSetup;

#pragma mark - Defaults
+ (BOOL)defaultKYCOnly;
+ (BOOL)new_order_for_remaining_amount;
+ (BitcoinDE_TrustLevel)defaultTrustLevelBuyOrder;
+ (BitcoinDE_TrustLevel)defaultTrustLevelNewOrder;
+ (BitcoinDE_PaymentOption)defaultPaymentOptionForCreateOrder;
+ (BitcoinDE_PaymentOption)defaultPaymentOptionForExecuteTrade;
+ (BOOL)secureExecuteTrade;
+ (NSDecimalNumber *)minimalVolume;

#pragma mark - Sepa Payment Option
+ (NSControlStateValue )sepaPaymentOptionState;
+ (NSControlStateValue )sepaPaymentOptionStateForOrderType:(BitcoinDE_OrderType)orderType
                                              currencyType:(BitcoinDE_CurrencyType)currencyType;
+ (void)setSepaPaymentFilterOption:(NSControlStateValue )state
                      forOrderType:(BitcoinDE_OrderType)orderType
                      currencyType:(BitcoinDE_CurrencyType)currencyType;

#pragma mark - Country Codes
+ (NSArray *)defaultCountryCodes;
+ (NSArray <NSString *> *)supportedCountryCodes;
+ (NSArray <NSString *> *)activeCountryCodesforOrderType:(BitcoinDE_OrderType)orderType
                                            currencyType:(BitcoinDE_CurrencyType)currencyType;
+ (NSArray <NSString *> *)activeCountryCodes;

+ (void)setActiveCountryCodes:(NSArray <NSString *> *)activeCountryCodes
                 forOrderType:(BitcoinDE_OrderType)orderType
                 currencyType:(BitcoinDE_CurrencyType)currencyType;

#pragma mark - Countries
+ (NSArray <NSString *> *)supportedCountryNames;
+ (NSString *)countryNameForCountryCode:(NSString *)countryCode;

@end
