//
//  SOXDateFormatter.m
//  BitcoinApp
//
//  Created by Peter Hauke on 24.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXDateFormatter.h"

@implementation SOXDateFormatter
/*
 https://developer.apple.com/library/content/qa/qa1480/_index.html
 http://stackoverflow.com/questions/24873069/nsdateformatter-format-string-for-rfc-3339-date-string-without-milliseconds
 */

#pragma mark - Static Formatters
+ (NSDateFormatter *)dateFormatterRFC3339 {
    static dispatch_once_t pred;
    static NSDateFormatter *sRFC3339DateFormatter = nil;
    dispatch_once(&pred, ^{
        sRFC3339DateFormatter            = [[NSDateFormatter alloc] init];
        sRFC3339DateFormatter.locale     = [NSLocale autoupdatingCurrentLocale];
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

#pragma mark - Public methods
+ (NSString *)stringDateTimeStringForRFC3339DateTimeString:(NSString *)rfc3339DateTimeString {
    // Returns a user-visible date time string that corresponds to the
    // specified RFC 3339 date time string. Note that this does not handle
    // all possible RFC 3339 date time strings, just one of the most common
    // styles.

    NSDate *date = [[SOXDateFormatter dateFormatterRFC3339] dateFromString:rfc3339DateTimeString];
    NSString *userVisibleDateTimeString = nil;
    
    if (date != nil) {
        userVisibleDateTimeString = [[SOXDateFormatter dateFormatterShortDateShortTime] stringFromDate:date];
    }
    
    return userVisibleDateTimeString;
}

@end
