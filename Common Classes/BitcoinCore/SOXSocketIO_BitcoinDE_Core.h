//
//  SOXWebSocket_BitcoinDE_Core.h
//  BitcoinApp
//
//  Created by Peter Hauke on 14.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SOXShowOrderbookData;

typedef NS_ENUM (NSUInteger, BitcoinDE_UpdateType) {
    UnknownType = 0
    , BitcoinDE_UpdateType_AllOrderChanges
    , BitcoinDE_UpdateType_BuyOrderChanges
    , BitcoinDE_UpdateType_SellOrderChanges
};

@protocol SOXSocketIOCoreProtocol <NSObject>

@optional
- (void)addedOrder:(SOXShowOrderbookData *)addOrderData;
- (void)removedOrder:(id)socketArgs;
- (void)updatedOrder:(id)socketArgs;

@end

@interface SOXSocketIO_BitcoinDE_Core : NSObject

+ (void)startWebSocketCore;

+ (void)registerForAllOrderUpdatesWithDelegate:(id <SOXSocketIOCoreProtocol>)delegate;
+ (void)registerForOrderUpdatesForUpdateType:(BitcoinDE_UpdateType)bitcoinDE_UpdateType
                                    delegate:(id <SOXSocketIOCoreProtocol>)delegate;

@property (weak, nonatomic) id <SOXSocketIOCoreProtocol> delegate;
@end
