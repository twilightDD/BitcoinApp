//
//  SOXAutomaticTradingCore.h
//  BitcoinApp
//
//  Created by Peter Hauke on 11.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SOXAutomaticTradingCoreManager.h"

#import "SOXSocketIO_BitcoinDE_Core.h"
#import "SOXMarket_DefTypes.h"

@protocol SOXAutomaticTradingCoreProtocol <NSObject>

- (void)logLine:(NSString *)line;
- (void)statusUpdate:(NSString *)status;
- (void)automaticTradingDidBegin;
- (void)automaticTradingDidStop;

@end

@interface SOXAutomaticTradingCore : NSObject

@property (weak, nonatomic) id <SOXAutomaticTradingCoreProtocol, SOXSocketIOCoreProtocol, SOXSocketIOCoreStatusProtocol> delegate;
@property (nonatomic) BitcoinCurrencyType bitcoinCurrencyType;

//+ (instancetype)sharedTradingCore;
- (void)setupProperties;

- (void)startAutomaticTrading;
- (void)stopAutomaticTrading;

- (void)setBuyInterestRate:(NSDecimalNumber *)buyInterestRate;
- (void)setSellInterestRate:(NSDecimalNumber *)sellInterestRate;
- (void)setBuyMaximalFidorAmount:(NSDecimalNumber *)buyMaximalEuro;
- (void)setSellMaximalBTCAmount:(NSDecimalNumber *)sellMaximalBTC;

@end
