//
//  SOXFormatters.h
//  BitcoinApp
//
//  Created by Peter Hauke on 24.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOXFormatters : NSObject

#pragma mark - Number Formatters
+ (NSNumberFormatter *)bitcoinNumberFormatter;
+ (NSNumberFormatter *)bitcoinNumberWithoutCurrencySymbolFormatter;

#pragma mark - Date methods
+ (NSDate *)fidorFeeStartedAtDate;
+ (NSDate *)dateForRFC3339DateTimeString:(NSString *)rfc3339DateTimeString;
+ (NSDate *)dateAtMidnightForDate:(NSDate *)date;
+ (NSDate *)dateBeforeMidnightForDate:(NSDate *)date;
+ (NSDate *)dateQuarterBeforeMidnightForDate:(NSDate *)date;
+ (NSDate *)dateNextDayQuarterBeforeMidnightForDate:(NSDate *)date;

+ (NSDate *)dateFirstDayOfMonth:(NSNumber *)month year:(NSNumber *)year;
+ (NSDate *)dateLastDayOfMonth:(NSNumber *)month year:(NSNumber *)year;

+ (NSString *)stringDateTimeStringForRFC3339DateTimeString:(NSString *)rfc3339DateTimeString;
+ (NSString*)rfc3339GetDateTimeStringDate:(NSDate *)date;
+ (NSString*)rfc3339PostDateTimeStringDate:(NSDate *)date;
+ (NSString *)shortDateShortTimeStringForDate:(NSDate *)date;
+ (NSString *)shortDateMediumTimeStringForDate:(NSDate *)date;
+ (NSString *)shortDateLongTimeStringForDate:(NSDate *)date;

#pragma mark - Currency methods
+ (NSDecimalNumberHandler *)currencyNumberHandler;
+ (NSDecimalNumberHandler *)currencyNumberHandlerRoundDown;
+ (NSDecimalNumberHandler *)currencyNumberHandlerRoundUp;
+ (NSDecimalNumber *)currencyNumberForNumber:(NSDecimalNumber *)value roundingMode:(NSNumberFormatterRoundingMode)roundingMode;
+ (NSString *)currencyStringForNumber:(NSDecimalNumber *)value roundingMode:(NSNumberFormatterRoundingMode)roundingMode;

#pragma mark - BTC methods
+ (NSDecimalNumberHandler *)btcNumberHandler;
+ (NSString *)stringForBTCNumber:(NSDecimalNumber *)btcValue;

#pragma mark - Decimal Number handling
+ (NSDecimalNumber *)greaterDecimalNumberFrom:(NSDecimalNumber *)decimalNumber1 and:(NSDecimalNumber *)decimalNumber2;
+ (NSDecimalNumber *)lesserDecimalNumberFrom:(NSDecimalNumber *)decimalNumber1 and:(NSDecimalNumber *)decimalNumber2;

#pragma mark - Interest Rate
+ (NSDecimalNumber *)formattedInterestRate:(NSDecimalNumber *)effectivInteresRate;

@end
