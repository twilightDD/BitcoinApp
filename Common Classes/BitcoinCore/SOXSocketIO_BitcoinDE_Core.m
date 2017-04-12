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
@property (strong, nonatomic) NSHashTable *delegateForBuyOrderUpdates;
@property (strong, nonatomic) NSHashTable *delegateForSellOrderUpdates;
@property (strong, nonatomic) NSHashTable *delegateForRemoveOrderUpdates;

@property (nonatomic) BOOL socketIsRunning;

@end

#pragma mark - Implementation
@implementation SOXSocketIO_BitcoinDE_Core

#pragma mark - Public Class methods
+ (void)registerForAllOrderUpdatesWithDelegate:(id <SOXSocketIOCoreProtocol>)delegate {
    if (delegate) {
        [[SOXSocketIO_BitcoinDE_Core sharedCore].delegateForBuyOrderUpdates addObject:delegate];
        [[SOXSocketIO_BitcoinDE_Core sharedCore].delegateForSellOrderUpdates addObject:delegate];
        [[SOXSocketIO_BitcoinDE_Core sharedCore].delegateForRemoveOrderUpdates addObject:delegate];
        
        if (![SOXSocketIO_BitcoinDE_Core sharedCore].socketIO) {
            [SOXSocketIO_BitcoinDE_Core startWebSocketCore];
        }
    }
}
+ (void)registerForOrderUpdatesForUpdateType:(BitcoinDE_UpdateType)bitcoinDE_UpdateType
                                    delegate:(id <SOXSocketIOCoreProtocol>)delegate {
    if (delegate) {
        switch (bitcoinDE_UpdateType) {
            case BitcoinDE_UpdateType_BuyOrderChanges:
                [[SOXSocketIO_BitcoinDE_Core sharedCore].delegateForBuyOrderUpdates addObject:delegate];
                break;
            case BitcoinDE_UpdateType_SellOrderChanges:
                [[SOXSocketIO_BitcoinDE_Core sharedCore].delegateForSellOrderUpdates addObject:delegate];
                break;
            case BitcoinDE_UpdateType_RemoveOrderChanges:
                [[SOXSocketIO_BitcoinDE_Core sharedCore].delegateForRemoveOrderUpdates addObject:delegate];
                break;
            default:
                NSLog(@"ERROR: registerForOrderUpdatesForUpdateType - unknown type");
                break;
        }
        
        if (![SOXSocketIO_BitcoinDE_Core sharedCore].socketIO) {
            [SOXSocketIO_BitcoinDE_Core startWebSocketCore];
        }
    }
}

+ (void)unRegisterForUpdateType:(BitcoinDE_UpdateType)bitcoinDE_UpdateType
                       delegate:(id <SOXSocketIOCoreProtocol>)delegate {
    SOXSocketIO_BitcoinDE_Core *core = [SOXSocketIO_BitcoinDE_Core sharedCore];
    
    [core.delegateForBuyOrderUpdates removeObject:delegate];
    [core.delegateForSellOrderUpdates removeObject:delegate];
    [core.delegateForRemoveOrderUpdates removeObject:delegate];
    
    if (core.delegateForBuyOrderUpdates.count == 0
        && core.delegateForSellOrderUpdates.count == 0
        && core.delegateForRemoveOrderUpdates.count == 0) {
        [SOXSocketIO_BitcoinDE_Core stopWebSocketCore];
    }
}

#pragma mark - Private class methods
+ (instancetype)sharedCore {
    static SOXSocketIO_BitcoinDE_Core *sharedCore;
    
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        sharedCore = [[self class] new];
        sharedCore.delegateForBuyOrderUpdates = [[NSHashTable alloc] init];
        sharedCore.delegateForSellOrderUpdates = [[NSHashTable alloc] init];
        sharedCore.delegateForRemoveOrderUpdates = [[NSHashTable alloc] init];
        
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

#pragma mark SocketIODelegate

- (void) socketIODidConnect:(SocketIO *)socket {
    NSLog(@"socketIODidConnect: %@ ", socket);
}

- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error {
    NSLog(@"socketIODidDisconnect: %@ disconnectedWithError:\n%@", socket, error);
    
    // wait a little bit and restart socket
}

- (void) socketIO:(SocketIO *)socket didReceiveMessage:(SocketIOPacket *)packet {
    NSLog(@"socketIO: %@ didReceiveMessage:\n%@", socket, packet);
}

- (void) socketIO:(SocketIO *)socket didReceiveJSON:(SocketIOPacket *)packet {
    NSLog(@"socketIO: %@ didReceiveJSON:\n%@", socket, packet);
}

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet {
    
    NSArray <NSDictionary *> *packetArguments = packet.args;
    if (!packetArguments) {
        return;
    }
   
    
    if ([packet.name isEqualToString:BitcoinDE_WebSocket_AddOrder_MainKey]) {
        for (NSDictionary *packetDictionary in packetArguments) {
            SOXShowOrderbookData *addOrderData = [SOXShowOrderbook_BitcoinDE_Data orderBookDataForSocketIODictionary:packetDictionary];
            if (!addOrderData) {
                NSLog(@"nil");
            }
            if ([addOrderData.orderInformation_type isEqualToString:@"offer"]) {
                for (NSObject *delegate in self.delegateForBuyOrderUpdates) {
                    if ([delegate respondsToSelector:@selector(addedOrder:)]) {
                        [delegate performSelector:@selector(addedOrder:) withObject:addOrderData];
                    }
                }
            }
            else if ([addOrderData.orderInformation_type isEqualToString:@"order"]) {
                for (NSObject *delegate in self.delegateForSellOrderUpdates) {
                    if ([delegate respondsToSelector:@selector(addedOrder:)]) {
                        [delegate performSelector:@selector(addedOrder:) withObject:addOrderData];
                    }
                }
            }
            else {
                NSLog(@"socketIO:didReceiveEvent: BitcoinDE_WebSocket_AddOrder_MainKey -> unknown type: %@", addOrderData.orderInformation_type);
            }
        }
    }

    else if ([packet.name isEqualToString:BitcoinDE_WebSocket_RemoveOrder_MainKey]) {
        NSLog(@"SocketIO: remove_order");
        // TODO: Todo: siehe Doku, for eigene Angebote, die (teilweise) verkauft wurden
        for (NSDictionary *packetDictionary in packetArguments) {
            for (NSObject *delegate in self.delegateForRemoveOrderUpdates) {
                if ([delegate respondsToSelector:@selector(removedOrderWithOrderID:)]) {
                    [delegate performSelector:@selector(removedOrderWithOrderID:)
                                   withObject:[packetDictionary objectForKey:@"order_id"]];
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
                    
                    // an buy-delegates senden
                    for (NSObject *delegate in self.delegateForBuyOrderUpdates) {
                        if ([delegate respondsToSelector:@selector(updateOrderWithSocketOrderObjectID:withValues:)]) {
                            [delegate performSelector:@selector(updateOrderWithSocketOrderObjectID:withValues:)
                                           withObject:objectOrderID
                                           withObject:changesDictionary];
                        }
                    }
                    
                    // an sell-delegates senden
                    for (NSObject *delegate in self.delegateForSellOrderUpdates) {
                        if ([delegate respondsToSelector:@selector(updateOrderWithSocketOrderObjectID:withValues:)]) {
                            [delegate performSelector:@selector(updateOrderWithSocketOrderObjectID:withValues:)
                                           withObject:objectOrderID
                                           withObject:changesDictionary];
                        }
                    }
                }
            }
        }
    }
    else {
        // TODO: error handling
        NSLog(@"unbekannter Name: %@", packet.name);
    }
}

- (void) socketIO:(SocketIO *)socket didSendMessage:(SocketIOPacket *)packet {
    // NSLog(@"socketIO: %@ didSendMessage:\n%@", socket, packet);
    
    
}

- (void) socketIO:(SocketIO *)socket onError:(NSError *)error {
    NSLog(@"socketIO: %@ onError:\n%@", socket, error);
}


@end
