//
//  SOXPreferencesCore.m
//  BitcoinApp
//
//  Created by Peter Hauke on 12.07.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXPreferencesCore.h"

#import "SAMKeychain.h"

#import "SOXConstants.h"

#pragma mark - Interface
@interface SOXPreferencesCore ()

@property (nonatomic) BOOL validKeychain;
@property (strong, nonatomic, nonnull) NSMutableArray <NSMutableDictionary*> *keysAndSecrets;

@end

#pragma mark - Implementation
@implementation SOXPreferencesCore
#pragma mark Init&Co.

#pragma mark - Public Class methods
+ (void)startupPreferencesCore {
    [SOXPreferencesCore sharedCore];
}

+ (BOOL)validKeychain {
    BOOL validKeychain = [[SOXPreferencesCore sharedCore] validKeychain];
    return validKeychain;
}

+ (NSUInteger )countOfValidKeychainItems {
    NSUInteger countOfValidKeychainItems = [SOXPreferencesCore sharedCore].keysAndSecrets.count;
    return countOfValidKeychainItems;
}

+ (NSString *)apiKeyAtIndex:(NSUInteger)index {
    NSMutableDictionary *keysAndSecretDictionary = [[SOXPreferencesCore sharedCore].keysAndSecrets objectAtIndex:index];
    NSString *key = [keysAndSecretDictionary objectForKey:APIUserKey];
    return key;
}

+ (NSString *)apiSecretAtIndex:(NSUInteger)index {
    NSMutableDictionary *keysAndSecretDictionary = [[SOXPreferencesCore sharedCore].keysAndSecrets objectAtIndex:index];
    NSString *secret = [keysAndSecretDictionary objectForKey:APISecretKey];
    return secret;
}

#pragma mark - Private Class methods
+ (SOXPreferencesCore * _Nonnull)sharedCore {
    static SOXPreferencesCore *sharedCore;

    static dispatch_once_t pred;

    dispatch_once(&pred, ^{
        sharedCore = [[self class] new];
        sharedCore.keysAndSecrets = [NSMutableArray array];
        [sharedCore loadFromKeychain];
    });

    return sharedCore;
}

#pragma mark - Private Instance methods

#pragma mark | Keychain methods
- (void)loadFromKeychain {
    NSError *error = nil;

    NSData *data = [SAMKeychain passwordDataForService:@"BitcoinService"
                                               account:@"BitcounAccount"];
    if (data) {
        NSMutableArray *array = [NSJSONSerialization JSONObjectWithData:data
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&error];
        self.keysAndSecrets = [array mutableCopy];
    }
    else {
        self.keysAndSecrets = [NSMutableArray array];
    }
}

- (void)saveToKeychain {
    NSError *error = nil;

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.keysAndSecrets
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    [SAMKeychain setPasswordData:jsonData
                      forService:@"BitcoinService"
                         account:@"BitcounAccount"];
}

@end
