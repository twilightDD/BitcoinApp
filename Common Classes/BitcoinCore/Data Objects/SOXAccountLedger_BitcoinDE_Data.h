//
//  SOXAccountLedger_BitcoinDE_Data.h
//  BitcoinApp
//
//  Created by Peter Hauke on 28.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXAbstractData.h"

#import "SOXMarket_DefTypes.h"
#import "SOXMarket_BitcoinDE_DefTypes.h"

typedef NS_ENUM(NSUInteger, BitcoinDE_AccountLedgerParameter_OrderType) {
    BitcoinDE_AccountLedgerParameter_UnknownOrderType = 0,
    BitcoinDE_AccountLedgerParameter_AllOrderType,
    BitcoinDE_AccountLedgerParameter_BuyOrderType,
    BitcoinDE_AccountLedgerParameter_SellOrderType,
    BitcoinDE_AccountLedgerParameter_InpaymentOrderType,
    BitcoinDE_AccountLedgerParameter_PayoutOrderType,
    BitcoinDE_AccountLedgerParameter_AffiliateOrderType,
    BitcoinDE_AccountLedgerParameter_WelcomeBTCOrderType,
    BitcoinDE_AccountLedgerParameter_BuyYubiKeyOrderType,
    BitcoinDE_AccountLedgerParameter_BuyGoldshopOrderType,
    BitcoinDE_AccountLedgerParameter_BuyDiamondshopOrderType,
    BitcoinDE_AccountLedgerParameter_KickbackOrderType,
    BitcoinDE_AccountLedgerParameter_OutgoingFeeVoluntaryOrderType,
    BitcoinDE_AccountLedgerParameter_EndOfType
};


@interface SOXAccountLedger_BitcoinDE_Data : SOXAbstractData

@property (strong, nonatomic, readonly) NSDate *positionDetails_Date;                // Datum
@property (strong, nonatomic, readonly) NSString *positionDetails_Type;              // NSNumber
@property (strong, nonatomic, readonly) NSString *positionDetails_Reference;         // NSString
@property (strong, nonatomic, readonly) NSDecimalNumber *positionDetails_Cashflow;   // NSNumber
@property (strong, nonatomic, readonly) NSDecimalNumber *positionDetails_Balance;    // Number

@property (strong, nonatomic, readonly) NSString *tradeDetails_Trade_id;                 // string
@property (strong, nonatomic, readonly) NSDecimalNumber *tradeDetails_Price;             // number
@property (strong, nonatomic, readonly) NSDecimalNumber *tradeDetails_BTC_before_fee;    // number
@property (strong, nonatomic, readonly) NSDecimalNumber *tradeDetails_BTC_after_fee;     // number
@property (strong, nonatomic, readonly) NSDecimalNumber *tradeDetails_Euro_before_fee;   // number
@property (strong, nonatomic, readonly) NSDecimalNumber *tradeDetails_Euro_after_fee;    // number
@property (strong, nonatomic, readonly) NSString *tradeDetails_trading_pair;             // string

+ (NSMutableArray *)accountLedgerDataArrayForAccountLedgerDictionary:(NSDictionary *)payloadDictionary
                                                     forCurrencyType:(BitcoinDE_CurrencyType)currencyType;

+ (NSDictionary *)parameterForOrderType:(BitcoinDE_AccountLedgerParameter_OrderType)orderType
                        forCurrencyType:(BitcoinDE_CurrencyType)currencyType
                              startDate:(NSDate *)startDate
                                endDate:(NSDate *)endDate
                                   page:(NSInteger)page;


+ (NSString *)titleForAccountLedgerOrderType:(BitcoinDE_AccountLedgerParameter_OrderType)orderType;
@end
