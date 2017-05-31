//
//  SOXMarket_BitcoinDE_Core.m
//  BitcoinApp
//
//  Created by Peter Hauke on 13.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXMarket_BitcoinDE_Core.h"

#import "SOXKeys_BitcoinDE.h"
#import "SOXHash.h"

#import "SOXDataConverter_BitcoinDE.h"
#import "SOXErrorMessage_BitcoinDE.h"

#pragma mark - Keys
NSString *const _Nonnull ServerAnswerServerCommandKey = @"ServerCommand";
NSString *const _Nonnull ServerAnswerPayloadKey       = @"Payload";
NSString *const _Nonnull ServerAnswerURLResponseKey   = @"URLResponse";
NSString *const _Nonnull ServerAnswerErrorKey         = @"Error";

NSString *const _Nonnull CreditUpdate_CurrentCreditsKey = @"CreditUpdate_CurrentCredits";
NSString *const _Nonnull CreditUpdate_MaximalCreditsKey = @"CreditUpdate_MaximalCredits";

NSString *const _Nonnull HTTPMethodGETKey    = @"GET";
NSString *const _Nonnull HTTPMethodDELETEKey = @"DELETE";
NSString *const _Nonnull HTTPMethodPOSTKey   = @"POST";

NSString *const _Nonnull NSURLSessionTaskKey = @"NSURLSessionTask";

@interface SOXMarket_BitcoinDE_Core ()

@property (copy, nonatomic) NSString *baseURL;
@property (weak, nonatomic) NSTimer *reloadBannerDataTimer;

@property (copy, nonatomic) NSString *nonce;
@property (copy, nonatomic) NSString *httpMethod;
@property (copy, nonatomic) NSString *url_encoded_query_string;
@property (copy, nonatomic) NSString *uri;
@property (copy, nonatomic) NSString *url;
@property (copy, nonatomic) NSString *post_parameter_md5_hashed_url_encoded_query_string;
@property (copy, nonatomic) NSString *hmac_data;
@property (copy, nonatomic) NSString *hmac;
@property (copy, nonatomic) NSString *api_key;
@property (copy, nonatomic) NSString *api_secret;

//@property (weak, nonatomic) id delegateForRequests;
@property (weak, nonatomic) id <SOXBannerDataProtocol> delegateForBannerUpdates;
@property (weak, nonatomic) NSObject <SOXMarketCoreErrorProtocol> *delegateForErrorMessages;
@property (weak, nonatomic) NSObject <SOXStatusBarUpdateProtocol> *delegateForStatusBarUpdates;

#pragma mark | Network Queue handling
@property (strong, nonatomic) NSMutableArray <NSDictionary *> *networkQueue;
@property (nonatomic) BOOL networkQueueIsRunning;

#pragma mark | Credit handling
@property (weak, nonatomic) NSTimer *creditTimer;
@property (nonatomic) NSInteger currentCredits;
@property (nonatomic) NSInteger maxCredits;
@property (weak, nonatomic) id <SOXCreditUpdateProtocol> delegateForCreditUpdates;

@end

#pragma mark - Implementation
@implementation SOXMarket_BitcoinDE_Core
- (void)startRequests {
            [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowAccountInfoCommandType
                                                        respondTo:nil];
            [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowRatesCommandType
                                                        respondTo:nil];
}

#pragma mark Public Class methods
+ (instancetype _Nonnull)sharedCore {
    static SOXMarket_BitcoinDE_Core *sharedCore;
    
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        sharedCore = [[self class] new];
        sharedCore.networkQueueIsRunning = NO;
        sharedCore.networkQueue = [NSMutableArray array];
        sharedCore.maxCredits = 0;
        
        sharedCore.rate_weighted      = [NSDecimalNumber decimalNumberWithString:@"0"];
        sharedCore.rate_weighted_half = [NSDecimalNumber decimalNumberWithString:@"0"];
    });
    return sharedCore;
}

+ (void)requestDataForServerCommand:(BitcoinDE_ServerCommandType)serverCommandType
                          respondTo:(NSObject <SOXMarketCoreServerRequestProtocol>* _Nullable)controller {
    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:serverCommandType
                                            withParameter:nil
                                                respondTo:controller];
}

+ (void)executeTradeWithOrderID:(NSString *)orderID
                      withParameter:(NSDictionary * _Nullable)parameterDictionary
                          respondTo:(NSObject <SOXMarketCoreServerRequestProtocol>* _Nullable)controller{
    
}

+ (void)prepareRequestDataForServerCommand:(BitcoinDE_ServerCommandType)serverCommandType
                             withParameter:(NSDictionary * _Nullable)parameterDictionary {
    // reset values
    {
        [SOXMarket_BitcoinDE_Core sharedCore].uri = nil;
        [SOXMarket_BitcoinDE_Core sharedCore].nonce = nil;
        [SOXMarket_BitcoinDE_Core sharedCore].url_encoded_query_string = nil;
        [SOXMarket_BitcoinDE_Core sharedCore].post_parameter_md5_hashed_url_encoded_query_string = nil;
        [SOXMarket_BitcoinDE_Core sharedCore].httpMethod = nil;
        [SOXMarket_BitcoinDE_Core sharedCore].hmac_data = nil;
        [SOXMarket_BitcoinDE_Core sharedCore].hmac = nil;
    }
    
    [SOXMarket_BitcoinDE_Core createHttpMethodForServerCommandType:serverCommandType];
    [SOXMarket_BitcoinDE_Core createURIForServerCommandType:serverCommandType];
    [SOXMarket_BitcoinDE_Core createNonceString];
    if (serverCommandType != BitcoinDE_ExecuteTrade) {
        [SOXMarket_BitcoinDE_Core create_url_encoded_query_stringFromParameterDictionary:parameterDictionary];
        [SOXMarket_BitcoinDE_Core createURL];
    }
    else {
        NSString *orderID = [parameterDictionary objectForKey:BitcoinDE_ExecuteTrade_OrderID];
        
        // create_url_encoded_query_stringFromParameterDictionary
        {
            NSMutableDictionary *mutableParameterDictionary = [parameterDictionary mutableCopy];
            [mutableParameterDictionary removeObjectForKey:BitcoinDE_ExecuteTrade_OrderID];
            [SOXMarket_BitcoinDE_Core create_url_encoded_query_stringFromParameterDictionary:[mutableParameterDictionary copy]];
        }
        
        // createURL
        {
            SOXMarket_BitcoinDE_Core *core = [SOXMarket_BitcoinDE_Core sharedCore];
            NSString *url = [NSString stringWithFormat:@"%@%@%@", [SOXMarket_BitcoinDE_Core baseURLString],core.uri, orderID];
            core.url = url;
        }
        
    }
    
    [SOXMarket_BitcoinDE_Core createMD5Of_url_encoded_query_string];
    [SOXMarket_BitcoinDE_Core createHmac_data];
    [SOXMarket_BitcoinDE_Core createHMAC];

}


+ (void)requestDataForServerCommand:(BitcoinDE_ServerCommandType)serverCommandType
                      withParameter:(NSDictionary * _Nullable)parameterDictionary
                          respondTo:(NSObject <SOXMarketCoreServerRequestProtocol>* _Nullable)controller {
    [SOXMarket_BitcoinDE_Core prepareRequestDataForServerCommand:serverCommandType
                                                   withParameter:parameterDictionary];
    
    NSURLRequest *request = [SOXMarket_BitcoinDE_Core createRequest];

    if (!request) {
        return;
    }
    
    weakify(self)
    NSURLSessionTask *getTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                                    strongify(self)
                                                                    [SOXMarket_BitcoinDE_Core startNextNSURLSessionTask];
                                                                
                                                                    NSString *serverRequestTitle = [NSString stringWithFormat:@"%tu (%@)",
                                                                                                    serverCommandType
                                                                                                    ,[SOXMarket_BitcoinDE_Core descriptionForServerCommandType:serverCommandType]];
                                                                    
                                                                    SOXErrorMessage_BitcoinDE *errorMessage = [[SOXErrorMessage_BitcoinDE alloc] initWithServerRequestTitle:serverRequestTitle];
                                                                    
                                                                    NSDictionary *serverAnswer = [self answerDictionaryForServerCommand:serverCommandType
                                                                                                                               withData:data
                                                                                                                            urlResponse:response
                                                                                                                                  error:error
                                                                                                                           errorMessage:errorMessage];
                                                                    
                                                                    if (serverCommandType == BitcoinDE_ShowAccountInfoCommandType) {
                                                                        [[NSNotificationCenter defaultCenter] postNotificationName:BitcoinDE_Notification_RequestShowAccountInfo
                                                                                                                            object:serverAnswer];
                                                                    }
                                                                    else if (serverCommandType == BitcoinDE_ShowRatesCommandType) {
                                                                        [[NSNotificationCenter defaultCenter] postNotificationName:BitcoinDE_Notification_RequestShowRates
                                                                                                                            object:serverAnswer];
                                                                    } else {
                                                                        // Send answer to asking controller
                                                                        if ([controller respondsToSelector:@selector(answerOfServerRequest:)]) {
                                                                            // NSURLSessionTask has its own thread
                                                                            [controller performSelectorOnMainThread:@selector(answerOfServerRequest:)
                                                                                                         withObject:serverAnswer
                                                                                                      waitUntilDone:NO];
                                                                        }
                                                                        
                                                                        // Error handling
                                                                        NSObject *delegateForErrorMessages = [SOXMarket_BitcoinDE_Core sharedCore].delegateForErrorMessages;
                                                                        if (errorMessage.hasError
                                                                            && [delegateForErrorMessages respondsToSelector:@selector(presentErrorMessage:)]) {
                                                                            // NSURLSessionTask has its own thread
                                                                            [delegateForErrorMessages performSelectorOnMainThread:@selector(presentErrorMessage:)
                                                                                                                       withObject:errorMessage
                                                                                                                    waitUntilDone:NO];
                                                                        }
                                                                    }
                                                                }];
    
    [SOXMarket_BitcoinDE_Core addNSURLSessionTask:getTask forServerCommand:serverCommandType];
}

#pragma mark | Status bar handling
+ (void)registerForCreditUpdates:(id <SOXCreditUpdateProtocol> _Nullable)delegateForCreditUpdates {
    [SOXMarket_BitcoinDE_Core sharedCore].delegateForCreditUpdates = delegateForCreditUpdates;
}

+ (void)registerForStatusBarUpdates:(id <SOXCreditUpdateProtocol> _Nullable) delegateForStatusBarUpdates {
    [SOXMarket_BitcoinDE_Core sharedCore].delegateForStatusBarUpdates = delegateForStatusBarUpdates;
}

#pragma mark | Error handling
+ (void)registerForErrorMessages:(id <SOXMarketCoreErrorProtocol> _Nullable)delegateForErrorMessages {
    [SOXMarket_BitcoinDE_Core sharedCore].delegateForErrorMessages = delegateForErrorMessages;
}

#pragma mark - Private Class methods
+ (NSDictionary *)answerDictionaryForServerCommand:(BitcoinDE_ServerCommandType)serverCommandType
                                          withData:(NSData * _Nullable)data
                                       urlResponse:(NSURLResponse * _Nullable)response
                                             error:(NSError * _Nullable)error
                                      errorMessage:(SOXErrorMessage_BitcoinDE * _Nullable)errorMessage {
    // check for error in urlResponse
    [errorMessage checkNSURLResonse:response];
    
    // get payload from server data
    NSDictionary *payloadDictionary;
    {
        NSError *jsonError = nil;
        if (data) {
            payloadDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                options:0
                                                                  error:&jsonError];
        }
        else {
            [errorMessage appendErrorDescripton:@"Data for JSON is nil"];
        }
        // check for error in json deserialization
        [errorMessage checkJsonError:jsonError];

        // check for error in server answer
        [errorMessage checkforAPIErrors:[payloadDictionary objectForKey:@"errors"]];
        
        [self updateCurrentCredit:[payloadDictionary valueForKey:@"credits"]
             forServerCommandType:serverCommandType];
    }
    
    // process server answer
    NSDictionary *serverAnswer;
    {
        if (error) {
            serverAnswer = [NSDictionary dictionaryWithObjectsAndKeys:
                            @(serverCommandType), ServerAnswerServerCommandKey
                            ,response, ServerAnswerURLResponseKey
                            ,error, ServerAnswerErrorKey
                            , nil];
        }
        else if (!error && errorMessage.hasError) {
            // on error on executeTrade there is no error! (Warum auch immer)
            serverAnswer = [NSDictionary dictionaryWithObjectsAndKeys:
                            @(serverCommandType), ServerAnswerServerCommandKey
                            ,response, ServerAnswerURLResponseKey
                            ,[payloadDictionary objectForKey:@"errors"], ServerAnswerErrorKey
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

+ (NSString  * _Nullable )httpMethodForServerCommandType:(BitcoinDE_ServerCommandType)serverCommandType {
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
        case BitcoinDE_ShowMyTradesType:
        case BitcoinDE_ShowAccountLedgerType:
            return HTTPMethodGETKey;
            break;
        case BitcoinDE_RemoveOrderType:
            return HTTPMethodDELETEKey;
            break;
        case BitcoinDE_CreateOrderType:
        case BitcoinDE_ExecuteTrade:
            return HTTPMethodPOSTKey;
        default:
            break;
    }
    return nil;
}

#pragma mark - Create methods

+ (void)createURIForServerCommandType:(BitcoinDE_ServerCommandType)serverCommandType {
    NSString *uri = [SOXMarket_BitcoinDE_Core commandForServerCommandType:serverCommandType];
//    NSLog(@"uri\n%@",uri);
    [SOXMarket_BitcoinDE_Core sharedCore].uri = uri;
}

+ (void)createNonceString {
    NSDate   *date     = [NSDate date];
    NSString *timeInMS = [NSString stringWithFormat:@"%.0f", floor([date timeIntervalSince1970] * 1000000)];

//    NSLog(@"nonce \n%@",timeInMS);
    [SOXMarket_BitcoinDE_Core sharedCore].nonce = timeInMS;
}

+ (void)create_url_encoded_query_stringFromParameterDictionary:(NSDictionary *)parameterDictionary {
    // BSP: url_encoded_query_string = 'max_amount=5.3&price=255.5&type=buy'
    NSString *url_encoded_query_string = nil;
    if (parameterDictionary.allKeys.count > 0) {
        // get and sort parameterKeys
        NSArray *allKeys = parameterDictionary.allKeys;
        allKeys = [allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        
        NSString *httpMethod = [SOXMarket_BitcoinDE_Core sharedCore].httpMethod;
        if ([httpMethod isEqualToString:HTTPMethodDELETEKey]) {
            NSArray *orderIDs = parameterDictionary.allValues;
            url_encoded_query_string = orderIDs.firstObject;
        }
        else {//if ([httpMethod isEqualToString:HTTPMethodPOSTKey]) {
            // create "parameter=value" pairs
            NSMutableArray *parameters = [NSMutableArray array];
            for (NSString *key in allKeys) {
                NSString *parameter = [NSString stringWithFormat:@"%@=%@", key, [parameterDictionary objectForKey:key]];
                [parameters addObject:parameter];
            }
            // join pairs with "&"
            url_encoded_query_string = [parameters componentsJoinedByString:@"&"];
        }
//        else {
//            NSLog(@"ERROR: httpMethod should be DELETE or POST but is %@",httpMethod);
//        };
    }

    NSLog(@"url_encoded_query string\n%@",url_encoded_query_string);
//    NSLog(@"url_encoded_query string\n%s",url_encoded_query_string.UTF8String);
    
    [SOXMarket_BitcoinDE_Core sharedCore].url_encoded_query_string = url_encoded_query_string;
}

+ (void)createURL {
    SOXMarket_BitcoinDE_Core *core = [SOXMarket_BitcoinDE_Core sharedCore];
    
    
    NSString *baseURL = [SOXMarket_BitcoinDE_Core baseURLString];
    NSString *uri     = core.uri;
    NSString *url_encoded_query_string = core.url_encoded_query_string;
    NSString *httpMethod = core.httpMethod;
    
    NSString *url = nil;
    url = [NSString stringWithFormat:@"%@%@", baseURL, uri];
    
    if (url_encoded_query_string && [httpMethod isEqualToString:HTTPMethodDELETEKey]) {
        url = [url stringByAppendingString:url_encoded_query_string];
    }
    else if (url_encoded_query_string && [httpMethod isEqualToString:HTTPMethodGETKey]) {
        url = [url stringByAppendingString:@"?"];
        url = [url stringByAppendingString:url_encoded_query_string];
    }
    NSLog(@"url\n%@",url);
    core.url = url;
}

+ (void)createMD5Of_url_encoded_query_string {
    SOXMarket_BitcoinDE_Core *core = [SOXMarket_BitcoinDE_Core sharedCore];
    
    NSString *md5String = @"d41d8cd98f00b204e9800998ecf8427e"; // md5 for @""
    if ([core.httpMethod isEqualToString:HTTPMethodPOSTKey]) {
        NSString *url_encoded_query_string = core.url_encoded_query_string;
        if (url_encoded_query_string) {
            md5String = [SOXHash md5StringForString:url_encoded_query_string];
        }
    }

//    NSLog(@"md5 %@", md5String);
    [SOXMarket_BitcoinDE_Core sharedCore].post_parameter_md5_hashed_url_encoded_query_string = md5String;
}

+ (void)createHttpMethodForServerCommandType:(BitcoinDE_ServerCommandType)serverCommandType {
    NSString *httpMethod = [self httpMethodForServerCommandType:serverCommandType];
    
    [SOXMarket_BitcoinDE_Core sharedCore].httpMethod = httpMethod;
}

+ (void)createHmac_data {
    // hmac_data = http_method+'#'+uri+'#'+api_key+'#'+nonce+'#'+post_parameter_md5_hashed_url_encoded_query_string
    SOXMarket_BitcoinDE_Core *core = [SOXMarket_BitcoinDE_Core sharedCore];
    
    NSString *httpMethod = core.httpMethod;
    NSString *url = core.url;
    NSString *api_key = core.api_key;
    NSString *nonce = core.nonce;
    NSString *post_parameter_md5_hashed_url_encoded_query_string = core.post_parameter_md5_hashed_url_encoded_query_string;
    
    NSString *hmac_data = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@"
                           , httpMethod
                           , @"#"
                           , url
                           , @"#"
                           , api_key
                           , @"#"
                           , nonce
                           , @"#"
                           , post_parameter_md5_hashed_url_encoded_query_string
                           ];
//    NSLog(@"hmac_data\n%@",hmac_data);
    [SOXMarket_BitcoinDE_Core sharedCore].hmac_data = hmac_data;
}

+ (void)createHMAC {
    SOXMarket_BitcoinDE_Core *core = [SOXMarket_BitcoinDE_Core sharedCore];
    NSString *hmac_data  = core.hmac_data;
    NSString *api_secret = core.api_secret;
    
    NSString *hmac = nil;
    if (hmac_data) {
        hmac = [SOXHash hexadecimalHMACForString:hmac_data
                                         withKey:api_secret];
    }
    
//    NSLog(@"hmac\n%@", hmac);
    core.hmac = hmac;
}


+ (NSURLRequest *)createRequest {
    SOXMarket_BitcoinDE_Core *core = [SOXMarket_BitcoinDE_Core sharedCore];
    
    NSString *httpMethod            = core.httpMethod;
    NSString *urlString             = core.url;
    NSString *api_key               = core.api_key;
    NSString *nonce                 = core.nonce;
    NSString *hmac                  = core.hmac;
    NSString *postParametersString  = core.url_encoded_query_string;
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    {
        [request setHTTPMethod:httpMethod];
        [request addValue:api_key           forHTTPHeaderField:@"X-API-KEY"];
        [request addValue:nonce             forHTTPHeaderField:@"X-API-NONCE"];
        [request addValue:hmac              forHTTPHeaderField:@"X-API-SIGNATURE"];
        if (postParametersString
            && [httpMethod isEqualToString:HTTPMethodPOSTKey]) {
        [request setHTTPBody:[postParametersString dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    return [request copy];
}

#pragma mark | Network Queue handling
+ (NSMutableArray *)networkQueue {
    NSMutableArray *networkQueue = [[SOXMarket_BitcoinDE_Core sharedCore] networkQueue];
    if (!networkQueue) {
        networkQueue = [NSMutableArray array];
    }
    
    return networkQueue;
}

+ (void)addNSURLSessionTask:(NSURLSessionTask* )urlSessionTask forServerCommand:(BitcoinDE_ServerCommandType)serverCommand {
 //   NSLog(@"### ADD A NEW NSURLSessionTask");
    NSMutableArray *networkQueue = [SOXMarket_BitcoinDE_Core networkQueue];
    NSDictionary *queueDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                     urlSessionTask, NSURLSessionTaskKey
                                     , @(serverCommand), ServerAnswerServerCommandKey
                                     , nil];
    
    [networkQueue addObject:queueDictionary];
    
    if (![[SOXMarket_BitcoinDE_Core sharedCore] networkQueueIsRunning]) {
        [SOXMarket_BitcoinDE_Core startNextNSURLSessionTask];
    }
}

+ (void)startNextNSURLSessionTask {
 //   NSLog(@"startNextNSURLSessionTask - currentCredits: %ti", [[SOXMarket_BitcoinDE_Core sharedCore] currentCredits]);
    NSMutableArray *networkQueue = [SOXMarket_BitcoinDE_Core networkQueue];
    NSDictionary *nextTastDictionary = networkQueue.firstObject;
    NSURLSessionTask *nextTask = [nextTastDictionary objectForKey:NSURLSessionTaskKey];
    
    if (nextTask) {
        if ([SOXMarket_BitcoinDE_Core sharedCore].creditTimer
            && [SOXMarket_BitcoinDE_Core sharedCore].currentCredits < 3) { // TODO: TODO vergleich mit serverCommandType
            NSLog(@"Delay ### START NEXT NSURLSessionTask");
            dispatch_async(dispatch_get_main_queue(), ^{
                NSTimer *startNextDelayTimer  = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                                                 target:[SOXMarket_BitcoinDE_Core class]
                                                                               selector:@selector(startNextNSURLSessionTask)
                                                                               userInfo:nil
                                                                                repeats:NO];
                [[NSRunLoop mainRunLoop] addTimer:startNextDelayTimer forMode:NSDefaultRunLoopMode];
                [[SOXMarket_BitcoinDE_Core sharedCore].delegateForStatusBarUpdates statusBarUpdated:@"Too less credits. Waiting for more ..."];
            });
        }
        else {
            NSLog(@"### START NEXT NSURLSessionTask");
            [nextTask resume];
        
            // update status bar
            dispatch_async(dispatch_get_main_queue(), ^{
                BitcoinDE_ServerCommandType serverCommand = [[nextTastDictionary objectForKey:ServerAnswerServerCommandKey] unsignedIntegerValue];
                NSString *statusBarString = [self commandDescriptionForServerCommand:serverCommand];
                [[SOXMarket_BitcoinDE_Core sharedCore].delegateForStatusBarUpdates statusBarUpdated:statusBarString];
            });
            
            [networkQueue removeObjectAtIndex:0];
            [SOXMarket_BitcoinDE_Core sharedCore].networkQueueIsRunning = YES;
        }
    }
    else {
        NSLog(@"### There is no NEXT NSURLSessionTask - queue is empty");
        [SOXMarket_BitcoinDE_Core sharedCore].networkQueueIsRunning = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[SOXMarket_BitcoinDE_Core sharedCore].delegateForStatusBarUpdates statusBarUpdated:@"Idle"];
        });
    }
}

#pragma mark | Credit handling
+ (void)updateCurrentCredit:(NSNumber *)newCreditValue forServerCommandType:(BitcoinDE_ServerCommandType)serverCommandType {
    NSInteger creditCosts = [SOXMarket_BitcoinDE_Core creditCostsForServerCommandType:serverCommandType];
    
    if ([SOXMarket_BitcoinDE_Core sharedCore].maxCredits == 0) {
        // get maxCredits from first server responds
        [SOXMarket_BitcoinDE_Core sharedCore].maxCredits = newCreditValue.integerValue + creditCosts;
       // NSLog(@"updateCurrentCredit, inital maxCredits: %ti", [SOXMarket_BitcoinDE_Core sharedCore].maxCredits);
    }
    else if ([SOXMarket_BitcoinDE_Core sharedCore].maxCredits < newCreditValue.integerValue) {
        // maybe maxCredit has changed?
        [SOXMarket_BitcoinDE_Core sharedCore].maxCredits = newCreditValue.integerValue + creditCosts;
        //NSLog(@"updateCurrentCredit, update maxCredits: %ti", [SOXMarket_BitcoinDE_Core sharedCore].maxCredits);
    }
    
    // set currentCredits to new value
    [SOXMarket_BitcoinDE_Core sharedCore].currentCredits = newCreditValue.integerValue;
  //  NSLog(@"updateCurrentCredit, currentCredits: %ti", [SOXMarket_BitcoinDE_Core sharedCore].currentCredits);
}

+ (void)creditUpdateTimerMethod:(id)userInfo {
    // increase credit counter
    if ([SOXMarket_BitcoinDE_Core sharedCore].currentCredits < [SOXMarket_BitcoinDE_Core sharedCore].maxCredits) {
        [SOXMarket_BitcoinDE_Core sharedCore].currentCredits++;
    }
 //   NSLog(@"CreditTimer update: currentCredits %tu", [SOXMarket_BitcoinDE_Core sharedCore].currentCredits);
    if ([SOXMarket_BitcoinDE_Core sharedCore].currentCredits == [SOXMarket_BitcoinDE_Core sharedCore].maxCredits) {
        // stop timer
        NSTimer *creditTimer = [[SOXMarket_BitcoinDE_Core sharedCore] creditTimer];
        [creditTimer invalidate];
        creditTimer = nil;
 //       NSLog(@"Credit timer invalidated and nil'ed");
    }
}

- (void)setCurrentCredits:(NSInteger)currentCredits {
    _currentCredits = currentCredits;
    
    // setup credit timer if needed
    NSTimer *creditTimer = [self creditTimer];
    if (!creditTimer) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSTimer *creditTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                    target:[SOXMarket_BitcoinDE_Core class]
                                                                  selector:@selector(creditUpdateTimerMethod:)
                                                                  userInfo:nil
                                                                   repeats:YES];
            creditTimer.tolerance = 0.05;
            [[NSRunLoop mainRunLoop] addTimer:creditTimer forMode:NSDefaultRunLoopMode];
            [SOXMarket_BitcoinDE_Core sharedCore].creditTimer = creditTimer;
           // NSLog(@"Credit timer started");
        });
    }
    
    // inform delegate
    NSObject *delegateForCreditUpdates = [SOXMarket_BitcoinDE_Core sharedCore].delegateForCreditUpdates;
    
    if ([delegateForCreditUpdates respondsToSelector:@selector(creditValuesUpdated:)]) {
        NSDictionary *creditValuesUpdatedDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                       @([SOXMarket_BitcoinDE_Core sharedCore].currentCredits), CreditUpdate_CurrentCreditsKey
                                                       ,@([SOXMarket_BitcoinDE_Core sharedCore].maxCredits), CreditUpdate_MaximalCreditsKey
                                                       , nil];

        
        [delegateForCreditUpdates  performSelectorOnMainThread:@selector(creditValuesUpdated:)
                                                    withObject:creditValuesUpdatedDictionary
                                                 waitUntilDone:NO];
    }
}

#pragma mark - Private statics
+ (NSDictionary *)commands {
    static NSDictionary    *commandDescriptions;
    
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        commandDescriptions = @{
                                @(UnknownCommand): @"Error"
                                , @(BitcoinDE_ShowBuyOrderbookCommandType): @"/orders"  //"sell" liefert Kaufangebote
                                , @(BitcoinDE_ShowSellOrderbookCommandType): @"/orders"  //"buy" liefert Verkaufsangebote
                                , @(BitcoinDE_ShowMyOrdersCommandType): @"/orders/my_own"
                                , @(BitcoinDE_ShowMyOrderDetailsCommandType): @"/orders/:order_id"
                                , @(BitcoinDE_ShowAccountInfoCommandType): @"/account"
                                , @(BitcoinDE_ShowOrderbookCompactCommandType): @"/orders/compact"
                                , @(BitcoinDE_ShowPublicTradeHistoryCommandType): @"/trades/history"
                                , @(BitcoinDE_ShowRatesCommandType): @"/rates"
                                , @(BitcoinDE_ShowMyTradesType):@"/trades"
                                , @(BitcoinDE_ShowAccountLedgerType):@"/account/ledger"
                                , @(BitcoinDE_RemoveOrderType):@"/orders/"
                                , @(BitcoinDE_CreateOrderType):@"/orders"
                                , @(BitcoinDE_ExecuteTrade):@"/trades/"
                                };
    });
    return commandDescriptions;
}

+ (NSString *)commandDescriptionForServerCommand:(BitcoinDE_ServerCommandType)serverCommand {
    NSDictionary *commandDescriptions = [self commandDescriptions];
    NSString *commandDescriptionForServerCommand = [commandDescriptions objectForKey:@(serverCommand)];
    
    return commandDescriptionForServerCommand;
}

+ (NSDictionary *)commandDescriptions {
    static NSDictionary    *commandDescriptions;
    
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        commandDescriptions = @{
                                @(UnknownCommand): @"Error"
                                , @(BitcoinDE_ShowBuyOrderbookCommandType): @"Retrieving Buy Orders"
                                , @(BitcoinDE_ShowSellOrderbookCommandType): @"Retrieving Sell Offers"
                                , @(BitcoinDE_ShowMyOrdersCommandType): @"Retrieving My active Orders"
                                , @(BitcoinDE_ShowMyOrderDetailsCommandType): @"Retrieving Data for Order ID"
                                , @(BitcoinDE_ShowAccountInfoCommandType): @"Retrieving Account Informations"
                                , @(BitcoinDE_ShowOrderbookCompactCommandType): @"— wo wird dies denn angezeigt? —"
                                , @(BitcoinDE_ShowPublicTradeHistoryCommandType): @"— haben wir auch noch nicht - chart ;) —"
                                , @(BitcoinDE_ShowRatesCommandType): @"Retrieving Rates"
                                , @(BitcoinDE_ShowMyTradesType): @"Retrieving own Trades"
                                , @(BitcoinDE_ShowAccountLedgerType): @"Retrieving Account ledger"
                                , @(BitcoinDE_RemoveOrderType): @"Removing Order"
                                , @(BitcoinDE_CreateOrderType) : @"Creating Order"
                                , @(BitcoinDE_ExecuteTrade): @"Executing Trade"
                                };
        /* Doitscha Text
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
                                , @(BitcoinDE_ShowMyTradesType): @"Abrufen und Filtern meiner getätigten Trades."
                                , @(BitcoinDE_ShowAccountLedgerType): @"Abruf des Kontoauszuges"
                                , @(BitcoinDE_RemoveOrderType): @"Löschen einer Order"
                                , @(BitcoinDE_ExecuteTrade): @"Kaufen/Verkaufen einer konkreten Order"
                                };
         */

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
                                   , @(3) // BitcoinDE_ShowMyTradesType
                                   , @(3) // BitcoinDE_ShowAccountLedger
                                   , @(1) // BitcoinDE_RemoveOrderType
                                   , @(1) // BitcoinDE_CreateOrderType
                                   , @(1) // BitcoinDE_ExecuteTrade
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
    return @"db8b38266d2f955fa96f19064f60a4c8";
}

- (NSString *)api_key {
    return [SOXMarket_BitcoinDE_Core apiKey];
}

+ (NSString *)apiSecret {
    return @"a4ebc1d021b88bba3c8b79ba4b93b1045dea0cc7";
}

- (NSString *)api_secret {
    return [SOXMarket_BitcoinDE_Core apiSecret];
}

#pragma mark - Code for later use
// for later use
+ (void)startBannerUpdatesWithScheduleTime:(NSTimeInterval)timeInterval
                                  delegate:(id <SOXBannerDataProtocol> _Nonnull)delegateForBannerUpdates {
    // timer
//    weakify(self)
//    NSTimer *reloadBannerDataTimer = [NSTimer timerWithTimeInterval:timeInterval
//                                                            repeats:YES
//                                                              block:^(NSTimer * _Nonnull timer) {
//                                                                  strongify(self)
//                                                                //  [self startBannerUpdate];
//                                                              }];
//        [SOXMarket_BitcoinDE_Core sharedCore].reloadBannerDataTimer = reloadBannerDataTimer;
//
//        // delegate
//        [SOXMarket_BitcoinDE_Core sharedCore].delegateForBannerUpdates = delegateForBannerUpdates;
//
}
@end
