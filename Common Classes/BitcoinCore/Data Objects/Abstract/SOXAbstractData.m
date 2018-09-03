//
//  SOXAbstractData.m
//  BitcoinApp
//
//  Created by Peter Hauke on 03.09.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXAbstractData.h"

@implementation SOXAbstractData

- (NSDecimalNumber *)convertToNumber:(id)value {
    NSDecimalNumber *convertToNumber = nil;
    if ([value isKindOfClass:[NSString class]]) {
        convertToNumber = [NSDecimalNumber decimalNumberWithString:value];
    }
    else if ([value isKindOfClass:[NSNumber class]]) {
        convertToNumber = [NSDecimalNumber decimalNumberWithDecimal:[(NSNumber *)value decimalValue]];
    }

    return convertToNumber;
}

@end
