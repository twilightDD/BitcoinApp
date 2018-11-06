//
//  SOXPreferenceCenter.m
//  BitcoinApp
//
//  Created by Peter Hauke on 10.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXPreferenceCenter.h"

static NSString *OrderViewControllerSEPAKey = @"noSepaPaymentOptionFilter";
static NSString *OrderViewControllerCountryCodeKey = @"countryCodeFilter";

@implementation SOXPreferenceCenter
+ (void)resetAllSettings {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dictionaryRepresentation = [userDefaults dictionaryRepresentation];

    [self removeUserDefaultForKey:OrderViewControllerCountryCodeKey];

    for (BitcoinDE_OrderType orderType = BitcoinDE_OrderTypeBuy;
         orderType < BitcoinDE_OrderType_EndOfType;
         orderType++) {
        for (BitcoinDE_CurrencyType currencyType = BitcoinDE_CurrencyTypeBitcoin;
             currencyType <BitcoinDE_CurrencyType_EndOfType;
             currencyType++) {
            NSString *userDefaultKey = [self userDefaultKeyForDomain:OrderViewControllerCountryCodeKey
                                                           orderType:orderType
                                                        currencyType:currencyType];
            [self removeUserDefaultForKey:userDefaultKey];

            userDefaultKey = [self userDefaultKeyForDomain:OrderViewControllerSEPAKey
                                                 orderType:orderType
                                              currencyType:currencyType];
            [self removeUserDefaultForKey:userDefaultKey];
        }
    }
    dictionaryRepresentation = [userDefaults dictionaryRepresentation];
}



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

+ (BOOL)secureExecuteTrade {
    return YES;
}

+ (NSDecimalNumber *)minimalVolume {
    static dispatch_once_t pred;
    static NSDecimalNumber *minimalVolume = nil;
    dispatch_once(&pred, ^{
        minimalVolume = [NSDecimalNumber decimalNumberWithString:@"60"];
    });

    return minimalVolume;
}

#pragma mark - Sepa Payment Option
+ (NSControlStateValue )sepaPaymentOptionState {
    NSControlStateValue sepaPaymentOptionState = NSControlStateValueOff;
    id noSepaFilterValue = [self userDefaultForKey:OrderViewControllerSEPAKey];
    if (noSepaFilterValue != nil
        && [noSepaFilterValue isKindOfClass:[NSNumber class]]) {
        sepaPaymentOptionState = [(NSNumber *)noSepaFilterValue boolValue] ? NSControlStateValueOn: NSControlStateValueOff;
    }

    return sepaPaymentOptionState;
}

+ (NSControlStateValue )sepaPaymentOptionStateForOrderType:(BitcoinDE_OrderType)orderType
                                              currencyType:(BitcoinDE_CurrencyType)currencyType {
    NSControlStateValue sepaPaymentOptionState = NSControlStateValueOn;
    
    { // look up at userDefaults
        NSString *userDefaultKey = [self userDefaultKeyForDomain:OrderViewControllerSEPAKey
                                                       orderType:orderType
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
    if (orderType != BitcoinDE_OrderTypeUnknown
        && currencyType != BitcoinDE_CurrencyTypeUnknown) {
        NSNumber *noSepaFilterValue = @NO;
        if (state == NSControlStateValueOn) {
            noSepaFilterValue = @YES;
        }
        NSString *userDefaultKey = [self userDefaultKeyForDomain:OrderViewControllerSEPAKey
                                                       orderType:orderType
                                                    currencyType:currencyType];
        [self setUserDefaultObject:noSepaFilterValue
                            forKey:userDefaultKey];
    }
    else {
        [self setSepaPaymentFilterOption:state];
    }
}

+ (void)setSepaPaymentFilterOption:(NSControlStateValue)state {
    NSNumber *noSepaFilterValue = @NO;
    if (state == NSControlStateValueOn) {
        noSepaFilterValue = @YES;
    }
    // for all
    [self setUserDefaultObject:noSepaFilterValue
                        forKey:OrderViewControllerSEPAKey];

    // for orderType and currencyType
    for (BitcoinDE_OrderType orderType = BitcoinDE_OrderTypeBuy;
         orderType < BitcoinDE_OrderType_EndOfType;
         orderType++) {
        for (BitcoinDE_CurrencyType currencyType = BitcoinDE_CurrencyTypeBitcoin;
             currencyType <BitcoinDE_CurrencyType_EndOfType;
             currencyType++) {
            NSString *userDefaultKey = [self userDefaultKeyForDomain:OrderViewControllerSEPAKey
                                                           orderType:orderType
                                                        currencyType:currencyType];
            [self setUserDefaultObject:noSepaFilterValue
                                forKey:userDefaultKey];
        }
    }

    // Inform all orderViewControllers of changes in global "noSepaOrders"-list
    [[NSNotificationCenter defaultCenter] postNotificationName:ShowNoSepaOrdersPreferencesDidChangeNotification
                                                        object:noSepaFilterValue];
}


#pragma mark - Country Codes
+ (NSArray *)defaultCountryCodes {
    NSArray *defaultTradingCountries = [NSArray arrayWithObjects:@"AT", @"CH", @"DE", nil];
    
    return defaultTradingCountries;
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

+ (NSArray <NSString *> *)activeCountryCodesforOrderType:(BitcoinDE_OrderType)orderType
                                            currencyType:(BitcoinDE_CurrencyType)currencyType {
    NSString *userDefaultKey = [self userDefaultKeyForDomain:OrderViewControllerCountryCodeKey
                                                   orderType:orderType
                                                currencyType:currencyType];
    NSArray *activeCountryCodes = [self userDefaultForKey:userDefaultKey];
    
    return activeCountryCodes;
}

+ (NSArray <NSString *> *)activeCountryCodes {
    NSString *userDefaultKey = OrderViewControllerCountryCodeKey;
    NSArray *userDefaultsValue = [self userDefaultForKey:userDefaultKey];
    if (userDefaultsValue == nil) {
        userDefaultsValue = [self defaultCountryCodes];
        [self setUserDefaultObject:userDefaultsValue
                            forKey:userDefaultKey];
    }

    return userDefaultsValue;
}

+ (void)setActiveCountryCodes:(NSArray <NSString *> *)activeCountryCodes {
    // for all
    [self setUserDefaultObject:activeCountryCodes
                        forKey:OrderViewControllerCountryCodeKey];

    // for orderType and currencyType
    for (BitcoinDE_OrderType orderType = BitcoinDE_OrderTypeBuy;
         orderType < BitcoinDE_OrderType_EndOfType;
         orderType++) {
        for (BitcoinDE_CurrencyType currencyType = BitcoinDE_CurrencyTypeBitcoin;
             currencyType <BitcoinDE_CurrencyType_EndOfType;
             currencyType++) {
            NSString *userDefaultKey = [self userDefaultKeyForDomain:OrderViewControllerCountryCodeKey
                                                           orderType:orderType
                                                        currencyType:currencyType];
            [self setUserDefaultObject:activeCountryCodes
                                forKey:userDefaultKey];
        }
    }


    // Inform all orderViewControllers of changes in global "active country codes"-list
    [[NSNotificationCenter defaultCenter] postNotificationName:ActiveCountryCodesPreferencesDidChangeNotification
                                                        object:activeCountryCodes];
}

+ (void)setActiveCountryCodes:(NSArray <NSString *> *)activeCountryCodes
                 forOrderType:(BitcoinDE_OrderType)orderType
                 currencyType:(BitcoinDE_CurrencyType)currencyType {
    if (orderType != BitcoinDE_OrderTypeUnknown
        && currencyType != BitcoinDE_CurrencyTypeUnknown) {
        NSString *userDefaultKey = [self userDefaultKeyForDomain:OrderViewControllerCountryCodeKey
                                                       orderType:orderType
                                                    currencyType:currencyType];
        [self setUserDefaultObject:activeCountryCodes forKey:userDefaultKey];
    }
    else {
        [self setActiveCountryCodes:activeCountryCodes];
    }
}


#pragma mark - Countries
+ (NSArray <NSString *> *)supportedCountryNames {
    static dispatch_once_t pred;
    static NSArray *supportedCountryNames = nil;
    dispatch_once(&pred, ^{
        supportedCountryNames = @[@"AT Österreich",
                                  @"BE Belgien",
                                  @"BG Bulgarien",
                                  @"CH Schweiz",
                                  @"CY Zypern",
                                  @"CZ Tschechische Republik",
                                  @"DE Deutschland",
                                  @"DK Dänemark",
                                  @"EE Estland",
                                  @"ES Spanien",
                                  @"FI Finnland",
                                  @"FR Frankreich",
                                  @"GB Vereinigtes Königreich",
                                  @"GR Griechenland",
                                  @"HR Kroatien",
                                  @"HU Ungarn",
                                  @"IE Irland",
                                  @"IS Island",
                                  @"IT Italien",
                                  @"LI Liechtenstein",
                                  @"LT Litauen",
                                  @"LU Luxemburg",
                                  @"LV Lettland",
                                  @"MQ Martinique",
                                  @"MT Malta",
                                  @"NL Niederlande",
                                  @"NO Norwegen",
                                  @"PL Polen",
                                  @"PT Portugal",
                                  @"RO Rumänien",
                                  @"SE Schweden",
                                  @"SI Slowenien",
                                  @"SK Slowakei",
                                  ];
    });

    return supportedCountryNames;
}

+ (NSString *)countryNameForCountryCode:(NSString *)countryCode {
    NSUInteger countryCodeIndex = [[self supportedCountryCodes] indexOfObject:countryCode];
    NSString *countryName = [[self supportedCountryNames] objectAtIndex:countryCodeIndex];

    return countryName;
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

+ (void)removeUserDefaultForKey:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:key];
}

#pragma mark - Private methods
+ (NSString *)userDefaultKeyForDomain:(NSString *)domain
                            orderType:(BitcoinDE_OrderType)orderType
                         currencyType:(BitcoinDE_CurrencyType)currencyType {
    NSString *userDefaultKey = [domain copy];
    if (orderType != BitcoinDE_OrderTypeUnknown
        && currencyType != BitcoinDE_CurrencyTypeUnknown) {
        userDefaultKey = [userDefaultKey stringByAppendingString:@"_"];
        userDefaultKey = [userDefaultKey stringByAppendingString:[SOXMarket_BitcoinDE_DefTypes tradingPairStringForCurrencyType:currencyType]];
        userDefaultKey = [userDefaultKey stringByAppendingString:@"_"];
        userDefaultKey = [userDefaultKey stringByAppendingString:[SOXMarket_BitcoinDE_DefTypes orderTypeStringForOrderType:orderType]];
    }
    
    return userDefaultKey;
}
@end
