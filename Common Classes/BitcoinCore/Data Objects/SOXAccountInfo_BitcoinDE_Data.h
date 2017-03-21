//
//  SOXBanner_BitcoinDE_Data.h
//  BitcoinApp
//
//  Created by Peter Hauke on 14.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXAccountInfoData.h"

FOUNDATION_EXPORT NSString *const BannerDataKey;

@interface SOXAccountInfo_BitcoinDE_Data : SOXAccountInfoData

+ (instancetype)accountInfoDataForAccountInfoDictionary:(NSDictionary *)accountInfoDictionary;

@end
