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
    static NSDateFormatter *dateFormatterRFC3339 = nil;
    dispatch_once(&pred, ^{
        dateFormatterRFC3339           = [[NSDateFormatter alloc] init];
        dateFormatterRFC3339.locale    = [NSLocale autoupdatingCurrentLocale];
        dateFormatterRFC3339.dateStyle = NSDateFormatterShortStyle;
        dateFormatterRFC3339.timeStyle = NSDateFormatterShortStyle;
    });
    return dateFormatterRFC3339;
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

#pragma mark | Currency methods
+ (NSNumber *)currencyNumberForNumber:(NSNumber *)value roundingMode:(NSNumberFormatterRoundingMode)roundingMode {
    NSNumberFormatter *currencyFormatter = [SOXFormatters currencyFormatter];
    currencyFormatter.roundingMode       = roundingMode;

    NSString *currencyString = [currencyFormatter stringFromNumber:value];
    NSNumber *currencyNumber = [currencyFormatter numberFromString:currencyString];
    
    return currencyNumber;
}

+ (NSString *)currencyStringForNumber:(NSNumber *)value roundingMode:(NSNumberFormatterRoundingMode)roundingMode {
    NSNumberFormatter *currencyFormatter = [SOXFormatters currencyFormatter];
    currencyFormatter.roundingMode       = roundingMode;
    
    NSString *currencyString = [currencyFormatter stringFromNumber:value];
    return currencyString;
}

#pragma mark - Basic Math
+ (NSNumber *)divideNumber:(NSNumber *)dividend by:(NSInteger)divisor {
    if (!dividend || divisor == 0) {
        return @0;
    }
    
    NSDecimalNumber *dividendDN = [NSDecimalNumber decimalNumberWithDecimal:dividend.decimalValue];
    
    NSString *divisorString    = [NSString stringWithFormat:@"%zd", divisor];
    NSDecimalNumber *divisorDN = [NSDecimalNumber decimalNumberWithString:divisorString];
    
    NSDecimalNumber *result = [dividendDN decimalNumberByDividingBy:divisorDN];
    return result;
}

@end
