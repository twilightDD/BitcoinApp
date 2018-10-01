//
//  SOXPreferenceCenter.m
//  BitcoinApp
//
//  Created by Peter Hauke on 10.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXPreferenceCenter.h"

@implementation SOXPreferenceCenter

+ (BOOL)defaultKYCOnly {
    return YES;
}

+ (BOOL)new_order_for_remaining_amount {
    return YES;
}

+ (BitcoinDE_TrustLevel)defaultTrustLevelBuyOrder {
    return BitcoinDE_TrustLevelGold;
}

+ (BitcoinDE_TrustLevel)defaultTrustLevelNewOrder {
    return BitcoinDE_TrustLevelBronze;
}

+ (BitcoinDE_PaymentOption)defaultPaymentOptionForCreateOrder {
    return BitcoinDE_PaymentOptionExpressOnly;
}

+ (BitcoinDE_PaymentOption)defaultPaymentOptionForExecuteTrade {
//    return BitcoinDE_PaymentOptionExpressOnly;
//    return BitcoinDE_PaymentOptionSEPAOnly;
        return BitcoinDE_PaymentOptionExpressAndSepa;
}

+ (NSArray *)defaultTradingCountries {
    NSArray *defaultTradingCountries = [NSArray arrayWithObjects:@"DE", nil];
    
    return defaultTradingCountries;
}

#pragma mark - No Sepa Filter Option on OrdersViewController
+ (NSControlStateValue )sepaPaymentOptionStateForOrderType:(BitcoinDE_OrderType)orderType
                                              currencyType:(BitcoinDE_CurrencyType)currencyType {
    NSControlStateValue sepaPaymentOptionState = NSControlStateValueOn;

    { // look up at userDefaults
        NSString *userDefaultKey = [self sepaPaymentOptionUserDefaultKeyForOrderType:orderType
                                                                        currencyType:currencyType];
        id noSepaFilterValue = [self userDefaultForKey:userDefaultKey];
        if (noSepaFilterValue != nil
            && [noSepaFilterValue isKindOfClass:[NSNumber class]]) {
            sepaPaymentOptionState = [(NSNumber *)noSepaFilterValue boolValue] ? NSControlStateValueOn: NSControlStateValueOff;
        }
    }

    return sepaPaymentOptionState;
}

+ (void)setSepaPaymentFilterOption:(NSControlStateValue )state
                      forOrderType:(BitcoinDE_OrderType)orderType
                      currencyType:(BitcoinDE_CurrencyType)currencyType {
    NSNumber *noSepaFilterValue = @NO;
    if (state == NSControlStateValueOn) {
        noSepaFilterValue = @YES;
    }
    NSString *userDefaultKey = [self sepaPaymentOptionUserDefaultKeyForOrderType:orderType
                                                                    currencyType:currencyType];
    [self setUserDefaultObject:noSepaFilterValue
                        forKey:userDefaultKey];
}


+ (NSString *)sepaPaymentOptionUserDefaultKeyForOrderType:(BitcoinDE_OrderType)orderType
                                             currencyType:(BitcoinDE_CurrencyType)currencyType {
    NSString *userDefaultKey = @"noSepaPaymentOptionFilter";
    userDefaultKey = [userDefaultKey stringByAppendingString:@"_"];
    userDefaultKey = [userDefaultKey stringByAppendingString:[SOXMarket_BitcoinDE_DefTypes tradingPairStringForCurrencyType:currencyType]];
    userDefaultKey = [userDefaultKey stringByAppendingString:@"_"];
    userDefaultKey = [userDefaultKey stringByAppendingString:[SOXMarket_BitcoinDE_DefTypes orderTypeStringForOrderType:orderType]];

    return userDefaultKey;
}

+ (BOOL)secureExecuteTrade {
    return YES;
}

+ (NSArray <NSString *> *)supportedCountryCodes {
    static dispatch_once_t pred;
    static NSArray *supportedCountryCodes = nil;
    dispatch_once(&pred, ^{
        supportedCountryCodes = @[@"AT",
                                  @"BE",
                                  @"BG",
                                  @"CH",
                                  @"CY",
                                  @"CZ",
                                  @"DE",
                                  @"DK",
                                  @"EE",
                                  @"ES",
                                  @"FI",
                                  @"FR",
                                  @"GB",
                                  @"GR",
                                  @"HR",
                                  @"HU",
                                  @"IE",
                                  @"IS",
                                  @"IT",
                                  @"LI",
                                  @"LT",
                                  @"LU",
                                  @"LV",
                                  @"MT",
                                  @"MQ",
                                  @"NL",
                                  @"NO",
                                  @"PL",
                                  @"PT",
                                  @"RO",
                                  @"SE",
                                  @"SI",
                                  @"SK"
                                  ];
    });
    return supportedCountryCodes;
}

+ (NSArray <NSString *> *)activeCountryCodes {
    static dispatch_once_t pred;
    static NSArray *activeCountryCodes = nil;
    dispatch_once(&pred, ^{
        activeCountryCodes = @[@"AT",
                                  @"BE",
                                  @"DE",
                                  @"SK"
                                  ];
    });
    return activeCountryCodes;
}
#pragma mark - NSUserDefault access
+ (id )userDefaultForKey:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *userDefaultForKey = [userDefaults valueForKey:key];

    return userDefaultForKey;
}

+ (void)setUserDefaultObject:(id)object forKey:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:object forKey:key];
}

@end
