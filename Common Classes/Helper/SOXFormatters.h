//
//  SOXFormatters.h
//  BitcoinApp
//
//  Created by Peter Hauke on 24.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOXFormatters : NSObject

+ (NSString *)stringDateTimeStringForRFC3339DateTimeString:(NSString *)rfc3339DateTimeString;
+ (NSString *)rfc3339DateTimeStringDate:(NSDate *)date;

+ (NSNumber *)currencyStringForNumber:(NSNumber *)value roundingMode:(NSNumberFormatterRoundingMode)roundingMode;

@end
