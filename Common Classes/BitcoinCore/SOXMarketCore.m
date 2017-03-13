//
//  SOXMarketCore.m
//  BitcoinApp
//
//  Created by Peter Hauke on 13.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXMarketCore.h"

@implementation SOXMarketCore

+ (instancetype )sharedCore {
    static id sharedCore;
    
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        sharedCore = [[self class] new];
    });
    return sharedCore;
}

@end
