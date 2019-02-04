//
//  SOXSingleSelectionValueTransformer.m
//  BitcoinApp
//
//  Created by Peter Hauke on 13.09.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXSingleSelectionValueTransformer.h"

@implementation SOXSingleSelectionValueTransformer

+ (Class)transformedValueClass {
    return [NSNumber class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    if ([value isKindOfClass:[NSNumber class]]) {
        NSNumber *valueNumber = value;
        if (valueNumber.integerValue == 1) {
            return @YES;
        }
    }

    return @NO;
}

@end
