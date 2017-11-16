//
//  SOXRates_BitcoinDE_Data.h
//  BitcoinApp
//
//  Created by Peter Hauke on 21.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXRatesData.h"
#import "SOXMarket_BitcoinDE_DefTypes.h"

@interface SOXBitcoinDE_Rate : NSObject
@property (strong, nonatomic, readonly) NSDecimalNumber *rate_weighted;
@property (strong, nonatomic, readonly) NSDecimalNumber *rate_weighted_3h;
@property (strong, nonatomic, readonly) NSDecimalNumber *rate_weighted_12h;
@property (strong, nonatomic, readonly) NSDecimalNumber *rate_weighted_half;
@end


@interface SOXRates_BitcoinDE_Data : SOXRatesData

+ (SOXRatesData *)rateDataForRateInfoDictionary:(NSDictionary *)payloadDictionary;

+ (NSDictionary *)parametersForCurrencyType:(BitcoinDE_CurrencyType)currencyType;


- (NSDecimalNumber *)rateWeightedForCurrencyType:(BitcoinDE_CurrencyType)currencyType;
- (NSDecimalNumber *)rateWeighted3hForCurrencyType:(BitcoinDE_CurrencyType)currencyType;
- (NSDecimalNumber *)rateWeighted12hForCurrencyType:(BitcoinDE_CurrencyType)currencyType;
- (NSDecimalNumber *)rateWeightedHalfForCurrencyType:(BitcoinDE_CurrencyType)currencyType;

@end
