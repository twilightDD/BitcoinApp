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

+ (NSUInteger )defaultMinTrustLevel {
    /*1 - bronze
     2 - silver
     3 - gold*/
    
    return 3;
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
    NSArray *defaultTradingCountries = [NSArray arrayWithObjects:@"DE", nil];
    
    return defaultTradingCountries;
}


@end
