//
//  SOXAutomaticTradingCore_Private.h
//  BitcoinApp
//
//  Created by Peter Hauke on 18.06.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXFormatters.h"

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


- (void)informBuyDelegateWithNote:(NSString *)note;
- (void)informSellDelegateWithNote:(NSString *)note;
- (void)informBuyDelegateWithStatus:(NSString *)status;
- (void)informSellDelegateWithStatus:(NSString *)status;
- (void)updateBuyStatus;
- (void)updateSellStatus;

@end
