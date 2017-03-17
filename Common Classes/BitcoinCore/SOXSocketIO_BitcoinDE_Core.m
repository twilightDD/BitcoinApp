//
//  SOXWebSocket_BitcoinDE_Core.m
//  BitcoinApp
//
//  Created by Peter Hauke on 14.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXSocketIO_BitcoinDE_Core.h"

#import "SocketIO.h"
#import "SocketIOPacket.h"
#import <SocketRocket/SRWebSocket.h>

static NSString *AddOrderKey = @"add_order";
static NSString *RemoveOrderKey = @"remove_order";
static NSString *UpdateOrderKey = @"refresh_express_option";
@interface SOXSocketIO_BitcoinDE_Core ()

@property (strong, nonatomic) SocketIO *socketIO;

@end

@implementation SOXSocketIO_BitcoinDE_Core

+ (void)startWebSocketCore {
//    [SOXSocketIO_BitcoinDE_Core shared].socketIO = [[SocketIO alloc] initWithDelegate:[SOXSocketIO_BitcoinDE_Core shared]];
//    [SOXSocketIO_BitcoinDE_Core shared].socketIO.useSecure = YES;
//    [[SOXSocketIO_BitcoinDE_Core shared].socketIO connectToHost:@"ws.bitcoin.de" onPort:443];
}

#pragma mark SocketIODelegate

- (void) socketIODidConnect:(SocketIO *)socket {
    //NSLog(@"socketIODidConnect: %@ ", socket);
}

- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error {
    //NSLog(@"socketIODidDisconnect: %@ disconnectedWithError:\n%@", socket, error);
}

- (void) socketIO:(SocketIO *)socket didReceiveMessage:(SocketIOPacket *)packet {
    //NSLog(@"socketIO: %@ didReceiveMessage:\n%@", socket, packet);
}

- (void) socketIO:(SocketIO *)socket didReceiveJSON:(SocketIOPacket *)packet {
    //NSLog(@"socketIO: %@ didReceiveJSON:\n%@", socket, packet);
}

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet {
    if ([packet.name isEqualToString:AddOrderKey]) {
        NSLog(@"SocketIO: add_order");
        if ([self.delegate respondsToSelector:@selector(addOrder:)]) {
            [self.delegate performSelector:@selector(addOrder:) withObject:packet.args];
        }
    }
    else if ([packet.name isEqualToString:RemoveOrderKey]) {
        NSLog(@"SocketIO: remove_order");
        if ([self.delegate respondsToSelector:@selector(removeOrder:)]) {
            [self.delegate performSelector:@selector(removeOrder:) withObject:packet.args];
        }
    }
    else if ([packet.name isEqualToString:UpdateOrderKey]) {
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
