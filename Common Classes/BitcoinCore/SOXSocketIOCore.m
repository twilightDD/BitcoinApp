//
//  SOXWebSocketCore.m
//  BitcoinApp
//
//  Created by Peter Hauke on 14.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXSocketIOCore.h"
#import "SOXSocketIOCore_Private.h"

#import "SocketIOPacket.h"

@implementation SOXSocketIOCore


+ (instancetype )shared {
    static id shared;
    
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        shared = [[self class] new];
    });
    return shared;
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
    if ([packet.name isEqualToString:@"add_order"]) {
        NSLog(@"Order hinzu");
    }
    else if ([packet.name isEqualToString:@"remove_order"]) {
        NSLog(@"Order weg");
    }
    else if ([packet.name isEqualToString:@"refresh_express_option"]) {
        NSLog(@"refresh_express_option");
    }
    else {
        NSLog(@"unbekannter Name: %@", packet.name);
    }
    
}

- (void) socketIO:(SocketIO *)socket didSendMessage:(SocketIOPacket *)packet {
    NSLog(@"socketIO: %@ didSendMessage:\n%@", socket, packet);
    

}

- (void) socketIO:(SocketIO *)socket onError:(NSError *)error {
    NSLog(@"socketIO: %@ onError:\n%@", socket, error);
}


@end
