//
//  SOXWebSocket_BitcoinDE_Core.h
//  BitcoinApp
//
//  Created by Peter Hauke on 14.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOXMarket_BitcoinDE_DefTypes.h"

@class SOXShowOrderbookData;

@protocol SOXSocketIOCoreProtocol <NSObject>

@optional
- (void)addedOrder:(SOXShowOrderbookData *)addOrderData;
- (void)removedOrderWithOrderID:(NSString *)orderID;
- (void)updateOrderWithSocketOrderObjectID:(NSString *)orderID withValues:(NSDictionary *)changesDictionary;

@end

@interface SOXSocketIO_BitcoinDE_Core : NSObject

+ (void)registerForAllOrderUpdatesWithDelegate:(id <SOXSocketIOCoreProtocol>)delegate;
+ (void)registerForOrderUpdatesForUpdateType:(BitcoinDE_UpdateType)bitcoinDE_UpdateType
                                    delegate:(id <SOXSocketIOCoreProtocol>)delegate;
+ (void)unRegisterForOrderUpdatesForUpdateType:(BitcoinDE_UpdateType)bitcoinDE_UpdateType
                                      delegate:(id <SOXSocketIOCoreProtocol>)delegate;

@property (weak, nonatomic) id <SOXSocketIOCoreProtocol> delegate;
@end
