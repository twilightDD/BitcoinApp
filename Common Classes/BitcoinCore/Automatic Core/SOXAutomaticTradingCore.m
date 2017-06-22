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

+ (void)missedImplementation:(NSString *)methodName {
    NSAssert(NO, @"%@ must be implemented in subclass", methodName);
}

#pragma mark - Class methods
+ (instancetype)sharedTradingCore {
    [self missedImplementation:@"+ (instancetype)sharedTradingCore"];
    return nil;
}

- (void)setupProperties {
    [self setBuyDelegates:[[NSHashTable alloc] init]];
    [self setSellDelegates:[[NSHashTable alloc] init]];
    [self setBuyInterestRate:[NSDecimalNumber one]];
    [self setBuyInterestFactor:[NSDecimalNumber one]];
    [self setSellInterestRate:[NSDecimalNumber one]];
    [self setSellInterestFactor:[NSDecimalNumber one]];
    [self setBuySEPAOrderBook:[NSMutableSet set]];
    [self setSellSEPAOrderBook:[NSMutableSet set]];
    [self setRemainingBuyBitcoinAmount:[NSDecimalNumber zero]];
    [self setRemainingSellBitcoinAmount:[NSDecimalNumber zero]];

    [self setBuyBalanceTradeParameters:[NSMutableArray array]];
    [self setSellBalanceTradeParameters:[NSMutableArray array]];

}
#pragma mark - Manual setters
+ (void)setBuyInterestRate:(NSDecimalNumber *)buyInterestRate {
    if (buyInterestRate) {
        SOXAutomaticTradingCore *core = [self sharedTradingCore];
        core.buyInterestRate = buyInterestRate;
        NSDecimalNumber *buyInterestRatePercent = [buyInterestRate decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"100"]];
        core.buyInterestFactor = [[NSDecimalNumber one] decimalNumberBySubtracting:buyInterestRatePercent];
        NSString *note = [NSString stringWithFormat:@"UPDATE VALUE: Set interest factor to %@", core.buyInterestRate];
        [core informBuyDelegateWithNote:note];

        [core updateBuyStatus];
    }
}

+ (void)setSellInterestRate:(NSDecimalNumber *)sellInterestRate {
    if (sellInterestRate) {
        SOXAutomaticTradingCore *core = [self sharedTradingCore];
        core.sellInterestRate = sellInterestRate;
        NSDecimalNumber *sellInterestRatePercent = [sellInterestRate decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"100"]];
        core.sellInterestFactor = [[NSDecimalNumber one] decimalNumberByAdding:sellInterestRatePercent];
        NSString *note = [NSString stringWithFormat:@"UPDATE VALUE: Set interest factor to %@", core.sellInterestRate];
        [core informSellDelegateWithNote:note];

        [core updateSellStatus];
    }
}

+ (void)setBuyMaximalFidorAmount:(NSDecimalNumber *)buyMaximalEuro {
    if (buyMaximalEuro) {
        SOXAutomaticTradingCore *core = [self sharedTradingCore];
        core.buyMaximalFidorAmountInvestment = buyMaximalEuro;
        NSString *note = [NSString stringWithFormat:@"UPDATE VALUE: Set maximal trading volume to %@ €", buyMaximalEuro];
        [core informBuyDelegateWithNote:note];
    }
}

+ (void)setSellMaximalBTCAmount:(NSDecimalNumber *)sellMaximalBTC {
    if (sellMaximalBTC) {
        SOXAutomaticTradingCore *core = [self sharedTradingCore];
        core.sellMaximalBTCInvestment = sellMaximalBTC;
        NSString *note = [NSString stringWithFormat:@"UPDATE VALUE: Set maximal trading amount to %@ BTC", sellMaximalBTC];
        [core informSellDelegateWithNote:note];
    }
}

#pragma mark - Instance methods
- (void)startAutomaticTrading {
    [SOXAutomaticTradingCore missedImplementation:@"startAutomaticTrading"];
}
- (void)stopAutomaticTrading {
    [SOXAutomaticTradingCore missedImplementation:@"stopAutomaticTrading"];
}

#pragma mark - Interest Rate methods
- (NSDecimalNumber *)effectiveBuyInterestRateForData:(SOXShowOrderbookData *)orderOfInterestData
                                     toReferenceData:(SOXShowOrderbookData *)referenceData {
    return [self effectiveBuyInterestRateForPrice:orderOfInterestData.orderInformation_price
                                 toReferencePrice:referenceData.orderInformation_price];
}

- (NSDecimalNumber *)effectiveSellInterestRateForData:(SOXShowOrderbookData *)orderOfInterestData
                                      toReferenceData:(SOXShowOrderbookData *)referenceData {
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
- (void)checkForBuyableOrder {
    if (self.buyOrderBook.count < 2) {
        NSString *note = [NSString stringWithFormat:@"no buy - too less entries with payOption 1 or 3 in buyOrderBook (count: %tu)"
                          , self.buyOrderBook.count];
        [self informBuyDelegateWithNote:note];
        return;
    }

    SOXShowOrderbookData *dataOfInterest  = [self.buyOrderBook objectAtIndex:0];
    SOXShowOrderbookData *referenceData   = [self.buyOrderBook objectAtIndex:1];
    NSDecimalNumber *effectivInterestRate = [self effectiveBuyInterestRateForData:dataOfInterest toReferenceData:referenceData];

    NSString *statisticForNote = [NSString stringWithFormat:@"- type %@ - ID %@ - minAmo %@ - maxAmo %@ - p0 %@ - p1 %@ - iR %@"
                                  , dataOfInterest.orderInformation_type
                                  , dataOfInterest.orderInformation_orderID
                                  , [SOXFormatters stringForBTCNumber:dataOfInterest.orderInformation_minAmount]
                                  , [SOXFormatters stringForBTCNumber:dataOfInterest.orderInformation_maxAmount]
                                  , [SOXFormatters currencyStringForNumber:dataOfInterest.orderInformation_price roundingMode:NSNumberFormatterRoundDown]
                                  , [SOXFormatters currencyStringForNumber:referenceData.orderInformation_price roundingMode:NSNumberFormatterRoundDown]
                                  , effectivInterestRate];

    if ([effectivInterestRate isLessThan:self.buyInterestRate]) {
        NSString *note = [NSString stringWithFormat:@"no buy %@", statisticForNote];
        [self informBuyDelegateWithNote:note];
    }
    else {
        // check for potential balance trade orders in sellOrderBook
        


        [self informBuyDelegateWithNote:@"------"];
        NSString *note = [NSString stringWithFormat:@"TRY TO BUY %@", statisticForNote];

        [self informBuyDelegateWithNote:note];
        NSDecimalNumber *btcAmountToBuy= [self btcBuyAmountForOrder:dataOfInterest];
        [self tryToBuy:dataOfInterest btcAmountToBuy:btcAmountToBuy];
    }
}

- (void)checkForSellableOrder {
    if (self.sellOrderBook.count < 2) {
        NSString *note = [NSString stringWithFormat:@"no sell - too less entries with payOption 1 or 3 in sellOrderBook (count: %tu)"
                          , self.sellOrderBook.count];
        [self informSellDelegateWithNote:note];
        return;
    }

    SOXShowOrderbookData *dataOfInterest  = [self.sellOrderBook objectAtIndex:0];
    SOXShowOrderbookData *referenceData   = [self.sellOrderBook objectAtIndex:1];
    NSDecimalNumber *effectivInterestRate = [self effectiveSellInterestRateForData:dataOfInterest toReferenceData:referenceData];

    NSString *statisticForNote = [NSString stringWithFormat:@"- type %@ - ID %@ - minAmo %@ - maxAmo %@ - p0 %@ - p1 %@ - iR %@"
                                  , dataOfInterest.orderInformation_type
                                  , dataOfInterest.orderInformation_orderID
                                  , [SOXFormatters stringForBTCNumber:dataOfInterest.orderInformation_minAmount]
                                  , [SOXFormatters stringForBTCNumber:dataOfInterest.orderInformation_maxAmount]
                                  , [SOXFormatters currencyStringForNumber:dataOfInterest.orderInformation_price roundingMode:NSNumberFormatterRoundDown]
                                  , [SOXFormatters currencyStringForNumber:referenceData.orderInformation_price roundingMode:NSNumberFormatterRoundDown]
                                  , effectivInterestRate];

    if ([effectivInterestRate isLessThan:self.sellInterestRate]) {
        NSString *note = [NSString stringWithFormat:@"no sell %@", statisticForNote];
        [self informSellDelegateWithNote:note];
    }
    else {
        [self informSellDelegateWithNote:@"------"];
        NSString *note = [NSString stringWithFormat:@"TRY TO SELL %@", statisticForNote];
        [self informSellDelegateWithNote:note];

        NSDecimalNumber *btcAmountToSell = [self btcSellAmountForOrder:dataOfInterest];
        [self tryToSell:dataOfInterest btcAmountToSell:btcAmountToSell];
    }
}

- (NSDecimalNumber *)btcBuyAmountForOrder:(SOXShowOrderbookData *)orderToBuy {
    NSDecimalNumber *orderToBuyMinVolume = orderToBuy.orderInformation_minVolume;

    // consider user given maxFidorAmount
    NSDecimalNumber *availableFidorAmount = [[SOXMarket_BitcoinDE_Core sharedCore] availableFidorAmount];
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

    }
    else if ([orderToBuyMinVolume isEqual:availableFidorAmount]) {
        // minVolume = availableAmount => buy minAmount
        note = [NSString stringWithFormat:@"BUY possible: order_minVol %@ = avaFidor %@ (buy order.minAmount)"
                , [SOXFormatters currencyStringForNumber:orderToBuyMinVolume roundingMode:NSNumberFormatterRoundDown]
                , [SOXFormatters currencyStringForNumber:availableFidorAmount roundingMode:NSNumberFormatterRoundDown]];

        btcAmountToBuy = orderToBuy.orderInformation_minAmount;
    }
    else if ([orderToBuyMinVolume isLessThan:availableFidorAmount]) {
        // minVolume < availableAmount => buy more than minAmount (figure out, how much)
        note = [NSString stringWithFormat:@"BUY possible: order_minVol %@ < avaFidor %@ (figure out btcToBuyAmount now ...)"
                , [SOXFormatters currencyStringForNumber:orderToBuyMinVolume roundingMode:NSNumberFormatterRoundDown]
                , [SOXFormatters currencyStringForNumber:availableFidorAmount roundingMode:NSNumberFormatterRoundDown]];

        NSDecimalNumber *volumeToBuy = [SOXFormatters lesserDecimalNumberFrom:orderToBuy.orderInformation_maxVolume
                                                                          and:availableFidorAmount];
        btcAmountToBuy = [volumeToBuy decimalNumberByDividingBy:orderToBuy.orderInformation_price];
    }
    [self informBuyDelegateWithNote:note];
    return btcAmountToBuy;
}

- (NSDecimalNumber *)btcSellAmountForOrder:(SOXShowOrderbookData *)orderToSell {
    NSDecimalNumber *btcAmountToSell;

    NSDecimalNumber *orderMinAmountToSell = orderToSell.orderInformation_minAmount;

    NSDecimalNumber *availableBTCAmount = [SOXMarket_BitcoinDE_Core sharedCore].availableBitcoinAmount;
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
    else if ([orderMinAmountToSell isLessThan:availableBTCAmount]) {
        // minAmountToSell < availableBTCAmount => sell more than minAmount (figure out, how much)
        note = [NSString stringWithFormat:@"SELL possible: orderMinAmo %@ < avaBTC %@ (figure out btcToBuyAmount now ...)"
                , [SOXFormatters stringForBTCNumber:orderMinAmountToSell]
                , [SOXFormatters stringForBTCNumber:availableBTCAmount]];
        NSDecimalNumber *volumeToSell = [SOXFormatters lesserDecimalNumberFrom:orderToSell.orderInformation_maxAmount
                                                                           and:availableBTCAmount];
        btcAmountToSell = volumeToSell;

    }

    [self informSellDelegateWithNote:note];
    return btcAmountToSell;
}
#pragma mark | Subclass dummies
- (void)tryToBuy:(SOXShowOrderbookData *)orderToBuy btcAmountToBuy:(NSDecimalNumber *)btcAmountToBuy {
    [SOXAutomaticTradingCore missedImplementation:@"- (void)tryToBuy:(SOXShowOrderbookData *)orderToBuy btcAmountToBuy:(NSDecimalNumber *)btcAmountToBuy"];
}

- (void)tryToSell:(SOXShowOrderbookData *)orderToSell btcAmountToSell:(NSDecimalNumber *)btcAmountToSell {
    [SOXAutomaticTradingCore missedImplementation:@"- (void)tryToSell:(SOXShowOrderbookData *)orderToSell btcAmountToSell:(NSDecimalNumber *)btcAmountToSell"];
}

#pragma mark - Inform delegates
- (void)informBuyDelegateWithNote:(NSString *)note {
    if (note) {
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
    dispatch_async(dispatch_get_main_queue(), ^{
        SOXShowOrderbookData *bestOrderData = self.buyOrderBook.firstObject;
        NSDecimalNumber *bestOrderDataPrice = bestOrderData.orderInformation_price;
        NSDecimalNumber *buyLowerThanPrice = [bestOrderDataPrice decimalNumberByMultiplyingBy:self.buyInterestFactor];
        NSString *status = [NSString stringWithFormat:@"Best: price %@, buy less than %@",
                            [SOXFormatters currencyStringForNumber:bestOrderDataPrice roundingMode:NSNumberFormatterRoundDown]
                            , [SOXFormatters currencyStringForNumber:buyLowerThanPrice roundingMode:NSNumberFormatterRoundDown]];
        [self informBuyDelegateWithStatus:status];
        [self informBuyDelegateWithNote:status];
    });
}

- (void)updateSellStatus {
    dispatch_async(dispatch_get_main_queue(), ^{
        SOXShowOrderbookData *bestOrderData = self.sellOrderBook.firstObject;
        NSDecimalNumber *bestOrderDataPrice = bestOrderData.orderInformation_price;
        NSDecimalNumber *sellGreaterThanPrice = [bestOrderDataPrice decimalNumberByMultiplyingBy:self.sellInterestFactor];
        NSString *status = [NSString stringWithFormat:@"Best: price %@, sell greater than %@",
                            [SOXFormatters currencyStringForNumber:bestOrderDataPrice roundingMode:NSNumberFormatterRoundDown]
                            , [SOXFormatters currencyStringForNumber:sellGreaterThanPrice roundingMode:NSNumberFormatterRoundDown]];
        [self informSellDelegateWithStatus:status];
        [self informSellDelegateWithNote:status];
    });
}

@end
