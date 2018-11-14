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
+ (BOOL)automaticallyLoadOrderbookForOrderType:(BitcoinDE_OrderType)orderType
                               forCurrencyType:(BitcoinDE_CurrencyType)currencyType;
+ (NSControlStateValue)controlStateForAutoLoadOrderbookForOrderType:(BitcoinDE_OrderType)orderType
                                                    forCurrencyType:(BitcoinDE_CurrencyType)currencyType;
+ (void)setAutomaticallyLoadOrderbook:(BOOL)automaticallyLoadOrderbook
                         forOrderType:(BitcoinDE_OrderType)orderType
                      forCurrencyType:(BitcoinDE_CurrencyType)currencyType;

+ (BOOL)automaticallyLoadBannerForCurrencyType:(BitcoinDE_CurrencyType)currencyType;
+ (NSControlStateValue)controlStateForBannerForCurrencyType:(BitcoinDE_CurrencyType)currencyType;
+ (void)setAutomaticallyLoadBanner:(BOOL)automaticallyLoadBanner
                   forCurrencyType:(BitcoinDE_CurrencyType)currencyType;

+ (BOOL)defaultKYCOnly;
+ (void)setDefaultKYCOnly:(BOOL)defaultKYCOnly;

+ (BOOL)reNewOrderForRemainingAmount;
+ (void)setReNewOrderForRemainingAmount:(BOOL)reNewOrderForRemainingAmount;

+ (BitcoinDE_TrustLevel)defaultTrustLevelBuyOrder;

+ (BitcoinDE_TrustLevel)defaultTrustLevelForNewOrder;
+ (void)setDefaultTrustLevelNewOrder:(BitcoinDE_TrustLevel)defaultTrustLevelNewOrder;

+ (BitcoinDE_PaymentOption)defaultPaymentOptionForNewOrder;

+ (BitcoinDE_PaymentOption)defaultPaymentOptionForExecuteTrade;

+ (NSNumber *)defaultEndDateTimespan;
+ (void)setDefaultEndDateTimespan:(NSNumber *)endDateTimespan;

+ (BOOL)secureExecuteTrade;
+ (NSDecimalNumber *)minimalVolume;

+ (BOOL)autoUpdateInfoTabs;
+ (NSControlStateValue)controlStateForAutoUpdateInfoTabs;
+ (void)setAutoUpdateInfoTabs:(BOOL)autoUpdateInfoTabs;

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
