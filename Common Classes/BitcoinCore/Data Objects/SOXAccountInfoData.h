//
//  SOXAccountInfoData.h
//  BitcoinApp
//
//  Created by Peter Hauke on 21.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOXAccountInfoData : NSObject

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

@end
