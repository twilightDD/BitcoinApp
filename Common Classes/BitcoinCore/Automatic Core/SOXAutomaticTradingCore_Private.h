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

@interface SOXAutomaticTradingCore ()

@property (nonatomic) BOOL socketIODidDisconnectAppeared;

@property (strong, nonatomic) NSHashTable *buyDelegates;
@property (strong, nonatomic) NSHashTable *sellDelegates;

@property (strong, nonatomic) NSMutableArray *buyOrderBook;
@property (strong, nonatomic) NSMutableArray *sellOrderBook;
@property (strong, nonatomic) NSMutableSet *buySEPAOrderBook; // as cache for SEPA offers
@property (strong, nonatomic) NSMutableSet *sellSEPAOrderBook;  // as cache for SEPA orders
@property (strong, nonatomic) NSMutableArray *buyOrderBookInExecution;
@property (strong, nonatomic) NSMutableArray *sellOrderBookInExecution;

@property (nonatomic) BOOL automaticTradingIsRunning;
@property (nonatomic) BOOL waitingForBannerUpdate;

@property (nonatomic) BOOL executeBuyTrades;
@property (nonatomic) BOOL executeSellTrades;
@property (nonatomic) BOOL executeAutomaticTradesForBuyTrades;
@property (nonatomic) BOOL executeAutomaticTradesForSellTrades;
@property (nonatomic) BOOL executeBalanceTradesForBuyTrades;
@property (nonatomic) BOOL executeBalanceTradesForSellTrades;

@property (strong, nonatomic) NSDecimalNumber *buyInterestRate;
@property (strong, nonatomic) NSDecimalNumber *buyInterestFactor;
@property (strong, nonatomic) NSDecimalNumber *buyMaximalFidorAmountInvestment;
@property (strong, nonatomic) NSDecimalNumber *sellInterestRate;
@property (strong, nonatomic) NSDecimalNumber *sellInterestFactor;
@property (strong, nonatomic) NSDecimalNumber *sellMaximalBTCInvestment;

@property (strong, nonatomic) NSMutableArray *runningAutomaticBuyTradeParameters;
@property (strong, nonatomic) NSMutableArray *runningAutomaticSellTradeParameters;
@property (strong, nonatomic) NSMutableArray *runningBalanceBuyTradeParameters;
@property (strong, nonatomic) NSMutableArray *runningBalanceSellTradeParameters;

@property (strong, nonatomic) NSMutableArray *boughtTradeParametersBacklog; // buy parameters we have to balance out
@property (strong, nonatomic) NSMutableArray *soldTradeParametersBacklog;   // sell parameters we have to balance out
@property (strong, nonatomic) NSMutableArray *successfulBalanceBuyTradeParameters;
@property (strong, nonatomic) NSMutableArray *successfulBalanceSellTradeParameters;

- (void)setupProperties;

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
- (BOOL)checkForSellableOrder;
- (NSDecimalNumber *)btcBuyAmountForOrder:(SOXShowOrderbookData *)orderToBuy;
- (NSDecimalNumber *)btcSellAmountForOrder:(SOXShowOrderbookData *)orderToSell;

#pragma mark - Balance trade methods
- (void)createBalanceTradesForBoughtTrades;
- (void)createBalanceTradesForSoldTrades;

- (NSMutableArray *)buyBalanceTradeParametersForSellAmount:(NSDecimalNumber *)soldBTCAmount
                                              forSellPrice:(NSDecimalNumber *)soldPrice
                                 createPotentialParameters:(BOOL)createPotentialParameters;

- (NSMutableArray *)sellBalanceTradeParametersForBuyAmount:(NSDecimalNumber *)boughtBTCAmount
                                               forBuyPrice:(NSDecimalNumber *)boughtPrice
                                 createPotentialParameters:(BOOL)createPotentialParameters;

#pragma mark - Math Helpers
- (NSDecimalNumber *)sumOfBitcoinsOfParameters:(NSArray <NSDictionary *>*)parameter;

#pragma mark - Handle (un)successful trades
#pragma mark | Auto trades
- (void)successfulAutomaticBuyTrade:(NSDictionary *)tradeParameters;
- (void)successfulAutomaticSellTrade:(NSDictionary *)tradeParameters;
- (void)unSuccessfulAutomaticBuyTrade:(NSDictionary *)tradeParameters;
- (void)unSuccessfulAutomaticSellTrade:(NSDictionary *)tradeParameters;
#pragma mark | Balance trades
- (void)successfulBalanceBuyTrade:(NSDictionary *)tradeParameters;
- (void)successfulBalanceSellTrade:(NSDictionary *)tradeParameters;
- (void)unSuccessfulBalanceBuyTrade:(NSDictionary *)tradeParameters;
- (void)unSuccessfulBalanceSellTrade:(NSDictionary *)tradeParameters;

#pragma mark - Inform delegates
- (void)informBuyDelegateWithNote:(NSString *)note;
- (void)informSellDelegateWithNote:(NSString *)note;
- (void)informBuyDelegateWithStatus:(NSString *)status;
- (void)informSellDelegateWithStatus:(NSString *)status;
#pragma mark | Helpers
- (void)updateBuyStatus;
- (void)updateSellStatus;
- (void)informBuyDelegateAboutRunningQueues;
- (void)informSellDelegateAboutRunningQueues;

@end
