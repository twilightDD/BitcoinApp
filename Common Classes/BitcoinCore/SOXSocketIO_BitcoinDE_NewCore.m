//
//  SOXSocketIO_BitcoinDE_NewCore.m
//  BitcoinApp
//
//  Created by Peter Hauke on 28.03.21.
//  Copyright © 2021 2sox / Peter Hauke. All rights reserved.
//

#import "SOXSocketIO_BitcoinDE_NewCore.h"

@import SocketIO;


@interface SOXSocketIO_BitcoinDE_NewCore ()

@property SocketManager *socketManager;
@property SocketIOClient *socket;


@end

@implementation SOXSocketIO_BitcoinDE_NewCore

+ (instancetype)sharedCore {
    static SOXSocketIO_BitcoinDE_NewCore *sharedCore;
    
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        sharedCore                               = [[self class] new];
//        sharedCore.delegateForBuyOrderUpdates    = [NSMutableDictionary dictionary];
//        sharedCore.delegateForSellOrderUpdates   = [NSMutableDictionary dictionary];
//        sharedCore.delegateForRemoveOrderUpdates = [NSMutableDictionary dictionary];
        
        // [NSHashTable hashTableWithOptions:NSHashTableWeakMemory];
    });
    return sharedCore;
}

- (void)testMself {
    SOXSocketIO_BitcoinDE_NewCore *shared = SOXSocketIO_BitcoinDE_NewCore.sharedCore;
    
    
    NSURL *socketURL = [[NSURL alloc] initWithString:@"https://ws-mig.bitcoin.de:443"];
    
    SocketManager *socketManager = [[SocketManager alloc] initWithSocketURL: socketURL
                                                                     config: @{@"log": @YES,
                                                                               @"forcePolling": @YES,
                                                                               @"connectParams": @{}
                                                                     }];
    
    shared.socketManager = socketManager;
    
    
    SocketIOClient *defaultSocket = socketManager.defaultSocket;
    socketManager.nsps = @{
        @"/market" : defaultSocket
    };
    
    NSString *nsp = defaultSocket.nsp;
    NSLog(@"nsp: %@", nsp);
    
//
//
//                                       let defaultNamespaceSocket = manager.defaultSocket
//    let swiftSocket = manager.socket(forNamespace: "/swift")
//
//
//
    SocketIOClient *socket = [[SocketIOClient alloc] initWithManager:socketManager nsp:@"/market"];
    
    shared.socket = socket;
    
    
    [shared.socket onAny:^(SocketAnyEvent * _Nonnull event) {
        NSLog(@"item event: %@", event.description);
        for (id item in event.items) {
//            NSLog(@"class: %@", NSStringFromClass(item));
            NSLog(@"item: %@", item);
        }
    }];
    [shared.socket on:@"connecting"
      callback: ^(NSArray  * _Nonnull data, SocketAckEmitter * _Nonnull ackEmitter) {
        NSLog(@"connecting");
    }];
    
//    [socket on: @"connect" callback: ^(NSArray* data, void (^ack)(NSArray*)) {
//        NSLog(@"connected");
//        [socket emitObjc:@"echo" withItems:@[@"echo test"]];
//        [socket emitWithAckObjc:@"ackack" withItems:@[@1]](10, ^(NSArray* data) {
//            NSLog(@"Got ack");
//        });
//    }];

    [shared.socket connect];
    
  
    
    [shared.socket on:@"connect"
               callback: ^(NSArray  * _Nonnull data, SocketAckEmitter * _Nonnull ackEmitter) {
        NSLog(@"connect");
    }];
    
    [shared.socket on:@"disconnect"
      callback: ^(NSArray  * _Nonnull data, SocketAckEmitter * _Nonnull ackEmitter) {
        NSLog(@"disconnect");
    }];
    [shared.socket on:@"remove_order"
      callback: ^(NSArray  * _Nonnull data, SocketAckEmitter * _Nonnull ackEmitter) {
        NSLog(@"remove_order");
    }];
    [shared.socket on:@"add_order"
      callback: ^(NSArray  * _Nonnull data, SocketAckEmitter * _Nonnull ackEmitter) {
        NSLog(@"add_order");
    }];
   
}




@end
