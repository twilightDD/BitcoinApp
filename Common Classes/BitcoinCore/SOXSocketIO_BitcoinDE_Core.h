//
//  SOXWebSocket_BitcoinDE_Core.h
//  BitcoinApp
//
//  Created by Peter Hauke on 14.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SOXSocketIOCoreProtocol <NSObject>

- (void)addOrder:(NSArray *)socketArgs;
- (void)removeOrder:(NSArray *)socketArgs;
- (void)updateOrder:(NSArray *)socketArgs;

@end
@interface SOXSocketIO_BitcoinDE_Core : NSObject

+ (void)startWebSocketCore;
@property (weak, nonatomic) id <SOXSocketIOCoreProtocol> delegate;
@end
