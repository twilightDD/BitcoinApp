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
    [self setBuyInterestRate:[NSDecimalNumber one]];
    [self setBuyInterestFactor:[NSDecimalNumber one]];

    [self setBuySEPAOrderBook:[NSMutableSet set]];
    [self setSellSEPAOrderBook:[NSMutableSet set]];

    [self setBuyOrderBookInExecution:[NSMutableArray array]];
    [self setSellOrderBookInExecution:[NSMutableArray array]];

    [self setSuccessfulAutomaticBuyTradeParameters:[NSMutableArray array]];
    [self setSuccessfulBalanceSellTradeParameters:[NSMutableArray array]];

    [self setRunningAutomaticBuyTradeParameters:[NSMutableArray array]];
    [self setRunningBalanceSellTradeParameters:[NSMutableArray array]];

    self.executeBuyTrades = NO;
    self.executeAutomaticTradesForBuyTrades = NO;
    self.executeBalanceTradesForBuyTrades = NO;
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
        }

        [self.buyOrderBook removeAllObjects];
        [self.buySEPAOrderBook removeAllObjects];
        [self.sellOrderBook removeAllObjects];
        [self.sellSEPAOrderBook removeAllObjects];

        [self updateBuyStatus];
        for (NSObject <SOXAutomaticTradingCoreProtocol> *delegate in self.buyDelegates) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate performSelector:@selector(flushLogView)];
            });
        }


        { // DEBUG
            NSString *note = [NSString stringWithFormat:@"Did flush all orderBooks. Count of orderBooks after:\n"
                              "%tu buyOrderBook\n"
                              "%tu buySEPAOrderBook\n"
                              "%tu sellOrderBook\n"
                              "%tu sellSEPAOrderBook\n"
                              "------------------------",
                              self.buyOrderBook.count, self.buySEPAOrderBook.count, self.sellOrderBook.count, self.sellSEPAOrderBook.count];
            [self informBuyDelegateWithNote:note];
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

- (void)setBuyMaximalFidorAmount:(NSDecimalNumber *)buyMaximalFidorAmountInvestment {
    if (buyMaximalFidorAmountInvestment) {
        _buyMaximalFidorAmountInvestment = buyMaximalFidorAmountInvestment;
        NSString *note = [NSString stringWithFormat:@"UPDATE VALUE: Set maximal trading volume to %@ €", self.buyMaximalFidorAmountInvestment];
        [self informBuyDelegateWithNote:note];
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
        [self informBuyDelegateWithNote:note];
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
        btcAmountToBuy = orderToBuy.orderInformation_minAmount;
    }
    else if ([orderToBuyMaxVolume isEqual:availableFidorAmount]) {
        // minVolume = availableAmount => buy minAmount
        btcAmountToBuy = orderToBuy.orderInformation_maxAmount;
    }
    else if ([orderToBuyMinVolume isLessThan:availableFidorAmount]) {
        // minVolume < availableAmount => buy more than minAmount (figure out, how much)
        NSDecimalNumber *volumeToBuy = [SOXFormatters lesserDecimalNumberFrom:orderToBuy.orderInformation_maxVolume
                                                                          and:availableFidorAmount];
        btcAmountToBuy = [volumeToBuy decimalNumberByDividingBy:orderToBuy.orderInformation_price
                                                   withBehavior:[SOXFormatters btcNumberHandler]];
    }

    if (btcAmountToBuy) {
        btcAmountToBuy = [self potentialSellBalanceTradeAmountForBuyAmount:btcAmountToBuy
                                                               forBuyPrice:orderToBuy.orderInformation_price];
    }

    return btcAmountToBuy;
}

#pragma mark | Balance trade methods
- (NSDecimalNumber *)potentialSellBalanceTradeAmountForBuyAmount:(NSDecimalNumber *)buyAmount
                                                     forBuyPrice:(NSDecimalNumber *)buyPrice {

    if (!self.executeBalanceTradesForBuyTrades) {
        return buyAmount;
    }

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
    return sellBalanceTradeAmount;
}

- (NSMutableArray *)sellBalanceTradeParametersForBuyAmount:(NSDecimalNumber *)boughtBTCAmount
                                               forBuyPrice:(NSDecimalNumber *)boughtPrice
                                 createPotentialParameters:(BOOL)createPotentialParameters {
    NSDecimalNumber *remainingBitcoinAmountToSell = [boughtBTCAmount copy];

    // add fee to price - we get 0,8% less bitcoins than we buy!
    NSDecimalNumber *fee = [NSDecimalNumber decimalNumberWithString:@"1.008"];
    NSDecimalNumber *boughtPriceWithFee = [boughtPrice decimalNumberByMultiplyingBy:fee
                                                                       withBehavior:[SOXFormatters currencyNumberHandler]];
    NSMutableArray *balanceSellParameters = [NSMutableArray array];

    for (NSUInteger idx = 0; idx < self.sellOrderBook.count; idx++) {
        SOXShowOrderbookData *sellOrder = [self.sellOrderBook objectAtIndex:idx];

        if ([sellOrder.orderInformation_price isLessThan:boughtPriceWithFee]) {
            break;
        }

        if ([sellOrder.orderInformation_minAmount isLessThanOrEqualTo:remainingBitcoinAmountToSell]) {
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

            if ([remainingBitcoinAmountToSell isEqualTo:[NSDecimalNumber zero]]) {
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

#pragma mark | Balance trade responses
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
        DDLogInfo(@"%@: %@"
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

- (NSString *)runningQueueNote {
    NSString *runningQueueNote = [NSString stringWithFormat:@"RUNNING.count: autoBuy %tu - balanceSell %tu - buyBacklog %tu"
                                  , self.runningAutomaticBuyTradeParameters.count
                                  , self.runningBalanceSellTradeParameters.count
                                  , self.successfulAutomaticBuyTradeParameters.count];
    return runningQueueNote;
}

- (void)informBuyDelegateAboutRunningQueues {
    [self informBuyDelegateWithNote:[self runningQueueNote]];
}

#pragma mark - SOXSocketIOCoreStatusProtocol
- (void)socketIODidConnect:(NSString *)socketStatus {
    [self informBuyDelegateWithNote:socketStatus];
    if (self.socketIODidDisconnectAppeared) {
        self.socketIODidDisconnectAppeared = NO;
        [[self class] registerForWebSocketUpdates];
    }
}

- (void)socketIODidDisconnect:(NSString *)socketStatus {
    [self informBuyDelegateWithNote:socketStatus];

    // Flush all orderBooks
    [self flushAllOrderBooks];
}

- (void)socketIOError:(NSString *)socketError {
    [self informBuyDelegateWithNote:socketError];
}

@end
