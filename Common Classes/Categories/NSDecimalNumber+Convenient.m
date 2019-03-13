//
//  NSDecimalNumber+Convenient.m
//  BitcoinApp
//
//  Created by Peter Hauke on 26.11.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "NSDecimalNumber+Convenient.h"

@implementation NSDecimalNumber (Convenient)

+ (NSDecimalNumber *)minusOne {
    return [NSDecimalNumber decimalNumberWithString:@"-1"];
}

- (NSDecimalNumber *)absoluteDecimalNumber {
    if ([self compare:[NSDecimalNumber zero]] == NSOrderedAscending) {
        // negative value
        return [[NSDecimalNumber zero] decimalNumberBySubtracting:self];
    } else {
        return self;
    }
}

@end
