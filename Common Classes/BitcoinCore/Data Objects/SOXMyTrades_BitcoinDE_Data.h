//
//  SOXMyTrades_BitcoinDE_Data.h
//  BitcoinApp
//
//  Created by Peter Hauke on 03.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, BitcoinDE_MyTradeHistoryParameter_OrderType) {
    BitcoinDE_MyTradeHistoryParameter_UnknownOrderType = 0
    , BitcoinDE_MyTradeHistoryParameter_BuyOrderType   = 1
    , BitcoinDE_MyTradeHistoryParameter_SellOrderType  = 2
};

typedef NS_ENUM (NSUInteger, BitcoinDE_MyTradeHistoryParameter_TradeStateType) {
    BitcoinDE_MyTradeHistoryParameter_UnknownTradeStateType       = 0
    , BitcoinDE_MyTradeHistoryParameter_SuccessfulTradeStateType  = 1
    , BitcoinDE_MyTradeHistoryParameter_PendingTradeStateType     = 2
    , BitcoinDE_MyTradeHistoryParameter_CancelledTradeStateType   = 3
};


@interface SOXMyTrades_BitcoinDE_Data : NSObject

@property (strong, nonatomic, readonly) NSString *tradeID;
@property (strong, nonatomic, readonly) NSString *type;
@property (strong, nonatomic, readonly) NSNumber *amount;
@property (strong, nonatomic, readonly) NSNumber *price;
@property (strong, nonatomic, readonly) NSNumber *volume;
@property (strong, nonatomic, readonly) NSNumber *feeEur;
@property (strong, nonatomic, readonly) NSNumber *feeBTC;
@property (strong, nonatomic, readonly) NSString *aNewOrderIDForRemainingAmount;
@property (strong, nonatomic, readonly) NSNumber *state;
@property (strong, nonatomic, readonly) NSString *myRatingForTradingPartner;
@property (strong, nonatomic, readonly) NSString *createdAt;
@property (strong, nonatomic, readonly) NSString *successfullyFinishedAt;
@property (strong, nonatomic, readonly) NSString *cancelledAt;
@property (strong, nonatomic, readonly) NSNumber *paymentMethod;
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
                              startDate:(NSDate *)startDate
                                endDate:(NSDate *)endDate
                                   page:(NSInteger)page;

+ (NSMutableArray *)myTradesDataArrayForMyTradeHistoryDictionary:(NSDictionary *)payloadDictionary;

@end
