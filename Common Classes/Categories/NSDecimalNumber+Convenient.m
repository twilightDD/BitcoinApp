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

@end
