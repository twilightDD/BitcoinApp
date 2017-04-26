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

+ (BitcoinDE_MinimalTrustLevel )defaultMinTrustLevel {
    return BitcoinDE_GoldMinimalTrustLevel;
}

+ (BitcoinDE_PaymentOption)defaultPaymentOption {
    return BitcoinDE_PaymentOptionExpressOnly;
}

+ (NSArray *)defaultTradingCountries {
    NSArray *defaultTradingCountries = [NSArray arrayWithObjects:@"DE", nil];
    
    return defaultTradingCountries;
}


@end
