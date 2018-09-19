//
//  SOXBoolNmberToWordValueTransformer.m
//  BitcoinApp
//
//  Created by Peter Hauke on 19.09.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXBoolNmberToWordValueTransformer.h"

@implementation SOXBoolNmberToWordValueTransformer

+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    if ([value isKindOfClass:[NSNumber class]]) {
        if ([(NSNumber *)value boolValue]) {
            return @"YES";
        }
        else {
            return @"NO";
        }
    }

    return @"Input must be NSNumber";
}

@end
