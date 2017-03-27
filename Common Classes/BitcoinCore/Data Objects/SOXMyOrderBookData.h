//
//  SOXMyOrderBookData.h
//  BitcoinApp
//
//  Created by Peter Hauke on 27.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOXMyOrderBookData : NSObject

#pragma mark Properties
#pragma mark | Order Details
@property (strong, nonatomic, readonly) NSString *orderInformation_orderID;
@property (strong, nonatomic, readonly) NSString *orderInformation_type;
@property (strong, nonatomic, readonly) NSNumber *orderInformation_maxAmount;
@property (strong, nonatomic, readonly) NSNumber *orderInformation_minAmount;
@property (strong, nonatomic, readonly) NSNumber *orderInformation_price;
@property (strong, nonatomic, readonly) NSNumber *orderInformation_maxVolume;
@property (strong, nonatomic, readonly) NSNumber *orderInformation_minVolume;
@property (strong, nonatomic, readonly) NSString *orderInformation_createdAt;
@property (strong, nonatomic, readonly) NSString *orderInformation_endDateTime;
@property (nonatomic, readonly)         BOOL     orderInformation_newOrderForRemainingAmount;
@property (strong, nonatomic, readonly) NSNumber *orderInformation_state;

#pragma mark | Order Requirements
@property (strong, nonatomic, readonly) NSString *orderRequirements_minTrustLevel;
@property (nonatomic, readonly)         BOOL     orderRequirements_onlyKYCFull;
@property (strong, nonatomic, readonly) NSString *orderRequirements_paymentOption;
@property (strong, nonatomic, readonly) NSArray  *orderRequirements_seatOfBank;

#pragma mark | Page information
@property (strong, nonatomic, readonly) NSNumber *page_current;
@property (strong, nonatomic, readonly) NSNumber *page_last;

@end
