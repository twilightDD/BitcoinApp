//
//  SOXRates_BitcoinDE_Data.m
//  BitcoinApp
//
//  Created by Peter Hauke on 21.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXRates_BitcoinDE_Data.h"

#import "SOXKeys_BitcoinDE.h"

#pragma mark - Interface
@interface SOXRates_BitcoinDE_Data ()

#pragma mark Properties
@property (strong, nonatomic, readwrite) NSString *rate_weighted;
@property (strong, nonatomic, readwrite) NSString *rate_weighted_3h;
@property (strong, nonatomic, readwrite) NSString *rate_weighted_12h;

@end

@implementation SOXRates_BitcoinDE_Data

@dynamic rate_weighted, rate_weighted_3h, rate_weighted_12h;

+ (SOXRatesData *)rateDataForRateInfoDictionary:(NSDictionary *)payloadDictionary {
    SOXRates_BitcoinDE_Data *rateData = [[SOXRates_BitcoinDE_Data alloc] init];
    
    [rateData setupDataForRateInfoDictionary:payloadDictionary];
    
    return rateData;
}

- (void)setupDataForRateInfoDictionary:(NSDictionary *)payloadDictionary {
    NSDictionary *ratesDictionary = [payloadDictionary objectForKey:BitcoinDE_ShowRates_MainKey];
    
    self.rate_weighted = [ratesDictionary objectForKey:BitcoinDE_ShowRates_rate_weighted];
    self.rate_weighted_3h = [ratesDictionary objectForKey:BitcoinDE_ShowRates_rate_weighted_3h];
    self.rate_weighted_12h = [ratesDictionary objectForKey:BitcoinDE_ShowRates_rate_weighted_12h];
}

@end
