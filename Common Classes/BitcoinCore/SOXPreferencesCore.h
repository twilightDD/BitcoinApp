//
//  SOXPreferencesCore.h
//  BitcoinApp
//
//  Created by Peter Hauke on 12.07.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOXPreferencesCore : NSObject

+ (void)startupPreferencesCore;

+ (BOOL)validKeychain;
+ (NSUInteger )countOfValidKeychainItems;

+ (NSString *)apiKeyAtIndex:(NSUInteger)index;
+ (NSString *)apiSecretAtIndex:(NSUInteger)index;

@end
