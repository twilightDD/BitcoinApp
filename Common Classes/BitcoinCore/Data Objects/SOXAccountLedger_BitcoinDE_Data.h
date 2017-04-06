//
//  SOXAccountLedger_BitcoinDE_Data.h
//  BitcoinApp
//
//  Created by Peter Hauke on 28.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, BitcoinDE_AccountLedgerParameter_OrderType) {
    BitcoinDE_AccountLedgerParameter_UnknownOrderType = 0
    , BitcoinDE_AccountLedgerParameter_AllOrderType
    , BitcoinDE_AccountLedgerParameter_BuyOrderType
    , BitcoinDE_AccountLedgerParameter_SellOrderType
    , BitcoinDE_AccountLedgerParameter_InpaymentOrderType
    , BitcoinDE_AccountLedgerParameter_PayoutOrderType
    , BitcoinDE_AccountLedgerParameter_AffiliateOrderType
    , BitcoinDE_AccountLedgerParameter_WelcomeBTCOrderType
    , BitcoinDE_AccountLedgerParameter_BuyYubiKeyOrderType
    , BitcoinDE_AccountLedgerParameter_BuyGoldshopOrderType
    , BitcoinDE_AccountLedgerParameter_BuyDiamondshopOrderType
    , BitcoinDE_AccountLedgerParameter_KickbackOrderType
    , BitcoinDE_AccountLedgerParameter_OutgoingFeeVoluntaryOrderType
};


@interface SOXAccountLedger_BitcoinDE_Data : NSObject

@property (strong, nonatomic, readonly) NSString *positionDetails_Date;
@property (strong, nonatomic, readonly) NSString *positionDetails_Type;
@property (strong, nonatomic, readonly) NSString *positionDetails_Reference;
@property (strong, nonatomic, readonly) NSString *positionDetails_Cashflow;
@property (strong, nonatomic, readonly) NSString *positionDetails_Balance;

@property (strong, nonatomic, readonly) NSString *tradeDetails_Trade_id;
@property (strong, nonatomic, readonly) NSString *tradeDetails_Price;
@property (strong, nonatomic, readonly) NSString *tradeDetails_BTC_before_fee;
@property (strong, nonatomic, readonly) NSString *tradeDetails_BTC_after_fee;
@property (strong, nonatomic, readonly) NSString *tradeDetails_Euro_before_fee;
@property (strong, nonatomic, readonly) NSString *tradeDetails_Euro_after_fee;

+ (NSMutableArray *)accountLedgerDataArrayForAccountLedgerDictionary:(NSDictionary *)payloadDictionary;

+ (NSDictionary *)parameterForOrderType:(BitcoinDE_AccountLedgerParameter_OrderType)orderType
                              startDate:(NSDate *)startDate
                                endDate:(NSDate *)endDate
                                   page:(NSInteger)page;

@end
