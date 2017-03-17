//
//  SOXMarket_BitcoinDE_Core.h
//  BitcoinApp
//
//  Created by Peter Hauke on 13.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, BitcoinDE_ServerCommandType) {
    UnknownCommand = 0
    , BitcoinDE_ShowBuyOrderbookCommandType
    , BitcoinDE_ShowSellOrderbookCommandType
    , BitcoinDE_ShowMyOrdersCommandType
    , BitcoinDE_ShowMyOrderDetailsCommandType
    , BitcoinDE_ShowAccountInfoCommandType
    , BitcoinDE_ShowOrderbookCompactCommandType
    , BitcoinDE_ShowPublicTradeHistoryCommandType
    , BitcoinDE_ShowRatesCommandType
};

FOUNDATION_EXPORT NSString *const _Nonnull ServerAnswerServerCommandKey;
FOUNDATION_EXPORT NSString *const _Nonnull ServerAnswerPayloadKey;
FOUNDATION_EXPORT NSString *const _Nonnull ServerAnswerURLResponseKey;
FOUNDATION_EXPORT NSString *const _Nonnull ServerAnswerErrorKey;

@protocol SOXMarketCoreServerRequestProtocol <NSObject>

- (void)answerOfServerRequest:(NSDictionary * _Nonnull)answerOfServerRequest;

@end

@protocol SOXBannerDataProtocol <NSObject>

- (void)didUpdateBannerData:(id _Nonnull)bannerData;

@end

@interface SOXMarket_BitcoinDE_Core : NSObject

/**
 *  Singleton.
 *
 *  @return The Core.
 */
+ (instancetype _Nonnull)sharedCore;

+ (void)requestDataForServerCommand:(BitcoinDE_ServerCommandType)serverCommandType respondTo:(id <SOXMarketCoreServerRequestProtocol> _Nonnull)controller;

+ (void)startBannerUpdatesWithScheduleTime:(NSTimeInterval)timeInterval delegate:(id <SOXBannerDataProtocol> _Nonnull)delegateForBannerUpdates;

+ (NSURLRequest * _Nullable)urlRequestForServerCommandType:(BitcoinDE_ServerCommandType)serverCommandType;

+ (NSArray * _Nonnull)serverCommandsKeys;
+ (NSString * _Nonnull)descriptionForServerCommandType:(BitcoinDE_ServerCommandType)serverCommandType;

@end
