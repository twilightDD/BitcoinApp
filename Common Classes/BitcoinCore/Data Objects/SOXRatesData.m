//
//  SOXRatesData.m
//  BitcoinApp
//
//  Created by Peter Hauke on 21.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXRatesData.h"

@interface SOXRatesData ()

@property (strong, nonatomic, readwrite) NSMutableDictionary *rates;

@end

@implementation SOXRatesData

- (instancetype)init {
    self = [super init];
    if (self) {
        self.rates = [NSMutableDictionary dictionary];
    }

    return self;
}

@end
