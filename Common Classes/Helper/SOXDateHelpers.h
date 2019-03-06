//
//  SOXDateHelpers.h
//  BitcoinApp
//
//  Created by Peter Hauke on 06.03.19.
//  Copyright © 2019 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SOXDateRangeType) {
    SOXDateRangeTypeAll,
    SOXDateRangeTypeThisMonth,
    SOXDateRangeTypeLastMonth,
    SOXDateRangeTypeThisYear,
    SOXDateRangeTypeLastYear,
    SOXDateRangeTypeEndOfType
};

@interface SOXDateHelpers : NSObject

+ (NSArray <NSString *> *)convenientDateRangeTitles;

+ (NSDate *)startDateForDateRange:(SOXDateRangeType)dateRange;
+ (NSDate *)endDateForDateRange:(SOXDateRangeType)dateRange;

@end

NS_ASSUME_NONNULL_END
