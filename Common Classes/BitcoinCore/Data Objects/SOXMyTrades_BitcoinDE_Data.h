//
//  SOXMyTrades_BitcoinDE_Data.h
//  BitcoinApp
//
//  Created by Peter Hauke on 03.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOXMarket_BitcoinDE_DefTypes.h"

typedef NS_ENUM (NSUInteger, BitcoinDE_MyTradeHistoryParameter_OrderType) {
    BitcoinDE_MyTradeHistoryParameter_UnknownOrderType = 0
    , BitcoinDE_MyTradeHistoryParameter_AllOrderType
    , BitcoinDE_MyTradeHistoryParameter_BuyOrderType
    , BitcoinDE_MyTradeHistoryParameter_SellOrderType
    , BitcoinDE_MyTradeHistoryParameter_EndOfOrderType
};

typedef NS_ENUM (NSUInteger, BitcoinDE_MyTradeHistoryParameter_TradeStateType) {
    BitcoinDE_MyTradeHistoryParameter_UnknownTradeStateType       = 0
    , BitcoinDE_MyTradeHistoryParameter_SuccessfulTradeStateType
    , BitcoinDE_MyTradeHistoryParameter_PendingTradeStateType
    , BitcoinDE_MyTradeHistoryParameter_CancelledTradeStateType
    , BitcoinDE_MyTradeHistoryParameter_EndOfTradeStateType
};


@interface SOXMyTrades_BitcoinDE_Data : NSObject

@property (strong, nonatomic, readonly) NSString *tradeID;
@property (strong, nonatomic, readonly) NSString *type;
@property (strong, nonatomic, readonly) NSDecimalNumber *amount;
@property (strong, nonatomic, readonly) NSDecimalNumber *price;
@property (strong, nonatomic, readonly) NSDecimalNumber *volume;
@property (strong, nonatomic, readonly) NSDecimalNumber *feeEur;
@property (strong, nonatomic, readonly) NSDecimalNumber *feeBTC;
@property (strong, nonatomic, readonly) NSString *aNewOrderIDForRemainingAmount;
@property (strong, nonatomic, readonly) NSNumber *state;
@property (strong, nonatomic, readonly) NSString *myRatingForTradingPartner;
@property (strong, nonatomic, readonly) NSString *createdAt;
@property (strong, nonatomic, readonly) NSDate *successfullyFinishedAt;
@property (strong, nonatomic, readonly) NSString *cancelledAt;
@property (strong, nonatomic, readonly) NSNumber *paymentMethod;
@property (strong, nonatomic, readonly) NSString *trading_pair;

@property (strong, nonatomic, readonly) NSString *tradingPartnerInfo_Username;
@property (nonatomic, readonly)         BOOL tradingPartnerInfo_IsKYCFull;
@property (strong, nonatomic, readonly) NSString *tradingPartnerInfo_TrustLevel;
@property (strong, nonatomic, readonly) NSString *tradingPartnerInfo_BankName;
@property (strong, nonatomic, readonly) NSString *tradingPartnerInfo_BIC;
@property (strong, nonatomic, readonly) NSString *tradingPartnerInfo_SeatOfBank;
@property (strong, nonatomic, readonly) NSNumber *tradingPartnerInfo_amountTrades;
@property (strong, nonatomic, readonly) NSNumber *tradingPartnerInfo_Rating;


+ (NSDictionary *)parameterForOrderType:(BitcoinDE_MyTradeHistoryParameter_OrderType)orderType
                             tradeState:(BitcoinDE_MyTradeHistoryParameter_TradeStateType)tradeState
                           currencyType:(BitcoinDE_CurrencyType)currencyType
                              startDate:(NSDate *)startDate
                                endDate:(NSDate *)endDate
                                   page:(NSInteger)page;

+ (NSMutableArray *)myTradesDataArrayForMyTradeHistoryDictionary:(NSDictionary *)payloadDictionary;

+ (NSString *)titleForOrderType:(BitcoinDE_MyTradeHistoryParameter_OrderType)orderType;
+ (NSString *)titleForTradeStateType:(BitcoinDE_MyTradeHistoryParameter_TradeStateType)tradeStateType;

+ (NSString *)pasteboardStringForTrades:(NSArray <SOXMyTrades_BitcoinDE_Data *> *)trades;
@end
