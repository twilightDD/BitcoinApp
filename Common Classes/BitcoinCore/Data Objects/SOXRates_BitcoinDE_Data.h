//
//  SOXRates_BitcoinDE_Data.h
//  BitcoinApp
//
//  Created by Peter Hauke on 21.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXRatesData.h"

@interface SOXRates_BitcoinDE_Data : SOXRatesData

+ (SOXRatesData *)rateDataForRateInfoDictionary:(NSDictionary *)payloadDictionary;

@end
