//
//  SOXAutomaticTradingCore_Private.h
//  BitcoinApp
//
//  Created by Peter Hauke on 18.06.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXFormatters.h"

#import "SOXMarket_BitcoinDE_Core.h"

#import "SOXShowOrderbookData.h"
#import "SOXTradeJob_BitcoinDE_Data.h"

#import "SOXKeys_BitcoinDE.h"

@interface SOXAutomaticTradingCore ()

@property (nonatomic) BitcoinDE_CurrencyType currencyType;
@property (nonatomic, copy) NSString *currencyTypeString;

@property (nonatomic) BOOL socketIODidDisconnectAppeared;

@property (strong, nonatomic) NSHashTable *buyDelegates;
//@property (strong, nonatomic) NSHashTable *sellDelegates;

@property (strong, nonatomic) NSMutableArray *buyOrderBook;
@property (strong, nonatomic) NSMutableArray *sellOrderBook;
@property (strong, nonatomic) NSMutableSet *buySEPAOrderBook; // as cache for SEPA offers
@property (strong, nonatomic) NSMutableSet *sellSEPAOrderBook;  // as cache for SEPA orders
@property (strong, nonatomic) NSMutableArray *buyOrderBookInExecution;
@property (strong, nonatomic) NSMutableArray *sellOrderBookInExecution;

@property (nonatomic) BOOL automaticTradingIsRunning;
@property (nonatomic) BOOL waitingForBannerUpdate;

@property (nonatomic) BOOL executeBuyTrades;
//@property (nonatomic) BOOL executeSellTrades;
@property (nonatomic) BOOL executeAutomaticTradesForBuyTrades;
//@property (nonatomic) BOOL executeAutomaticTradesForSellTrades;
@property (nonatomic) BOOL executeBalanceTradesForBuyTrades;
//@property (nonatomic) BOOL executeBalanceTradesForSellTrades;

@property (strong, nonatomic) NSDecimalNumber *buyInterestRate;
@property (strong, nonatomic) NSDecimalNumber *buyInterestFactor;
@property (strong, nonatomic) NSDecimalNumber *buyMaximalFidorAmountInvestment;
//@property (strong, nonatomic) NSDecimalNumber *sellInterestRate;
//@property (strong, nonatomic) NSDecimalNumber *sellInterestFactor;
//@property (strong, nonatomic) NSDecimalNumber *sellMaximalBTCInvestment;

@property (strong, nonatomic) NSMutableArray *runningAutomaticBuyTradeParameters;
//@property (strong, nonatomic) NSMutableArray *runningAutomaticSellTradeParameters;
//@property (strong, nonatomic) NSMutableArray *runningBalanceBuyTradeParameters;
@property (strong, nonatomic) NSMutableArray *runningBalanceSellTradeParameters;

@property (strong, nonatomic) NSMutableArray *successfulAutomaticBuyTradeParameters; // buy parameters we have to balance out
//@property (strong, nonatomic) NSMutableArray *successfulAutomaticSellTradeParameters;   // sell parameters we have to balance out
//@property (strong, nonatomic) NSMutableArray *successfulBalanceBuyTradeParameters;
@property (strong, nonatomic) NSMutableArray *successfulBalanceSellTradeParameters;

- (void)setupProperties;
- (void)flushAllOrderBooks;

#pragma mark - Interest Rate methods
- (NSDecimalNumber *)effectiveBuyInterestRateForData:(SOXShowOrderbookData *)orderOfInterestData
                                     toReferenceData:(SOXShowOrderbookData *)referenceData;
- (NSDecimalNumber *)effectiveSellInterestRateForData:(SOXShowOrderbookData *)orderOfInterestData
                                      toReferenceData:(SOXShowOrderbookData *)referenceData;
- (NSDecimalNumber *)effectiveBuyInterestRateForPrice:(NSDecimalNumber *)priceOfInterest
                                     toReferencePrice:(NSDecimalNumber *)referencePrice;
- (NSDecimalNumber *)effectiveSellInterestRateForPrice:(NSDecimalNumber *)priceOfInterest
                                      toReferencePrice:(NSDecimalNumber *)referencePrice;

#pragma mark - Banner update methods
- (void)updateBannerAfterSuccessfulAutomaticBuyTrade;
- (void)updateBannerAfterSuccessfulBalanceTrades;

#pragma mark - Automatic trading methods
- (BOOL)checkForBuyableOrder;
- (NSDecimalNumber *)btcBuyAmountForOrder:(SOXShowOrderbookData *)orderToBuy;

#pragma mark - Balance trade methods
- (void)createBalanceTradesForBoughtTrades;

- (NSMutableArray *)sellBalanceTradeParametersForBuyAmount:(NSDecimalNumber *)boughtBTCAmount
                                               forBuyPrice:(NSDecimalNumber *)boughtPrice
                                 createPotentialParameters:(BOOL)createPotentialParameters;

- (void)tryToExecuteBalanceTradesWithParameters:(NSArray *)parametersToExecute
                                   forOrderType:(BitcoinDE_OrderType)orderType ;
#pragma mark - Math Helpers
- (NSDecimalNumber *)sumOfBitcoinsOfParameters:(NSArray <NSDictionary *>*)parameter;

#pragma mark - Handle (un)successful trades
#pragma mark | Auto trades
- (void)successfulAutomaticBuyTrade:(NSDictionary *)tradeParameters;
- (void)unSuccessfulAutomaticBuyTrade:(NSDictionary *)tradeParameters;

#pragma mark | Balance trades
- (void)successfulBalanceSellTrade:(NSDictionary *)tradeParameters;
- (void)unSuccessfulBalanceSellTrade:(NSDictionary *)tradeParameters errorCode:(NSNumber *)errorCode;

#pragma mark - Inform delegates
- (void)informBuyDelegateWithNote:(NSString *)note;
- (void)informEventLogWithNote:(NSString *)note;
- (void)informBuyDelegateWithStatus:(NSString *)status;
- (void)informBuyDelegateAboutRunningQueues;

#pragma mark | Helpers
- (void)updateBuyStatus;

@end
