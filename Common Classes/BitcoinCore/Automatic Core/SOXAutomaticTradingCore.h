//
//  SOXAutomaticTradingCore.h
//  BitcoinApp
//
//  Created by Peter Hauke on 11.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SOXAutomaticTradingCoreProtocol <NSObject>

- (void)executedTrade:(NSString *)tradeLine;

@end

@interface SOXAutomaticTradingCore : NSObject

@property (nonatomic) double currentPriceLimit;
@property (nonatomic) double interestRate;
@property (nonatomic) double freeReservedMoney;

@property (nonatomic) double currentBestBuyPrice;
@property (nonatomic) double currentBestSellPrice;

@property (weak, nonatomic) id <SOXAutomaticTradingCoreProtocol> delegate;

+ (instancetype)sharedTradingCore;

- (void)startAutomaticTrading;
- (void)stopAutomaticTrading;

@end
