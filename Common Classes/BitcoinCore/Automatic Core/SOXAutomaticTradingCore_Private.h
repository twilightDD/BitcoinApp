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

@interface SOXAutomaticTradingCore ()

@property (strong, nonatomic) NSHashTable *buyDelegates;
@property (strong, nonatomic) NSHashTable *sellDelegates;

@property (strong, nonatomic) NSMutableArray *buyOrderBook;
@property (strong, nonatomic) NSMutableArray *sellOrderBook;
@property (strong, nonatomic) NSMutableSet *buySEPAOrderBook; // as cache for SEPA offers
@property (strong, nonatomic) NSMutableSet *sellSEPAOrderBook;  // as cache for SEPA orders

@property (nonatomic) BOOL executeBuyTrades;
@property (nonatomic) BOOL executeSellTrades;
@property (nonatomic) BOOL executeBalanceBuyTrades;
@property (nonatomic) BOOL executeBalanceSellTrades;

@property (strong, nonatomic) NSDecimalNumber *buyInterestRate;
@property (strong, nonatomic) NSDecimalNumber *buyInterestFactor;
@property (strong, nonatomic) NSDecimalNumber *buyMaximalFidorAmountInvestment;
@property (strong, nonatomic) NSDecimalNumber *sellInterestRate;
@property (strong, nonatomic) NSDecimalNumber *sellInterestFactor;
@property (strong, nonatomic) NSDecimalNumber *sellMaximalBTCInvestment;

@property (strong, nonatomic) NSDecimalNumber *remainingBuyBitcoinAmount;
@property (strong, nonatomic) NSDecimalNumber *remainingSellBitcoinAmount;


#pragma mark - Interest Rate methods
- (NSDecimalNumber *)effectiveBuyInterestRateForData:(SOXShowOrderbookData *)orderOfInterestData
                                     toReferenceData:(SOXShowOrderbookData *)referenceData;
- (NSDecimalNumber *)effectiveSellInterestRateForData:(SOXShowOrderbookData *)orderOfInterestData
                                      toReferenceData:(SOXShowOrderbookData *)referenceData;
- (NSDecimalNumber *)effectiveBuyInterestRateForPrice:(NSDecimalNumber *)priceOfInterest
                                     toReferencePrice:(NSDecimalNumber *)referencePrice;
- (NSDecimalNumber *)effectiveSellInterestRateForPrice:(NSDecimalNumber *)priceOfInterest
                                      toReferencePrice:(NSDecimalNumber *)referencePrice;

#pragma mark - Automatic trading methods
- (void)checkForBuyableOrder;
- (void)checkForSellableOrder;
- (NSDecimalNumber *)btcBuyAmountForOrder:(SOXShowOrderbookData *)orderToBuy;
- (NSDecimalNumber *)btcSellAmountForOrder:(SOXShowOrderbookData *)orderToSell;

#pragma mark - Inform delegates
- (void)informBuyDelegateWithNote:(NSString *)note;
- (void)informSellDelegateWithNote:(NSString *)note;
- (void)informBuyDelegateWithStatus:(NSString *)status;
- (void)informSellDelegateWithStatus:(NSString *)status;
#pragma mark | Helpers
- (void)updateBuyStatus;
- (void)updateSellStatus;

@end
