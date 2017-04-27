//
//  SOXPaymentOptionValueTransformer.m
//  BitcoinApp
//
//  Created by Peter Hauke on 27.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXPaymentOptionValueTransformer.h"

#import "SOXMarket_BitcoinDE_DefTypes.h"

@implementation SOXPaymentOptionValueTransformer

+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    NSString *transformedValue = @"Error in transformer";
    if ([value isKindOfClass:[NSNumber class]]) {
        NSNumber *valueNumber = value;
        transformedValue = [SOXMarket_BitcoinDE_DefTypes paymentOptionStringForPaymentOption:valueNumber.unsignedIntegerValue];
    }
    
    return transformedValue;
}

@end
