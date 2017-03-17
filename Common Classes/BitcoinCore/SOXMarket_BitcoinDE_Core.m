//
//  SOXMarket_BitcoinDE_Core.m
//  BitcoinApp
//
//  Created by Peter Hauke on 13.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXMarket_BitcoinDE_Core.h"

#import "SOXHash.h"

NSString *const _Nonnull ServerAnswerServerCommandKey = @"ServerCommand";
NSString *const _Nonnull ServerAnswerPayloadKey       = @"Payload";
NSString *const _Nonnull ServerAnswerURLResponseKey   = @"URLResponse";
NSString *const _Nonnull ServerAnswerErrorKey         = @"Error";



@interface SOXMarket_BitcoinDE_Core ()

@property (strong, nonatomic) NSString *nonceString;
@property (strong, nonatomic) NSString *baseURL;
@property (strong, nonatomic) NSTimer *reloadBannerDataTimer;

@property (weak, nonatomic) id delegateForRequests;
@property (weak, nonatomic) id <SOXBannerDataProtocol> delegateForBannerUpdates;

@end

@implementation SOXMarket_BitcoinDE_Core

#pragma mark - Public methods
+ (instancetype _Nonnull)sharedCore {
    static id sharedCore;
    
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        sharedCore = [[self class] new];
    });
    return sharedCore;
}

+ (void)requestDataForServerCommand:(BitcoinDE_ServerCommandType)serverCommandType
                          respondTo:(id <SOXMarketCoreServerRequestProtocol> _Nonnull)controller {
    NSURLRequest *request = [self urlRequestForServerCommandType:serverCommandType];
    
    NSURLSessionTask *getTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                                    
                                                                    NSDictionary *payloadDictionary;
                                                                    {
                                                                        NSError *jsonError = nil;
                                                                        payloadDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                                                                            options:0
                                                                                                                              error:&jsonError];
                                                                    
                                                                        if (jsonError) {
                                                                            NSLog(@"JSONError: %@", jsonError);
                                                                            return;
                                                                        }
                                                                    }
                                                                    
                                                                    NSDictionary *serverAnswer;
                                                                    {
                                                                        if (error) {
                                                                            serverAnswer = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                                            @(serverCommandType), ServerAnswerServerCommandKey
                                                                                            ,response, ServerAnswerURLResponseKey
                                                                                            ,error, ServerAnswerErrorKey
                                                                                            , nil];
                                                                        }
                                                                        else {
                                                                            serverAnswer = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                                            @(serverCommandType), ServerAnswerServerCommandKey
                                                                                            , payloadDictionary, ServerAnswerPayloadKey
                                                                                            , response, ServerAnswerURLResponseKey
                                                                                            , nil];
                                                                        }
                                                                    }

                                                                    if ([controller respondsToSelector:@selector(answerOfServerRequest:)]) {
                                                                        [controller performSelector:@selector(answerOfServerRequest:)
                                                                                         withObject:serverAnswer];
                                                                    }
                                                                    
//                                                                    NSLog(@"completionHandler");
//                                                                    NSLog(@"Data: %@", [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed]);
//                                                                    NSLog(@"JSON: %@", self.serverAnswerDictionary);
//                                                                    NSLog(@"response: %@", response);
//                                                                    NSLog(@"error: %@", error);
//                                                                    NSLog(@"jsonError: %@", jsonError);
//                                                                    
//                                                                    
//                                                                    [self performSelectorOnMainThread:@selector(report:)
//                                                                                           withObject:self.serverAnswerDictionary
//                                                                                        waitUntilDone:YES];
                                                                    
                                                                }];
    
    [getTask resume];

    
}

+ (void)startBannerUpdatesWithScheduleTime:(NSTimeInterval)timeInterval delegate:(id <SOXBannerDataProtocol> _Nonnull)delegateForBannerUpdates {
    // timer
    weakify(self)
    NSTimer *reloadBannerDataTimer = [NSTimer timerWithTimeInterval:timeInterval
                                                            repeats:YES
                                                              block:^(NSTimer * _Nonnull timer) {
                                                                  strongify(self)
                                                                //  [self startBannerUpdate];
                                                              }];
        [SOXMarket_BitcoinDE_Core sharedCore].reloadBannerDataTimer = reloadBannerDataTimer;
    
        // delegate
        [SOXMarket_BitcoinDE_Core sharedCore].delegateForBannerUpdates = delegateForBannerUpdates;

}

+ (NSURLRequest * _Nullable)urlRequestForServerCommandType:(BitcoinDE_ServerCommandType)serverCommandType {
    [SOXMarket_BitcoinDE_Core updateNonceString];
    
    NSString            *urlString       = [SOXMarket_BitcoinDE_Core urlStringForServerCommandType:serverCommandType];
    NSString            *signatureString = [SOXMarket_BitcoinDE_Core signatureStringForURLString:urlString];
    NSString            *hmacHex         = [SOXHash hexadecimalHMACForString:signatureString
                                                                     withKey:[SOXMarket_BitcoinDE_Core apiSecret]];
    
    NSMutableURLRequest *request         = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    {
        NSString *getOrPostHTTPMethod = [SOXMarket_BitcoinDE_Core getOrPostForServerCommandType:serverCommandType];
        if (getOrPostHTTPMethod) {
            [request setHTTPMethod:getOrPostHTTPMethod];
            [request addValue:[SOXMarket_BitcoinDE_Core apiKey] forHTTPHeaderField:@"X-API-KEY"];
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
                                 , [SOXMarket_BitcoinDE_Core apiKey] // apiKey
                                 , @"#"
                                 , [SOXMarket_BitcoinDE_Core sharedCore].nonceString // nonce
                                 , @"#"
                                 , @"d41d8cd98f00b204e9800998ecf8427e" // postParameterMD5; hier: für md5 für weil get keine POSTParameter hat" " 
                                 ];
    
    return signatureString;
}


+ (NSString  * _Nullable )getOrPostForServerCommandType:(BitcoinDE_ServerCommandType)serverCommandType {
    switch (serverCommandType) {
        case UnknownCommand: {
            return nil;
            break;
        }
            
        case BitcoinDE_ShowBuyOrderbookCommandType:
        case BitcoinDE_ShowSellOrderbookCommandType:
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
                                , @(BitcoinDE_ShowBuyOrderbookCommandType): @"/orders?type=buy"
                                , @(BitcoinDE_ShowSellOrderbookCommandType): @"/orders?type=sell"
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
                                , @(BitcoinDE_ShowBuyOrderbookCommandType): @"Durchsuchen des Orderbooks nach passenden Kaufangeboten"
                                , @(BitcoinDE_ShowSellOrderbookCommandType): @"Durchsuchen des Orderbooks nach passenden Verkaufsangeboten"
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

#pragma mark - Manual getter
+ (NSString *)baseURLString {
    static NSString        *baseURLString;
    
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        baseURLString = @"https://api.bitcoin.de/v1";
    });
    
    return baseURLString;
}

+ (NSString *)apiKey {
    return @"a2982795ee454d6c210645c79da61bda";
    //    return @"1db1c2c90724daf1c9e11631e39572fb";
}

+ (NSString *)apiSecret {
    return @"5e664fb1d6779e372bab040bef2846a7cfab7880";
    //    return @"79bc727e274b37ac90e782e121bc75b7e41ef8f2";
}

@end
