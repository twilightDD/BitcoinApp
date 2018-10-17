//
//  SOXMarket_BitcoinDE_Core.m
//  BitcoinApp
//
//  Created by Peter Hauke on 13.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXMarket_BitcoinDE_Core.h"

#import "MacAppDelegate.h"

#import "SOXPreferencesCore.h"

#import "SOXLogWindowController.h"

#import "SOXKeys_BitcoinDE.h"
#import "SOXHash.h"
#import "SOXFormatters.h"

#import "SOXDataConverter_BitcoinDE.h"
#import "SOXErrorMessage_BitcoinDE.h"

#import "SOXAccountInfo_BitcoinDE_Data.h"
#import "SOXRates_BitcoinDE_Data.h"

#pragma mark - Keys
NSString *const _Nonnull ServerAnswerServerCommandKey = @"ServerCommand";
NSString *const _Nonnull ServerAnswerPayloadKey       = @"Payload";
NSString *const _Nonnull ServerAnswerURLResponseKey   = @"URLResponse";
NSString *const _Nonnull ServerAnswerErrorKey         = @"Error";
NSString *const _Nonnull ServerAnswerParametersKey    = @"Parameters";

NSString *const _Nonnull CreditUpdate_CurrentCreditsKey = @"CreditUpdate_CurrentCredits";
NSString *const _Nonnull CreditUpdate_MaximalCreditsKey = @"CreditUpdate_MaximalCredits";

NSString *const _Nonnull HTTPMethodGETKey    = @"GET";
NSString *const _Nonnull HTTPMethodDELETEKey = @"DELETE";
NSString *const _Nonnull HTTPMethodPOSTKey   = @"POST";

NSString *const _Nonnull NSURLSessionTaskKey      = @"NSURLSessionTask";
NSString *const _Nonnull NetworkRequestCounterKey = @"NetworkRequestCounter";

@interface SOXMarket_BitcoinDE_Core ()

@property (copy, nonatomic) NSString *baseURL;
@property (weak, nonatomic) NSTimer *reloadBannerDataTimer;

@property (copy, nonatomic) NSString *nonce;
@property (copy, nonatomic) NSString *httpMethod;
@property (copy, nonatomic) NSString *urlQueryString;
@property (copy, nonatomic) NSString *urlEncodedQueryString;
@property (copy, nonatomic) NSString *uri;
@property (copy, nonatomic) NSString *url;
@property (copy, nonatomic) NSString *postParameterMD5hashedURLQueryString;
@property (copy, nonatomic) NSString *hmacDataString;
@property (copy, nonatomic) NSString *hmacString;

@property (copy, nonatomic) NSString *apiKey;
@property (copy, nonatomic) NSString *apiSecret;
@property (nonatomic) NSUInteger apiPointer;
@property (nonatomic) NSUInteger apiPointerLimit;

//@property (weak, nonatomic) id delegateForRequests;
@property (weak, nonatomic) id <SOXBannerDataProtocol> delegateForBannerUpdates;
@property (weak, nonatomic, readwrite) NSObject <SOXMarketCoreErrorProtocol> *delegateForErrorMessages;
@property (weak, nonatomic) NSObject <SOXStatusBarUpdateProtocol>  *_Nullable delegateForStatusBarUpdates;

#pragma mark | Network Queue handling
@property (strong, nonatomic) NSMutableArray <NSDictionary *> *defaultNetworkQueue;
@property (strong, nonatomic) NSMutableArray <NSDictionary *> *prioritizedNetworkQueue;
@property (strong, nonatomic) NSMutableArray <NSDictionary *> *runningRequests;
@property (nonatomic) BOOL networkQueueIsRunning;
@property (nonatomic) NSUInteger networkRequestCounter;

#pragma mark | Credit handling
@property (weak, nonatomic) NSTimer *creditTimer;
@property (nonatomic) NSInteger currentCredits;
@property (nonatomic) NSInteger maxCredits;
@property (weak, nonatomic) id <SOXCreditUpdateProtocol> delegateForCreditUpdates;

@end

#pragma mark - Implementation
@implementation SOXMarket_BitcoinDE_Core
-(void)setRatesData:(SOXRatesData *)ratesData {
    _ratesData = ratesData;

}
#pragma mark Public Class methods
+ (SOXMarket_BitcoinDE_Core * _Nonnull)sharedCore {
    static SOXMarket_BitcoinDE_Core *sharedCore;
    
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        sharedCore = [[self class] new];
        sharedCore.networkQueueIsRunning = NO;
        sharedCore.defaultNetworkQueue = [NSMutableArray array];
        sharedCore.prioritizedNetworkQueue = [NSMutableArray array];
        sharedCore.runningRequests = [NSMutableArray array];
        sharedCore.networkRequestCounter = 0;
        sharedCore.maxCredits = 0;

        // Keychain
#if PETER
//        sharedCore.apiKeys = @[@"ac80762c443ee36c6d8edea28be22a52"];
//        sharedCore.apiSecrets = @[@"9b7076a0bea40908af7c71cfb62bfdedf6dfb42f"];
#else
        // last change: 25.06.2018
//        sharedCore.apiKeys = @[@"682a336bd3b7a57cac62a609698719cf"
//                               ,@"6c231fc2f51d581b05391fea32f8993c"
//                               ,@"12bae445a73ea666d179d34406af7805"
//                               ,@"6a5a9aa31af7363f59d9e91de1deccbe"
//                               ,@"1cd6d2bad928fd6ab4cef2ce8f19e791"
//                               ,@"b03655d9edbab687de87ee12405985a4"
//                               ,@"484e31d7b736853725e7ff0e98f6c705"
//                               ,@"06b1cee8e3e73aaf6ad45659a6cbf580"
//                               ,@"b7fb7136c3314a4d698c68e1df05fe0a"
//                               ,@"281f159c4dfd18e80b198c2709eb1942"];
//        sharedCore.apiSecrets = @[@"1e5ee72479b48283d5e795bdbb144119bcab2d78"
//                                  ,@"ac577e6f200a5c0043b537596fd0e302786a5218"
//                                  ,@"232200877339400ac3e9a94d0482848564f793af"
//                                  ,@"98c93aaf5e9d9e901c42c965ff6b040509843c13"
//                                  ,@"c8f540c117073965b111ad926586e39d4d96531e"
//                                  ,@"6270272446b1332d9c45db7f11db47612c939fdb"
//                                  ,@"73223048fb087f4fee004874ebda488c113aa2c5"
//                                  ,@"4c8c6b938933409cfdb009d1d87b967fb10bbfdf"
//                                  ,@"c0704f3e2f637c9849a263df6731f466db87a6bc"
//                                  ,@"c4ac430f5f57cfada0a0413a4ea3b8b7e2335dff"];
#endif
        sharedCore.apiPointer = 0;
        // Keychain
        sharedCore.apiPointerLimit = [SOXPreferencesCore countOfValidKeychainItems];
    });
    return sharedCore;
}

+ (NSDecimalNumber * _Nullable)allocationPercentForCurrency:(BitcoinDE_CurrencyType)currencyType {
    SOXAccountInfo_BitcoinDE_Data *accountInfoData = (SOXAccountInfo_BitcoinDE_Data*)[SOXMarket_BitcoinDE_Core sharedCore].accountInfoData;
    return [accountInfoData allocationPercentForCurrencyType:currencyType];
}

+ (NSDecimalNumber * _Nullable)allocationMaxEurVolumeForCurrency:(BitcoinDE_CurrencyType)currencyType {
    SOXAccountInfo_BitcoinDE_Data *accountInfoData = (SOXAccountInfo_BitcoinDE_Data*)[SOXMarket_BitcoinDE_Core sharedCore].accountInfoData;
    return [accountInfoData allocationMaxEurVolumeForCurrencyType:currencyType];
}

+ (NSDecimalNumber * _Nullable)allocationEurVolumeOpenOrdersForCurrency:(BitcoinDE_CurrencyType)currencyType {
    SOXAccountInfo_BitcoinDE_Data *accountInfoData = (SOXAccountInfo_BitcoinDE_Data*)[SOXMarket_BitcoinDE_Core sharedCore].accountInfoData;
    return [accountInfoData allocationEurVolumeOpenOrdersForCurrencyType:currencyType];
}

+ (NSDecimalNumber * _Nullable)totalAmountForCurrencyType:(BitcoinDE_CurrencyType)currencyType {
    SOXAccountInfo_BitcoinDE_Data *accountInfoData = (SOXAccountInfo_BitcoinDE_Data*)[SOXMarket_BitcoinDE_Core sharedCore].accountInfoData;
    return [accountInfoData totalAmountForCurrencyType:currencyType];
}

+ (NSDecimalNumber * _Nullable)availableAmountForCurrencyType:(BitcoinDE_CurrencyType)currencyType {
    SOXAccountInfo_BitcoinDE_Data *accountInfoData = (SOXAccountInfo_BitcoinDE_Data*)[SOXMarket_BitcoinDE_Core sharedCore].accountInfoData;
    return [accountInfoData availableAmountForCurrencyType:currencyType];
}

+ (NSDecimalNumber * _Nullable)reservedAmountForCurrencyType:(BitcoinDE_CurrencyType)currencyType {
    SOXAccountInfo_BitcoinDE_Data *accountInfoData = (SOXAccountInfo_BitcoinDE_Data*)[SOXMarket_BitcoinDE_Core sharedCore].accountInfoData;
    return [accountInfoData reservedAmountForCurrencyType:currencyType];
}

+ (NSDecimalNumber * _Nullable)rateWeightedForCurrencyType:(BitcoinDE_CurrencyType)currencyType {
    SOXRates_BitcoinDE_Data *ratesData = (SOXRates_BitcoinDE_Data *)[SOXMarket_BitcoinDE_Core sharedCore].ratesData;
    return [ratesData rateWeightedForCurrencyType:currencyType];
}

+ (NSDecimalNumber * _Nullable)rateWeighted3hForCurrencyType:(BitcoinDE_CurrencyType)currencyType {
    SOXRates_BitcoinDE_Data *ratesData = (SOXRates_BitcoinDE_Data *)[SOXMarket_BitcoinDE_Core sharedCore].ratesData;
    return [ratesData rateWeighted3hForCurrencyType:currencyType];
}

+ (NSDecimalNumber * _Nullable)rateWeighted12hForCurrencyType:(BitcoinDE_CurrencyType)currencyType {
    SOXRates_BitcoinDE_Data *ratesData = (SOXRates_BitcoinDE_Data *)[SOXMarket_BitcoinDE_Core sharedCore].ratesData;
    return [ratesData rateWeighted12hForCurrencyType:currencyType];
}

+ (NSDecimalNumber * _Nullable)rateWeightedHalfForCurrencyType:(BitcoinDE_CurrencyType)currencyType {
    SOXRates_BitcoinDE_Data *ratesData = (SOXRates_BitcoinDE_Data *)[SOXMarket_BitcoinDE_Core sharedCore].ratesData;
    return [ratesData rateWeightedHalfForCurrencyType:currencyType];
}

+ (void)requestDataForServerCommand:(BitcoinDE_ServerCommandType)serverCommandType
                      withParameter:(NSDictionary * _Nullable)parameterDictionary
                          respondTo:(NSObject <SOXMarketCoreServerRequestProtocol>* _Nullable)controller {

    // Check for valid apiKey/Secret-pairs in keychain
    if ([SOXPreferencesCore validKeychain] == NO) {
        SOXErrorMessage_BitcoinDE *errorMessage = [[SOXErrorMessage_BitcoinDE alloc] initWithServerRequestTitle:@"No keys and secrets!"];
        errorMessage.errorMessage = @"Use Preference pane.";

        [controller presentErrorWithErrorDictionary:errorMessage];

        return;
    }


    NSURLRequest * request = [self requestForServerCommandType:serverCommandType
                                                    parameters:parameterDictionary];

    if (!request) {
        return;
    }

    if (!parameterDictionary) {
        parameterDictionary = [NSDictionary dictionary];
    }
    [SOXMarket_BitcoinDE_Core sharedCore].networkRequestCounter++;
    NSUInteger networkRequestCounter = [SOXMarket_BitcoinDE_Core sharedCore].networkRequestCounter;

    weakify(self)
    NSURLSessionTask *getTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                                    strongify(self)

                                                                    [SOXMarket_BitcoinDE_Core incomingResponseForNetworkRequestCounter:networkRequestCounter];

                                                                    // Erro handling
                                                                    NSString *serverRequestTitle = [NSString stringWithFormat:@"%tu (%@)",
                                                                                                    serverCommandType
                                                                                                    ,[SOXMarket_BitcoinDE_Core descriptionForServerCommandType:serverCommandType]];
                                                                    if (parameterDictionary.allKeys.count > 0) {
                                                                        NSString *furtherTitle = [NSString stringWithFormat:@" - pair: %@"
                                                                                                  , [parameterDictionary objectForKey:BitcoinDE_ShowOrderbook_TradingPair]];
                                                                        serverRequestTitle = [serverRequestTitle stringByAppendingString:furtherTitle];
                                                                    }
                                                                    
                                                                    SOXErrorMessage_BitcoinDE *errorMessage = [[SOXErrorMessage_BitcoinDE alloc] initWithServerRequestTitle:serverRequestTitle];
                                                                    
                                                                    __block NSDictionary *serverAnswer;
                                                                    dispatch_sync(dispatch_get_main_queue(), ^{
                                                                        serverAnswer = [self answerDictionaryForServerCommand:serverCommandType
                                                                                                                   parameters:parameterDictionary
                                                                                                                     withData:data
                                                                                                                  urlResponse:response
                                                                                                                        error:error
                                                                                                                 errorMessage:errorMessage];
                                                                    });
                                                                    if (serverAnswer) {
                                                                        if (serverCommandType == BitcoinDE_ShowAccountInfoCommandType) {
                                                                            SOXAccountInfo_BitcoinDE_Data *accountInfoData = [serverAnswer objectForKey:ServerAnswerPayloadKey];
                                                                            if (accountInfoData) {
                                                                                [SOXMarket_BitcoinDE_Core sharedCore].accountInfoData = accountInfoData;
                                                                                [[NSNotificationCenter defaultCenter] postNotificationName:BitcoinDE_Notification_RequestShowAccountInfo
                                                                                                                                    object:serverAnswer];
                                                                            }

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
                                                                        }
                                                                    }

                                                                    if (errorMessage.hasError) {
                                                                        MacAppDelegate* appDelegate = (MacAppDelegate*)[[NSApplication sharedApplication] delegate];
                                                                        SOXLogWindowController *errorWindowController = appDelegate.errorWindowController;
                                                                        [errorWindowController performSelectorOnMainThread:@selector(showErrorMessage:)
                                                                                                                withObject:errorMessage
                                                                                                             waitUntilDone:NO];
                                                                    }
                                                                }];
    getTask.priority = 1.0;

    [SOXMarket_BitcoinDE_Core addNSURLSessionTask:getTask
                                 forServerCommand:serverCommandType
                            networkRequestCounter:[SOXMarket_BitcoinDE_Core sharedCore].networkRequestCounter];

    DDLogInfo(@"getTask.currentRequest.URL: %@", getTask.currentRequest.URL);
    DDLogInfo(@"getTask.originalRequest.URL: %@", getTask.originalRequest.URL);
}

#pragma mark | Status bar handling
+ (void)registerForCreditUpdates:(id <SOXCreditUpdateProtocol> _Nullable)delegateForCreditUpdates {
    [SOXMarket_BitcoinDE_Core sharedCore].delegateForCreditUpdates = delegateForCreditUpdates;
}

+ (void)registerForStatusBarUpdates:(id <SOXStatusBarUpdateProtocol> _Nullable) delegateForStatusBarUpdates {
    [SOXMarket_BitcoinDE_Core sharedCore].delegateForStatusBarUpdates = delegateForStatusBarUpdates;
}

#pragma mark | Error handling
+ (void)registerForErrorMessages:(id <SOXMarketCoreErrorProtocol> _Nullable)delegateForErrorMessages {
    [SOXMarket_BitcoinDE_Core sharedCore].delegateForErrorMessages = delegateForErrorMessages;
}



+ (NSDictionary *)answerDictionaryForServerCommand:(BitcoinDE_ServerCommandType)serverCommandType
                                        parameters:(NSDictionary *)parameters
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
            if (!payloadDictionary) {
                NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                
                DDLogError(@"answerDictionaryForServerCommand - payloadDictionary for %tu is nil => dataAsString:\n%@"
                           , serverCommandType
                           , dataString);
                payloadDictionary = [NSDictionary dictionary];
            }
        }
        else {
            [errorMessage appendErrorDescripton:@"Data for JSON is nil"];
            DDLogError(@"answerDictionaryForServerCommand - data for %tu is nil"
                       , serverCommandType);
            // TODO: return somethind with an ErrorMessage
            return nil;
        }
        // check for error in json deserialization
        [errorMessage checkJsonError:jsonError];

        // check for error in server answer
        [errorMessage checkforAPIErrors:[payloadDictionary objectForKey:@"errors"]];
        
        [self updateCurrentCredit:[payloadDictionary valueForKey:@"credits"]
             forServerCommandType:serverCommandType];
    }
    
    // process server answer
    NSMutableDictionary *serverAnswer = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         @(serverCommandType), ServerAnswerServerCommandKey
                                         , response, ServerAnswerURLResponseKey
                                         , parameters, ServerAnswerParametersKey
                                         , nil];
    {
        if (error) {
            [serverAnswer setObject:error
                             forKey:ServerAnswerErrorKey];
        }
        else if (!error && errorMessage.hasError) {
            // on error on executeTrade there is no error! (Warum auch immer)
            id errorsObject = [payloadDictionary objectForKey:@"errors"];
            if (errorsObject) {
                [serverAnswer setObject:errorsObject
                                 forKey:ServerAnswerErrorKey];
            }
        }
        else {
            id payload = [SOXDataConverter_BitcoinDE payloadForServerDictionary:payloadDictionary
                                                               forServerCommand:serverCommandType];
            if (payload) {
                [serverAnswer setObject:payload
                                 forKey:ServerAnswerPayloadKey];
            }
            else {
                NSString *payloadErrorMsg = [NSString stringWithFormat:@"PAYLOAD is nil for serverCommandType %tu (%@)"
                                             , serverCommandType, [NSDate date]];
                NSString *logErrorMsg = [NSString stringWithFormat:@"PAYLOAD is nil for serverCommandType %tu(%@)\n"
                                         "payloadDictionary %@\n"
                                         "response %@\n"
                                         "error %@"
                                         , serverCommandType
                                         , [NSDate date]
                                         , payloadDictionary
                                         , response
                                         , error];
                DDLogInfo(@"%@", logErrorMsg);
                [errorMessage appendErrorDescripton:payloadErrorMsg];
                serverAnswer = nil;
            }
        }
    }
    return [serverAnswer copy];
}

#pragma mark - Server commands
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

#pragma mark - Create NSURLRequest Methods
+ (NSURLRequest *)requestForServerCommandType:(BitcoinDE_ServerCommandType)serverCommandType
                                   parameters:(NSDictionary * _Nullable)parameterDictionary {
    [SOXMarket_BitcoinDE_Core prepareRequestDataForServerCommand:serverCommandType
                                                   withParameter:parameterDictionary];
    NSURLRequest *request = [SOXMarket_BitcoinDE_Core createRequest];
    return request;
}

#pragma mark | Helper
+ (void)prepareRequestDataForServerCommand:(BitcoinDE_ServerCommandType)serverCommandType
                             withParameter:(NSDictionary * _Nullable)parameterDictionary {

    [[SOXMarket_BitcoinDE_Core sharedCore] increaseApiPointer]; // use mulptiple key:secret pairs
    // reset values
    {
        [SOXMarket_BitcoinDE_Core sharedCore].uri = nil;
        [SOXMarket_BitcoinDE_Core sharedCore].nonce = nil;
        [SOXMarket_BitcoinDE_Core sharedCore].urlQueryString = nil;
        [SOXMarket_BitcoinDE_Core sharedCore].urlEncodedQueryString = nil;
        [SOXMarket_BitcoinDE_Core sharedCore].postParameterMD5hashedURLQueryString = nil;
        [SOXMarket_BitcoinDE_Core sharedCore].httpMethod = nil;
        [SOXMarket_BitcoinDE_Core sharedCore].hmacDataString = nil;
        [SOXMarket_BitcoinDE_Core sharedCore].hmacString = nil;
    }

    [SOXMarket_BitcoinDE_Core createHttpMethodForServerCommandType:serverCommandType];
    [SOXMarket_BitcoinDE_Core createURIForServerCommandType:serverCommandType];
    [SOXMarket_BitcoinDE_Core createNonceString];
    if (serverCommandType != BitcoinDE_ExecuteTrade) {
        [SOXMarket_BitcoinDE_Core createURLQueryStringFromParameterDictionary:parameterDictionary];
        [SOXMarket_BitcoinDE_Core createURL];
    }
    else {
        NSString *orderID = [parameterDictionary objectForKey:BitcoinDE_ExecuteTrade_OrderID];

        // create_urlQueryStringFromParameterDictionary
        {
            NSMutableDictionary *mutableParameterDictionary = [parameterDictionary mutableCopy];
            [mutableParameterDictionary removeObjectForKey:BitcoinDE_ExecuteTrade_OrderID];
            [SOXMarket_BitcoinDE_Core createURLQueryStringFromParameterDictionary:[mutableParameterDictionary copy]];
        }

        // createURL
        {
            SOXMarket_BitcoinDE_Core *core = [SOXMarket_BitcoinDE_Core sharedCore];
            NSString *url = [NSString stringWithFormat:@"%@%@%@", [SOXMarket_BitcoinDE_Core baseURLString],core.uri, orderID];
            core.url = url;
        }

    }

    [SOXMarket_BitcoinDE_Core createMD5ofURLQueryString];
    [SOXMarket_BitcoinDE_Core createHMACDataString];
    [SOXMarket_BitcoinDE_Core createHMACString];
}

+ (void)createURIForServerCommandType:(BitcoinDE_ServerCommandType)serverCommandType {
    NSString *uri = [SOXMarket_BitcoinDE_Core commandForServerCommandType:serverCommandType];
    //    DDLogInfo(@"uri\n%@",uri);
    [SOXMarket_BitcoinDE_Core sharedCore].uri = uri;
}

+ (void)createNonceString {
    NSDate   *date     = [NSDate date];
    NSTimeInterval timeInterval =[date timeIntervalSince1970];
    NSString *timeInMS = [NSString stringWithFormat:@"%.0f", floor([date timeIntervalSince1970] * 1000000)];

    NSLog(@"nonce \n%@ - %f",timeInMS, timeInterval);
    [SOXMarket_BitcoinDE_Core sharedCore].nonce = timeInMS;
}

+ (void)createURLQueryStringFromParameterDictionary:(NSDictionary *)parameterDictionary {
    // BSP: url_query_string = 'max_amount=5.3&price=255.5&type=buy'
    __block NSString *urlQueryString = nil;
    if (parameterDictionary.allKeys.count > 0) {
        // get and sort parameterKeys
        NSArray *allKeys = parameterDictionary.allKeys;
        allKeys = [allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        
        NSString *httpMethod = [SOXMarket_BitcoinDE_Core sharedCore].httpMethod;
        if ([httpMethod isEqualToString:HTTPMethodDELETEKey]) {
            NSMutableArray *parameters = [NSMutableArray array];
            for (NSString *key in allKeys) {
                NSString *parameter = [parameterDictionary objectForKey:key];
                [parameters addObject:parameter];
            }
            // join pairs with "/"
            urlQueryString = [parameters componentsJoinedByString:@"/"];
        }
        else {//if ([httpMethod isEqualToString:HTTPMethodPOSTKey]) {
            // create "parameter=value" pairs
            NSMutableArray *parameters = [NSMutableArray array];
            for (NSString *key in allKeys) {
                NSString *parameter = [NSString stringWithFormat:@"%@=%@"
                                       , key
                                       , [parameterDictionary objectForKey:key]];
                [parameters addObject:parameter];
            }
            // join pairs with "&"
            urlQueryString = [parameters componentsJoinedByString:@"&"];
        }
    }

    [SOXMarket_BitcoinDE_Core sharedCore].urlQueryString = urlQueryString;

    // Encode urlQueryString in POST and AccountLedger
    if ([[SOXMarket_BitcoinDE_Core sharedCore].httpMethod isEqualToString:HTTPMethodPOSTKey]
        || [[SOXMarket_BitcoinDE_Core sharedCore].uri isEqualToString:@"/account/ledger"]){
        NSMutableCharacterSet *chars = NSCharacterSet.URLQueryAllowedCharacterSet.mutableCopy;
        [chars removeCharactersInRange:NSMakeRange(':', 1)]; // %3A
        [chars removeCharactersInRange:NSMakeRange('+', 1)]; // %2B
        NSString *urlEncodedQueryString = [urlQueryString stringByAddingPercentEncodingWithAllowedCharacters:chars];

        [SOXMarket_BitcoinDE_Core sharedCore].urlQueryString = urlEncodedQueryString; // needed for POST (createOrder)
        [SOXMarket_BitcoinDE_Core sharedCore].urlEncodedQueryString = urlEncodedQueryString;
    }
}

+ (void)createURL {
    SOXMarket_BitcoinDE_Core *core = [SOXMarket_BitcoinDE_Core sharedCore];
    
    
    NSString *baseURL = [SOXMarket_BitcoinDE_Core baseURLString];
    NSString *uri     = core.uri;
    NSString *urlQueryString = core.urlQueryString;
    NSString *urlEncodedQueryString = core.urlEncodedQueryString;
    NSString *httpMethod = core.httpMethod;
    
    NSString *url = nil;
    url = [NSString stringWithFormat:@"%@%@", baseURL, uri];
    
    if (urlQueryString
        && [httpMethod isEqualToString:HTTPMethodDELETEKey]) {
        url = [url stringByAppendingString:urlQueryString];
    }
    else if (urlEncodedQueryString
             && [httpMethod isEqualToString:HTTPMethodGETKey]) {
        // Account ledger needs urlEncodedQueryString
        url = [url stringByAppendingString:@"?"];
        url = [url stringByAppendingString:urlEncodedQueryString];
    }
    else if (urlQueryString
             && [httpMethod isEqualToString:HTTPMethodGETKey]) {
        // MyActiveTrades and MyTradeHistory need urlQueryString
        url = [url stringByAppendingString:@"?"];
        url = [url stringByAppendingString:urlQueryString];
    }

    core.url = url;
}

+ (void)createMD5ofURLQueryString {
    SOXMarket_BitcoinDE_Core *core = [SOXMarket_BitcoinDE_Core sharedCore];
    
    NSString *md5String = @"d41d8cd98f00b204e9800998ecf8427e"; // md5 for @""
    if ([core.httpMethod isEqualToString:HTTPMethodPOSTKey]) {
        NSString *urlQueryString = core.urlQueryString;
        if (urlQueryString) {
            md5String = [SOXHash md5StringForString:urlQueryString];
        }
    }

    //    DDLogInfo(@"md5 %@", md5String);
    [SOXMarket_BitcoinDE_Core sharedCore].postParameterMD5hashedURLQueryString = md5String;
}

+ (void)createHttpMethodForServerCommandType:(BitcoinDE_ServerCommandType)serverCommandType {
    NSString *httpMethod = [self httpMethodForServerCommandType:serverCommandType];
    
    [SOXMarket_BitcoinDE_Core sharedCore].httpMethod = httpMethod;
}

+ (void)createHMACDataString {
    // hmacDataString = http_method+'#'+uri+'#'+apiKey+'#'+nonce+'#'+post_parameter_md5_hashed_url_encoded_query_string
    SOXMarket_BitcoinDE_Core *core = [SOXMarket_BitcoinDE_Core sharedCore];
    
    NSString *httpMethod = core.httpMethod;
    NSString *url = core.url;
    NSString *apiKey = core.apiKey;
    NSString *nonce = core.nonce;
    NSString *postParameterMD5hashedURLQueryString = core.postParameterMD5hashedURLQueryString;
    
    NSString *hmacDataString = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@"
                           , httpMethod
                           , @"#"
                           , url
                           , @"#"
                           , apiKey
                           , @"#"
                           , nonce
                           , @"#"
                           , postParameterMD5hashedURLQueryString
                           ];

    [SOXMarket_BitcoinDE_Core sharedCore].hmacDataString = hmacDataString;
}

+ (void)createHMACString {
    SOXMarket_BitcoinDE_Core *core = [SOXMarket_BitcoinDE_Core sharedCore];
    NSString *hmacDataString  = core.hmacDataString;
    NSString *apiSecret = core.apiSecret;
    
    NSString *hmacString = nil;
    if (hmacDataString) {
        hmacString = [SOXHash hexadecimalHMACForString:hmacDataString
                                               withKey:apiSecret];
    }

    core.hmacString = hmacString;
}


+ (NSURLRequest *)createRequest {
    SOXMarket_BitcoinDE_Core *core = [SOXMarket_BitcoinDE_Core sharedCore];
    
    NSString *httpMethod            = core.httpMethod;
    NSString *urlString             = core.url;
    NSString *apiKey                = core.apiKey;
    NSString *nonce                 = core.nonce;
    NSString *hmacString            = core.hmacString;
    NSString *postParametersString  = core.urlQueryString;
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    {
        [request setHTTPMethod:httpMethod];
        [request addValue:apiKey            forHTTPHeaderField:@"X-API-KEY"];
        [request addValue:nonce             forHTTPHeaderField:@"X-API-NONCE"];
        [request addValue:hmacString        forHTTPHeaderField:@"X-API-SIGNATURE"];
        if (postParametersString
            && [httpMethod isEqualToString:HTTPMethodPOSTKey]) {
            [request setHTTPBody:[postParametersString dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    return [request copy];
}

#pragma mark - Network Queue handling
//+ (NSMutableArray *)networkQueue {
//    NSMutableArray *networkQueue = [[SOXMarket_BitcoinDE_Core sharedCore] defaultNetworkQueue];
//    if (!networkQueue) {
//        networkQueue = [NSMutableArray array];
//    }
//
//    return networkQueue;
//}

+ (void)addNSURLSessionTask:(NSURLSessionTask* )urlSessionTask
           forServerCommand:(BitcoinDE_ServerCommandType)serverCommand
      networkRequestCounter:(NSUInteger)networkRequestCounter {
    DDLogInfo(@"### ADD A NEW NSURLSessionTask for serverCommandType %@, networkRequestCounter %ti"
              , [self descriptionForServerCommandType:serverCommand]
              , networkRequestCounter);

    SOXMarket_BitcoinDE_Core *sharedCore = [SOXMarket_BitcoinDE_Core sharedCore];

    NSMutableArray *networkQueue;
    if (serverCommand == BitcoinDE_ExecuteTrade) {
        networkQueue = sharedCore.prioritizedNetworkQueue;
    }
    else {
        networkQueue = sharedCore.defaultNetworkQueue;
    }

    NSDictionary *queueDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                     urlSessionTask, NSURLSessionTaskKey
                                     , @(serverCommand), ServerAnswerServerCommandKey
                                     , @(networkRequestCounter), NetworkRequestCounterKey
                                     , nil];

    [networkQueue addObject:queueDictionary];

    [SOXMarket_BitcoinDE_Core startNextNSURLSessionTask];
}

+ (void)startNextNSURLSessionTask {
    if ([SOXPreferencesCore validKeychain] == NO) {
        // we don't have any valid api/secret pair in keychain => don't send anything
        // User beschimpfen

        return;
    }
//    return; // KILL SWITCH

    SOXMarket_BitcoinDE_Core *sharedCore = [SOXMarket_BitcoinDE_Core sharedCore];

    // Get next task
    NSMutableArray *networkQueue;
    if (sharedCore.prioritizedNetworkQueue.count > 0) {
        networkQueue = sharedCore.prioritizedNetworkQueue;
    }
    else {
        networkQueue = sharedCore.defaultNetworkQueue;
    }
    NSDictionary *nextTaskDictionary = networkQueue.firstObject;

    if (nextTaskDictionary) {
        NSURLSessionTask *nextTask = [nextTaskDictionary objectForKey:NSURLSessionTaskKey];
        if ([SOXMarket_BitcoinDE_Core sharedCore].currentCredits
            && [SOXMarket_BitcoinDE_Core sharedCore].currentCredits < 6) { // TODO: vergleich mit serverCommandType
            NSUInteger countOfNetworkQueues = sharedCore.prioritizedNetworkQueue.count + sharedCore.defaultNetworkQueue.count;
            DDLogInfo(@"Delay ### START NEXT NSURLSessionTask (%ti requests in queue)", countOfNetworkQueues);
            NSString *statusBarString = [NSString stringWithFormat:@"Too less credits. Waiting for more ... (%ti requests in queue)"
                                         , countOfNetworkQueues];
            [[SOXMarket_BitcoinDE_Core sharedCore].delegateForStatusBarUpdates statusBarUpdated:statusBarString];
        }
        else {
            //            DDLogInfo(@"### WILL START NEXT NSURLSessionTask (credits before resume: %ti)"
            //                  , [SOXMarket_BitcoinDE_Core sharedCore].currentCredits);

            [SOXMarket_BitcoinDE_Core sharedCore].networkQueueIsRunning = YES;

            BitcoinDE_ServerCommandType serverCommandType = [[nextTaskDictionary objectForKey:ServerAnswerServerCommandKey] unsignedIntegerValue];
            [SOXMarket_BitcoinDE_Core sharedCore].currentCredits = [SOXMarket_BitcoinDE_Core sharedCore].currentCredits - [self creditCostsForServerCommandType:serverCommandType];

            [nextTask resume];
            DDLogInfo(@"### DID START NEXT NSURLSessionTask (credits after resume: %ti) with complete URL \n%@"
                      , [SOXMarket_BitcoinDE_Core sharedCore].currentCredits
                      , nextTask.currentRequest.URL);

            [networkQueue removeObject:nextTaskDictionary];
            [sharedCore.runningRequests addObject:nextTaskDictionary];

            [SOXMarket_BitcoinDE_Core updateStatusBarInformation];

            [SOXMarket_BitcoinDE_Core startNextNSURLSessionTask];
        }
    }
}

+ (void)incomingResponseForNetworkRequestCounter:(NSUInteger)networkRequestCounter {
    SOXMarket_BitcoinDE_Core *sharedCore = [SOXMarket_BitcoinDE_Core sharedCore];

    __block NSDictionary *taskDictionaryToRemove;
    // parse prioritizedNetworkQueue
    [sharedCore.runningRequests enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull taskDictionary
                                                             , NSUInteger idx
                                                             , BOOL * _Nonnull stop) {
        NSNumber *counter = [taskDictionary objectForKey:NetworkRequestCounterKey];
        if (counter.unsignedIntegerValue == networkRequestCounter) {
            taskDictionaryToRemove = taskDictionary;
            *stop = YES;
        }
    }];

    if (taskDictionaryToRemove) {
        [sharedCore.runningRequests removeObject:taskDictionaryToRemove];
    }

    // check status of networkQueueIsRunning
    if (sharedCore.prioritizedNetworkQueue.count == 0
        && sharedCore.defaultNetworkQueue.count == 0) {
        sharedCore.networkQueueIsRunning = NO;
    }

    [SOXMarket_BitcoinDE_Core updateStatusBarInformation];
}

+ (void)updateStatusBarInformation {
    SOXMarket_BitcoinDE_Core *sharedCore = [SOXMarket_BitcoinDE_Core sharedCore];
    if (!sharedCore.delegateForStatusBarUpdates) {
        return;
    }

    if (sharedCore.networkQueueIsRunning == NO) {
        //dispatch_async(dispatch_get_main_queue(), ^{
        [[SOXMarket_BitcoinDE_Core sharedCore].delegateForStatusBarUpdates statusBarUpdated:@"Idle"];
        //});
    }

    if (sharedCore.networkQueueIsRunning) {
        NSMutableArray *runningRequestDescriptions = [NSMutableArray array];
        for (NSDictionary *taskDictionary in sharedCore.runningRequests) {
            BitcoinDE_ServerCommandType serverCommand = [[taskDictionary objectForKey:ServerAnswerServerCommandKey] unsignedIntegerValue];
            [runningRequestDescriptions addObject:[SOXMarket_BitcoinDE_Core commandDescriptionForServerCommand:serverCommand]];
        }
        NSString *runningRequestDescription = [runningRequestDescriptions componentsJoinedByString:@" - "];
        NSString *statusBarString = [NSString stringWithFormat:@"%tu: %@"
                                     , sharedCore.runningRequests.count
                                     , runningRequestDescription];
        if (sharedCore.runningRequests.count > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [sharedCore.delegateForStatusBarUpdates statusBarUpdated:statusBarString];
            });
        }
    }
}

#pragma mark - Credit handling
+ (void)updateCurrentCredit:(NSNumber *)newCreditValue forServerCommandType:(BitcoinDE_ServerCommandType)serverCommandType {
    NSInteger creditCosts = [SOXMarket_BitcoinDE_Core creditCostsForServerCommandType:serverCommandType];

    // set currentCredits to new value
    [SOXMarket_BitcoinDE_Core sharedCore].currentCredits = newCreditValue.integerValue;

    // Set maxCredits
    if ([SOXMarket_BitcoinDE_Core sharedCore].maxCredits == 0
        || [SOXMarket_BitcoinDE_Core sharedCore].maxCredits < newCreditValue.integerValue) {
        // get maxCredits from first server responds
        [SOXMarket_BitcoinDE_Core sharedCore].maxCredits = newCreditValue.integerValue + creditCosts;
    }
}

+ (void)creditUpdateTimerMethod:(id)userInfo {
    // increase credit counter
    if ([SOXMarket_BitcoinDE_Core sharedCore].currentCredits < [SOXMarket_BitcoinDE_Core sharedCore].maxCredits) {
        [SOXMarket_BitcoinDE_Core sharedCore].currentCredits++;
    }

    // stop timer if maxCredits is reached
    if ([SOXMarket_BitcoinDE_Core sharedCore].currentCredits == [SOXMarket_BitcoinDE_Core sharedCore].maxCredits) {
        NSTimer *creditTimer = [[SOXMarket_BitcoinDE_Core sharedCore] creditTimer];
        [creditTimer invalidate];
        creditTimer = nil;
    }

    // check for serverRequests to do
    [SOXMarket_BitcoinDE_Core startNextNSURLSessionTask];
}

- (void)setCurrentCredits:(NSInteger)currentCredits {
    _currentCredits = currentCredits;
    
    // setup credit timer if needed
    NSTimer *creditTimer = [self creditTimer];
    if (!creditTimer) {
        //dispatch_async(dispatch_get_main_queue(), ^{
        [SOXMarket_BitcoinDE_Core sharedCore].creditTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                                             target:[SOXMarket_BitcoinDE_Core class]
                                                                                           selector:@selector(creditUpdateTimerMethod:)
                                                                                           userInfo:nil
                                                                                            repeats:YES];
        creditTimer.tolerance = 0.05;
        [[NSRunLoop mainRunLoop] addTimer:[SOXMarket_BitcoinDE_Core sharedCore].creditTimer
                                  forMode:NSDefaultRunLoopMode];

        DDLogInfo(@"Credit timer started");
        //});
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
        baseURLString = @"https://api.bitcoin.de/v2";
    });
    
    return baseURLString;
}

#pragma mark | Key and Secret handling
- (NSString *)apiKey {
    // Keychain
//    NSString *apiKey = [self.apiKeys objectAtIndex:self.apiPointer];
    NSString *apiKey = [SOXPreferencesCore apiKeyAtIndex:self.apiPointer];
    return apiKey;
}

- (NSString *)apiSecret {
    // Keychain
//    NSString *apiSecret = [self.apiSecrets objectAtIndex:self.apiPointer];
    NSString *apiSecret = [SOXPreferencesCore apiSecretAtIndex:self.apiPointer];
    return apiSecret;
}

- (void)increaseApiPointer {
    self.apiPointer++;
    if (self.apiPointer >= self.apiPointerLimit) {
        self.apiPointer = 0;
    }
}

#pragma mark - Banner Update Methods
- (void)startAccountInfoUpdate {
    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowAccountInfoCommandType
                                            withParameter:nil
                                                respondTo:nil];
}

- (NSInteger)startAllRatesUpdate {
    // rates for each currencyType
    for (BitcoinDE_CurrencyType idx = BitcoinDE_CurrencyTypeUnknown + 1
         ; idx < BitcoinDE_CurrencyType_EndOfType
         ; idx++) {
        double delayInSeconds = 0.2 * (double)idx;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            DDLogInfo(@"BannerUpdate: get rates for currency %@ (delay: %f)"
                      , [SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:idx]
                      , delayInSeconds);
            [self startRatesUpdateForCurrencyType:idx];
        });
    }

    return BitcoinDE_CurrencyType_EndOfType - 1;
}

- (void)startRatesUpdateForCurrencyType:(BitcoinDE_CurrencyType)currencyType {
    NSDictionary *ratesParameters = [SOXRates_BitcoinDE_Data parametersForCurrencyType:currencyType];
    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowRatesCommandType
                                            withParameter:ratesParameters
                                                respondTo:nil];
}

@end
