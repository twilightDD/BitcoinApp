//
//  SOXRatesData.h
//  BitcoinApp
//
//  Created by Peter Hauke on 21.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOXRatesData : NSObject

@property (strong, nonatomic, readonly) NSString *rate_weighted;
@property (strong, nonatomic, readonly) NSString *rate_weighted_3h;
@property (strong, nonatomic, readonly) NSString *rate_weighted_12h;

@end
