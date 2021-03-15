//
//  NSDate+Limit.m
//  BitcoinApp
//
//  Created by Peter Hauke on 15.03.21.
//  Copyright © 2021 2sox / Peter Hauke. All rights reserved.
//

#import "NSDate+Limit.h"

#import "SOXFormatters.h"

#import "NSDate+SOXCompare.h"

@implementation NSDate (Limit)

/// Check date:
/// If date is later than now, it returns a new date "now"
/// Otherwise it returns self
- (NSDate *)limitedToNow {
    NSDate *now = [NSDate date];
    if ([self isLaterThan:now]) {
        return  now;
    }
    
    return  self;
}

- (NSDate *)limitedToYesterday {
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDate *startOfToday =  [calendar startOfDayForDate:[NSDate date]];
    NSDate *startOfSelf = [calendar startOfDayForDate:self];
    if ([startOfSelf isEqualTo:startOfToday]) {
        NSDate *limitedToYesterday = [startOfToday dateByAddingTimeInterval:-1];
        return limitedToYesterday;
    }
    
    return self;
}


@end
