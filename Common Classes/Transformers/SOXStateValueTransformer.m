//
//  SOXStateValueTransformer.m
//  BitcoinApp
//
//  Created by Peter Hauke on 08.01.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXStateValueTransformer.h"

#import "SOXMyTrades_BitcoinDE_Data.h"

@implementation SOXStateValueTransformer

+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    if ([value isKindOfClass:[NSNumber class]]) {
        NSNumber *state = value;
        NSString *stateString = nil;
        switch (state.integerValue) {
            case -1:
                stateString = @"Cancelled";
                break;
            case 0:
                stateString = @"Pending";
                break;
            case 1:
                stateString = @"Successful";
                break;
            default:
                break;
        }
        return  stateString;
    }

    return @"Error";
}

@end
