//
//  SOXBanner_BitcoinDE_Data.h
//  BitcoinApp
//
//  Created by Peter Hauke on 14.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXAccountInfoData.h"

FOUNDATION_EXPORT NSString *const BannerDataKey;

@interface SOXBitcoinDE_Balance : NSObject
@property (strong, nonatomic, readonly) NSDecimalNumber *totalAmount;
@property (strong, nonatomic, readonly) NSDecimalNumber *availableAmount;
@property (strong, nonatomic, readonly) NSDecimalNumber *reservedAmount;
@end

@interface SOXBitcoinDE_Allocation : NSObject
@property (strong, nonatomic, readonly) NSDecimalNumber *allocation_percent;
@property (strong, nonatomic, readonly) NSDecimalNumber *allocation_max_eur_volume;
@property (strong, nonatomic, readonly) NSDecimalNumber *allocation_eur_volume_open_orders;
@end


@interface SOXAccountInfo_BitcoinDE_Data : SOXAccountInfoData

+ (instancetype)accountInfoDataForAccountInfoDictionary:(NSDictionary *)accountInfoDictionary;

@end
