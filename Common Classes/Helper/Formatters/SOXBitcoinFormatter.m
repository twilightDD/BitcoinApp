//
//  SOXBitcoinFormatter.m
//  BitcoinApp
//
//  Created by Peter Hauke on 21.06.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXBitcoinFormatter.h"

@implementation SOXBitcoinFormatter
+ (NSNumberFormatter *)bitcoinFormatter {
    static NSNumberFormatter *bitcoinFormatter;

    static dispatch_once_t pred;

    dispatch_once(&pred, ^{
        bitcoinFormatter = [[NSNumberFormatter alloc] init];

        bitcoinFormatter.locale= [NSLocale autoupdatingCurrentLocale];
        bitcoinFormatter.minimumIntegerDigits = 1;
        bitcoinFormatter.maximumIntegerDigits = 1000;
        bitcoinFormatter.minimumFractionDigits = 2;
        bitcoinFormatter.maximumFractionDigits = 8;

        bitcoinFormatter.numberStyle =NSNumberFormatterCurrencyStyle;
        bitcoinFormatter.currencySymbol = @"\u20BF";
        bitcoinFormatter.currencyCode = @"\u20BF";
        bitcoinFormatter.internationalCurrencySymbol = @"XBT";
    });

    return bitcoinFormatter;

}

- (NSString *)stringForObjectValue:(id)obj {
    NSString *stringForObjectValue = @"";
    if ([obj isKindOfClass:[NSNumber class]]) {
        NSNumberFormatter *bitcoinFormatter = [SOXBitcoinFormatter bitcoinFormatter];

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
