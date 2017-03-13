//
//  SOXMarket_BitcoinDE_Core.m
//  BitcoinApp
//
//  Created by Peter Hauke on 13.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXMarket_BitcoinDE_Core.h"
#import "SOXMarketCore_Private.h"

#import "SOXHash.h"

@interface SOXMarket_BitcoinDE_Core ()

@property (strong, nonatomic) NSString *nonceString;
@property (strong, nonatomic) NSString *baseURL;

@end

@implementation SOXMarket_BitcoinDE_Core

#pragma mark - Public methods
+ (NSURLRequest * _Nullable)urlRequestForServerCommandType:(BitcoinDE_ServerCommandType)serverCommandType {
    [SOXMarket_BitcoinDE_Core updateNonceString];
    
    NSString            *urlString       = [SOXMarket_BitcoinDE_Core urlStringForServerCommandType:serverCommandType];
    NSString            *signatureString = [SOXMarket_BitcoinDE_Core signatureStringForURLString:urlString];
    NSString            *hmacHex         = [SOXHash hexadecimalHMACForString:signatureString
                                                                     withKey:[SOXMarket_BitcoinDE_Core sharedCore].apiSecret];
    
    NSMutableURLRequest *request         = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    {
        NSString *getOrPostHTTPMethod = [SOXMarket_BitcoinDE_Core getOrPostForServerCommandType:serverCommandType];
        if (getOrPostHTTPMethod) {
            [request setHTTPMethod:getOrPostHTTPMethod];
            [request addValue:[SOXMarket_BitcoinDE_Core sharedCore].apiKey forHTTPHeaderField:@"X-API-KEY"];
            [request addValue:[SOXMarket_BitcoinDE_Core sharedCore].nonceString forHTTPHeaderField:@"X-API-NONCE"];
            [request addValue:hmacHex forHTTPHeaderField:@"X-API-SIGNATURE"];
        }
        else {
            request = nil;
        }
    }
    
    return request;
}

+ (NSArray * _Nonnull)serverCommandsKeys {
    NSDictionary *commands = [SOXMarket_BitcoinDE_Core commands];
    NSArray *sortedKeys = [commands.allKeys sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self"
                                                                                                        ascending:YES]]];
    
    return sortedKeys;
}

+ (NSString * _Nonnull)descriptionForServerCommandType:(BitcoinDE_ServerCommandType)serverCommandType {
    NSDictionary *commandDescriptions   = [SOXMarket_BitcoinDE_Core commandDescriptions];
    NSString     *descriptionForCommand = [commandDescriptions objectForKey:@(serverCommandType)];
    
    if (descriptionForCommand) {
        return descriptionForCommand;
    }
    else {
        return @"Error descriptionForServerCommandType";
    }
}

#pragma mark - Private methods
+ (NSString *)urlStringForServerCommandType:(BitcoinDE_ServerCommandType)serverCommandType {
    NSString *urlString = [SOXMarket_BitcoinDE_Core baseURLString];
    urlString = [urlString stringByAppendingString:[SOXMarket_BitcoinDE_Core commandForServerCommandType:serverCommandType]];
    
    return urlString;
}
+ (NSString *)commandForServerCommandType:(BitcoinDE_ServerCommandType)serverCommandType {
    NSDictionary *commands                    = [SOXMarket_BitcoinDE_Core commands];
    NSString     *commandForServerCommandType = [commands objectForKey:@(serverCommandType)];
    
    if (commandForServerCommandType) {
        return commandForServerCommandType;
    }
    else {
        return @"Error commandForServerCommandType";
    }
}

+ (NSString *)signatureStringForURLString:(NSString *)urlString {
    //hmac_data = http_method+'#'+uri+'#'+api_key+'#'+nonce+'#'+post_parameter_md5_hashed_url_encoded_query_string
    
    NSString *signatureString = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@"
                                 , @"GET" // http_method
                                 , @"#"
                                 , urlString // uri
                                 , @"#"
                                 , [SOXMarket_BitcoinDE_Core sharedCore].apiKey // apiKey
                                 , @"#"
                                 , [SOXMarket_BitcoinDE_Core sharedCore].nonceString // nonce
                                 , @"#"
                                 , @"d41d8cd98f00b204e9800998ecf8427e" // postParameterMD5
                                 ];
    
    return signatureString;
}

#pragma mark - Private Helper methods
+ (void)updateNonceString {
    NSDate   *date     = [NSDate date];
    NSString *timeInMS = [NSString stringWithFormat:@"%lld", [@(floor([date timeIntervalSince1970]))longLongValue]];
    [SOXMarket_BitcoinDE_Core sharedCore].nonceString = timeInMS;
}

#pragma mark - Private statics
+ (NSDictionary *)commands {
    static NSDictionary    *commandDescriptions;
    
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        commandDescriptions = @{
                                @(UnknownCommand): @"Error"
                                , @(BitcoinDE_ShowOrderbookCommandType): @"/orders?type=buy"
                                , @(BitcoinDE_ShowMyOrdersCommandType): @"/orders/my_own"
                                , @(BitcoinDE_ShowMyOrderDetailsCommandType): @"/orders/:order_id"
                                , @(BitcoinDE_ShowAccountInfoCommandType): @"/account"
                                , @(BitcoinDE_ShowOrderbookCompactCommandType): @"/orders/compact"
                                , @(BitcoinDE_ShowPublicTradeHistoryCommandType): @"/trades/history"
                                , @(BitcoinDE_ShowRatesCommandType): @"/rates"
                                };
    });
    return commandDescriptions;
}

+ (NSDictionary *)commandDescriptions {
    static NSDictionary    *commandDescriptions;
    
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        commandDescriptions = @{
                                @(UnknownCommand): @"Error"
                                , @(BitcoinDE_ShowOrderbookCommandType): @"Durchsuchen des Orderbooks nach passenden Angeboten"
                                , @(BitcoinDE_ShowMyOrdersCommandType): @"Abrufen und Filtern meiner Orders"
                                , @(BitcoinDE_ShowMyOrderDetailsCommandType): @"Details zu einer meiner Order abrufen"
                                , @(BitcoinDE_ShowAccountInfoCommandType): @"Abruf von Account Infos"
                                , @(BitcoinDE_ShowOrderbookCompactCommandType): @"Kauf- und Verkaufsangebote (bids und asks) in kompakter Form."
                                , @(BitcoinDE_ShowPublicTradeHistoryCommandType): @"Erfolgreich abgeschlossene Trades der letzten 7 Tage."
                                , @(BitcoinDE_ShowRatesCommandType): @"Abfrage des gewichteten Durchschnittskurses der letzten 3 Stunden und der letzten 12 Stunden."
                                };
    });
    return commandDescriptions;
}

#pragma mark - Not used
+ (NSString  * _Nullable )getOrPostForServerCommandType:(BitcoinDE_ServerCommandType)serverCommandType {
    switch (serverCommandType) {
        case UnknownCommand: {
            return nil;
            break;
        }
            
        case BitcoinDE_ShowOrderbookCommandType:
        case BitcoinDE_ShowMyOrdersCommandType:
        case BitcoinDE_ShowMyOrderDetailsCommandType:
        case BitcoinDE_ShowAccountInfoCommandType:
        case BitcoinDE_ShowOrderbookCompactCommandType:
        case BitcoinDE_ShowPublicTradeHistoryCommandType:
        case BitcoinDE_ShowRatesCommandType:
            return @"GET";
            
        default:
            break;
    }
}

#pragma mark - Manual getter

+ (NSString *)baseURLString {
    static NSString        *baseURLString;
    
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        baseURLString = @"https://api.bitcoin.de/v1";
    });
    
    return baseURLString;
}

- (NSString *)apiKey {
    return @"a2982795ee454d6c210645c79da61bda";
    //    return @"1db1c2c90724daf1c9e11631e39572fb";
}

- (NSString *)apiSecret {
    return @"5e664fb1d6779e372bab040bef2846a7cfab7880";
    //    return @"79bc727e274b37ac90e782e121bc75b7e41ef8f2";
}

@end
