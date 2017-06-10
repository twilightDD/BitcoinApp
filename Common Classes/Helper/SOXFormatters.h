//
//  SOXFormatters.h
//  BitcoinApp
//
//  Created by Peter Hauke on 24.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOXFormatters : NSObject

#pragma mark - Date methods
+ (NSString *)stringDateTimeStringForRFC3339DateTimeString:(NSString *)rfc3339DateTimeString;
+ (NSString *)rfc3339DateTimeStringDate:(NSDate *)date;
+ (NSString *)shortDateShortTimeStringForDate:(NSDate *)date;
+ (NSString *)shortDateMediumTimeStringForDate:(NSDate *)date;

#pragma mark - Currency methods
+ (NSDecimalNumber *)currencyNumberForNumber:(NSDecimalNumber *)value roundingMode:(NSNumberFormatterRoundingMode)roundingMode;
+ (NSString *)currencyStringForNumber:(NSDecimalNumber *)value roundingMode:(NSNumberFormatterRoundingMode)roundingMode;

#pragma mark - BTC methods
+ (NSDecimalNumberHandler *)btcNumberHandler;
+ (NSString *)stringForBTCNumber:(NSDecimalNumber *)btcValue;

#pragma mark - Decimal Number handling
+ (NSDecimalNumber *)greaterDecimalNumberFrom:(NSDecimalNumber *)decimalNumber1 and:(NSDecimalNumber *)decimalNumber2;
+ (NSDecimalNumber *)lesserDecimalNumberFrom:(NSDecimalNumber *)decimalNumber1 and:(NSDecimalNumber *)decimalNumber2;

+ (NSDecimalNumberHandler *)interestRateNumberHandler;
@end
