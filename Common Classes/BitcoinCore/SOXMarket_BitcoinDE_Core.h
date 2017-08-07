//
//  SOXMarket_BitcoinDE_Core.h
//  BitcoinApp
//
//  Created by Peter Hauke on 13.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOXMarket_BitcoinDE_DefTypes.h"

@class SOXErrorMessage_BitcoinDE;

FOUNDATION_EXPORT NSString *const _Nonnull ServerAnswerServerCommandKey;
FOUNDATION_EXPORT NSString *const _Nonnull ServerAnswerPayloadKey;
FOUNDATION_EXPORT NSString *const _Nonnull ServerAnswerURLResponseKey;
FOUNDATION_EXPORT NSString *const _Nonnull ServerAnswerErrorKey;
FOUNDATION_EXPORT NSString *const _Nonnull ServerAnswerParametersKey;

FOUNDATION_EXPORT NSString *const _Nonnull CreditUpdate_CurrentCreditsKey;
FOUNDATION_EXPORT NSString *const _Nonnull CreditUpdate_MaximalCreditsKey;

FOUNDATION_EXPORT NSString *const _Nonnull HTTPMethodGETKey;
FOUNDATION_EXPORT NSString *const _Nonnull HTTPMethodDELETEKey;
FOUNDATION_EXPORT NSString *const _Nonnull HTTPMethodPOSTKey;

@protocol SOXMarketCoreServerRequestProtocol <NSObject>

- (void)answerOfServerRequest:(NSDictionary * _Nonnull)answerOfServerRequest;

@end

@protocol SOXBannerDataProtocol <NSObject>

- (void)didUpdateBannerData:(id _Nonnull)bannerData;

@end

@protocol SOXCreditUpdateProtocol <NSObject>

- (void)creditValuesUpdated:(NSDictionary * _Nonnull)creditDicts;

@end

@protocol SOXStatusBarUpdateProtocol <NSObject>

- (void)statusBarUpdated:(NSString * _Nonnull)statusBarText;

@end

@protocol SOXMarketCoreErrorProtocol <NSObject>

- (void)presentErrorMessage:(SOXErrorMessage_BitcoinDE * _Nonnull)errorMessage;

@end


@interface SOXMarket_BitcoinDE_Core : NSObject
@property (strong, nonatomic) NSDecimalNumber * _Nullable rate_weighted;
@property (strong, nonatomic) NSDecimalNumber * _Nullable rate_weighted_half;
@property (strong, nonatomic) NSDecimalNumber * _Nullable availableBitcoinAmount;
@property (strong, nonatomic) NSDecimalNumber * _Nullable availableFidorAmount;

@property (weak, nonatomic, readonly) NSObject <SOXMarketCoreErrorProtocol> * _Nullable delegateForErrorMessages;

- (void)startRequests;

/**
 *  Singleton.
 *
 *  @return The Core.
 */
+ (SOXMarket_BitcoinDE_Core * _Nonnull)sharedCore;

+ (void)requestDataForServerCommand:(BitcoinDE_ServerCommandType)serverCommandType
                      withParameter:(NSDictionary * _Nullable)parameterDictionary
                          respondTo:(NSObject <SOXMarketCoreServerRequestProtocol>* _Nullable)controller;

#pragma mark | Status handling
+ (void)registerForCreditUpdates:(id <SOXCreditUpdateProtocol> _Nullable) delegateForCreditUpdates;
+ (void)registerForStatusBarUpdates:(id <SOXCreditUpdateProtocol> _Nullable) delegateForStatusBarUpdates;

#pragma mark | Error handling
+ (void)registerForErrorMessages:(id <SOXMarketCoreErrorProtocol> _Nullable)delegateForErrorMessages;


@end
