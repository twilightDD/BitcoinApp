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
    return BitcoinDE_PaymentOptionExpressAndSepa;
}

+ (NSArray *)defaultTradingCountries {
    NSArray *defaultTradingCountries = [NSArray arrayWithObjects:@"DE", nil];
    
    return defaultTradingCountries;
}

+ (BOOL)secureExecuteTrade {
    return YES;
}

@end
