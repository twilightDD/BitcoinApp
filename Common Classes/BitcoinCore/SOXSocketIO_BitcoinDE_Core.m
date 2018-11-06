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

#import "SocketIO.h"
#import "SocketIOPacket.h"
#import <SocketRocket/SRWebSocket.h>

#pragma mark - Keys
static NSString *AddOrderKey = @"add_order";
static NSString *RemoveOrderKey = @"remove_order";
static NSString *UpdateOrderKey = @"refresh_express_option";

#pragma mark - Interface
@interface SOXSocketIO_BitcoinDE_Core () <SocketIODelegate>

#pragma mark Properties
@property (strong, nonatomic) SocketIO *socketIO;

//@property (strong, nonatomic) NSHashTable *delegateForAllOrderUpdates;
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
                                      delegate:(id <SOXSocketIOCoreProtocol>)delegate {
    NSString *tradingPairString = [SOXMarket_BitcoinDE_DefTypes tradingPairStringForCurrencyType:currencyType];

    SOXSocketIO_BitcoinDE_Core *core = [SOXSocketIO_BitcoinDE_Core sharedCore];
    switch (bitcoinDE_UpdateType) {
        case BitcoinDE_SocketUpdateType_BuyOrderChanges: {
            NSHashTable *buyChangesDelegatesForCurrencyType = [core.delegateForBuyOrderUpdates objectForKey:tradingPairString];
            if (buyChangesDelegatesForCurrencyType) {
                [buyChangesDelegatesForCurrencyType removeObject:delegate];
            }
            break;
        }
        case BitcoinDE_SocketUpdateType_SellOrderChanges: {
            NSHashTable *sellChangesDelegatesForCurrencyType = [core.delegateForSellOrderUpdates objectForKey:tradingPairString];
            if (sellChangesDelegatesForCurrencyType) {
                [sellChangesDelegatesForCurrencyType removeObject:delegate];
            }
            break;
        }
        case BitcoinDE_SocketUpdateType_RemoveOrderChanges: {
            NSHashTable *removeChangesDelegatesForCurrencyType = [core.delegateForRemoveOrderUpdates objectForKey:tradingPairString];
            if (removeChangesDelegatesForCurrencyType) {
                [removeChangesDelegatesForCurrencyType removeObject:delegate];
            }
            break;
        }
            break;
        default:
            break;
    }

    if (core.delegateForBuyOrderUpdates.count == 0
        && core.delegateForSellOrderUpdates.count == 0
        && core.delegateForRemoveOrderUpdates.count == 0) {
        // [SOXSocketIO_BitcoinDE_Core stopWebSocketCore];
    }
}

+ (void)registerForOrderUpdatesForUpdateType:(BitcoinDE_SocketUpdateType)bitcoinDE_UpdateType
                             forCurrencyType:(BitcoinDE_CurrencyType)currencyType
                                    delegate:(id <SOXSocketIOCoreProtocol>)delegate {
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
            case BitcoinDE_SocketUpdateType_SellOrderChanges:
            {
                NSHashTable *sellChangesDelegatesForCurrencyType = [core.delegateForSellOrderUpdates objectForKey:tradingPairString];
                if (!sellChangesDelegatesForCurrencyType) {
                    sellChangesDelegatesForCurrencyType = [NSHashTable hashTableWithOptions:NSHashTableWeakMemory];
                    [core.delegateForSellOrderUpdates setObject:sellChangesDelegatesForCurrencyType
                                                         forKey:tradingPairString];
                }
                [sellChangesDelegatesForCurrencyType addObject:delegate];
                break;
            }
            case BitcoinDE_SocketUpdateType_RemoveOrderChanges:
            {
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
                DDLogInfo(@"ERROR: registerForOrderUpdatesForUpdateType - unknown type");
                break;
        }

        if (![SOXSocketIO_BitcoinDE_Core sharedCore].socketIO) {
            [SOXSocketIO_BitcoinDE_Core startWebSocketCore];
        }
    }
}

#pragma mark - Private class methods
+ (instancetype)sharedCore {
    static SOXSocketIO_BitcoinDE_Core *sharedCore;
    
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        sharedCore = [[self class] new];
        sharedCore.delegateForBuyOrderUpdates    = [NSMutableDictionary dictionary];
        sharedCore.delegateForSellOrderUpdates   = [NSMutableDictionary dictionary];
        sharedCore.delegateForRemoveOrderUpdates = [NSMutableDictionary dictionary];
        
        // [NSHashTable hashTableWithOptions:NSHashTableWeakMemory];
    });
    return sharedCore;
}

+ (void)startWebSocketCore {
    [SOXSocketIO_BitcoinDE_Core sharedCore].socketIO = [[SocketIO alloc] initWithDelegate:[SOXSocketIO_BitcoinDE_Core sharedCore]];
    [SOXSocketIO_BitcoinDE_Core sharedCore].socketIO.useSecure = YES;
    [[SOXSocketIO_BitcoinDE_Core sharedCore].socketIO connectToHost:@"ws.bitcoin.de" onPort:443];
}

+ (void)stopWebSocketCore {
    [[SOXSocketIO_BitcoinDE_Core sharedCore].socketIO disconnect];
    [[SOXSocketIO_BitcoinDE_Core sharedCore] setSocketIO:nil];
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
    NSTimer *ratesReloadTimer  = [NSTimer scheduledTimerWithTimeInterval:20
                                                                  target:[SOXSocketIO_BitcoinDE_Core class]
                                                                selector:@selector(startWebSocketCore)
                                                                userInfo:nil
                                                                 repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:ratesReloadTimer forMode:NSDefaultRunLoopMode];

}

#pragma mark SocketIODelegate
- (void)socketIODidConnect:(SocketIO *)socket {
    DDLogInfo(@"~~~~~ socketIODidConnect");
    SEL socketIODidConnectSelector = NSSelectorFromString(@"socketIODidConnect:");
    NSString *note = @"*** socketIODidConnect";
    for (NSObject *delegate in self.delegateForBuyOrderUpdates) {
        if ([delegate respondsToSelector:socketIODidConnectSelector]) {
            [delegate performSelectorOnMainThread:socketIODidConnectSelector
                                       withObject:note
                                    waitUntilDone:NO];
        }

    }
    for (NSObject *delegate in self.delegateForSellOrderUpdates) {
        if ([delegate respondsToSelector:socketIODidConnectSelector]) {
            [delegate performSelectorOnMainThread:socketIODidConnectSelector
                                       withObject:note
                                    waitUntilDone:NO];
        }
    }
}

- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error {
    DDLogInfo(@"~~~~~ socketIODidDisconnect: %@ disconnectedWithError:\n%@", socket, error);

    SEL socketIODidDisconnect = NSSelectorFromString(@"socketIODidDisconnect:");
    NSString *note = [NSString stringWithFormat:@"*** socketIODidDisconnect with Error:\n%@", error.localizedDescription];
    for (NSObject *delegate in self.delegateForBuyOrderUpdates) {
        if ([delegate respondsToSelector:socketIODidDisconnect]) {
            [delegate performSelectorOnMainThread:socketIODidDisconnect
                                       withObject:note
                                    waitUntilDone:NO];
        }

    }
    for (NSObject *delegate in self.delegateForSellOrderUpdates) {
        if ([delegate respondsToSelector:socketIODidDisconnect]) {
            [delegate performSelectorOnMainThread:socketIODidDisconnect
                                       withObject:note
                                    waitUntilDone:NO];
        }
    }
    [SOXSocketIO_BitcoinDE_Core restartWebSocketCore];
}

- (void)socketIO:(SocketIO *)socket didReceiveMessage:(SocketIOPacket *)packet {
    DDLogInfo(@"~~~~~ socketIO: %@ didReceiveMessage:\n%@", socket, packet);
}

- (void)socketIO:(SocketIO *)socket didReceiveJSON:(SocketIOPacket *)packet {
    DDLogInfo(@"~~~~~ socketIO: %@ didReceiveJSON:\n%@", socket, packet);
}

- (void)socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet {
    
    NSArray <NSDictionary *> *packetArguments = packet.args;
    if (!packetArguments) {
        return;
    }

    
    if ([packet.name isEqualToString:BitcoinDE_WebSocket_AddOrder_MainKey]) {
        for (NSDictionary *packetDictionary in packetArguments) {
            SOXShowOrderbookData *addOrderData = [SOXShowOrderbook_BitcoinDE_Data orderBookDataForSocketIODictionary:packetDictionary];
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
                DDLogInfo(@"socketIO:didReceiveEvent: BitcoinDE_WebSocket_AddOrder_MainKey -> unknown type: %@", addOrderData.orderInformation_type);
            }
        }
    }

    else if ([packet.name isEqualToString:BitcoinDE_WebSocket_RemoveOrder_MainKey]) {
        DDLogInfo(@"SocketIO: remove_order");
        for (NSDictionary *packetDictionary in packetArguments) {
            NSString *tradingPairString = [packetDictionary objectForKey:BitcoinDE_WebSocket_TradingPair];
            NSHashTable *delegateForRemoveOrderUpdatesForTradingPair = [self.delegateForRemoveOrderUpdates objectForKey:tradingPairString];
            for (NSObject *delegate in delegateForRemoveOrderUpdatesForTradingPair) {
                if ([delegate respondsToSelector:@selector(removedOrderWithOrderID:)]) {
                    [delegate performSelectorOnMainThread:@selector(removedOrderWithOrderID:)
                                               withObject:packetDictionary
                                            waitUntilDone:NO];
                }
            }
        }
    }
    else if ([packet.name isEqualToString:BitcoinDE_WebSocket_UpdateOrder_MainKey]) {
        /* packet.args ist ein Array aus Dictionaries
         (
         {
         4466901 = {                                             => Key des Dict ist objectOrderID (sehr geile API!)
         "is_trade_by_fidor_reservation_allowed" = 1;
         "is_trade_by_sepa_allowed" = 0;
         "trading_pair" = btceur/bcheur/etheur/...;
         };
         }
         )
         */
        
        if ([packet.args isKindOfClass:[NSArray class]]) {
            NSArray *updateDictionaries = (NSArray *)packet.args;
            
            // alle Dict im Array parsen
            for (NSDictionary *updateDictionary in updateDictionaries) {
                NSArray *objectOrderIDs = updateDictionary.allKeys; // Key des Dict ist objectOrderID (sehr geile API!)
                for (NSString *objectOrderID in objectOrderIDs) { // für jeden Key(objectOrderID) die Payload an die Delegates senden
                    NSDictionary *changesDictionary = [updateDictionary objectForKey:objectOrderID];

                    NSString *tradingPairString = [changesDictionary objectForKey:BitcoinDE_WebSocket_TradingPair];
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
        }
    }
    else {
        // TODO: error handling
        DDLogInfo(@"--- START ---");
        DDLogInfo(@"socketIO:didReceiveEvent: - unknown event name: %@", packet.name);
        DDLogInfo(@"packetArguments:\n%@", packetArguments);
        DDLogInfo(@"--- END ---");
    }
}

- (void) socketIO:(SocketIO *)socket didSendMessage:(SocketIOPacket *)packet {
    // DDLogInfo(@"socketIO: %@ didSendMessage:\n%@", socket, packet);
}

- (void) socketIO:(SocketIO *)socket onError:(NSError *)error {
    DDLogInfo(@"~~~~~ socketIO: %@ onError:\n%@", socket, error);

    SEL socketIODidDisconnect = NSSelectorFromString(@"socketIOError:");
    NSString *note = [NSString stringWithFormat:@"*** socketIO onError:\n%@", error.localizedDescription];
    for (NSObject *delegate in self.delegateForBuyOrderUpdates) {
        if ([delegate respondsToSelector:socketIODidDisconnect]) {
            [delegate performSelectorOnMainThread:socketIODidDisconnect
                                       withObject:note
                                    waitUntilDone:NO];
        }

    }
    for (NSObject *delegate in self.delegateForSellOrderUpdates) {
        if ([delegate respondsToSelector:socketIODidDisconnect]) {
            [delegate performSelectorOnMainThread:socketIODidDisconnect
                                       withObject:note
                                    waitUntilDone:NO];
        }
    }

    [SOXSocketIO_BitcoinDE_Core restartWebSocketCore];
}

@end
