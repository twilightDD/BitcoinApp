//
//  SOXDateHelpers.m
//  BitcoinApp
//
//  Created by Peter Hauke on 06.03.19.
//  Copyright © 2019 2sox / Peter Hauke. All rights reserved.
//

#import "SOXDateHelpers.h"

#import "SOXFormatters.h"

#pragma mark - Implementation
@implementation SOXDateHelpers

#pragma mark - Public Class Methods
+ (NSArray<NSString *> *)convenientDateRangeTitles {
    NSMutableArray<NSString *> *convenientDateRangeMenuItems = [NSMutableArray array];
    for (SOXDateRangeType dateRange = 0; dateRange < SOXDateRangeTypeEndOfType; dateRange++) {
        [convenientDateRangeMenuItems addObject:[SOXDateHelpers titleForDateRange:dateRange]];
    }

    return [convenientDateRangeMenuItems copy];
}

+ (NSDate *)startDateForDateRange:(SOXDateRangeType)dateRange {
    NSDate *startDate = [NSDate date];

    switch (dateRange) {
        case SOXDateRangeTypeAll:
            startDate = [SOXDateHelpers dateFirstDate];
            break;
        case SOXDateRangeTypeThisMonth:
            startDate = [SOXDateHelpers dateFirstDayOfThisMonth];
            break;
        case SOXDateRangeTypeLastMonth:
            startDate = [SOXDateHelpers dateFirstDayOfLastMonth];
            break;
        case SOXDateRangeTypeThisYear:
            startDate = [SOXDateHelpers dateFirstDayOfThisYear];
            break;
        case SOXDateRangeTypeLastYear:
            startDate = [SOXDateHelpers dateFirstDayOfLastYear];
            break;
        default:
            break;
    }

    return startDate;
}

+ (NSDate *)endDateForDateRange:(SOXDateRangeType)dateRange {
    NSDate *endDate = [NSDate date];

    switch (dateRange) {
        case SOXDateRangeTypeAll:
            endDate = [SOXDateHelpers dateLastDate];
            break;
        case SOXDateRangeTypeThisMonth:
            endDate = [SOXDateHelpers dateLastDate];
            break;
        case SOXDateRangeTypeLastMonth:
            endDate = [SOXDateHelpers dateLastDayWithinLastMonth];
            break;
        case SOXDateRangeTypeThisYear:
            endDate = [SOXDateHelpers dateLastDate];
            break;
        case SOXDateRangeTypeLastYear:
            endDate = [SOXDateHelpers dateLastDayWithinLastYear];
            break;
        default:
            break;
    }

    return endDate;
}

#pragma mark - Private Class Methods
+ (NSString *)titleForDateRange:(SOXDateRangeType)dateRangeType {
    static NSDictionary *titleForDateRanges;

    static dispatch_once_t pred;

    dispatch_once(&pred, ^{
        titleForDateRanges = @{
            @(-1): @"empty",
            @(SOXDateRangeTypeAll): @"All",
            @(SOXDateRangeTypeThisMonth): @"This Month",
            @(SOXDateRangeTypeLastMonth): @"Last Month",
            @(SOXDateRangeTypeThisYear): @"This Year",
            @(SOXDateRangeTypeLastYear): @"Last Year",
        };
    });

    NSString *titleForDateRange = [titleForDateRanges objectForKey:@(dateRangeType)];
    return titleForDateRange;
}

+ (NSDate *)dateFirstDate {
    NSDate *date = [SOXFormatters dateFirstDayOfMonth:@1 year:@2000];
    return date;
}

+ (NSDate *)dateLastDate {
    NSDate *date = [SOXFormatters dateBeforeMidnightForDate:[NSDate date]];
    return date;
}

+ (NSDate *)dateFirstDayOfThisMonth {
    NSDate *date = [SOXFormatters dateFirstDayOfMonth:[SOXFormatters currentMonth]
                                                 year:[SOXFormatters currentYear]];
    return date;
}

//+ (NSDate *)dateLastDayWithinThisMonth {
//    NSDate *date = [SOXFormatters dateLastDayWithinMonth:[SOXFormatters currentMonth]
//                                                    year:[SOXFormatters currentYear]];
//    return date;
//}

+ (NSDate *)dateFirstDayOfLastMonth {
    NSNumber *month = [SOXFormatters currentMonth];
    NSNumber *year  = [SOXFormatters currentYear];
    if (month.integerValue == 1) {
        month = @12;
        year  = @(year.integerValue - 1);
    }
    else {
        month = @(month.integerValue - 1);
    }

    NSDate *date = [SOXFormatters dateFirstDayOfMonth:month
                                                 year:year];
    return date;
}

+ (NSDate *)dateLastDayWithinLastMonth {
    NSNumber *month = [SOXFormatters currentMonth];
    NSNumber *year  = [SOXFormatters currentYear];
    if (month.integerValue == 1) {
        month = @12;
        year  = @(year.integerValue - 1);
    }
    else {
        month = @(month.integerValue - 1);
    }

    NSDate *date = [SOXFormatters dateLastDayWithinMonth:month
                                                    year:year];
    return date;
}

+ (NSDate *)dateFirstDayOfThisYear {
    NSDate *date = [SOXFormatters dateFirstDayOfMonth:@1
                                                 year:[SOXFormatters currentYear]];
    return date;
}

//+ (NSDate *)dateLastDayWithinThisYear {
//    NSDate *date = [SOXFormatters ];
//    return date;
//}

+ (NSDate *)dateFirstDayOfLastYear {
    NSNumber *lastYear = @([SOXFormatters currentYear].integerValue - 1);
    NSDate *date       = [SOXFormatters dateFirstDayOfMonth:@1
                                                 year:lastYear];
    return date;
}

+ (NSDate *)dateLastDayWithinLastYear {
    NSNumber *lastYear = @([SOXFormatters currentYear].integerValue - 1);
    NSDate *date       = [SOXFormatters dateLastDayWithinMonth:@12
                                                    year:lastYear];
    return date;
}


@end
