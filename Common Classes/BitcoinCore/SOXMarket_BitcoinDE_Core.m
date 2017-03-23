//
//  SOXMarket_BitcoinDE_Core.m
//  BitcoinApp
//
//  Created by Peter Hauke on 13.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXMarket_BitcoinDE_Core.h"

#import "SOXHash.h"

#import "SOXDataConverter_BitcoinDE.h"

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

#pragma mark | Network Queue handling
@property (strong, nonatomic) NSMutableArray <NSURLSessionTask *> *networkQueue;
@property (nonatomic) BOOL networkQueueIsRunning;

#pragma mark | Credit handling
@property (strong, nonatomic) NSTimer *creditTimer;
@property (nonatomic) NSInteger currentCredits;
@property (nonatomic) NSInteger maxCredits;
@property (weak, nonatomic) NSObject <SOXCreditUpdateProtocol> *delegateForCredit;

@end

@implementation SOXMarket_BitcoinDE_Core

#pragma mark - Public Class methods
+ (instancetype _Nonnull)sharedCore {
    static SOXMarket_BitcoinDE_Core *sharedCore;
    
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        sharedCore = [[self class] new];
        sharedCore.networkQueueIsRunning = NO;
        sharedCore.networkQueue = [NSMutableArray array];
        sharedCore.maxCredits = 0;
    });
    return sharedCore;
}

+ (void)requestDataForServerCommand:(BitcoinDE_ServerCommandType)serverCommandType
                          respondTo:(NSObject <SOXMarketCoreServerRequestProtocol>* _Nonnull)controller {
    NSURLRequest *request = [self urlRequestForServerCommandType:serverCommandType];
    
    weakify(self)
    NSURLSessionTask *getTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                                    strongify(self)
                                                                    NSDictionary *serverAnswer = [self answerDictionaryForServerCommand:serverCommandType
                                                                                                                               withData:data
                                                                                                                            urlResponse:response
                                                                                                                                  error:error];
                                                                    // NSURLSessionTask has its own thread
                                                                    if ([controller respondsToSelector:@selector(answerOfServerRequest:)]) {
                                                                        [controller performSelectorOnMainThread:@selector(answerOfServerRequest:)
                                                                                                     withObject:serverAnswer
                                                                                                  waitUntilDone:YES];
                                                                    }
                                                                    
                                                                    if (error) {
                                                                        NSLog(@"NSURLSessionTask completionHandler - ERROR:\n%@", error);
                                                                    }
                                                                    
//                                                                    NSLog(@"### NSURLSession completionhandler finished");
                                                                    [SOXMarket_BitcoinDE_Core startNextNSURLSessionTask];
                                                                }];
    [SOXMarket_BitcoinDE_Core addNSURLSessionTask:getTask];
}

#pragma mark - Private Class methods

+ (NSDictionary *)answerDictionaryForServerCommand:(BitcoinDE_ServerCommandType)serverCommandType
                                          withData:(NSData * _Nullable)data
                                       urlResponse:(NSURLResponse * _Nullable)response
                                             error:(NSError * _Nullable)error {
    NSDictionary *payloadDictionary;
    {
        NSError *jsonError = nil;
        payloadDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                            options:0
                                                              error:&jsonError];
        
        if (jsonError) {
            NSLog(@"JSONError: %@", jsonError);
            return nil;
        }
        
         NSLog(@"CREDITS: %@ serverCommand: %tu", [payloadDictionary valueForKey:@"credits"], serverCommandType);
        NSNumber *currentCredits =[payloadDictionary valueForKey:@"credits"];
        [self updateCurrentCredit:currentCredits forServerCommandType:serverCommandType];
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
            id payload = [SOXDataConverter_BitcoinDE payloadForServerDictionary:payloadDictionary
                                                               forServerCommand:serverCommandType];
            
            serverAnswer = [NSDictionary dictionaryWithObjectsAndKeys:
                            @(serverCommandType), ServerAnswerServerCommandKey
                            , payload, ServerAnswerPayloadKey
                            , response, ServerAnswerURLResponseKey
                            , nil];
        }
    }
    return serverAnswer;
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
    // First step: update nonce string
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
    NSString *timeInMS = [NSString stringWithFormat:@"%.0f", floor([date timeIntervalSince1970] * 100000)];
    [SOXMarket_BitcoinDE_Core sharedCore].nonceString = timeInMS;
}

#pragma mark | Network Queue handling
+ (NSMutableArray *)networkQueue {
    NSMutableArray *networkQueue = [[SOXMarket_BitcoinDE_Core sharedCore] networkQueue];
    if (!networkQueue) {
        networkQueue = [NSMutableArray array];
    }
    
    return networkQueue;
}

+ (void)addNSURLSessionTask:(NSURLSessionTask* )urlSessionTask {
     NSLog(@"### ADD A NEW NSURLSessionTask");
    NSMutableArray *networkQueue = [SOXMarket_BitcoinDE_Core networkQueue];
    [networkQueue addObject:urlSessionTask];
    
    if (![[SOXMarket_BitcoinDE_Core sharedCore] networkQueueIsRunning]) {
        [SOXMarket_BitcoinDE_Core startNextNSURLSessionTask];
    }
}

+ (void)startNextNSURLSessionTask {
    NSLog(@"startNextNSURLSessionTask - currentCredits: %ti", [[SOXMarket_BitcoinDE_Core sharedCore] currentCredits]);
    NSMutableArray *networkQueue = [SOXMarket_BitcoinDE_Core networkQueue];
    NSURLSessionTask *nextTask = networkQueue.firstObject;
    if (nextTask) {
        if ([[SOXMarket_BitcoinDE_Core sharedCore] startCreditTimer]
             && [[SOXMarket_BitcoinDE_Core sharedCore] currentCredits] < 3) {
            NSLog(@"Delay ### START NEXT NSURLSessionTask");
            dispatch_async(dispatch_get_main_queue(), ^{
                NSTimer *startNextDelayTimer  = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                                                 target:[SOXMarket_BitcoinDE_Core class]
                                                                               selector:@selector(startNextNSURLSessionTask)
                                                                               userInfo:nil
                                                                                repeats:YES];
                [[NSRunLoop mainRunLoop] addTimer:startNextDelayTimer forMode:NSDefaultRunLoopMode];
                
            });
        }
        else {
        
            NSLog(@"### START NEXT NSURLSessionTask");
            [nextTask resume];
            [networkQueue removeObjectAtIndex:0];
            [SOXMarket_BitcoinDE_Core sharedCore].networkQueueIsRunning = YES;
        }
    }
    else {
       // NSLog(@"### There is no NEXT NSURLSessionTask - queue is empty");
        [SOXMarket_BitcoinDE_Core sharedCore].networkQueueIsRunning = NO;
    }
    
}

#pragma mark | Credit handling
+ (void)registerForCreditUpdates:(id <SOXCreditUpdateProtocol> _Nullable) delegateForCredit {
    [SOXMarket_BitcoinDE_Core sharedCore].delegateForCredit = delegateForCredit;
}

- (NSTimer *)startCreditTimer {
    NSTimer *creditTimer = [[SOXMarket_BitcoinDE_Core sharedCore] creditTimer];
    
    if (!creditTimer) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSTimer *creditTimer = [[SOXMarket_BitcoinDE_Core sharedCore] creditTimer];
            creditTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                           target:[SOXMarket_BitcoinDE_Core sharedCore]
                                                         selector:@selector(creditUpdateTimerMethod:)
                                                         userInfo:nil
                                                          repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:creditTimer forMode:NSDefaultRunLoopMode];
             [SOXMarket_BitcoinDE_Core sharedCore].creditTimer = creditTimer;
        });
        
//        creditTimer = [NSTimer timerWithTimeInterval:1
//                                             repeats:YES
//                                               block:^(NSTimer * _Nonnull timer) {
//                                                    // Update credit value
//                                                   if ([SOXMarket_BitcoinDE_Core sharedCore].currentCredits < [SOXMarket_BitcoinDE_Core sharedCore].maxCredits) {
//                                                       [SOXMarket_BitcoinDE_Core sharedCore].currentCredits++;
//                                                   }
//                                                   NSLog(@"CreditTimer update: currentCredits %tu", [SOXMarket_BitcoinDE_Core sharedCore].currentCredits);
//                                                   // inform delegate
//                                                   NSObject *delegateForCredit = [SOXMarket_BitcoinDE_Core sharedCore].delegateForCredit;
//                                                   if ([delegateForCredit respondsToSelector:@selector(showCreditValue:)]) {
//
//                                                        [delegateForCredit performSelectorOnMainThread:@selector(showCreditValue:)
//                                                                                     withObject:@([SOXMarket_BitcoinDE_Core sharedCore].currentCredits)
//                                                                                  waitUntilDone:YES];
//                                                   }
//                                               }];
//        [creditTimer fire];
       
    }
    
    return creditTimer;
}
- (void)creditUpdateTimerMethod:(id)userInfo {
    if ([SOXMarket_BitcoinDE_Core sharedCore].currentCredits < [SOXMarket_BitcoinDE_Core sharedCore].maxCredits) {
        [SOXMarket_BitcoinDE_Core sharedCore].currentCredits++;
    }
    NSLog(@"CreditTimer update: currentCredits %tu", [SOXMarket_BitcoinDE_Core sharedCore].currentCredits);
    // inform delegate
    NSObject *delegateForCredit = [SOXMarket_BitcoinDE_Core sharedCore].delegateForCredit;
    if ([delegateForCredit respondsToSelector:@selector(showCreditValue:)]) {
        
        [delegateForCredit performSelectorOnMainThread:@selector(showCreditValue:)
                                            withObject:@([SOXMarket_BitcoinDE_Core sharedCore].currentCredits)
                                         waitUntilDone:YES];
    }

}

+ (void)updateCurrentCredit:(NSNumber *)newCreditValue forServerCommandType:(BitcoinDE_ServerCommandType)serverCommandType {
    NSInteger creditCosts = [SOXMarket_BitcoinDE_Core creditCostsForServerCommandType:serverCommandType];
    if ([SOXMarket_BitcoinDE_Core sharedCore].maxCredits == 0) {
        // get maxCredits from first server responds
        [SOXMarket_BitcoinDE_Core sharedCore].maxCredits = newCreditValue.integerValue + creditCosts;
        NSLog(@"updateCurrentCredit, inital maxCredits: %ti", [SOXMarket_BitcoinDE_Core sharedCore].maxCredits);
        [[SOXMarket_BitcoinDE_Core sharedCore] startCreditTimer];
    }
    else if ([SOXMarket_BitcoinDE_Core sharedCore].maxCredits < newCreditValue.integerValue) {
        // maybe maxCredit has changed?
        [SOXMarket_BitcoinDE_Core sharedCore].maxCredits = newCreditValue.integerValue + creditCosts;
        NSLog(@"updateCurrentCredit, update maxCredits: %ti", [SOXMarket_BitcoinDE_Core sharedCore].maxCredits);
    }
    
    // set currentCredits to new value
    [SOXMarket_BitcoinDE_Core sharedCore].currentCredits = newCreditValue.integerValue;
    NSLog(@"updateCurrentCredit, currentCredits: %ti", [SOXMarket_BitcoinDE_Core sharedCore].currentCredits);
    

}

- (void)setCurrentCredits:(NSInteger)currentCredits {
    _currentCredits = currentCredits;
    if ([[SOXMarket_BitcoinDE_Core sharedCore].delegateForCredit respondsToSelector:@selector(creditValuesUpdated:)]) {
        NSDictionary *creditDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          @([SOXMarket_BitcoinDE_Core sharedCore].currentCredits), @"currentCredit"
                                          ,@([SOXMarket_BitcoinDE_Core sharedCore].maxCredits), @"maxCredits"
                                          , nil];
        
        [[SOXMarket_BitcoinDE_Core sharedCore].delegateForCredit  performSelectorOnMainThread:@selector(creditValuesUpdated:)
                                                                                   withObject:creditDictionary
                                                                                waitUntilDone:YES];
    }
}

#pragma mark - Private statics
+ (NSDictionary *)commands {
    static NSDictionary    *commandDescriptions;
    
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        commandDescriptions = @{
                                @(UnknownCommand): @"Error"
                                , @(BitcoinDE_ShowBuyOrderbookCommandType): @"/orders?type=buy"  //"sell" liefert Kaufangebote
                                , @(BitcoinDE_ShowSellOrderbookCommandType): @"/orders?type=sell"  //"buy" liefert Verkaufsangebote
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

+ (NSInteger )creditCostsForServerCommandType:(BitcoinDE_ServerCommandType)serverCommandType {
    static NSArray *commandCreditCostsArray;
    
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        commandCreditCostsArray = [NSArray arrayWithObjects:
                                   @(0)   // UnknownCommand = 0
                                   , @(2) // BitcoinDE_ShowBuyOrderbookCommandType  //"buy" liefert Verkaufsangebote
                                   , @(2) // BitcoinDE_ShowSellOrderbookCommandType //"sell" liefert Kaufangebote
                                   , @(2) // BitcoinDE_ShowMyOrdersCommandType
                                   , @(2) // BitcoinDE_ShowMyOrderDetailsCommandType
                                   , @(2) // BitcoinDE_ShowAccountInfoCommandType
                                   , @(3) // BitcoinDE_ShowOrderbookCompactCommandType
                                   , @(3) // BitcoinDE_ShowPublicTradeHistoryCommandType
                                   , @(3) // BitcoinDE_ShowRatesCommandType
                                   , nil];
        
    });
    NSInteger commandCreditCosts = [(NSNumber *)[commandCreditCostsArray objectAtIndex:serverCommandType] integerValue];
    
    return commandCreditCosts;
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
}

+ (NSString *)apiSecret {
    /* APIKeys:
     
     Noch nutzbare:
     910db7219c06a814e5152ff1321c1ae7
     c0631648d8c3e804e11b36f38d5c5309
     f153353bbee85ee554ea6d0a2f293fb9
     
     Verschlissen:
     79bc727e274b37ac90e782e121bc75b7e41ef8f2
     */
    
    return @"5e664fb1d6779e372bab040bef2846a7cfab7880";
}

@end
