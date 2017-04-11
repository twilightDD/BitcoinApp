//
//  SOXAutomaticTradingCore.m
//  BitcoinApp
//
//  Created by Peter Hauke on 11.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXAutomaticTradingCore.h"

@interface SOXAutomaticTradingCore ()

@end

@implementation SOXAutomaticTradingCore

+ (instancetype)sharedTradingCore {
    static id sharedTradingCore;
    
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        sharedTradingCore = [[self class] new];
    });
    
    return sharedTradingCore;
}

- (void)startAutomaticTrading {
    NSLog(@"startAutomaticTrading Must be implemented in subclass");
}
- (void)stopAutomaticTrading {
    NSLog(@"stopAutomaticTrading Must be implemented in subclass");
}

@end
