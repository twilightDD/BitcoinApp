//
//  SOXWebSocket_BitcoinDE_Core.m
//  BitcoinApp
//
//  Created by Peter Hauke on 14.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXSocketIO_BitcoinDE_Core.h"

#import "SOXKeys_BitcoinDE.h"

#import "SOXShowOrderbook_BitcoinDE_Data.h"

#import "mac_BitcoinApp-Swift.h"

#pragma mark - Interface
@interface SOXSocketIO_BitcoinDE_Core ()

#pragma mark Properties
@property (strong, nonatomic) NSMutableDictionary *delegateForBuyOrderUpdates;
@property (strong, nonatomic) NSMutableDictionary *delegateForSellOrderUpdates;
@property (strong, nonatomic) NSMutableDictionary *delegateForRemoveOrderUpdates;

@property (nonatomic) BOOL socketIsRunning;

@end

#pragma mark - Implementation
@implementation SOXSocketIO_BitcoinDE_Core

#pragma mark - Public Class methods
+ (void)unRegisterForOrderUpdatesForUpdateType:(BitcoinDE_SocketUpdateType)bitcoinDE_UpdateType
                               forCurrencyType:(BitcoinDE_CurrencyType)currencyType
                                      delegate:(id<SOXSocketIOCoreProtocol>)delegate {
    if ([SOXNewSocket_BitcoinDE_Core isConnected] == false) {
        NSLog(@"~~~~~ socket == nil");
        return;
    }
    
    SOXSocketIO_BitcoinDE_Core *core = [SOXSocketIO_BitcoinDE_Core sharedCore];

    NSString *tradingPairString           = [SOXMarket_BitcoinDE_DefTypes tradingPairStringForCurrencyType:currencyType];
    NSHashTable *buyDelegatesHashTable    = [core.delegateForBuyOrderUpdates objectForKey:tradingPairString];
    NSHashTable *sellDelegatesHashTable   = [core.delegateForSellOrderUpdates objectForKey:tradingPairString];
    NSHashTable *removeDelegatesHashTable = [core.delegateForRemoveOrderUpdates objectForKey:tradingPairString];

    if (buyDelegatesHashTable == nil && sellDelegatesHashTable == nil && removeDelegatesHashTable == nil) {
        return;
    }

    NSLog(@"~~~~~ Will unregister  buy sockets:%@, sell sockets: %@, RemoveSockets: %@", @(buyDelegatesHashTable.allObjects.count), @(sellDelegatesHashTable.allObjects.count), @(removeDelegatesHashTable.allObjects.count));

    switch (bitcoinDE_UpdateType) {
        case BitcoinDE_SocketUpdateType_BuyOrderChanges: {
            [buyDelegatesHashTable removeObject:delegate];
            break;
        }
        case BitcoinDE_SocketUpdateType_SellOrderChanges: {
            [sellDelegatesHashTable removeObject:delegate];
            break;
        }
        case BitcoinDE_SocketUpdateType_RemoveOrderChanges: {
            [removeDelegatesHashTable removeObject:delegate];
            break;
        } break;
        default:
            break;
    }

    NSLog(@"~~~~~  Did unregister  buy sockets:%@, sell sockets: %@, RemoveSockets: %@", @(buyDelegatesHashTable.allObjects.count), @(sellDelegatesHashTable.allObjects.count), @(removeDelegatesHashTable.allObjects.count));

    if (buyDelegatesHashTable.allObjects.count == 0
        && sellDelegatesHashTable.allObjects.count == 0
        && removeDelegatesHashTable.allObjects.count == 0) {
        
        [core.delegateForBuyOrderUpdates removeAllObjects];
        [core.delegateForSellOrderUpdates removeAllObjects];
        [core.delegateForRemoveOrderUpdates removeAllObjects];
        
        DDLogInfo(@"~~~~~ Going to stop webSocket: no delegate is interested anymore.");
        [SOXNewSocket_BitcoinDE_Core stopWebSocketCore];
    }
}

+ (void)registerForOrderUpdatesForUpdateType:(BitcoinDE_SocketUpdateType)bitcoinDE_UpdateType
                             forCurrencyType:(BitcoinDE_CurrencyType)currencyType
                                    delegate:(id<SOXSocketIOCoreProtocol>)delegate {
    NSString *tradingPairString = [SOXMarket_BitcoinDE_DefTypes tradingPairStringForCurrencyType:currencyType];

    SOXSocketIO_BitcoinDE_Core *core = [SOXSocketIO_BitcoinDE_Core sharedCore];
    if (delegate) {
        switch (bitcoinDE_UpdateType) {
            case BitcoinDE_SocketUpdateType_BuyOrderChanges: {
                NSHashTable *buyChangesDelegatesForCurrencyType = [core.delegateForBuyOrderUpdates objectForKey:tradingPairString];
                if (!buyChangesDelegatesForCurrencyType) {
                    buyChangesDelegatesForCurrencyType = [NSHashTable hashTableWithOptions:NSHashTableWeakMemory];
                    [core.delegateForBuyOrderUpdates setObject:buyChangesDelegatesForCurrencyType
                                                        forKey:tradingPairString];
                }
                [buyChangesDelegatesForCurrencyType addObject:delegate];
                break;
            }
            case BitcoinDE_SocketUpdateType_SellOrderChanges: {
                NSHashTable *sellChangesDelegatesForCurrencyType = [core.delegateForSellOrderUpdates objectForKey:tradingPairString];
                if (!sellChangesDelegatesForCurrencyType) {
                    sellChangesDelegatesForCurrencyType = [NSHashTable hashTableWithOptions:NSHashTableWeakMemory];
                    [core.delegateForSellOrderUpdates setObject:sellChangesDelegatesForCurrencyType
                                                         forKey:tradingPairString];
                }
                [sellChangesDelegatesForCurrencyType addObject:delegate];
                break;
            }
            case BitcoinDE_SocketUpdateType_RemoveOrderChanges: {
                NSHashTable *removeChangesDelegatesForCurrencyType = [core.delegateForRemoveOrderUpdates objectForKey:tradingPairString];
                if (!removeChangesDelegatesForCurrencyType) {
                    removeChangesDelegatesForCurrencyType = [NSHashTable hashTableWithOptions:NSHashTableWeakMemory];
                    [core.delegateForRemoveOrderUpdates setObject:removeChangesDelegatesForCurrencyType
                                                           forKey:tradingPairString];
                }
                [removeChangesDelegatesForCurrencyType addObject:delegate];
                break;
            }
            default:
                DDLogInfo(@"~~~~~ ERROR: registerForOrderUpdatesForUpdateType - unknown type");
                break;
        }

        [SOXNewSocket_BitcoinDE_Core startWebSocketCore];
    }
}

#pragma mark Socket Methods
+ (void)socketDidConnect {
    DDLogInfo(@"~~~~~ socketIODidConnect");
    
    SEL socketIODidConnectSelector = NSSelectorFromString(@"socketIODidConnect:");
    NSString *note                 = @"*** socketIODidConnect";
    for (NSObject *delegate in [SOXSocketIO_BitcoinDE_Core sharedCore].delegateForBuyOrderUpdates) {
        if ([delegate respondsToSelector:socketIODidConnectSelector]) {
            [delegate performSelectorOnMainThread:socketIODidConnectSelector
                                       withObject:note
                                    waitUntilDone:NO];
        }
    }
    for (NSObject *delegate in [SOXSocketIO_BitcoinDE_Core sharedCore].delegateForSellOrderUpdates) {
        if ([delegate respondsToSelector:socketIODidConnectSelector]) {
            [delegate performSelectorOnMainThread:socketIODidConnectSelector
                                       withObject:note
                                    waitUntilDone:NO];
        }
    }
}

+ (void)socketDidDisconnect {
    DDLogInfo(@"~~~~~ socketIODidDisconnect");
    
    SEL socketIODidDisconnect = NSSelectorFromString(@"socketIODidDisconnect:");
    NSString *note            = @"*** socketIODidDisconnect";
    for (NSObject *delegate in [SOXSocketIO_BitcoinDE_Core sharedCore].delegateForBuyOrderUpdates) {
        if ([delegate respondsToSelector:socketIODidDisconnect]) {
            [delegate performSelectorOnMainThread:socketIODidDisconnect
                                       withObject:note
                                    waitUntilDone:NO];
        }
    }
    for (NSObject *delegate in [SOXSocketIO_BitcoinDE_Core sharedCore].delegateForSellOrderUpdates) {
        if ([delegate respondsToSelector:socketIODidDisconnect]) {
            [delegate performSelectorOnMainThread:socketIODidDisconnect
                                       withObject:note
                                    waitUntilDone:NO];
        }
    }
    
    // Restart after disconnect if some delegates for updates are present
    SOXSocketIO_BitcoinDE_Core *core = [SOXSocketIO_BitcoinDE_Core sharedCore];
    if (core.delegateForBuyOrderUpdates.count > 0 || core.delegateForSellOrderUpdates.count > 0 || core.delegateForRemoveOrderUpdates.count > 0) {
        [SOXSocketIO_BitcoinDE_Core restartWebSocketCore];
    }
    else {
        NSString *info = @"~~~~~DON't restart WebSocket Connection: no delegates are interested ~~~~~";
        DDLogInfo(@"%@", info);
    }
}

+ (void)addOrder:(NSDictionary *)dictionary {
    [[SOXSocketIO_BitcoinDE_Core sharedCore] addOrder:dictionary];
}

+ (void)removeOrder:(NSDictionary *)dictionary {
    [[SOXSocketIO_BitcoinDE_Core sharedCore] removeOrder:dictionary];
}

+ (void)updateOrder:(NSDictionary *)dictionary {
    [[SOXSocketIO_BitcoinDE_Core sharedCore] updateOrder:dictionary];
}


#pragma mark - Private class methods
+ (instancetype)sharedCore {
    static SOXSocketIO_BitcoinDE_Core *sharedCore;

    static dispatch_once_t pred;

    dispatch_once(&pred, ^{
        sharedCore                               = [[self class] new];
        sharedCore.delegateForBuyOrderUpdates    = [NSMutableDictionary dictionary];
        sharedCore.delegateForSellOrderUpdates   = [NSMutableDictionary dictionary];
        sharedCore.delegateForRemoveOrderUpdates = [NSMutableDictionary dictionary];

        // [NSHashTable hashTableWithOptions:NSHashTableWeakMemory];
    });
    return sharedCore;
}

+ (void)restartWebSocketCore {
    NSString *info = @"~~~~~ Try to restart WebSocket Connection in 20 seconds ~~~~~";
    DDLogInfo(@"%@", info);

    SEL socketIODidDisconnect = NSSelectorFromString(@"socketIODidDisconnect:");
    for (NSObject *delegate in [[SOXSocketIO_BitcoinDE_Core sharedCore] delegateForBuyOrderUpdates]) {
        if ([delegate respondsToSelector:socketIODidDisconnect]) {
            [delegate performSelectorOnMainThread:socketIODidDisconnect
                                       withObject:info
                                    waitUntilDone:NO];
        }
    }
    for (NSObject *delegate in [[SOXSocketIO_BitcoinDE_Core sharedCore] delegateForSellOrderUpdates]) {
        if ([delegate respondsToSelector:socketIODidDisconnect]) {
            [delegate performSelectorOnMainThread:socketIODidDisconnect
                                       withObject:info
                                    waitUntilDone:NO];
        }
    }

    // wait a little bit and restart socket
    NSTimer *ratesReloadTimer = [NSTimer scheduledTimerWithTimeInterval:20
                                                                 target:[SOXNewSocket_BitcoinDE_Core class]
                                                               selector:@selector(startWebSocketCore)
                                                               userInfo:nil
                                                                repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:ratesReloadTimer forMode:NSDefaultRunLoopMode];
}

#pragma mark - Private Instance Methods
- (void)addOrder:(NSDictionary *)dictionary {
    SOXShowOrderbookData *addOrderData = [SOXShowOrderbook_BitcoinDE_Data orderBookDataForSocketIODictionary:dictionary];
    if (!addOrderData) {
        DDLogInfo(@"nil");
    }
    
    if ([addOrderData.orderInformation_type isEqualToString:BitcoinDE_WebSocket_BuyOrderType]) {
        NSHashTable *delegateForBuyOrderUpdatesForTradingPair = [self.delegateForBuyOrderUpdates objectForKey:addOrderData.orderInformation_tradingPair];
        for (NSObject *delegate in delegateForBuyOrderUpdatesForTradingPair) {
            [delegate performSelectorOnMainThread:@selector(addedOrder:)
                                       withObject:addOrderData
                                    waitUntilDone:NO];
        }
    }
    else if ([addOrderData.orderInformation_type isEqualToString:BitcoinDE_WebSocket_SellOrderType]) {
        NSHashTable *delegateForSellOrderUpdatesForTradingPair = [self.delegateForSellOrderUpdates objectForKey:addOrderData.orderInformation_tradingPair];
        for (NSObject *delegate in delegateForSellOrderUpdatesForTradingPair) {
            [delegate performSelectorOnMainThread:@selector(addedOrder:)
                                       withObject:addOrderData
                                    waitUntilDone:NO];
        }
    }
    else {
        DDLogInfo(@"- (void)addOrder:(NSDictionary *)dictionary -> unknown type: %@", addOrderData.orderInformation_type);
    }
}

- (void)removeOrder:(NSDictionary *)dictionary {
    NSString *tradingPairString = [dictionary objectForKey:BitcoinDE_WebSocket_TradingPair];
    NSHashTable *delegateForRemoveOrderUpdatesForTradingPair = [self.delegateForRemoveOrderUpdates objectForKey:tradingPairString];
    for (NSObject *delegate in delegateForRemoveOrderUpdatesForTradingPair) {
        if ([delegate respondsToSelector:@selector(removedOrderWithOrderID:)]) {
            [delegate performSelectorOnMainThread:@selector(removedOrderWithOrderID:)
                                       withObject:dictionary
                                    waitUntilDone:NO];
        }
    }
}

- (void)updateOrder:(NSDictionary *)dictionary {
    NSArray *objectOrderIDs = dictionary.allKeys;     // Key des Dict ist objectOrderID (sehr geile API!)
    for (NSString *objectOrderID in objectOrderIDs) { // für jeden Key(objectOrderID) die Payload an die Delegates senden
        NSDictionary *changesDictionary = [dictionary objectForKey:objectOrderID];
        
        NSString *tradingPairString              = [changesDictionary objectForKey:BitcoinDE_WebSocket_TradingPair];
        NSHashTable *delegateForSellOrderUpdates = [self.delegateForSellOrderUpdates objectForKey:tradingPairString];
        // inform sell-delegates: WebSocket_UpdateOrder only for sell orders
        for (NSObject *delegate in delegateForSellOrderUpdates) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate performSelector:@selector(updateOrderWithSocketOrderObjectID:withValues:)
                               withObject:objectOrderID
                               withObject:changesDictionary];
            });
        }
    }
}

@end
