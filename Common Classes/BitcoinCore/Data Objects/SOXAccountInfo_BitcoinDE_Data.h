//
//  SOXBanner_BitcoinDE_Data.h
//  BitcoinApp
//
//  Created by Peter Hauke on 14.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const BannerDataKey;

@interface SOXAccountInfo_BitcoinDE_Data : NSObject

@property (strong, nonatomic, readonly) NSString *btcBalance_totalAmount;
@property (strong, nonatomic, readonly) NSString *btcBalance_availableAmount;
@property (strong, nonatomic, readonly) NSString *btcBalance_reservedAmount;

@property (nonatomic, readonly) BOOL bankReservation_exists;
@property (strong, nonatomic, readonly) NSString *bankReservation_totalAmount;
@property (strong, nonatomic, readonly) NSString *bankReservation_availableAmount;
@property (strong, nonatomic, readonly) NSString *bankReservation_reservedAt;
@property (strong, nonatomic, readonly) NSString *bankReservation_validUntil;

@property (strong, nonatomic, readonly) NSString *bankInformation_bicShort;
@property (strong, nonatomic, readonly) NSString *bankInformation_bicFull;
@property (strong, nonatomic, readonly) NSString *bankInformation_UID;

+ (instancetype)bannerDataForAccountInfo:(NSDictionary *)accountInfoDictionary;

@end
