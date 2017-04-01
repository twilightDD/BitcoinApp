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

@property (strong, nonatomic) NSHashTable *delegateForAllOrderUpdates;
@property (strong, nonatomic) NSHashTable *delegateForBuyOrderUpdates;
@property (strong, nonatomic) NSHashTable *delegateForSellOrderUpdates;

@property (nonatomic) BOOL socketIsRunning;

@end

#pragma mark - Implementation
@implementation SOXSocketIO_BitcoinDE_Core

#pragma mark - Public Class methods
+ (void)registerForAllOrderUpdatesWithDelegate:(id <SOXSocketIOCoreProtocol>)delegate {
    if (delegate) {
        [[SOXSocketIO_BitcoinDE_Core sharedCore].delegateForAllOrderUpdates addObject:delegate];
        
        if (![SOXSocketIO_BitcoinDE_Core sharedCore].socketIO) {
            [SOXSocketIO_BitcoinDE_Core startWebSocketCore];
        }
    }
}
+ (void)registerForOrderUpdatesForUpdateType:(BitcoinDE_UpdateType)bitcoinDE_UpdateType
                                    delegate:(id <SOXSocketIOCoreProtocol>)delegate {
    if (delegate) {
        [[SOXSocketIO_BitcoinDE_Core sharedCore].delegateForAllOrderUpdates addObject:delegate];
        switch (bitcoinDE_UpdateType) {
            case BitcoinDE_UpdateType_BuyOrderChanges:
                [[SOXSocketIO_BitcoinDE_Core sharedCore].delegateForBuyOrderUpdates addObject:delegate];
                break;
            case BitcoinDE_UpdateType_SellOrderChanges:
                [[SOXSocketIO_BitcoinDE_Core sharedCore].delegateForSellOrderUpdates addObject:delegate];
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

#pragma mark - Private class methods
+ (instancetype)sharedCore {
    static SOXSocketIO_BitcoinDE_Core *sharedCore;
    
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        sharedCore = [[self class] new];
        sharedCore.delegateForAllOrderUpdates = [[NSHashTable alloc] init];
        sharedCore.delegateForBuyOrderUpdates = [[NSHashTable alloc] init];
        sharedCore.delegateForSellOrderUpdates = [[NSHashTable alloc] init];
        
    });
    return sharedCore;
}

+ (void)startWebSocketCore {
    [SOXSocketIO_BitcoinDE_Core sharedCore].socketIO = [[SocketIO alloc] initWithDelegate:[SOXSocketIO_BitcoinDE_Core sharedCore]];
    [SOXSocketIO_BitcoinDE_Core sharedCore].socketIO.useSecure = YES;
   [[SOXSocketIO_BitcoinDE_Core sharedCore].socketIO connectToHost:@"ws.bitcoin.de" onPort:443];
}

#pragma mark SocketIODelegate

- (void) socketIODidConnect:(SocketIO *)socket {
    NSLog(@"socketIODidConnect: %@ ", socket);
}

- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error {
    NSLog(@"socketIODidDisconnect: %@ disconnectedWithError:\n%@", socket, error);
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
        NSLog(@"SocketIO: add_order");
        for (NSObject *delegate in self.delegateForBuyOrderUpdates) {
            if ([delegate respondsToSelector:@selector(addedOrder:)]) {
                for (NSDictionary *packetDictionary in packetArguments) {
                    SOXShowOrderbookData *addOrderData = [SOXShowOrderbook_BitcoinDE_Data orderBookDataForSocketIODictionary:packetDictionary];
                    [delegate performSelector:@selector(addedOrder:) withObject:addOrderData];
                }
            }
        }
            
        
        
    }

    else if ([packet.name isEqualToString:BitcoinDE_WebSocket_RemoveOrder_MainKey]) {
        NSLog(@"SocketIO: remove_order");
        if ([self.delegate respondsToSelector:@selector(removeOrder:)]) {
            [self.delegate performSelector:@selector(removeOrder:) withObject:packet.args];
        }
    }
    else if ([packet.name isEqualToString:BitcoinDE_WebSocket_UpdateOrder_MainKey]) {
        NSLog(@"SocketIO: refresh_express_option");
        if ([self.delegate respondsToSelector:@selector(updateOrder:)]) {
            [self.delegate performSelector:@selector(updateOrder:) withObject:packet.args];
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
