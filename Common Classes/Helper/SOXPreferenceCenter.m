//
//  SOXPreferenceCenter.m
//  BitcoinApp
//
//  Created by Peter Hauke on 10.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXPreferenceCenter.h"

static NSString *UserDef_Domain_AutomaticallyLoadOrderbookKey = @"de.2sox.coiner.domain_automaticallyLoadOrderbook";
static NSString *UserDef_Domain_OrderViewControllerSEPAKey = @"de.2sox.coiner.domain_noSepaPaymentOptionFilter";
static NSString *UserDef_Domain_OrderViewControllerCountryCodeKey = @"de.2sox.coiner.domain_countryCodeFilter";
static NSString *UserDef_FirstAppStartKey = @"de.2sox.coiner.domain_date";

static NSString *UserDef_default_kycOnly = @"de.2sox.coiner.default_KYCOnly";
static NSString *UserDef_default_reNewOrderForRemainingAmount = @"de.2sox.coiner.default_reNewOrderForRemainingAmount";
static NSString *UserDef_default_trustLevelNewOrder = @"de.2sox.coiner.default_trustLevelNewOrder";
static NSString *UserDef_default_endDateTimespan = @"de.2sox.coiner.default_endDateTimespan";
static NSString *UserDef_default_autoUpdateInfoTabs = @"de.2sox.coiner.default_autoUpdateInfoTabs";

@implementation SOXPreferenceCenter

#pragma mark - General
+ (void)resetAllSettings {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dictionaryRepresentation = [userDefaults dictionaryRepresentation];

    for (NSString *userDefaultKey in dictionaryRepresentation.allKeys) {
        if ([userDefaultKey containsString:@"de.2sox.coiner."]) {
            [self removeUserDefaultForKey:userDefaultKey];
        }
    }

    dictionaryRepresentation = [userDefaults dictionaryRepresentation];
}

+ (BOOL)isVeryFirstAppStart {
    BOOL isVeryFirstAppStart = NO;
    NSDate *firstAppStartDate = [self userDefaultForKey:UserDef_FirstAppStartKey];
    if (firstAppStartDate == nil) {
        isVeryFirstAppStart = YES;
        [self setUserDefaultObject:[NSDate date]
                            forKey:UserDef_FirstAppStartKey];
    }

    return isVeryFirstAppStart;
}

+ (void)firstAppStartSetup {
    // Country Codes
    [self setActiveCountryCodes:[SOXPreferenceCenter defaultCountryCodes]];

    // defaultKYCOnly
    [self setDefaultKYCOnly:YES];

    // ReNewOrderForRemainingAmountReNewOrderForRemainingAmount
    [self setReNewOrderForRemainingAmount:YES];

    // defaultTrustLevelBuyOrder
    //[self setDefaultTrustLevelBuyOrder:BitcoinDE_TrustLevelBronze];

    // defaultTrustLevelNewOrder
    [self setDefaultTrustLevelNewOrder:BitcoinDE_TrustLevelBronze];

    // defaultPaymentOptionForCreateOrder

    // defaultPaymentOptionForExecuteTrade

    // defaultEndDateTimeSpan
    [self setDefaultEndDateTimespan:@5];

    // automatically load orderbooks
    [self setAutomaticallyLoadOrderbook:YES
                           forOrderType:BitcoinDE_OrderTypeBuy
                        forCurrencyType:BitcoinDE_CurrencyTypeBitcoin];
    [self setAutomaticallyLoadOrderbook:YES
                           forOrderType:BitcoinDE_OrderTypeBuy
                        forCurrencyType:BitcoinDE_CurrencyTypeBitcoinCash];
    // secureExecuteTrade

    // minimalVolume
}

#pragma mark - Defaults
+ (BOOL)automaticallyLoadOrderbookForOrderType:(BitcoinDE_OrderType)orderType
                               forCurrencyType:(BitcoinDE_CurrencyType)currencyType {
    NSString *userDefaultKey = [self userDefaultKeyForDomain:UserDef_Domain_AutomaticallyLoadOrderbookKey
                                                   orderType:orderType
                                                currencyType:currencyType];
    NSNumber *userDefault = [SOXPreferenceCenter userDefaultForKey:userDefaultKey];
    BOOL automaticallyLoadOrderbook = userDefault.boolValue;
    return automaticallyLoadOrderbook;
}

+ (NSControlStateValue)controlStateForAutoLoadOrderbookForOrderType:(BitcoinDE_OrderType)orderType
                                                    forCurrencyType:(BitcoinDE_CurrencyType)currencyType {
    BOOL controlState = [SOXPreferenceCenter automaticallyLoadOrderbookForOrderType:orderType
                                                                    forCurrencyType:currencyType];

    return controlState ? NSControlStateValueOn : NSControlStateValueOff;
}

+ (void)setAutomaticallyLoadOrderbook:(BOOL)automaticallyLoadOrderbook
                         forOrderType:(BitcoinDE_OrderType)orderType
                      forCurrencyType:(BitcoinDE_CurrencyType)currencyType {
    NSString *userDefaultKey = [self userDefaultKeyForDomain:UserDef_Domain_AutomaticallyLoadOrderbookKey
                                                   orderType:orderType
                                                currencyType:currencyType];
    [self setUserDefaultObject:@(automaticallyLoadOrderbook)
                        forKey:userDefaultKey];

}

+ (BOOL)defaultKYCOnly {
    NSNumber *userDefault = [SOXPreferenceCenter userDefaultForKey:UserDef_default_kycOnly];
    BOOL defaultKYCOnly = userDefault.boolValue;
    return defaultKYCOnly;
}

+ (void)setDefaultKYCOnly:(BOOL)defaultKYCOnly {
    [SOXPreferenceCenter setUserDefaultObject:@(defaultKYCOnly)
                                       forKey:UserDef_default_kycOnly];
}

+ (BOOL)reNewOrderForRemainingAmount {
    NSNumber *userDefault = [SOXPreferenceCenter userDefaultForKey:UserDef_default_reNewOrderForRemainingAmount];
    BOOL reNewOrderForRemainingAmount = userDefault.boolValue;
    return reNewOrderForRemainingAmount;
}

+ (void)setReNewOrderForRemainingAmount:(BOOL)reNewOrderForRemainingAmount {
    [SOXPreferenceCenter setUserDefaultObject:@(reNewOrderForRemainingAmount)
                                       forKey:UserDef_default_reNewOrderForRemainingAmount];
}

+ (BitcoinDE_TrustLevel)defaultTrustLevelBuyOrder {
    return BitcoinDE_TrustLevelGold;
}

+ (BitcoinDE_TrustLevel)defaultTrustLevelForNewOrder {
    NSNumber *userDefault = [SOXPreferenceCenter userDefaultForKey:UserDef_default_trustLevelNewOrder];
    BitcoinDE_TrustLevel reNewOrderForRemainingAmount = (BitcoinDE_TrustLevel)userDefault.unsignedIntegerValue;
    return reNewOrderForRemainingAmount;
}

+ (void)setDefaultTrustLevelNewOrder:(BitcoinDE_TrustLevel)defaultTrustLevelNewOrder {
    [SOXPreferenceCenter setUserDefaultObject:@(defaultTrustLevelNewOrder)
                                       forKey:UserDef_default_trustLevelNewOrder];
}

+ (BitcoinDE_PaymentOption)defaultPaymentOptionForNewOrder {
    return BitcoinDE_PaymentOptionExpressOnly;
}

+ (BitcoinDE_PaymentOption)defaultPaymentOptionForExecuteTrade {
    //    return BitcoinDE_PaymentOptionExpressOnly;
    //    return BitcoinDE_PaymentOptionSEPAOnly;
    return BitcoinDE_PaymentOptionExpressAndSepa;
}

+ (NSNumber *)defaultEndDateTimespan {
    NSNumber *defaultEndDateTimespan = [SOXPreferenceCenter userDefaultForKey:UserDef_default_endDateTimespan];
    return defaultEndDateTimespan;
}

+ (void)setDefaultEndDateTimespan:(NSNumber *)endDateTimespan {
    [SOXPreferenceCenter setUserDefaultObject:endDateTimespan
                                       forKey:UserDef_default_endDateTimespan];
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

+ (BOOL)autoUpdateInfoTabs {
    NSNumber *userDefault = [SOXPreferenceCenter userDefaultForKey:UserDef_default_autoUpdateInfoTabs];
    BOOL autoUpdateInfoTabs = userDefault.boolValue;
    return autoUpdateInfoTabs;
}

+ (NSControlStateValue)controlStateForAutoUpdateInfoTabs {
    BOOL autoUpdateInfoTabs = [SOXPreferenceCenter autoUpdateInfoTabs];

    return autoUpdateInfoTabs ? NSControlStateValueOn : NSControlStateValueOff;
}

+ (void)setAutoUpdateInfoTabs:(BOOL)autoUpdateInfoTabs {
    [SOXPreferenceCenter setUserDefaultObject:@(autoUpdateInfoTabs)
                                       forKey:UserDef_default_autoUpdateInfoTabs];
}

#pragma mark - Sepa Payment Option
+ (NSControlStateValue )sepaPaymentOptionState {
    NSControlStateValue sepaPaymentOptionState = NSControlStateValueOff;
    id noSepaFilterValue = [self userDefaultForKey:UserDef_Domain_OrderViewControllerSEPAKey];
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
        NSString *userDefaultKey = [self userDefaultKeyForDomain:UserDef_Domain_OrderViewControllerSEPAKey
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
        NSString *userDefaultKey = [self userDefaultKeyForDomain:UserDef_Domain_OrderViewControllerSEPAKey
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
                        forKey:UserDef_Domain_OrderViewControllerSEPAKey];

    // for orderType and currencyType
    for (BitcoinDE_OrderType orderType = BitcoinDE_OrderTypeBuy;
         orderType < BitcoinDE_OrderType_EndOfType;
         orderType++) {
        for (BitcoinDE_CurrencyType currencyType = BitcoinDE_CurrencyTypeBitcoin;
             currencyType <BitcoinDE_CurrencyType_EndOfType;
             currencyType++) {
            NSString *userDefaultKey = [self userDefaultKeyForDomain:UserDef_Domain_OrderViewControllerSEPAKey
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
    NSString *userDefaultKey = [self userDefaultKeyForDomain:UserDef_Domain_OrderViewControllerCountryCodeKey
                                                   orderType:orderType
                                                currencyType:currencyType];
    NSArray *activeCountryCodes = [self userDefaultForKey:userDefaultKey];
    
    return activeCountryCodes;
}

+ (NSArray <NSString *> *)activeCountryCodes {
    NSString *userDefaultKey = UserDef_Domain_OrderViewControllerCountryCodeKey;
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
                        forKey:UserDef_Domain_OrderViewControllerCountryCodeKey];

    // for orderType and currencyType
    for (BitcoinDE_OrderType orderType = BitcoinDE_OrderTypeBuy;
         orderType < BitcoinDE_OrderType_EndOfType;
         orderType++) {
        for (BitcoinDE_CurrencyType currencyType = BitcoinDE_CurrencyTypeBitcoin;
             currencyType <BitcoinDE_CurrencyType_EndOfType;
             currencyType++) {
            NSString *userDefaultKey = [self userDefaultKeyForDomain:UserDef_Domain_OrderViewControllerCountryCodeKey
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
        NSString *userDefaultKey = [self userDefaultKeyForDomain:UserDef_Domain_OrderViewControllerCountryCodeKey
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
