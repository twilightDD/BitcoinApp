//
//  SOXAutomaticTradingCore.m
//  BitcoinApp
//
//  Created by Peter Hauke on 11.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXAutomaticTradingCore.h"
#import "SOXAutomaticTradingCore_Private.h"

@interface SOXAutomaticTradingCore ()

@end

@implementation SOXAutomaticTradingCore
#pragma mark - Class methods

+ (void)missedImplementation:(NSString *)methodName {
    NSAssert(NO, @"%@ must be implemented in subclass", methodName);
}

#pragma mark - Public Instance methods
- (void)setupProperties {
    [self setBuyDelegates:[[NSHashTable alloc] init]];
    [self setSellDelegates:[[NSHashTable alloc] init]];
    [self setBuyInterestRate:[NSDecimalNumber one]];
    [self setBuyInterestFactor:[NSDecimalNumber one]];
    [self setSellInterestRate:[NSDecimalNumber one]];
    [self setSellInterestFactor:[NSDecimalNumber one]];

    [self setBuySEPAOrderBook:[NSMutableSet set]];
    [self setSellSEPAOrderBook:[NSMutableSet set]];

    [self setBuyOrderBookInExecution:[NSMutableArray array]];
    [self setSellOrderBookInExecution:[NSMutableArray array]];

    [self setSuccessfulAutomaticBuyTradeParameters:[NSMutableArray array]];
    [self setSuccessfulAutomaticSellTradeParameters:[NSMutableArray array]];
    [self setSuccessfulBalanceBuyTradeParameters:[NSMutableArray array]];
    [self setSuccessfulBalanceSellTradeParameters:[NSMutableArray array]];

    [self setRunningAutomaticBuyTradeParameters:[NSMutableArray array]];
    [self setRunningAutomaticSellTradeParameters:[NSMutableArray array]];
    [self setRunningBalanceBuyTradeParameters:[NSMutableArray array]];
    [self setRunningBalanceSellTradeParameters:[NSMutableArray array]];

    self.executeBuyTrades = NO;
    self.executeSellTrades = NO;
    self.executeAutomaticTradesForBuyTrades = NO;
    self.executeAutomaticTradesForSellTrades = NO;
    self.executeBalanceTradesForBuyTrades = NO;
    self.executeBalanceTradesForSellTrades = NO;
}

- (void)flushAllOrderBooks {
    if (!self.socketIODidDisconnectAppeared) {
        { // DEBUG
            NSString *note = [NSString stringWithFormat:@"Going to flush all orderBooks. Count of orderBooks before:\n"
                              "%tu buyOrderBook\n"
                              "%tu buySEPAOrderBook\n"
                              "%tu sellOrderBook\n"
                              "%tu sellSEPAOrderBook",
                              self.buyOrderBook.count, self.buySEPAOrderBook.count, self.sellOrderBook.count, self.sellSEPAOrderBook.count];
            [self informBuyDelegateWithNote:note];
            [self informSellDelegateWithNote:note];
        }

        [self.buyOrderBook removeAllObjects];
        [self.buySEPAOrderBook removeAllObjects];
        [self.sellOrderBook removeAllObjects];
        [self.sellSEPAOrderBook removeAllObjects];

        [self updateBuyStatus];
        [self updateSellStatus];

        { // DEBUG
            NSString *note = [NSString stringWithFormat:@"Did flush all orderBooks. Count of orderBooks after:\n"
                              "%tu buyOrderBook\n"
                              "%tu buySEPAOrderBook\n"
                              "%tu sellOrderBook\n"
                              "%tu sellSEPAOrderBook\n"
                              "------------------------",
                              self.buyOrderBook.count, self.buySEPAOrderBook.count, self.sellOrderBook.count, self.sellSEPAOrderBook.count];
            [self informBuyDelegateWithNote:note];
            [self informSellDelegateWithNote:note];
        }
    }

    self.socketIODidDisconnectAppeared = YES;
    self.automaticTradingIsRunning = NO;
}

#pragma mark - Manual setters
- (void)setBuyInterestRate:(NSDecimalNumber *)buyInterestRate {
    if (buyInterestRate) {
        _buyInterestRate = buyInterestRate;
        NSDecimalNumber *buyInterestRatePercent = [buyInterestRate decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"100"]];
        self.buyInterestFactor = [[NSDecimalNumber one] decimalNumberBySubtracting:buyInterestRatePercent];
        NSString *note = [NSString stringWithFormat:@"UPDATE VALUE: Set interest rate to %@%%", self.buyInterestRate];
        [self informBuyDelegateWithNote:note];

        [self updateBuyStatus];
    }
}

- (void)setSellInterestRate:(NSDecimalNumber *)sellInterestRate {
    if (sellInterestRate) {
        _sellInterestRate = sellInterestRate;
        NSDecimalNumber *sellInterestRatePercent = [sellInterestRate decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"100"]];
        self.sellInterestFactor = [[NSDecimalNumber one] decimalNumberByAdding:sellInterestRatePercent];
        NSString *note = [NSString stringWithFormat:@"UPDATE VALUE: Set interest rate to %@%%", self.sellInterestRate];
        [self informSellDelegateWithNote:note];

        [self updateSellStatus];
    }
}

- (void)setBuyMaximalFidorAmount:(NSDecimalNumber *)buyMaximalFidorAmountInvestment {
    if (buyMaximalFidorAmountInvestment) {
        _buyMaximalFidorAmountInvestment = buyMaximalFidorAmountInvestment;
        NSString *note = [NSString stringWithFormat:@"UPDATE VALUE: Set maximal trading volume to %@ €", self.buyMaximalFidorAmountInvestment];
        [self informBuyDelegateWithNote:note];
    }
}

- (void)setSellMaximalBTCAmount:(NSDecimalNumber *)sellMaximalBTCInvestment {
    if (sellMaximalBTCInvestment) {
        self.sellMaximalBTCInvestment = sellMaximalBTCInvestment;
        NSString *note = [NSString stringWithFormat:@"UPDATE VALUE: Set maximal trading amount to %@ BTC", self.sellMaximalBTCInvestment];
        [self informSellDelegateWithNote:note];
    }
}

#pragma mark - Interest Rate methods
- (NSDecimalNumber *)effectiveBuyInterestRateForData:(SOXShowOrderbookData *)orderOfInterestData
                                     toReferenceData:(SOXShowOrderbookData *)referenceData {
    NSDecimalNumber *priceOfInterest = orderOfInterestData.orderInformation_price;
    NSDecimalNumber *referencePrice = referenceData.orderInformation_price;

    if (!priceOfInterest
        || !referencePrice
        || priceOfInterest == [NSDecimalNumber zero]
        || referencePrice == [NSDecimalNumber zero]) {
        NSString *note = [NSString stringWithFormat:@"ERROR - priceOfInterest %@ (orderID: %@) - referencePrice %@ (orderID: %@)"
                          , priceOfInterest
                          , orderOfInterestData.orderInformation_orderID
                          , referencePrice
                          , referenceData.orderInformation_orderID];
        [self informBuyDelegateWithNote:note];
        return [NSDecimalNumber zero];
    }

    return [self effectiveBuyInterestRateForPrice:orderOfInterestData.orderInformation_price
                                 toReferencePrice:referenceData.orderInformation_price];
}

- (NSDecimalNumber *)effectiveSellInterestRateForData:(SOXShowOrderbookData *)orderOfInterestData
                                      toReferenceData:(SOXShowOrderbookData *)referenceData {
    NSDecimalNumber *priceOfInterest = orderOfInterestData.orderInformation_price;
    NSDecimalNumber *referencePrice = referenceData.orderInformation_price;

    if (!priceOfInterest
        || !referencePrice
        || priceOfInterest == [NSDecimalNumber zero]
        || referencePrice == [NSDecimalNumber zero]) {
        NSString *note = [NSString stringWithFormat:@"ERROR - priceOfInterest %@ (orderID: %@) - referencePrice %@ (orderID: %@)"
                          , priceOfInterest
                          , orderOfInterestData.orderInformation_orderID
                          , referencePrice
                          , referenceData.orderInformation_orderID];
        [self informSellDelegateWithNote:note];
        return [NSDecimalNumber zero];
    }

    return [self effectiveSellInterestRateForPrice:orderOfInterestData.orderInformation_price
                                  toReferencePrice:referenceData.orderInformation_price];
}

- (NSDecimalNumber *)effectiveBuyInterestRateForPrice:(NSDecimalNumber *)priceOfInterest
                                     toReferencePrice:(NSDecimalNumber *)referencePrice {
    NSDecimalNumber *effectiveInterestRate = [priceOfInterest decimalNumberByDividingBy:referencePrice];
    return [SOXFormatters formattedInterestRate:effectiveInterestRate];
}

- (NSDecimalNumber *)effectiveSellInterestRateForPrice:(NSDecimalNumber *)priceOfInterest
                                      toReferencePrice:(NSDecimalNumber *)referencePrice {
    NSDecimalNumber *effectiveInterestRate = [referencePrice decimalNumberByDividingBy:priceOfInterest];
    return [SOXFormatters formattedInterestRate:effectiveInterestRate];
}

#pragma mark - Automatic trading methods
- (BOOL)checkForBuyableOrder {
    if (self.buyOrderBook.count < 2) {
        NSString *note = [NSString stringWithFormat:@"no buy - too less entries with payOption 1 or 3 in buyOrderBook (count: %tu)"
                          , self.buyOrderBook.count];
        [self informBuyDelegateWithNote:note];
        return NO;
    }

    SOXShowOrderbookData *dataOfInterest  = self.buyOrderBook.firstObject;
    SOXShowOrderbookData *referenceData   = self.sellOrderBook.firstObject;
    NSDecimalNumber *effectivInterestRate = [self effectiveBuyInterestRateForData:dataOfInterest
                                                                  toReferenceData:referenceData];

//    NSString *statisticForNote = [NSString stringWithFormat:@"- type %@ - ID %@ - minAmo %@ - maxAmo %@ - buyP0 %@ - sellP0 %@ - iR %@"
//                                  , dataOfInterest.orderInformation_type
//                                  , dataOfInterest.orderInformation_orderID
//                                  , [SOXFormatters stringForBTCNumber:dataOfInterest.orderInformation_minAmount]
//                                  , [SOXFormatters stringForBTCNumber:dataOfInterest.orderInformation_maxAmount]
//                                  , [SOXFormatters currencyStringForNumber:dataOfInterest.orderInformation_price roundingMode:NSNumberFormatterRoundDown]
//                                  , [SOXFormatters currencyStringForNumber:referenceData.orderInformation_price roundingMode:NSNumberFormatterRoundDown]
//                                  , effectivInterestRate];

    if ([effectivInterestRate isLessThan:self.buyInterestRate]) {
        { // DEBUG
            NSString *statisticForNote = [NSString stringWithFormat:@"- type %@ - ID %@ - minAmo %@ - maxAmo %@ - buyP0 %@ - sellP0 %@ - iR %@"
                                          , dataOfInterest.orderInformation_type
                                          , dataOfInterest.orderInformation_orderID
                                          , [SOXFormatters stringForBTCNumber:dataOfInterest.orderInformation_minAmount]
                                          , [SOXFormatters stringForBTCNumber:dataOfInterest.orderInformation_maxAmount]
                                          , [SOXFormatters currencyStringForNumber:dataOfInterest.orderInformation_price roundingMode:NSNumberFormatterRoundDown]
                                          , [SOXFormatters currencyStringForNumber:referenceData.orderInformation_price roundingMode:NSNumberFormatterRoundDown]
                                          , effectivInterestRate];
            NSString *note = [NSString stringWithFormat:@"no buy (iR to less) %@", statisticForNote];
            [self informBuyDelegateWithNote:note];
        }
        return NO;
    }
    else {
//        { // DEBUG
//            [self informBuyDelegateWithNote:@"   ------"];
//
//            __block NSString *note = [NSString stringWithFormat:@"TRY TO BUY %@\nSELLORDERBOOK", statisticForNote];
//            // log first items of sellOrderBook
//            [self.sellOrderBook enumerateObjectsUsingBlock:^(SOXShowOrderbookData * _Nonnull sellOrderbookData,
//                                                            NSUInteger idx,
//                                                            BOOL * _Nonnull stop) {
//                note = [note stringByAppendingString:
//                        [NSString stringWithFormat:@"\nidx: %tu - oID: %@ - p: %@ - minA: %@ - maxA: %@ - payO: %@"
//                         , idx
//                         , sellOrderbookData.orderInformation_orderID
//                         , [SOXFormatters currencyStringForNumber:sellOrderbookData.orderInformation_price roundingMode:NSNumberFormatterRoundHalfUp]
//                         , [SOXFormatters stringForBTCNumber:sellOrderbookData.orderInformation_minAmount]
//                         , [SOXFormatters stringForBTCNumber:sellOrderbookData.orderInformation_maxAmount]
//                         , sellOrderbookData.orderRequirements_paymentOption]
//                        ];
//
//                if (idx > 10) {
//                    *stop = YES;
//                }
//            }];
//
//            [self informBuyDelegateWithNote:note];
//        }

        NSDecimalNumber *btcAmountToBuy= [self btcBuyAmountForOrder:dataOfInterest];
        if (btcAmountToBuy
            && [btcAmountToBuy isGreaterThanOrEqualTo:dataOfInterest.orderInformation_minAmount]) {
            [self tryToBuy:dataOfInterest btcAmountToBuy:btcAmountToBuy];
            return YES;
        }
        else {
            { // DEBUG
                NSString *note = [NSString stringWithFormat:@"Can't buy: btcAmountToBuy %@ is less than order.minAmount (%@)"
                                  , [SOXFormatters stringForBTCNumber:btcAmountToBuy]
                                  , [SOXFormatters stringForBTCNumber:dataOfInterest.orderInformation_minAmount]];
                [self informBuyDelegateWithNote:note];
            }
            return NO;
        }
    }
}

- (BOOL)checkForSellableOrder {
    if (self.sellOrderBook.count < 2) {
        NSString *note = [NSString stringWithFormat:@"no sell - too less entries with payOption 1 or 3 in sellOrderBook (count: %tu)"
                          , self.sellOrderBook.count];
        [self informSellDelegateWithNote:note];
        return NO;
    }

    SOXShowOrderbookData *dataOfInterest  = self.sellOrderBook.firstObject;
//    SOXShowOrderbookData *referenceData   = [self.sellOrderBook objectAtIndex:1];
    SOXShowOrderbookData *referenceData   = self.sellOrderBook.firstObject;
    NSDecimalNumber *effectivInterestRate = [self effectiveSellInterestRateForData:dataOfInterest toReferenceData:referenceData];

    NSString *statisticForNote = [NSString stringWithFormat:@"- type %@ - ID %@ - minAmo %@ - maxAmo %@ - p0 %@ - buyP0 %@ - iR %@"
                                  , dataOfInterest.orderInformation_type
                                  , dataOfInterest.orderInformation_orderID
                                  , [SOXFormatters stringForBTCNumber:dataOfInterest.orderInformation_minAmount]
                                  , [SOXFormatters stringForBTCNumber:dataOfInterest.orderInformation_maxAmount]
                                  , [SOXFormatters currencyStringForNumber:dataOfInterest.orderInformation_price roundingMode:NSNumberFormatterRoundDown]
                                  , [SOXFormatters currencyStringForNumber:referenceData.orderInformation_price roundingMode:NSNumberFormatterRoundDown]
                                  , effectivInterestRate];

    if ([effectivInterestRate isLessThan:self.sellInterestRate]) {
        { // DEBUG
            NSString *note = [NSString stringWithFormat:@"no sell (iR to less) %@", statisticForNote];
            [self informSellDelegateWithNote:note];
        }
        return NO;
    }
    else {
        { // DEBUG
            [self informSellDelegateWithNote:@"------"];
            __block NSString *note = [NSString stringWithFormat:@"TRY TO SELL %@\nBUYORDERBOOK", statisticForNote];

            // log first items of buyOrderBook
            [self.buyOrderBook enumerateObjectsUsingBlock:^(SOXShowOrderbookData * _Nonnull buyOrderbookData,
                                                            NSUInteger idx,
                                                            BOOL * _Nonnull stop) {
                note = [note stringByAppendingString:
                        [NSString stringWithFormat:@"\nidx: %tu - oID: %@ - p: %@ - minA: %@ - maxA: %@ - payO: %@"
                         , idx
                         , buyOrderbookData.orderInformation_orderID
                         , [SOXFormatters currencyStringForNumber:buyOrderbookData.orderInformation_price roundingMode:NSNumberFormatterRoundHalfUp]
                         , [SOXFormatters stringForBTCNumber:buyOrderbookData.orderInformation_minAmount]
                         , [SOXFormatters stringForBTCNumber:buyOrderbookData.orderInformation_maxAmount]
                         , buyOrderbookData.orderRequirements_paymentOption]
                        ];

                if (idx > 10) {
                    *stop = YES;
                }
            }];
            [self informSellDelegateWithNote:note];

        }

        NSDecimalNumber *btcAmountToSell = [self btcSellAmountForOrder:dataOfInterest];
        if (btcAmountToSell
            && [btcAmountToSell isGreaterThanOrEqualTo:dataOfInterest.orderInformation_minAmount]) {
            [self tryToSell:dataOfInterest btcAmountToSell:btcAmountToSell];
            return YES;
        }
        else {
            { // DEBUG
                NSString *note = [NSString stringWithFormat:@"Can't sell: btcAmountToSell %@ is less than order.minAmount (%@)"
                                  , [SOXFormatters stringForBTCNumber:btcAmountToSell]
                                  , [SOXFormatters stringForBTCNumber:dataOfInterest.orderInformation_minAmount]];
                [self informSellDelegateWithNote:note];
            }
            return NO;
        }
    }
}

- (NSDecimalNumber *)btcBuyAmountForOrder:(SOXShowOrderbookData *)orderToBuy {
    NSDecimalNumber *orderToBuyMinVolume = orderToBuy.orderInformation_minVolume;
    NSDecimalNumber *orderToBuyMaxVolume = orderToBuy.orderInformation_maxVolume;

    // consider user given maxFidorAmount
    NSDecimalNumber *availableFidorAmount = [SOXMarket_BitcoinDE_Core allocationMaxEurVolumeForCurrency:self.currencyType];
    if (self.buyMaximalFidorAmountInvestment) {
        availableFidorAmount = [SOXFormatters lesserDecimalNumberFrom:self.buyMaximalFidorAmountInvestment
                                                                  and:availableFidorAmount];
    }

    NSDecimalNumber *btcAmountToBuy = nil;
    NSString *note = @"Error in tryToExecuteBuyOrder";
    if ([orderToBuyMinVolume isGreaterThan:availableFidorAmount]) {
        // minVolume > availableAmount => no buy possible
        note = [NSString stringWithFormat:@"NO BUY possible: order_minVol %@ > avaFidor %@ (not enough fidor amount)"
                , [SOXFormatters currencyStringForNumber:orderToBuyMinVolume roundingMode:NSNumberFormatterRoundDown]
                , [SOXFormatters currencyStringForNumber:availableFidorAmount roundingMode:NSNumberFormatterRoundDown]];
        [self informBuyDelegateWithNote:note];

    }
    else if ([orderToBuyMinVolume isEqual:availableFidorAmount]) {
        // minVolume = availableAmount => buy minAmount
//        note = [NSString stringWithFormat:@"BUY possible: order_minVol %@ = avaFidor %@ (buy order.minAmount)"
//                , [SOXFormatters currencyStringForNumber:orderToBuyMinVolume roundingMode:NSNumberFormatterRoundDown]
//                , [SOXFormatters currencyStringForNumber:availableFidorAmount roundingMode:NSNumberFormatterRoundDown]];

        btcAmountToBuy = orderToBuy.orderInformation_minAmount;
    }
    else if ([orderToBuyMaxVolume isEqual:availableFidorAmount]) {
        // minVolume = availableAmount => buy minAmount
//        note = [NSString stringWithFormat:@"BUY possible: order_maxVol %@ = avaFidor %@ (buy order.maxAmount)"
//                , [SOXFormatters currencyStringForNumber:orderToBuyMaxVolume roundingMode:NSNumberFormatterRoundDown]
//                , [SOXFormatters currencyStringForNumber:availableFidorAmount roundingMode:NSNumberFormatterRoundDown]];

        btcAmountToBuy = orderToBuy.orderInformation_maxAmount;
    }
    else if ([orderToBuyMinVolume isLessThan:availableFidorAmount]) {
        // minVolume < availableAmount => buy more than minAmount (figure out, how much)
//        note = [NSString stringWithFormat:@"BUY possible: order_minVol %@ < avaFidor %@ (figure out btcToBuyAmount now ...)"
//                , [SOXFormatters currencyStringForNumber:orderToBuyMinVolume roundingMode:NSNumberFormatterRoundDown]
//                , [SOXFormatters currencyStringForNumber:availableFidorAmount roundingMode:NSNumberFormatterRoundDown]];

        NSDecimalNumber *volumeToBuy = [SOXFormatters lesserDecimalNumberFrom:orderToBuy.orderInformation_maxVolume
                                                                          and:availableFidorAmount];
        btcAmountToBuy = [volumeToBuy decimalNumberByDividingBy:orderToBuy.orderInformation_price
                                                   withBehavior:[SOXFormatters btcNumberHandler]];
    }

    if (btcAmountToBuy) {
        btcAmountToBuy = [self potentialSellBalanceTradeAmountForBuyAmount:btcAmountToBuy
                                                               forBuyPrice:orderToBuy.orderInformation_price];
    }

//    note = [note stringByAppendingString:[NSString stringWithFormat:@" potSellAmount: %@"
//                                          , btcAmountToBuy]];
//    [self informBuyDelegateWithNote:note];

    return btcAmountToBuy;
}

- (NSDecimalNumber *)btcSellAmountForOrder:(SOXShowOrderbookData *)orderToSell {
    NSDecimalNumber *btcAmountToSell;

    NSDecimalNumber *orderMinAmountToSell = orderToSell.orderInformation_minAmount;
    NSDecimalNumber *orderMaxAmountToSell = orderToSell.orderInformation_maxAmount;

    NSDecimalNumber *availableBTCAmount = [SOXMarket_BitcoinDE_Core availableAmountForCurrencyType:self.currencyType];
    if (self.sellMaximalBTCInvestment) {
        availableBTCAmount = [SOXFormatters lesserDecimalNumberFrom:self.sellMaximalBTCInvestment
                                                                and:availableBTCAmount];
    }


    NSString *note = @"error in tryToExecuteSellOrder";
    if ([orderMinAmountToSell isGreaterThan:availableBTCAmount]) {
        // minAmountToSell > availableBTCAmount => no sell possible
        note = [NSString stringWithFormat:@"NO SELL possible: orderMinAmo %@ > avaBTC %@ (not enough free BTC amount)"
                , [SOXFormatters stringForBTCNumber:orderMinAmountToSell]
                , [SOXFormatters stringForBTCNumber:availableBTCAmount]];
    }
    else if ([orderMinAmountToSell isEqualToNumber:availableBTCAmount]) {
        // minAmountToSell = availableBTCAmount => sell minAmount
        note = [NSString stringWithFormat:@"SELL possible: orderMinAmo %@ = avaBTC %@ (sell order.minAmount)"
                , [SOXFormatters stringForBTCNumber:orderMinAmountToSell]
                , [SOXFormatters stringForBTCNumber:availableBTCAmount]];

        btcAmountToSell = orderToSell.orderInformation_minAmount;
    }
    else if ([orderMaxAmountToSell isEqualToNumber:availableBTCAmount]) {
        note = [NSString stringWithFormat:@"SELL possible: orderMaxAmo %@ = avaBTC %@ (sell order.maxAmount)"
                , [SOXFormatters stringForBTCNumber:orderMinAmountToSell]
                , [SOXFormatters stringForBTCNumber:availableBTCAmount]];

        btcAmountToSell = orderToSell.orderInformation_maxAmount;
    }
    else if ([orderMinAmountToSell isLessThan:availableBTCAmount]) {
        // minAmountToSell < availableBTCAmount => sell more than minAmount (figure out, how much)
        note = [NSString stringWithFormat:@"SELL possible: orderMinAmo %@ < avaBTC %@ (figure out btcToBuyAmount now ...)"
                , [SOXFormatters stringForBTCNumber:orderMinAmountToSell]
                , [SOXFormatters stringForBTCNumber:availableBTCAmount]];
        NSDecimalNumber *volumeToSell = [SOXFormatters lesserDecimalNumberFrom:orderToSell.orderInformation_maxAmount
                                                                           and:availableBTCAmount];
        btcAmountToSell = volumeToSell;

    }

    if (btcAmountToSell) {
        btcAmountToSell = [self potentialBuyBalanceTradeAmountForSellAmount:btcAmountToSell
                                                               forSellPrice:orderToSell.orderInformation_price];
    }

    note = [note stringByAppendingString:[NSString stringWithFormat:@" potBuyAmount: %@"
                                          , btcAmountToSell]];

    [self informSellDelegateWithNote:note];
    return btcAmountToSell;
}

#pragma mark | Balance trade methods
- (NSDecimalNumber *)potentialBuyBalanceTradeAmountForSellAmount:(NSDecimalNumber *)sellAmount
                                                    forSellPrice:(NSDecimalNumber *)sellPrice {
    if (!self.executeBalanceTradesForSellTrades) {
        { // DEBUG
            [self informSellDelegateWithNote:@"---------------------------------"];
            NSString *note = [NSString stringWithFormat:@"start potentialBuyBalanceTradeAmountForSellAmount"];
            [self informSellDelegateWithNote:note];
            note = [NSString stringWithFormat:@"executeBalanceTradesForSellTrades == NO => we may sell without restriction"];
            [self informSellDelegateWithNote:note];
            [self informSellDelegateWithNote:@"---------------------------------"];
        }
        return sellAmount;
    }

    { // DEBUG
        [self informSellDelegateWithNote:@"---------------------------------"];
        NSString *note = [NSString stringWithFormat:@"start potentialBuyBalanceTradeAmountForSellAmount"];
        [self informSellDelegateWithNote:note];

        // log first items of buyOrderBook
        __block NSString *note2 = [NSString stringWithFormat:@"\nBUYORDERBOOK"];
        [self.buyOrderBook enumerateObjectsUsingBlock:^(SOXShowOrderbookData * _Nonnull buyOrderbookData,
                                                        NSUInteger idx,
                                                        BOOL * _Nonnull stop) {
            note2 = [note2 stringByAppendingString:
                     [NSString stringWithFormat:@"\nidx: %tu - oID: %@ - p: %@ - minA: %@ - maxA: %@ - payO: %@"
                      , idx
                      , buyOrderbookData.orderInformation_orderID
                      , [SOXFormatters currencyStringForNumber:buyOrderbookData.orderInformation_price roundingMode:NSNumberFormatterRoundHalfUp]
                      , [SOXFormatters stringForBTCNumber:buyOrderbookData.orderInformation_minAmount]
                      , [SOXFormatters stringForBTCNumber:buyOrderbookData.orderInformation_maxAmount]
                      , buyOrderbookData.orderRequirements_paymentOption]
                     ];

            if (idx > 9) {
                *stop = YES;
            }
        }];
        [self informSellDelegateWithNote:note2];


    }

    // we get 0,8% less bitcoins than we buy!
    NSDecimalNumber *fee = [NSDecimalNumber decimalNumberWithString:@"0.992"];
    sellAmount = [sellAmount decimalNumberByDividingBy:fee
                                          withBehavior:[SOXFormatters btcNumberHandler]];
    NSMutableArray *potentialBuyBalanceTradeParameters = [self buyBalanceTradeParametersForSellAmount:sellAmount
                                                                                         forSellPrice:sellPrice
                                                                            createPotentialParameters:YES];

    NSDecimalNumber *buyBalanceTradeAmount = [self sumOfBitcoinsOfParameters:potentialBuyBalanceTradeParameters];
    buyBalanceTradeAmount = [buyBalanceTradeAmount decimalNumberByMultiplyingBy:fee
                                                                   withBehavior:[SOXFormatters btcNumberHandler]];

    { // DEBUG
        NSString *note = [NSString stringWithFormat:@"found buyBalanceTradeAmount %@"
                          , buyBalanceTradeAmount];
        [self informSellDelegateWithNote:note];
        [self informSellDelegateWithNote:@"---------------------------------"];
    }
    return buyBalanceTradeAmount;
}

- (NSMutableArray *)buyBalanceTradeParametersForSellAmount:(NSDecimalNumber *)soldBTCAmount
                                              forSellPrice:(NSDecimalNumber *)soldPrice
                                 createPotentialParameters:(BOOL)createPotentialParameters {
    { // DEBUG
        [self informSellDelegateWithNote:@"   ----------------------------"];
        NSString *note = [NSString stringWithFormat:@"Start buyBalanceTradeParametersForSellAmount: %@ - forSellPrice: %@"
                          , soldBTCAmount
                          , soldPrice];
        [self informSellDelegateWithNote:note];
    }

    NSDecimalNumber *remainingBitcoinAmountToBuy = [soldBTCAmount copy];

    // add fee to price
    NSDecimalNumber *fee = [NSDecimalNumber decimalNumberWithString:@"1.008"];
    NSDecimalNumber *soldPriceWithFee = [soldPrice decimalNumberByDividingBy:fee
                                                                withBehavior:[SOXFormatters currencyNumberHandler]];

    { // DEBUG
        NSString *note = [NSString stringWithFormat:@"soldPriceWithFee (0,8%%): %@"
                          , soldPriceWithFee];
        [self informSellDelegateWithNote:note];
    }

    NSMutableArray *balanceBuyParameters = [NSMutableArray array];

    for (NSUInteger idx = 0; idx < self.buyOrderBook.count; idx++) {
        SOXShowOrderbookData *buyOrder = [self.buyOrderBook objectAtIndex:idx];

        { // DEBUG
            NSString *note = [NSString stringWithFormat:@"buyOrder - price: %@ - minA: %@ - maxA: %@ (idx: %tu)"
                              , buyOrder.orderInformation_price
                              , buyOrder.orderInformation_minAmount
                              , buyOrder.orderInformation_maxAmount
                              , idx];
            [self informSellDelegateWithNote:note];
        }

        if ([buyOrder.orderInformation_price isGreaterThan:soldPriceWithFee]) {
            { // DEBUG
                NSString *note = [NSString stringWithFormat:@"buyOrder.orderInformation_price isGreaterThan:soldPriceWithFee => break"];
                [self informSellDelegateWithNote:note];
            }
            break;
        }

        if ([buyOrder.orderInformation_minAmount isLessThanOrEqualTo:remainingBitcoinAmountToBuy]) {
            { // DEBUG
                NSString *note = [NSString stringWithFormat:
                                  @"[buyOrder.orderInformation_minAmount %@ "
                                  "isLessThanOrEqualTo:remainingBitcoinAmountToBuy %@] => look for amountToSell"
                                  , buyOrder.orderInformation_minAmount
                                  , remainingBitcoinAmountToBuy];
                [self informSellDelegateWithNote:note];
            }

            // create sellParameter
            NSDecimalNumber *amountToBuy = [SOXFormatters lesserDecimalNumberFrom:remainingBitcoinAmountToBuy
                                                                               and:buyOrder.orderInformation_maxAmount];
            NSDictionary *buyParameters = [SOXTradeJob_BitcoinDE_Data parameterBalanceTradingForOrderID:buyOrder.orderInformation_orderID
                                                                                              orderType:BitcoinDE_BuyOrderType
                                                                                          bitcoinAmount:amountToBuy
                                                                                                  price:buyOrder.orderInformation_price
                                                                                    automaticTradePrice:soldPrice
                                                                                        forCurrencyType:self.currencyType];
            [balanceBuyParameters addObject:buyParameters];
            remainingBitcoinAmountToBuy = [remainingBitcoinAmountToBuy decimalNumberBySubtracting:amountToBuy
                                                                                     withBehavior:[SOXFormatters btcNumberHandler]];

            { // DEBUG
                NSString *note = [NSString stringWithFormat:@"=> amountToBuy %@ => remainingBitcoinAmountToBuy %@"
                                  , amountToBuy
                                  , remainingBitcoinAmountToBuy];
                [self informSellDelegateWithNote:note];
            }

            if ([remainingBitcoinAmountToBuy isEqualTo:[NSDecimalNumber zero]]) {
                { // DEBUG
                    NSString *note = [NSString stringWithFormat:@"remainingBitcoinAmountToBuy == 0 => break"];
                    [self informSellDelegateWithNote:note];
                }
                break;
            }
            else if ([remainingBitcoinAmountToBuy isLessThan:[NSDecimalNumber zero]]) {
                { // DEBUG
                    NSString *note = [NSString stringWithFormat:@"!!!! ERROR !!!!"];
                    [self informSellDelegateWithNote:note];
                    note = [NSString stringWithFormat:@"remainingBitcoinAmountToBuy %@ is less than 0! (in buyBalanceTradeParametersForSellAmount)"
                            , remainingBitcoinAmountToBuy];
                    [self informSellDelegateWithNote:note];
                    note = [NSString stringWithFormat:@"!!!! ERROR !!!!"];
                    [self informSellDelegateWithNote:note];
                }
            }
        }
    }
    if (!createPotentialParameters) {
        if ([remainingBitcoinAmountToBuy isGreaterThan:[NSDecimalNumber zero]]) {
            [self addBuyBacklogForRemainingBitcoinAmountToBuy:remainingBitcoinAmountToBuy
                                                 forSoldPrice:soldPrice];
        }
    }

    { // DEBUG
        NSString *note = [NSString stringWithFormat:@"found %tu balanceBuyParameters (remainingBitcoinAmountToBuy: %@)"
                          , balanceBuyParameters.count
                          , remainingBitcoinAmountToBuy];
        [self informSellDelegateWithNote:note];
        [self informSellDelegateWithNote:@"----------------------------"];
    }

    return balanceBuyParameters;
}

- (NSDecimalNumber *)potentialSellBalanceTradeAmountForBuyAmount:(NSDecimalNumber *)buyAmount
                                                     forBuyPrice:(NSDecimalNumber *)buyPrice {

    if (!self.executeBalanceTradesForBuyTrades) {
//        { // DEBUG
//            [self informBuyDelegateWithNote:@"---------------------------------"];
//            NSString *note = [NSString stringWithFormat:@"start potentialBuyBalanceTradeAmountForSellAmount"];
//            [self informBuyDelegateWithNote:note];
//            note = [NSString stringWithFormat:@"executeBalanceTradesForBuyTrades == NO => we may buy without restriction"];
//            [self informBuyDelegateWithNote:note];
//            [self informBuyDelegateWithNote:@"---------------------------------"];
//        }
        return buyAmount;
    }

//    { // DEBUG
//        [self informBuyDelegateWithNote:@"---------------------------------"];
//        NSString *note = [NSString stringWithFormat:@"start potentialSellBalanceTradeAmountForBuyAmount"];
//        [self informBuyDelegateWithNote:note];
//
//        // log first items of sellOrderBook
//        __block NSString *note2 = [NSString stringWithFormat:@"\nSELLORDERBOOK"];
//        [self.sellOrderBook enumerateObjectsUsingBlock:^(SOXShowOrderbookData * _Nonnull sellOrderbookData,
//                                                         NSUInteger idx,
//                                                         BOOL * _Nonnull stop) {
//            note2 = [note2 stringByAppendingString:
//                     [NSString stringWithFormat:@"\nidx: %tu - oID: %@ - p: %@ - minA: %@ - maxA: %@ - payO: %@"
//                      , idx
//                      , sellOrderbookData.orderInformation_orderID
//                      , [SOXFormatters currencyStringForNumber:sellOrderbookData.orderInformation_price roundingMode:NSNumberFormatterRoundHalfUp]
//                      , [SOXFormatters stringForBTCNumber:sellOrderbookData.orderInformation_minAmount]
//                      , [SOXFormatters stringForBTCNumber:sellOrderbookData.orderInformation_maxAmount]
//                      , sellOrderbookData.orderRequirements_paymentOption]
//                     ];
//
//            if (idx > 9) {
//                *stop = YES;
//            }
//        }];
//        [self informBuyDelegateWithNote:note2];
//    }

    // consider fee - we get 0,8% less bitcoins than we buy!
    NSDecimalNumber *fee = [NSDecimalNumber decimalNumberWithString:@"0.992"];
    buyAmount = [buyAmount decimalNumberByMultiplyingBy:fee
                                           withBehavior:[SOXFormatters btcNumberHandler]];

    NSMutableArray *potentialSellBalanceTradeParameters = [self sellBalanceTradeParametersForBuyAmount:buyAmount
                                                                                           forBuyPrice:buyPrice
                                                                             createPotentialParameters:YES];

    NSDecimalNumber *sellBalanceTradeAmount = [self sumOfBitcoinsOfParameters:potentialSellBalanceTradeParameters];
    sellBalanceTradeAmount = [sellBalanceTradeAmount decimalNumberByDividingBy:fee
                                                                  withBehavior:[SOXFormatters btcNumberHandler]];


//    { // DEBUG
//        NSString *note = [NSString stringWithFormat:@"found potentialSellBalanceTradeAmountForBuyAmount %@"
//                          , sellBalanceTradeAmount];
//        [self informBuyDelegateWithNote:note];
//        [self informBuyDelegateWithNote:@"---------------------------------"];
//    }
    return sellBalanceTradeAmount;
}

- (NSMutableArray *)sellBalanceTradeParametersForBuyAmount:(NSDecimalNumber *)boughtBTCAmount
                                               forBuyPrice:(NSDecimalNumber *)boughtPrice
                                 createPotentialParameters:(BOOL)createPotentialParameters {

//    { // DEBUG
//        [self informBuyDelegateWithNote:@"   ----------------------------"];
//        NSString *note = [NSString stringWithFormat:@"Start sellBalanceTradeParametersForBuyAmount: %@ - forBuyPrice: %@"
//                          , boughtBTCAmount
//                          , boughtPrice];
//        [self informBuyDelegateWithNote:note];
//    }

    NSDecimalNumber *remainingBitcoinAmountToSell = [boughtBTCAmount copy];

    // add fee to price - we get 0,8% less bitcoins than we buy!
    NSDecimalNumber *fee = [NSDecimalNumber decimalNumberWithString:@"1.008"];
    NSDecimalNumber *boughtPriceWithFee = [boughtPrice decimalNumberByMultiplyingBy:fee
                                                                       withBehavior:[SOXFormatters currencyNumberHandler]];

//    { // DEBUG
//        NSString *note = [NSString stringWithFormat:@"boughtPriceWithFee (0,8%%): %@"
//                          , boughtPriceWithFee];
//        [self informBuyDelegateWithNote:note];
//    }

    NSMutableArray *balanceSellParameters = [NSMutableArray array];

    for (NSUInteger idx = 0; idx < self.sellOrderBook.count; idx++) {
        SOXShowOrderbookData *sellOrder = [self.sellOrderBook objectAtIndex:idx];

//        { // DEBUG
//            NSString *note = [NSString stringWithFormat:@"sellOrder - price: %@ - minA: %@ - maxA: %@ (idx: %tu)"
//                              , sellOrder.orderInformation_price
//                              , sellOrder.orderInformation_minAmount
//                              , sellOrder.orderInformation_maxAmount
//                              , idx];
//            [self informBuyDelegateWithNote:note];
//        }

        if ([sellOrder.orderInformation_price isLessThan:boughtPriceWithFee]) {
//            { // DEBUG
//                NSString *note = [NSString stringWithFormat:@"sellOrder.orderInformation_price isLessThan:boughtPriceWithFee => break"];
//                [self informBuyDelegateWithNote:note];
//            }
            break;
        }

        if ([sellOrder.orderInformation_minAmount isLessThanOrEqualTo:remainingBitcoinAmountToSell]) {
//            { // DEBUG
//                NSString *note = [NSString stringWithFormat:
//                                  @"[sellOrder.orderInformation_minAmount %@ "
//                                  "isLessThanOrEqualTo:remainingBitcoinAmount %@] => look for amountToSell"
//                                  , sellOrder.orderInformation_minAmount
//                                  , remainingBitcoinAmountToSell];
//                [self informBuyDelegateWithNote:note];
//            }

            // create sellParameter
            NSDecimalNumber *amountToSell = [SOXFormatters lesserDecimalNumberFrom:remainingBitcoinAmountToSell
                                                                               and:sellOrder.orderInformation_maxAmount];
            NSDictionary *sellParameters = [SOXTradeJob_BitcoinDE_Data parameterBalanceTradingForOrderID:sellOrder.orderInformation_orderID
                                                                                               orderType:BitcoinDE_SellOrderType
                                                                                           bitcoinAmount:amountToSell
                                                                                                   price:sellOrder.orderInformation_price
                                                                                     automaticTradePrice:boughtPrice
                                                                                         forCurrencyType:self.currencyType];
            [balanceSellParameters addObject:sellParameters];
            remainingBitcoinAmountToSell = [remainingBitcoinAmountToSell decimalNumberBySubtracting:amountToSell
                                                                                       withBehavior:[SOXFormatters btcNumberHandler]];

//            { // DEBUG
//                NSString *note = [NSString stringWithFormat:@"=> amountToSell %@ => remainingBitcoinAmountToSell %@"
//                                  , amountToSell
//                                  , remainingBitcoinAmountToSell];
//                [self informBuyDelegateWithNote:note];
//            }

            if ([remainingBitcoinAmountToSell isEqualTo:[NSDecimalNumber zero]]) {
//                { // DEBUG
//                    NSString *note = [NSString stringWithFormat:@"remainingBitcoinAmountToSell == 0 => break"];
//                    [self informBuyDelegateWithNote:note];
//                }
                break;
            }
            else if ([remainingBitcoinAmountToSell isLessThan:[NSDecimalNumber zero]]) {
                { // DEBUG
                    NSString *note = [NSString stringWithFormat:@"!!!! ERROR !!!!"];
                    [self informBuyDelegateWithNote:note];
                    note = [NSString stringWithFormat:@"remainingBitcoinAmountToSell %@ is less than 0! (in sellBalanceTradeParametersForBuyAmount)"
                            , remainingBitcoinAmountToSell];
                    [self informBuyDelegateWithNote:note];
                    note = [NSString stringWithFormat:@"!!!! ERROR !!!!"];
                    [self informBuyDelegateWithNote:note];
                }
            }
        }
    }

    if (!createPotentialParameters) {
        if ([remainingBitcoinAmountToSell isGreaterThan:[NSDecimalNumber zero]]) {
            [self addSellBacklogForRemainingBitcoinAmountToSell:remainingBitcoinAmountToSell
                                                 forBoughtPrice:boughtPrice];
        }
    }

//    { // DEBUG
//        NSString *note = [NSString stringWithFormat:@"found %tu balanceSellParameters (remainingBitcoinAmountToSell: %@)"
//                          , balanceSellParameters.count
//                          , remainingBitcoinAmountToSell];
//        [self informBuyDelegateWithNote:note];
//        [self informBuyDelegateWithNote:@"----------------------------"];
//    }

    return balanceSellParameters;
}

#pragma mark | Subclass dummies
+ (BOOL)registerForWebSocketUpdates {
    [SOXAutomaticTradingCore missedImplementation:@"+ (BOOL)registerForWebSocketUpdates"];
    return NO;
}

- (void)addBuyBacklogForRemainingBitcoinAmountToBuy:(NSDecimalNumber *)remainingBitcoinAmountToBuy
                                       forSoldPrice:(NSDecimalNumber *)soldPrice {
    return;
    [SOXAutomaticTradingCore missedImplementation:
     @"- (void)addBuyBacklogForRemainingBitcoinAmountToBuy:(NSDecimalNumber *)remainingBitcoinAmountToBuy "
     "forSoldPrice:(NSDecimalNumber *)soldPrice"];
}
- (void)addSellBacklogForRemainingBitcoinAmountToSell:(NSDecimalNumber *)remainingBitcoinAmountToSell
                                       forBoughtPrice:(NSDecimalNumber *)boughtPrice {
    return;
    [SOXAutomaticTradingCore missedImplementation:
     @"- (void)addSellBacklogForRemainingBitcoinAmountToSell:(NSDecimalNumber *)remainingBitcoinAmountToSell "
     "forBoughtPrice:(NSDecimalNumber *)boughtPrice"];
}

- (void)createBalanceTradesForBoughtTrades {
    [SOXAutomaticTradingCore missedImplementation:@"- (void)createBalanceTradesForBoughtTrades"];
}

- (void)createBalanceTradesForSoldTrades {
    [SOXAutomaticTradingCore missedImplementation:@"- (void)createBalanceTradesForSoldTrades"];
}

- (void)tryToBuy:(SOXShowOrderbookData *)orderToBuy btcAmountToBuy:(NSDecimalNumber *)btcAmountToBuy {
    [SOXAutomaticTradingCore missedImplementation:@"- (void)tryToBuy:(SOXShowOrderbookData *)orderToBuy btcAmountToBuy:(NSDecimalNumber *)btcAmountToBuy"];
}

- (void)tryToSell:(SOXShowOrderbookData *)orderToSell btcAmountToSell:(NSDecimalNumber *)btcAmountToSell {
    [SOXAutomaticTradingCore missedImplementation:@"- (void)tryToSell:(SOXShowOrderbookData *)orderToSell btcAmountToSell:(NSDecimalNumber *)btcAmountToSell"];
}

- (void)updateBannerAfterSuccessfulAutomaticBuyTrade {
    [SOXAutomaticTradingCore missedImplementation:@"- (void)updateBannerAfterSuccessfulAutomaticBuyTrade"];
}

- (void)updateBannerAfterSuccessfulBalanceTrades {
    [SOXAutomaticTradingCore missedImplementation:@"- (void)updateBannerAfterSuccessfulBalanceTrades"];
}

#pragma mark - Handle (un)successful trade responses
#pragma mark | Auto trade responses
- (void)successfulAutomaticBuyTrade:(NSDictionary *)tradeParameters {
    { // DEBUG
        NSString *note = [NSString stringWithFormat:@"successfulAutomaticBuyTrade tradeParameters:\n%@",
                          tradeParameters];
        [self informBuyDelegateWithNote:note];
    }

    [self.runningAutomaticBuyTradeParameters removeObject:tradeParameters];

    NSMutableDictionary *tradeParametersWithFee = [tradeParameters mutableCopy];

    { // calculate bitcoins with fee
        NSDecimalNumber *boughtBitcoins = [tradeParameters objectForKey:BitcoinDE_ExecuteTrade_BitcoinAmount];
        NSDecimalNumber *bitcoinFee = [NSDecimalNumber decimalNumberWithString:@"0.992"];
        NSDecimalNumber *balanceBitcoins = [boughtBitcoins decimalNumberByMultiplyingBy:bitcoinFee
                                                                           withBehavior:[SOXFormatters btcNumberHandler]];

        [tradeParametersWithFee setObject:balanceBitcoins forKey:BitcoinDE_ExecuteTrade_BitcoinAmount];
        // TODO:  consider fee for price here ?!
    }
    [self.successfulAutomaticBuyTradeParameters addObject:[tradeParametersWithFee copy]];

    // balance trades after banner update
    [self updateBannerAfterSuccessfulAutomaticBuyTrade];
}

- (void)unSuccessfulAutomaticBuyTrade:(NSDictionary *)tradeParameters {
    { // DEBUG
        NSString *note = [NSString stringWithFormat:@"unSuccessfulAutomaticBuyTrade tradeParameters:\n%@",
                          tradeParameters];
        [self informBuyDelegateWithNote:note];
    }
    [self.runningAutomaticBuyTradeParameters removeObject:tradeParameters];

    // Buy trade was not successful, but maybe the faster buyer did not bought the whole bunch of coins
    // So let's look for a replacement order in orderBook.
    // 12.2.18: disabled code: wir hatten eine Kaskade von "Wir versuchen den Ersatztrade" und waren jedesmal
    //          zu langsam; bekamen dann den darauffolgenden Ersatz auch nicht, da wir noch auf die Antwort
    //          des 1. Ersatztrades warten
//    { // DEBUG
//        NSString *note = [NSString stringWithFormat:@"Look for replacement order for unsuccessful autoBuy trade"];
//        [self informBuyDelegateWithNote:note];
//    }
//    [self checkForBuyableOrder];

    [self checkForBalanceTradesForBoughtTrades];
}

- (void)successfulAutomaticSellTrade:(NSDictionary *)tradeParameters {
    { // DEBUG
        NSString *note = [NSString stringWithFormat:@"successfulAutomaticSellTrade tradeParameters:\n%@",
                          tradeParameters];
        [self informSellDelegateWithNote:note];
    }
    [self.runningAutomaticSellTradeParameters removeObject:tradeParameters];

    NSMutableDictionary *tradeParametersWithFee = [tradeParameters mutableCopy];

    { // calculate bitcoins with fee
        NSDecimalNumber *soldBitcoins = [tradeParameters objectForKey:BitcoinDE_ExecuteTrade_BitcoinAmount];
        NSDecimalNumber *bitcoinFee = [NSDecimalNumber decimalNumberWithString:@"0.992"];
        NSDecimalNumber *balanceBitcoins = [soldBitcoins decimalNumberByDividingBy:bitcoinFee
                                                                      withBehavior:[SOXFormatters btcNumberHandler]];

        [tradeParametersWithFee setObject:balanceBitcoins forKey:BitcoinDE_ExecuteTrade_BitcoinAmount];
        // TODO:  consider fee for price here ?!
    }
    [self.successfulAutomaticSellTradeParameters addObject:[tradeParametersWithFee copy]];
    
    [self checkForBalanceTradesForSoldTrades]; // no banner update needed, we just balance out
}

- (void)unSuccessfulAutomaticSellTrade:(NSDictionary *)tradeParameters {
    { // DEBUG
        NSString *note = [NSString stringWithFormat:@"unSuccessfulAutomaticSellTrade tradeParameters:\n%@",
                          tradeParameters];
        [self informSellDelegateWithNote:note];
    }
    [self.runningAutomaticSellTradeParameters removeObject:tradeParameters];

    // Buy trade was not successful, but maybe the faster buyer did not bought the whole bunch of coins
    // So let's look for a replacement order in orderBook.
    { // DEBUG
        NSString *note = [NSString stringWithFormat:@"Look for replacement order for unsuccessful autoSell trade"];
        [self informSellDelegateWithNote:note];
    }
    [self checkForSellableOrder];

    [self checkForBalanceTradesForSoldTrades];
}

#pragma mark | Balance trade responses
- (void)successfulBalanceBuyTrade:(NSDictionary *)tradeParameters {
    { // DEBUG
        NSString *note = [NSString stringWithFormat:@"successfulBalanceBuyTrade tradeParameters:\n%@",
                          tradeParameters];
        [self informSellDelegateWithNote:note];
    }

    [self.runningBalanceBuyTradeParameters removeObject:tradeParameters];

    NSMutableDictionary *tradeParametersWithFee = [tradeParameters mutableCopy];
    { // calculate bitcoins with fee
        NSDecimalNumber *boughtBitcoins = [tradeParameters objectForKey:BitcoinDE_ExecuteTrade_BitcoinAmount];
        NSDecimalNumber *bitcoinFee = [NSDecimalNumber decimalNumberWithString:@"0.992"];
        NSDecimalNumber *balanceBitcoins = [boughtBitcoins decimalNumberByMultiplyingBy:bitcoinFee
                                                                           withBehavior:[SOXFormatters btcNumberHandler]];

        [tradeParametersWithFee setObject:balanceBitcoins forKey:BitcoinDE_ExecuteTrade_BitcoinAmount];
        // TODO:  consider fee for price here ?!
    }

    [self.successfulBalanceBuyTradeParameters addObject:[tradeParametersWithFee copy]];
    [self checkForBalanceTradesForSoldTrades];
}

- (void)unSuccessfulBalanceBuyTrade:(NSDictionary *)tradeParameters errorCode:(NSNumber *)errorCode {
    { // DEBUG
        NSString *note = [NSString stringWithFormat:@"unSuccessfulBalanceBuyTrade tradeParameters:\n%@",
                          tradeParameters];
        [self informSellDelegateWithNote:note];
    }

    // remove from stack
    [self.runningBalanceBuyTradeParameters removeObject:tradeParameters];

    // on invalide nonce error retry to balance
    if ([errorCode isEqualToNumber:@4]) {
        { // DEBUG
            NSString *note = [NSString stringWithFormat:@"retry balanceBuy"];
            [self informSellDelegateWithNote:note];
        }
        NSString *orderTypeString = [tradeParameters objectForKey:BitcoinDE_ExecuteTrade_Type];  //=> buy oder sell
        BitcoinDE_OrderType orderType = [SOXMarket_BitcoinDE_DefTypes orderTypeForOrderTypeString:orderTypeString];


        [self tryToExecuteBalanceTradesWithParameters:@[tradeParameters]
                                         forOrderType:orderType];
    }
    else {
        [self.successfulAutomaticSellTradeParameters addObject:tradeParameters];
        [self checkForBalanceTradesForSoldTrades];
    }
}

- (void)successfulBalanceSellTrade:(NSDictionary *)tradeParameters {
    { // DEBUG
        NSString *note = [NSString stringWithFormat:@"successfulBalanceSellTrade tradeParameters:\n%@",
                          tradeParameters];
        [self informBuyDelegateWithNote:note];
    }

    [self.runningBalanceSellTradeParameters removeObject:tradeParameters];
    [self.successfulBalanceSellTradeParameters addObject:tradeParameters];
    [self checkForBalanceTradesForBoughtTrades];
}

- (void)unSuccessfulBalanceSellTrade:(NSDictionary *)tradeParameters errorCode:(NSNumber *)errorCode {
    { // DEBUG
        NSString *note = [NSString stringWithFormat:@"unSuccessfulBalanceSellTrade tradeParameters:\n%@",
                          tradeParameters];
        [self informBuyDelegateWithNote:note];
    }
    [self.runningBalanceSellTradeParameters removeObject:tradeParameters];

    // on invalide nonce error retry to balance
    if ([errorCode isEqualToNumber:@4]) {
        { // DEBUG
            NSString *note = [NSString stringWithFormat:@"retry balanceSell"];
            [self informBuyDelegateWithNote:note];
        }

        NSString *orderTypeString = [tradeParameters objectForKey:BitcoinDE_ExecuteTrade_Type];  //=> buy oder sell
        BitcoinDE_OrderType orderType = [SOXMarket_BitcoinDE_DefTypes orderTypeForOrderTypeString:orderTypeString];
        [self tryToExecuteBalanceTradesWithParameters:@[tradeParameters]
                                         forOrderType:orderType];
    }
    else {
        [self.successfulAutomaticBuyTradeParameters addObject:tradeParameters];
        [self checkForBalanceTradesForBoughtTrades];
    }
}

#pragma mark | Helpers
- (void)checkForBalanceTradesForBoughtTrades {
    [self informBuyDelegateAboutRunningQueues];
    if (!self.executeBalanceTradesForBuyTrades) {
        return;
    }
    { // DEBUG
        NSString *note = [NSString stringWithFormat:@"checkForBalanceTradesForBoughtTrades:\n"
                          "self.runningBalanceSellTradeParameters.count:    %tu\n"
                          "self.successfulBalanceSellTradeParameters.count: %tu\n"
                          "self.boughtTradeParametersBacklog.count:         %tu"
                          , self.runningBalanceSellTradeParameters.count
                          , self.successfulBalanceSellTradeParameters.count
                          , self.successfulAutomaticBuyTradeParameters.count];
        [self informBuyDelegateWithNote:note];
    }

    if (self.runningAutomaticBuyTradeParameters.count == 0
        && self.runningBalanceSellTradeParameters.count == 0
        && self.successfulAutomaticBuyTradeParameters.count > 0) {
        {// DEBUG
            NSString *note = [NSString stringWithFormat:@"checkForBalanceTradesForBoughtTrades\n"
                              "self.boughtTradeParametersBacklog.count: %tu"
                              , self.successfulAutomaticBuyTradeParameters.count];
            [self informBuyDelegateWithNote:note];
        }
        [self createBalanceTradesForBoughtTrades];
    }
    else if (self.runningAutomaticBuyTradeParameters.count == 0
             && self.runningBalanceSellTradeParameters.count == 0
             && self.successfulBalanceSellTradeParameters.count > 0) {
        {// DEBUG
            NSString *note = [NSString stringWithFormat:@"checkForBalanceTradesForBoughtTrades\n"
                              "self.successfulBalanceSellTradeParameters.count: %tu (removed now)"
                              , self.successfulBalanceSellTradeParameters.count];
            [self informBuyDelegateWithNote:note];
        }

        [self updateBannerAfterSuccessfulBalanceTrades];
    }
}

- (void)checkForBalanceTradesForSoldTrades {
    [self informSellDelegateAboutRunningQueues];
    if (!self.executeBalanceTradesForSellTrades) {
        return;
    }
    { // DEBUG
        NSString *note = [NSString stringWithFormat:@"checkForBalanceTradesForSoldTrades:\n"
                          "self.runningBalanceBuyTradeParameters.count:     %tu\n"
                          "self.successfulBalanceSellTradeParameters.count: %tu\n"
                          "self.soldTradeParametersBacklog.count:           %tu"
                          , self.runningBalanceSellTradeParameters.count
                          , self.successfulBalanceSellTradeParameters.count
                          , self.successfulAutomaticSellTradeParameters.count];
        [self informSellDelegateWithNote:note];
    }
    if (self.runningAutomaticSellTradeParameters.count == 0
        && self.runningBalanceBuyTradeParameters.count == 0
        && self.successfulAutomaticSellTradeParameters.count > 0) {
        {// DEBUG
            NSString *note = [NSString stringWithFormat:@"checkForBalanceTradesForSoldTrades:\n"
                              "self.soldTradeParametersBacklog.count: %tu"
                              , self.successfulAutomaticBuyTradeParameters.count];
            [self informSellDelegateWithNote:note];
        }
        [self createBalanceTradesForSoldTrades];
    }
    else if (self.runningAutomaticSellTradeParameters.count == 0
             && self.runningBalanceBuyTradeParameters.count == 0
             && self.successfulBalanceBuyTradeParameters.count > 0) {
        {// DEBUG
            NSString *note = [NSString stringWithFormat:@"checkForBalanceTradesForSoldTrades\n"
                              "self.successfulBalanceBuyTradeParameters.count: %tu (removed now)"
                              , self.successfulBalanceBuyTradeParameters.count];
            [self informSellDelegateWithNote:note];
        }

        [self updateBannerAfterSuccessfulBalanceTrades];
    }
}

#pragma mark - Math Helpers
- (NSDecimalNumber *)sumOfBitcoinsOfParameters:(NSArray <NSDictionary *>*)parameters {
    if (!parameters
        || parameters.count == 0) {
        return [NSDecimalNumber zero];
    }

    NSString *sumOfBitcoinsKeyPath = [NSString stringWithFormat:@"@sum.%@", @"amount"];
    NSDecimalNumber *sumOfBitcoins = [parameters valueForKeyPath:sumOfBitcoinsKeyPath];

    return sumOfBitcoins;
}


#pragma mark - Inform delegates
- (void)informBuyDelegateWithNote:(NSString *)note {
    if (note) {
        DDLogInfo(@"%@ buyDele: %@"
                  , [SOXMarket_BitcoinDE_DefTypes tradingPairShortStringLowerCaseForCurrencyType:self.currencyType]
                  , note);

        for (NSObject <SOXAutomaticTradingCoreProtocol> *delegate in self.buyDelegates) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate performSelector:@selector(logLine:)
                               withObject:note
                 ];
            });
        }
    }
}
- (void)informSellDelegateWithNote:(NSString *)note {

    if (note) {
        DDLogInfo(@"%@ sellDele: %@"
                  , [SOXMarket_BitcoinDE_DefTypes tradingPairShortStringLowerCaseForCurrencyType:self.currencyType]
                  , note);

        for (NSObject <SOXAutomaticTradingCoreProtocol> *delegate in self.sellDelegates) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate performSelector:@selector(logLine:)
                               withObject:note
                 ];
            });
        }
    }
}

- (void)informBuyDelegateWithStatus:(NSString *)status {
    if (status) {
        for (NSObject <SOXAutomaticTradingCoreProtocol> *delegate in self.buyDelegates) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate performSelector:@selector(statusUpdate:)
                               withObject:status
                 ];
            });
        }
    }
}

- (void)informSellDelegateWithStatus:(NSString *)status {
    if (status) {
        for (NSObject <SOXAutomaticTradingCoreProtocol> *delegate in self.sellDelegates) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate performSelector:@selector(statusUpdate:)
                               withObject:status
                 ];
            });
        }
    }
}

#pragma mark | Helpers
- (void)updateBuyStatus {

    SOXShowOrderbookData *bestOrderData = self.buyOrderBook.firstObject;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *status;
        if (bestOrderData) {
            NSDecimalNumber *bestOrderDataPrice = bestOrderData.orderInformation_price;
            NSDecimalNumber *buyLowerThanPrice = [bestOrderDataPrice decimalNumberByMultiplyingBy:self.buyInterestFactor
                                                                                     withBehavior:[SOXFormatters currencyNumberHandler]];
            status = [NSString stringWithFormat:@"Bestprice %@, buy < %@\naBuy %tu bSell %tu"
                      , [SOXFormatters currencyStringForNumber:bestOrderDataPrice roundingMode:NSNumberFormatterRoundDown]
                      , [SOXFormatters currencyStringForNumber:buyLowerThanPrice roundingMode:NSNumberFormatterRoundDown]
                      , self.runningAutomaticBuyTradeParameters.count
                      , self.runningBalanceSellTradeParameters.count];
        }
        else {
            status = @"An error occured! No buyOrderBook";
        }

        [self informBuyDelegateWithStatus:status];
        [self informBuyDelegateWithNote:status];
    });
}

- (void)updateSellStatus {
    dispatch_async(dispatch_get_main_queue(), ^{
        SOXShowOrderbookData *bestOrderData = self.sellOrderBook.firstObject;
        NSString *status;
        if (bestOrderData) {
            NSDecimalNumber *bestOrderDataPrice = bestOrderData.orderInformation_price;
            NSDecimalNumber *sellGreaterThanPrice = [bestOrderDataPrice decimalNumberByMultiplyingBy:self.sellInterestFactor
                                                                                        withBehavior:[SOXFormatters currencyNumberHandler]];
            status = [NSString stringWithFormat:@"Bestprice %@, sell > %@\naSell %tu bBuy %tu"
                      , [SOXFormatters currencyStringForNumber:bestOrderDataPrice roundingMode:NSNumberFormatterRoundDown]
                      , [SOXFormatters currencyStringForNumber:sellGreaterThanPrice roundingMode:NSNumberFormatterRoundDown]
                      , self.runningAutomaticSellTradeParameters.count
                      , self.runningBalanceBuyTradeParameters.count];
        }
        else {
            status = @"An error occured! No sellOrderBook";
        }

        [self informSellDelegateWithStatus:status];
        [self informSellDelegateWithNote:status];
    });
}

- (NSString *)runningQueueNote {
    NSString *runningQueueNote = [NSString stringWithFormat:@"RUNNING.count: aBuy %tu - aSell %tu - bBuy %tu - bSell %tu - bBacklog %tu - sBacklog %tu"
                                  , self.runningAutomaticBuyTradeParameters.count
                                  , self.runningAutomaticSellTradeParameters.count
                                  , self.runningBalanceBuyTradeParameters.count
                                  , self.runningBalanceSellTradeParameters.count
                                  , self.successfulAutomaticBuyTradeParameters.count
                                  , self.successfulAutomaticSellTradeParameters.count];
    return runningQueueNote;
}

- (void)informBuyDelegateAboutRunningQueues {
    [self informBuyDelegateWithNote:[self runningQueueNote]];
}
- (void)informSellDelegateAboutRunningQueues {
    [self informSellDelegateWithNote:[self runningQueueNote]];
}

#pragma mark - SOXSocketIOCoreStatusProtocol
- (void)socketIODidConnect:(NSString *)socketStatus {
    [self informBuyDelegateWithNote:socketStatus];
    [self informSellDelegateWithNote:socketStatus];
    if (self.socketIODidDisconnectAppeared) {
        self.socketIODidDisconnectAppeared = NO;
        [[self class] registerForWebSocketUpdates];
    }
}

- (void)socketIODidDisconnect:(NSString *)socketStatus {
    [self informBuyDelegateWithNote:socketStatus];
    [self informSellDelegateWithNote:socketStatus];

    // Flush all orderBooks
    [self flushAllOrderBooks];
}

- (void)socketIOError:(NSString *)socketError {
    [self informBuyDelegateWithNote:socketError];
    [self informSellDelegateWithNote:socketError];
}

@end
