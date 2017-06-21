//
//  SOXBitcoinFormatter.m
//  BitcoinApp
//
//  Created by Peter Hauke on 21.06.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXBitcoinFormatter.h"
#import "SOXFormatters.h"

@implementation SOXBitcoinFormatter
- (NSString *)stringForObjectValue:(id)obj {
    NSString *stringForObjectValue = @"";
    if ([obj isKindOfClass:[NSNumber class]]) {
        NSNumberFormatter *bitcoinFormatter = [SOXFormatters bitcoinNumberFormatter];
        stringForObjectValue = [bitcoinFormatter stringFromNumber:obj];
    }
    return stringForObjectValue;
}

- (BOOL)getObjectValue:(out id  _Nullable __autoreleasing *)obj
            forString:(NSString *)string
     errorDescription:(out NSString *__autoreleasing  _Nullable *)error {

    return YES;
}



@end
