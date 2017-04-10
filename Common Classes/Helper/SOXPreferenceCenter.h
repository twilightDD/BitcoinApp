//
//  SOXPreferenceCenter.h
//  BitcoinApp
//
//  Created by Peter Hauke on 10.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOXPreferenceCenter : NSObject

+ (BOOL)defaultKYCOnly;
+ (NSString *)defaultMinTrustLevel;
+ (NSNumber *)defaultPaymentOption;
+ (NSArray *)defaultTradingCountries;

@end
