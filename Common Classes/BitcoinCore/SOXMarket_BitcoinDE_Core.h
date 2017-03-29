//
//  SOXMarket_BitcoinDE_Core.h
//  BitcoinApp
//
//  Created by Peter Hauke on 13.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SOXErrorMessage_BitcoinDE;

typedef NS_ENUM (NSUInteger, BitcoinDE_ServerCommandType) {
    UnknownCommand = 0
    , BitcoinDE_ShowBuyOrderbookCommandType  //"buy" liefert Verkaufsangebote
    , BitcoinDE_ShowSellOrderbookCommandType //"sell" liefert Kaufangebote
    , BitcoinDE_ShowMyOrdersCommandType
    , BitcoinDE_ShowMyOrderDetailsCommandType
    , BitcoinDE_ShowAccountInfoCommandType
    , BitcoinDE_ShowOrderbookCompactCommandType
    , BitcoinDE_ShowPublicTradeHistoryCommandType
    , BitcoinDE_ShowRatesCommandType
    , BitcoinDE_ShowMyTradesType
    , BitcoinDE_ShowAccountLedger
};

FOUNDATION_EXPORT NSString *const _Nonnull ServerAnswerServerCommandKey;
FOUNDATION_EXPORT NSString *const _Nonnull ServerAnswerPayloadKey;
FOUNDATION_EXPORT NSString *const _Nonnull ServerAnswerURLResponseKey;
FOUNDATION_EXPORT NSString *const _Nonnull ServerAnswerErrorKey;

FOUNDATION_EXPORT NSString *const _Nonnull CreditUpdate_CurrentCreditsKey;
FOUNDATION_EXPORT NSString *const _Nonnull CreditUpdate_MaximalCreditsKey;

@protocol SOXMarketCoreServerRequestProtocol <NSObject>

- (void)answerOfServerRequest:(NSDictionary * _Nonnull)answerOfServerRequest;

@end

@protocol SOXBannerDataProtocol <NSObject>

- (void)didUpdateBannerData:(id _Nonnull)bannerData;

@end

@protocol SOXCreditUpdateProtocol <NSObject>

- (void)creditValuesUpdated:(NSDictionary * _Nonnull)creditDicts;

@end

@protocol SOXMarketCoreErrorProtocol <NSObject>

- (void)presentErrorMessage:(SOXErrorMessage_BitcoinDE * _Nonnull)errorMessage;

@end
@interface SOXMarket_BitcoinDE_Core : NSObject

/**
 *  Singleton.
 *
 *  @return The Core.
 */
+ (instancetype _Nonnull)sharedCore;

+ (void)requestDataForServerCommand:(BitcoinDE_ServerCommandType)serverCommandType respondTo:(NSObject <SOXMarketCoreServerRequestProtocol>* _Nonnull)controller;

#pragma mark | Credit handling
+ (void)registerForCreditUpdates:(id <SOXCreditUpdateProtocol> _Nullable) delegateForCreditUpdates;

+ (void)registerForErrorMessages:(id <SOXMarketCoreErrorProtocol> _Nullable)delegateForErrorMessages;

@end
