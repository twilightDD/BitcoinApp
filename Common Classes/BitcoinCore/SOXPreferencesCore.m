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

@property (nonatomic) BOOL validKeychainBool;
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
//    return NO; // Test switch

    BOOL validKeychain = [[SOXPreferencesCore sharedCore] validKeychainBool];
    return validKeychain;
}

+ (NSUInteger )countOfValidKeychainItems {
    NSUInteger countOfValidKeychainItems = [SOXPreferencesCore sharedCore].keysAndSecrets.count;
    return countOfValidKeychainItems;
}

+ (NSString *)apiKeyAtIndex:(NSUInteger)index {
    NSString *key = @"computer sagt nein zu key";

    NSMutableArray *keysAndSecrets = [SOXPreferencesCore sharedCore].keysAndSecrets;

    if (keysAndSecrets.count >=  1) {
        NSMutableDictionary *keysAndSecretDictionary = [[SOXPreferencesCore sharedCore].keysAndSecrets objectAtIndex:index];
        key = [keysAndSecretDictionary objectForKey:APIUserKey];
    }

    return key;
}

+ (NSString *)apiSecretAtIndex:(NSUInteger)index {
    NSString *secret = @"computer sagt nein zu secret";

    NSMutableArray *keysAndSecrets = [SOXPreferencesCore sharedCore].keysAndSecrets;

    if (keysAndSecrets.count >=  1) {
        NSMutableDictionary *keysAndSecretDictionary = [[SOXPreferencesCore sharedCore].keysAndSecrets objectAtIndex:index];
        secret = [keysAndSecretDictionary objectForKey:APISecretKey];
    }
    return secret;
}

+ (NSMutableArray <NSMutableDictionary*> *)keysAndSecrets {
    return [SOXPreferencesCore sharedCore].keysAndSecrets;
}

+ (BOOL)saveKeysAndSecrets:(NSMutableArray <NSMutableDictionary*> *)keysAndSecrets
                     error:(NSError *)error {
    SOXPreferencesCore *preferenceCore = [SOXPreferencesCore sharedCore];
    preferenceCore.keysAndSecrets = keysAndSecrets;

    BOOL success = [preferenceCore saveToKeychain:error];

    return success;
}

+ (BOOL)validateKey:(NSString *)key {
    // 32
    if (key.length != 32) {
        return NO;
    }

    BOOL validateCharacterSets = [self validateCharacterSetsForString:key];

    return validateCharacterSets;
}

+ (BOOL)validateSecret:(NSString *)secret {
    // 40
    if (secret.length != 40) {
        return NO;
    }

    BOOL validateCharacterSets = [self validateCharacterSetsForString:secret];

    return validateCharacterSets;
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

+ (BOOL)validateCharacterSetsForString:(NSString *)string {

    // nur Kleinbuchstaben ODER Zahlen
    NSCharacterSet *upperCaseSet = [NSCharacterSet uppercaseLetterCharacterSet];
    if ([string rangeOfCharacterFromSet:upperCaseSet].location != NSNotFound) {
        return NO;
    }

    NSCharacterSet *whitespaceAndNewlineCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    if ([string rangeOfCharacterFromSet:whitespaceAndNewlineCharacterSet].location != NSNotFound) {
        return NO;
    }

    NSCharacterSet *illegalCharacterSet = [NSCharacterSet illegalCharacterSet];
    if ([string rangeOfCharacterFromSet:illegalCharacterSet].location != NSNotFound) {
        return NO;
    }
    
    NSCharacterSet *punctuationCharacterSet = [NSCharacterSet punctuationCharacterSet];
    if ([string rangeOfCharacterFromSet:punctuationCharacterSet].location != NSNotFound) {
        return NO;
    }

    return YES;
}

#pragma mark - Private Instance methods

- (BOOL)validKeychainBool {
    BOOL validKeychainBool = self.keysAndSecrets.count > 0;
    return validKeychainBool;
}

#pragma mark | Keychain methods
- (void)loadFromKeychain {
    self.validKeychainBool = NO;

    NSError *error = nil;

    NSData *data = [SAMKeychain passwordDataForService:@"BitcoinService"
                                               account:@"BitcounAccount"];
    if (data) {
        NSMutableArray *array = [NSJSONSerialization JSONObjectWithData:data
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&error];
        self.keysAndSecrets = [array mutableCopy];

        // TODO: check for _really_ valid keychain items!
        // - lenght
        // - only lowerCases or figures
        if (self.keysAndSecrets.count > 0) {
            self.validKeychainBool = YES;
        }
    }
    else {
        self.keysAndSecrets = [NSMutableArray array];
    }
}

- (BOOL)saveToKeychain:(NSError *)error {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.keysAndSecrets
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    BOOL success = [SAMKeychain setPasswordData:jsonData
                      forService:@"BitcoinService"
                         account:@"BitcounAccount"];

    if (error) {
        NSLog(@"Error on preference save: %@", error.localizedDescription);
    }

    return success;
}

@end
