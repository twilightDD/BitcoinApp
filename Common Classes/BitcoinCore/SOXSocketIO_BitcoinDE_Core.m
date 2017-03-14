//
//  SOXWebSocket_BitcoinDE_Core.m
//  BitcoinApp
//
//  Created by Peter Hauke on 14.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXSocketIO_BitcoinDE_Core.h"
#import "SOXSocketIOCore_Private.h"

@interface SOXSocketIO_BitcoinDE_Core ()

@property (strong, nonatomic) SocketIO *socketIO;

@end

@implementation SOXSocketIO_BitcoinDE_Core

+ (void)startWebSocketCore {
    [SOXSocketIO_BitcoinDE_Core shared].socketIO = [[SocketIO alloc] initWithDelegate:[SOXSocketIO_BitcoinDE_Core shared]];
    [SOXSocketIO_BitcoinDE_Core shared].socketIO.useSecure = YES;
    [[SOXSocketIO_BitcoinDE_Core shared].socketIO connectToHost:@"ws.bitcoin.de" onPort:443];
}

@end
