//
//  SOXAutomaticTradingCore.h
//  BitcoinApp
//
//  Created by Peter Hauke on 11.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>

//typedef NS_ENUM (NSUInteger, SOXAutomaticTradingType) {
//    SOXAutomaticTradingUnkownType   = 0
//    , SOXAutomaticTradingBuyType    = 1
//    , SOXAutomaticTradingSellType   = 2
//};

@interface SOXAutomaticTradingCore : NSObject

+ (instancetype)sharedTradingCore;

- (void)startAutomaticTrading;
- (void)stopAutomaticTrading;

@end
