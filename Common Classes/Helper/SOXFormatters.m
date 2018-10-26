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
        sRFC3339DateFormatter.timeZone   = [NSTimeZone localTimeZone];//[NSTimeZone timeZoneForSecondsFromGMT:0];
    });
    return sRFC3339DateFormatter;
}

+ (NSDateFormatter *)dateFormatterEncodeGetRFC3339 {
    static dispatch_once_t pred;
    static NSDateFormatter *sRFC3339DateFormatter = nil;
    dispatch_once(&pred, ^{
        sRFC3339DateFormatter            = [[NSDateFormatter alloc] init];
        sRFC3339DateFormatter.locale     = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        sRFC3339DateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
        sRFC3339DateFormatter.timeZone   = [NSTimeZone timeZoneForSecondsFromGMT:0]; // Get Z-Format
    });

    return sRFC3339DateFormatter;
}

+ (NSDateFormatter *)dateFormatterEncodePostRFC3339 {
    static dispatch_once_t pred;
    static NSDateFormatter *sRFC3339DateFormatter = nil;
    dispatch_once(&pred, ^{
        sRFC3339DateFormatter            = [[NSDateFormatter alloc] init];
        sRFC3339DateFormatter.locale     = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        sRFC3339DateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
    });

    return sRFC3339DateFormatter;

}
+ (NSDateFormatter *)dateFormatterEncodeRFC3339 {
    /*
     Format gemäß RFC 3339 (Bsp: 2015-01-20T15:00:00+02:00).
     */

    // 2018-09-17T23:45:00+02:00
    static dispatch_once_t pred;
    static NSDateFormatter *sRFC3339DateFormatter = nil;
    dispatch_once(&pred, ^{

        sRFC3339DateFormatter            = [[NSDateFormatter alloc] init];

        sRFC3339DateFormatter.locale     = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        sRFC3339DateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
//        sRFC3339DateFormatter.timeZone   = [NSTimeZone localTimeZone]; // Post 00:00 Format
        sRFC3339DateFormatter.timeZone   = [NSTimeZone timeZoneForSecondsFromGMT:0]; // Get Z-Format

    });

    /* Result: 2018-09-17T21:45:00Z
    dispatch_once(&pred, ^{
        sRFC3339DateFormatter            = [[NSDateFormatter alloc] init];
        sRFC3339DateFormatter.locale     = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        sRFC3339DateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
        sRFC3339DateFormatter.timeZone   = [NSTimeZone timeZoneForSecondsFromGMT:0];
    });
    */

    /* Result: 2018-09-17T23:45:00GMT+02:00
     sRFC3339DateFormatter            = [[NSDateFormatter alloc] init];
     //        sRFC3339DateFormatter.locale     = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
     sRFC3339DateFormatter.locale     = [NSLocale autoupdatingCurrentLocale];
     sRFC3339DateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZZZZZZZZZZZZZ";
     sRFC3339DateFormatter.timeZone   = [NSTimeZone timeZoneForSecondsFromGMT:7200];

     */


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
+ (NSDateFormatter *)dateFormatterShortDateLongTime {
    static dispatch_once_t pred;
    static NSDateFormatter *dateFormatterShortDateLongTime = nil;
    dispatch_once(&pred, ^{
        dateFormatterShortDateLongTime = [[NSDateFormatter alloc] init];
        [dateFormatterShortDateLongTime setDateFormat:@"dd.MM.yy HH:mm:ss:SSS"];
    });
    return dateFormatterShortDateLongTime;
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

+ (NSNumberFormatter *)bitcoinNumberFormatter {
    static dispatch_once_t pred;
    static NSNumberFormatter *btcFormatter = nil;
    dispatch_once(&pred, ^{
        btcFormatter = [NSNumberFormatter new];

        btcFormatter.minimumIntegerDigits = 1;
        btcFormatter.minimumFractionDigits = 2;
        btcFormatter.maximumFractionDigits = 8;

        btcFormatter.locale= [NSLocale autoupdatingCurrentLocale];
//        btcFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
//        btcFormatter.currencySymbol = @"\u20BF";
//        btcFormatter.currencyCode = @"\u20BF";
//        btcFormatter.internationalCurrencySymbol = @"XBT";
    });
    return btcFormatter;
}

+ (NSNumberFormatter *)bitcoinNumberWithoutCurrencySymbolFormatter {
    static dispatch_once_t pred;
    static NSNumberFormatter *btcFormatter = nil;
    dispatch_once(&pred, ^{
        btcFormatter = [NSNumberFormatter new];

        btcFormatter.minimumIntegerDigits = 1;
        btcFormatter.minimumFractionDigits = 8;
        btcFormatter.maximumFractionDigits = 8;

        btcFormatter.locale= [NSLocale autoupdatingCurrentLocale];
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

#pragma mark - Public methods
#pragma mark | Date methods
+ (NSDate *)dateForRFC3339DateTimeString:(NSString *)rfc3339DateTimeString {
    NSDate *date = [[SOXFormatters dateFormatterDecodeRFC3339] dateFromString:rfc3339DateTimeString];
    return date;
}

+ (NSDate *)dateAtMidnightForDate:(NSDate *)date {
    NSDateComponents *dateComponents = [self dateComponentsDayMonthYearFromDate:date];
    dateComponents.hour = 0;
    dateComponents.minute = 0;
    dateComponents.second = 0;

    NSDate *dateAtMidnightForDate = [self dateGregorianFromDateComponents:dateComponents];
    return dateAtMidnightForDate;
}

+ (NSDate *)dateBeforeMidnightForDate:(NSDate *)date {
    NSDateComponents *dateComponents = [self dateComponentsDayMonthYearFromDate:date];

    dateComponents.hour = 23;
    dateComponents.minute = 59;
    dateComponents.second = 59;

    NSDate *dateBeforeMidnight = [self dateGregorianFromDateComponents:dateComponents];
    return dateBeforeMidnight;
}

+ (NSDate *)dateQuarterBeforeMidnightForDate:(NSDate *)date {
    NSDateComponents *dateComponents = [self dateComponentsDayMonthYearFromDate:date];

    dateComponents.hour = 23;
    dateComponents.minute = 45;
    dateComponents.second = 00;

    NSDate *dateBeforeMidnight = [self dateFromDateComponents:dateComponents];
    return dateBeforeMidnight;
}

+ (NSDate *)dateNextDayQuarterBeforeMidnightForDate:(NSDate *)date {
    NSDateComponents *dateComponents = [self dateComponentsDayMonthYearFromDate:date];
    dateComponents.day = dateComponents.day + 1;
    dateComponents.hour = 23;
    dateComponents.minute = 45;
    dateComponents.second = 00;

    NSDate *dateBeforeMidnight = [self dateFromDateComponents:dateComponents];
    return dateBeforeMidnight;
}

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

+ (NSString*)rfc3339GetDateTimeStringDate:(NSDate *)date {
    if (!date) {
        date = [NSDate date];
    }

    NSString *rfc = [[SOXFormatters dateFormatterEncodeGetRFC3339] stringFromDate:date];
    return rfc;
}
+ (NSString*)rfc3339PostDateTimeStringDate:(NSDate *)date {
    if (!date) {
        date = [NSDate date];
    }

    NSString *rfc = [[SOXFormatters dateFormatterEncodePostRFC3339] stringFromDate:date];
    return rfc;
}

+ (NSString*)rfc3339DateTimeStringDate:(NSDate *)date {
    if (!date) {
        date = [NSDate date];
    }
    
    NSString *rfc = [[SOXFormatters dateFormatterEncodeRFC3339] stringFromDate:date];
    return rfc;
}

+ (NSString*)rfc3339DateTimeStringDate:(NSDate *)date addHours:(NSInteger)hoursToAdd {
    if (!date) {
        date = [NSDate date];
    }
    NSDate *dateByAddedHours = [self dateFromDate:date byAddingHours:hoursToAdd];
    NSString *rfc = [[SOXFormatters dateFormatterEncodeRFC3339] stringFromDate:dateByAddedHours];
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

+ (NSString *)shortDateLongTimeStringForDate:(NSDate *)date {
    if (!date) {
        return @"";
    }

    NSString *dateString = [[SOXFormatters dateFormatterShortDateLongTime] stringFromDate:date];
    return dateString;
}

#pragma mark | Currency methods
+ (NSDecimalNumberHandler *)currencyNumberHandler {
    static dispatch_once_t pred;
    static NSDecimalNumberHandler *currencyNumberHandler = nil;
    dispatch_once(&pred, ^{
        currencyNumberHandler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                                                                       scale:2
                                                                            raiseOnExactness:YES
                                                                             raiseOnOverflow:YES
                                                                            raiseOnUnderflow:YES
                                                                         raiseOnDivideByZero:YES];
    });
    return currencyNumberHandler;
}

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
        btcNumberHandler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                                                                  scale:8
                                                                       raiseOnExactness:YES
                                                                        raiseOnOverflow:YES
                                                                       raiseOnUnderflow:YES
                                                                    raiseOnDivideByZero:YES];
    });
    return btcNumberHandler;
}

+ (NSString *)stringForBTCNumber:(NSDecimalNumber *)btcValue {
    NSString *stringForBTCNumber = @"0";
    
    if (btcValue) {
        NSNumberFormatter *btcFormatter = [SOXFormatters bitcoinNumberFormatter];
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

#pragma mark - Interest Rate
+ (NSDecimalNumber *)formattedInterestRate:(NSDecimalNumber *)effectiveInterestRate {
    effectiveInterestRate = [[NSDecimalNumber one] decimalNumberBySubtracting:effectiveInterestRate];
    NSDecimalNumber *formattedInterestRate = [effectiveInterestRate decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"100"]
                                                                                    withBehavior:[SOXFormatters interestRateNumberHandler]];
    return formattedInterestRate;
}

#pragma mark - Private class methods
+ (NSDateComponents *)dateComponentsDayMonthYearFromDate:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *inputDateComponents = [calendar components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear)
                                                        fromDate:date];

    NSDateComponents *dateComponentsDayMonthYear = [[NSDateComponents alloc] init];
    //set date components
    dateComponentsDayMonthYear.day   = inputDateComponents.day;
    dateComponentsDayMonthYear.month = inputDateComponents.month;
    dateComponentsDayMonthYear.year  = inputDateComponents.year;

    return dateComponentsDayMonthYear;
}

+ (NSDate *)dateFromDateComponents:(NSDateComponents *)dateComponents {
    NSCalendar *currentCalendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDate *dateFromDateComponents = [currentCalendar dateFromComponents:dateComponents];

    return dateFromDateComponents;
}

+ (NSDate *)dateGregorianFromDateComponents:(NSDateComponents *)dateComponents {
    /* Warum gregorianischer Kalender?
     damit aus dem Eingangswert 10.9.2018 23:59:59
     ein Date 2018-09-10 23:59:59 +0000 wird
     und nicht 2018-09-10 21:59:59 +0200 (bei currentLocale)
     */
    NSCalendar *gregorianCalendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDate *dateGregorian = [gregorianCalendar dateFromComponents:dateComponents];

    return dateGregorian;
}

#warning HACK!
+ (NSDate *)dateFromDate:(NSDate *)date
           byAddingHours:(NSInteger )hoursToAdd {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *inputDateComponents = [calendar components:(NSCalendarUnitDay
                                                                  | NSCalendarUnitMonth
                                                                  | NSCalendarUnitYear
                                                                  | NSCalendarUnitHour
                                                                  | NSCalendarUnitMinute
                                                                  | NSCalendarUnitSecond)
                                                        fromDate:date];
    inputDateComponents.hour = inputDateComponents.hour + hoursToAdd;

    NSDate *dateFromDate = [self dateGregorianFromDateComponents:inputDateComponents];
    
    return dateFromDate;
}

@end
