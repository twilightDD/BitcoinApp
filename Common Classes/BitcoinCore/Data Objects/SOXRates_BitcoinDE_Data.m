//
//  SOXRates_BitcoinDE_Data.m
//  BitcoinApp
//
//  Created by Peter Hauke on 21.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXRates_BitcoinDE_Data.h"

#import "SOXMarket_BitcoinDE_Core.h"

#import "SOXFormatters.h"

#import "SOXKeys_BitcoinDE.h"

#pragma mark - SOXBitcoinDE_Rate
@interface SOXBitcoinDE_Rate ()
@property (strong, nonatomic, readwrite) NSDecimalNumber *rate_weighted;
@property (strong, nonatomic, readwrite) NSDecimalNumber *rate_weighted_3h;
@property (strong, nonatomic, readwrite) NSDecimalNumber *rate_weighted_12h;
@property (strong, nonatomic, readwrite) NSDecimalNumber *rate_weighted_half;
@property (strong, nonatomic, readwrite) NSDecimalNumber *rate_weighted_double;
@end

@implementation SOXBitcoinDE_Rate
@end

#pragma mark - Interface
@interface SOXRates_BitcoinDE_Data ()

#pragma mark Properties
@property (strong, nonatomic, readwrite) NSMutableDictionary *rates;
@property (strong, nonatomic, readwrite) NSDecimalNumber *rate_weighted;
@property (strong, nonatomic, readwrite) NSDecimalNumber *rate_weighted_3h;
@property (strong, nonatomic, readwrite) NSDecimalNumber *rate_weighted_12h;
@property (strong, nonatomic, readwrite) NSDecimalNumber *rate_weighted_half;
@property (strong, nonatomic, readwrite) NSDecimalNumber *rate_weighted_double;

@end

#pragma mark - Implementation
@implementation SOXRates_BitcoinDE_Data

@synthesize rates;

#pragma mark Synthesize
@synthesize rate_weighted, rate_weighted_3h, rate_weighted_12h, rate_weighted_half, rate_weighted_double;

#pragma mark - Init & Co.
+ (SOXRatesData *)rateDataForRateInfoDictionary:(NSDictionary *)payloadDictionary {
    SOXRates_BitcoinDE_Data *rateData = [[SOXRates_BitcoinDE_Data alloc] init];
    
    [rateData setupDataForRateInfoDictionary:payloadDictionary];
    
    return rateData;
}

+ (NSDictionary *)parametersForCurrencyType:(BitcoinDE_CurrencyType)currencyType {
    NSString *tradingPairString = [SOXMarket_BitcoinDE_DefTypes tradingPairStringForCurrencyType:currencyType];
    NSDictionary *parametersForCurrencyType = [NSDictionary dictionaryWithObject:tradingPairString
                                                                          forKey:BitcoinDE_ShowOrderbook_TradingPair];

    return parametersForCurrencyType;
}

#pragma mark - Public methods
- (NSDecimalNumber *)rateWeightedForCurrencyType:(BitcoinDE_CurrencyType)currencyType {
    SOXBitcoinDE_Rate *rate = [self rateForCurrencyType:currencyType];
    NSDecimalNumber *rateWeightedForCurrencyType = rate.rate_weighted;

    return rateWeightedForCurrencyType;
}

- (NSDecimalNumber *)rateWeighted3hForCurrencyType:(BitcoinDE_CurrencyType)currencyType {
    SOXBitcoinDE_Rate *rate = [self rateForCurrencyType:currencyType];
    NSDecimalNumber *rateWeighted3hForCurrencyType = rate.rate_weighted_3h;

    return rateWeighted3hForCurrencyType;
}

- (NSDecimalNumber *)rateWeighted12hForCurrencyType:(BitcoinDE_CurrencyType)currencyType {
    SOXBitcoinDE_Rate *rate = [self rateForCurrencyType:currencyType];
    NSDecimalNumber *rateWeighted12hForCurrencyType = rate.rate_weighted_12h;

    return rateWeighted12hForCurrencyType;
}

- (NSDecimalNumber *)rateWeightedHalfForCurrencyType:(BitcoinDE_CurrencyType)currencyType {
    SOXBitcoinDE_Rate *rate = [self rateForCurrencyType:currencyType];
    NSDecimalNumber *rateWeightedHalfForCurrencyType = rate.rate_weighted_half;

    return rateWeightedHalfForCurrencyType;
}

- (NSDecimalNumber *)rateWeightedDoubleForCurrencyType:(BitcoinDE_CurrencyType)currencyType {
    SOXBitcoinDE_Rate *rate = [self rateForCurrencyType:currencyType];
    NSDecimalNumber *rateWeightedDoubleForCurrencyType = rate.rate_weighted_double;

    return rateWeightedDoubleForCurrencyType;
}

#pragma mark - Instance methods
- (void)setupDataForRateInfoDictionary:(NSDictionary *)payloadDictionary {
    // get ratesData from core (if not existing: create it)
    // Tricky thing: for each trading pair we get a separate server answer!
    SOXRates_BitcoinDE_Data *ratesData = (SOXRates_BitcoinDE_Data *)[SOXMarket_BitcoinDE_Core sharedCore].ratesData;
    if (!ratesData) {
        ratesData = [[SOXRates_BitcoinDE_Data alloc] init];
        [SOXMarket_BitcoinDE_Core sharedCore].ratesData = ratesData;
    }

    NSDictionary *ratesDictionary = [payloadDictionary objectForKey:BitcoinDE_ShowRates_MainKey];
    SOXBitcoinDE_Rate *rate = [[SOXBitcoinDE_Rate alloc] init];
    {
        // NSString to NSNumber
        rate.rate_weighted = [NSDecimalNumber decimalNumberWithString:[ratesDictionary objectForKey:BitcoinDE_ShowRates_rate_weighted]];
        rate.rate_weighted_3h = [NSDecimalNumber decimalNumberWithString:[ratesDictionary objectForKey:BitcoinDE_ShowRates_rate_weighted_3h]];
        rate.rate_weighted_12h = [NSDecimalNumber decimalNumberWithString:[ratesDictionary objectForKey:BitcoinDE_ShowRates_rate_weighted_12h]];

        NSDecimalNumber *rate_weighted_half = [rate.rate_weighted decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"2"]];
        rate.rate_weighted_half = [SOXFormatters currencyNumberForNumber:rate_weighted_half
                                                            roundingMode:NSNumberFormatterRoundUp];

        NSDecimalNumber *rate_weighted_double = [rate.rate_weighted decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"2"]];
        rate.rate_weighted_double = [SOXFormatters currencyNumberForNumber:rate_weighted_double
                                                            roundingMode:NSNumberFormatterRoundDown];
    }
    [ratesData.rates setObject:rate
                        forKey:[payloadDictionary objectForKey:BitcoinDE_ShowRates_rate_trading_pair]];
}

- (SOXBitcoinDE_Rate *)rateForCurrencyType:(BitcoinDE_CurrencyType)currencyType {
    NSString *currencyTypeString = [SOXMarket_BitcoinDE_DefTypes tradingPairStringForCurrencyType:currencyType];
    SOXRates_BitcoinDE_Data *ratesData = (SOXRates_BitcoinDE_Data *)[SOXMarket_BitcoinDE_Core sharedCore].ratesData;
    SOXBitcoinDE_Rate *rateForCurrencyType = [ratesData.rates objectForKey:currencyTypeString];

    return rateForCurrencyType;

}

@end
