//
//  SOXMyTradeHistoryPaymentMethodValueTransformer.m
//  BitcoinApp
//
//  Created by Peter Hauke on 26.11.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXMyTradeHistoryPaymentMethodValueTransformer.h"

#import "SOXMyTrades_BitcoinDE_Data.h"

@implementation SOXMyTradeHistoryPaymentMethodValueTransformer

+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    if ([value isKindOfClass:[NSNumber class]]) {
        NSNumber *paymentMethod = (NSNumber *)value;
        NSString *paymentMethodString = [SOXMyTrades_BitcoinDE_Data titleForPaymentMethodType:paymentMethod.unsignedIntegerValue];
        return paymentMethodString;
    }

    return value;
}

@end
