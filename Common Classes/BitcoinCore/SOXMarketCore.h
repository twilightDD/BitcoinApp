//
//  SOXMarketCore.h
//  BitcoinApp
//
//  Created by Peter Hauke on 13.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOXMarketCore : NSObject
@property (strong, nonatomic, readonly) NSString *apiKey;
@property (strong, nonatomic, readonly) NSString *apiSecret;
@property (strong, nonatomic, readonly) NSString *baseURLString;

/**
 *  Singleton.
 *
 *  @return The Core.
 */
+ (instancetype)sharedCore;

@end
