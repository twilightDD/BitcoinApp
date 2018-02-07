//
//  SOXAutomaticTradingCore.h
//  BitcoinApp
//
//  Created by Peter Hauke on 11.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SOXSocketIO_BitcoinDE_Core.h"
@protocol SOXAutomaticTradingCoreProtocol <NSObject>

- (void)logLine:(NSString *)line;
- (void)statusUpdate:(NSString *)status;
- (void)automaticTradingDidBegin;
- (void)automaticTradingDidStop;

@end

@interface SOXAutomaticTradingCore : NSObject

@property (weak, nonatomic) id <SOXAutomaticTradingCoreProtocol, SOXSocketIOCoreProtocol, SOXSocketIOCoreStatusProtocol> delegate;

- (void)setBuyInterestRate:(NSDecimalNumber *)buyInterestRate;
- (void)setBuyMaximalFidorAmount:(NSDecimalNumber *)buyMaximalEuro;

@end
