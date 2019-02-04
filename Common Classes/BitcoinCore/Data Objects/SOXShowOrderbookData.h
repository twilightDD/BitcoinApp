//
//  SOXShowOrderbookData.h
//  BitcoinApp
//
//  Created by Peter Hauke on 21.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOXShowOrderbookData : NSObject

#pragma mark Properties
#pragma mark | Order information
@property (strong, nonatomic, readonly) NSString *orderInformation_orderID;
@property (strong, nonatomic, readonly) NSString *orderInformation_socketOrderObjectID;
@property (strong, nonatomic, readonly) NSString *orderInformation_type;
@property (strong, nonatomic, readonly) NSString *orderInformation_tradingPair;
@property (strong, nonatomic, readonly) NSDecimalNumber *orderInformation_maxAmount;
@property (strong, nonatomic, readonly) NSDecimalNumber *orderInformation_minAmount;
@property (strong, nonatomic, readonly) NSDecimalNumber *orderInformation_price;
@property (strong, nonatomic, readonly) NSDecimalNumber *orderInformation_maxVolume;
@property (strong, nonatomic, readonly) NSDecimalNumber *orderInformation_minVolume;
@property (nonatomic, readonly) BOOL orderInformation_orderRequirementsFullfilled;

#pragma mark | Trading Partner Information
@property (strong, nonatomic, readonly) NSString *tradingPartnerInformation_username;
@property (nonatomic, readonly) BOOL tradingPartnerInformation_isKYCFull;
@property (strong, nonatomic, readonly) NSString *tradingPartnerInformation_trustLevel;
@property (strong, nonatomic, readonly) NSString *tradingPartnerInformation_bankName;
@property (strong, nonatomic, readonly) NSString *tradingPartnerInformation_bic;
@property (strong, nonatomic, readonly) NSNumber *tradingPartnerInformation_rating;
@property (strong, nonatomic, readonly) NSNumber *tradingPartnerInformation_amountTrades;
@property (strong, nonatomic, readonly) NSString *tradingPartnerInformation_seatOfBank;

#pragma mark | Order Requirements
@property (strong, nonatomic, readonly) NSString *orderRequirements_minTrustLevel;
@property (nonatomic, readonly) BOOL orderRequirements_onlyKYCFull;
@property (strong, nonatomic, readonly) NSArray *orderRequirements_seatOfBank;
@property (strong, nonatomic, readonly) NSNumber *orderRequirements_paymentOption;


@end
