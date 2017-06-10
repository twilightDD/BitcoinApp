//
//  SOXFormatters.m
//  BitcoinApp
//
//  Created by Peter Hauke on 24.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXFormatters.h"

@implementation SOXFormatters
/*
 https://developer.apple.com/library/content/qa/qa1480/_index.html
 http://stackoverflow.com/questions/24873069/nsdateformatter-format-string-for-rfc-3339-date-string-without-milliseconds
 */

#pragma mark - Static DateFormatters
+ (NSDateFormatter *)dateFormatterDecodeRFC3339 {
    /*
     Format gemäß RFC 3339 (Bsp: 2015-01-20T15:00:00+02:00).
     */
    
    static dispatch_once_t pred;
    static NSDateFormatter *sRFC3339DateFormatter = nil;
    dispatch_once(&pred, ^{
        sRFC3339DateFormatter            = [[NSDateFormatter alloc] init];
        sRFC3339DateFormatter.locale     = [NSLocale autoupdatingCurrentLocale];
        sRFC3339DateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
        sRFC3339DateFormatter.timeZone   = [NSTimeZone timeZoneForSecondsFromGMT:0];
    });
    return sRFC3339DateFormatter;
}

+ (NSDateFormatter *)dateFormatterEncodeRFC3339 {
    /*
     Format gemäß RFC 3339 (Bsp: 2015-01-20T15:00:00+02:00).
     */
    
    static dispatch_once_t pred;
    static NSDateFormatter *sRFC3339DateFormatter = nil;
    dispatch_once(&pred, ^{
        sRFC3339DateFormatter            = [[NSDateFormatter alloc] init];
        sRFC3339DateFormatter.locale     = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        sRFC3339DateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
        sRFC3339DateFormatter.timeZone   = [NSTimeZone timeZoneForSecondsFromGMT:0];
    });
    return sRFC3339DateFormatter;
}

+ (NSDateFormatter *)dateFormatterShortDateShortTime {
    static dispatch_once_t pred;
    static NSDateFormatter *shortDateShortTimeDateFormatter = nil;
    dispatch_once(&pred, ^{
        shortDateShortTimeDateFormatter           = [[NSDateFormatter alloc] init];
        shortDateShortTimeDateFormatter.locale    = [NSLocale autoupdatingCurrentLocale];
        shortDateShortTimeDateFormatter.dateStyle = NSDateFormatterShortStyle;
        shortDateShortTimeDateFormatter.timeStyle = NSDateFormatterShortStyle;
    });
    return shortDateShortTimeDateFormatter;
}

+ (NSDateFormatter *)dateFormatterShortDateMediumTime {
    static dispatch_once_t pred;
    static NSDateFormatter *dateFormatterShortDateMediumTime = nil;
    dispatch_once(&pred, ^{
        dateFormatterShortDateMediumTime           = [[NSDateFormatter alloc] init];
        dateFormatterShortDateMediumTime.locale    = [NSLocale autoupdatingCurrentLocale];
        dateFormatterShortDateMediumTime.dateStyle = NSDateFormatterShortStyle;
        dateFormatterShortDateMediumTime.timeStyle = NSDateFormatterMediumStyle;
    });
    return dateFormatterShortDateMediumTime;
}


#pragma mark - Static NumberFormatters
+ (NSNumberFormatter *)currencyFormatter {
    static dispatch_once_t pred;
    static NSNumberFormatter *currencyStringFormatter = nil;
    dispatch_once(&pred, ^{
        currencyStringFormatter = [NSNumberFormatter new];
        [currencyStringFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [currencyStringFormatter setLocale:[NSLocale autoupdatingCurrentLocale]];
//        [currencyStringFormatter setRoundingIncrement:@(2)];
        [currencyStringFormatter setMinimumIntegerDigits:1];
        [currencyStringFormatter setMinimumFractionDigits:2];
        [currencyStringFormatter setMaximumFractionDigits:2];
    });
    return currencyStringFormatter;
}

+ (NSNumberFormatter *)btcFormatter {
    static dispatch_once_t pred;
    static NSNumberFormatter *btcFormatter = nil;
    dispatch_once(&pred, ^{
        btcFormatter = [NSNumberFormatter new];
        [btcFormatter setLocale:[NSLocale autoupdatingCurrentLocale]];
        [btcFormatter setMinimumIntegerDigits:1];
        [btcFormatter setMinimumFractionDigits:8];
        [btcFormatter setMaximumFractionDigits:8];
    });
    return btcFormatter;
}

+ (NSNumberFormatter *)fractionNumberFormatter {
    static dispatch_once_t pred;
    static NSNumberFormatter *fractionNumberFormatter = nil;
    dispatch_once(&pred, ^{
        fractionNumberFormatter = [NSNumberFormatter new];
        [fractionNumberFormatter setLocale:[NSLocale autoupdatingCurrentLocale]];
        [fractionNumberFormatter setMinimumIntegerDigits:1];
        [fractionNumberFormatter setMinimumFractionDigits:3];
        [fractionNumberFormatter setMaximumFractionDigits:3];
    });
    return fractionNumberFormatter;
}

#pragma mark - Public methods
#pragma mark | Date methods
+ (NSString *)stringDateTimeStringForRFC3339DateTimeString:(NSString *)rfc3339DateTimeString {
    // Returns a user-visible date time string that corresponds to the
    // specified RFC 3339 date time string. Note that this does not handle
    // all possible RFC 3339 date time strings, just one of the most common
    // styles.

    NSDate *date = [[SOXFormatters dateFormatterDecodeRFC3339] dateFromString:rfc3339DateTimeString];
    NSString *userVisibleDateTimeString = nil;
    
    if (date != nil) {
        userVisibleDateTimeString = [[SOXFormatters dateFormatterShortDateShortTime] stringFromDate:date];
    }
    
    return userVisibleDateTimeString;
}

+ (NSString*)rfc3339DateTimeStringDate:(NSDate *)date {
    if (!date) {
        date = [NSDate date];
    }
    
    NSString *rfc = [[SOXFormatters dateFormatterEncodeRFC3339] stringFromDate:date];
    return rfc;
}

+ (NSString *)shortDateShortTimeStringForDate:(NSDate *)date {
    if (!date) {
        return @"";
    }

    NSString *dateString = [[SOXFormatters dateFormatterShortDateShortTime] stringFromDate:date];
    return dateString;
}

+ (NSString *)shortDateMediumTimeStringForDate:(NSDate *)date {
    if (!date) {
        return @"";
    }

    NSString *dateString = [[SOXFormatters dateFormatterShortDateMediumTime] stringFromDate:date];
    return dateString;
}

#pragma mark | Currency methods
+ (NSDecimalNumber *)currencyNumberForNumber:(NSDecimalNumber *)value roundingMode:(NSNumberFormatterRoundingMode)roundingMode {
    NSNumberFormatter *currencyFormatter = [SOXFormatters currencyFormatter];
    currencyFormatter.roundingMode       = roundingMode;

    NSString *currencyString = [currencyFormatter stringFromNumber:value];
    NSNumber *currencyNumber = [currencyFormatter numberFromString:currencyString];
    
    return [NSDecimalNumber decimalNumberWithDecimal:currencyNumber.decimalValue];
}

+ (NSString *)currencyStringForNumber:(NSDecimalNumber *)value roundingMode:(NSNumberFormatterRoundingMode)roundingMode {
    NSNumberFormatter *currencyFormatter = [SOXFormatters currencyFormatter];
    currencyFormatter.roundingMode       = roundingMode;
    
    NSString *currencyString = [currencyFormatter stringFromNumber:value];
    return currencyString;
}

#pragma mark | BTC methods
+ (NSDecimalNumberHandler *)btcNumberHandler {
    static dispatch_once_t pred;
    static NSDecimalNumberHandler *btcNumberHandler = nil;
    dispatch_once(&pred, ^{
        btcNumberHandler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown
                                                                                  scale:8
                                                                       raiseOnExactness:YES
                                                                        raiseOnOverflow:YES
                                                                       raiseOnUnderflow:YES
                                                                    raiseOnDivideByZero:YES];
    });
    return btcNumberHandler;
}

+ (NSString *)stringForBTCNumber:(NSDecimalNumber *)btcValue {
    NSString *stringForBTCNumber = @"-";
    
    if (btcValue) {
        NSNumberFormatter *btcFormatter = [SOXFormatters btcFormatter];
        stringForBTCNumber = [btcFormatter stringFromNumber:btcValue];
    }
    
    return stringForBTCNumber;
}

#pragma mark | Decimal Number handling
+ (NSDecimalNumber *)greaterDecimalNumberFrom:(NSDecimalNumber *)decimalNumber1 and:(NSDecimalNumber *)decimalNumber2 {
    if ([decimalNumber1 isGreaterThanOrEqualTo:decimalNumber2]) {
        return decimalNumber1;
    }
    return decimalNumber2;
}

+ (NSDecimalNumber *)lesserDecimalNumberFrom:(NSDecimalNumber *)decimalNumber1 and:(NSDecimalNumber *)decimalNumber2 {
    if ([decimalNumber1 isLessThanOrEqualTo:decimalNumber2]) {
        return decimalNumber1;
    }
    return decimalNumber2;
}

+ (NSDecimalNumberHandler *)interestRateNumberHandler {
    static dispatch_once_t pred;
    static NSDecimalNumberHandler *interestRateNumberHandler = nil;
    dispatch_once(&pred, ^{
        interestRateNumberHandler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown
                                                                                           scale:3
                                                                                raiseOnExactness:YES
                                                                                 raiseOnOverflow:YES
                                                                                raiseOnUnderflow:YES
                                                                             raiseOnDivideByZero:YES];
    });
    return interestRateNumberHandler;
}

@end
