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

+ (NSString *)defaultMinTrustLevel {
    /*bronze
     silver
     gold*/
    
    return @"gold";
}

+ (NSNumber *)defaultPaymentOption {
    /*
    1 => Express-Only
    2 => SEPA-Only
    3 => Express & SEPA
     */
    
    return @(1);
}

+ (NSArray *)defaultTradingCountries {
    NSArray *defaultTradingCountries = [NSArray arrayWithObject:@"DE"];
    
    return defaultTradingCountries;
}


@end
