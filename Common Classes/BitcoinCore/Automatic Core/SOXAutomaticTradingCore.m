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

    [self setBuyBalanceTradeParametersBacklog:[NSMutableArray array]];
    [self setSellBalanceTradeParametersBacklog:[NSMutableArray array]];

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
- (BOOL)checkForBuyableOrder {
    if (self.buyOrderBook.count < 2) {
        NSString *note = [NSString stringWithFormat:@"no buy - too less entries with payOption 1 or 3 in buyOrderBook (count: %tu)"
                          , self.buyOrderBook.count];
        [self informBuyDelegateWithNote:note];
        return NO;
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
        return NO;
    }
    else {
        // check for potential balance trade orders in sellOrderBook
        


        [self informBuyDelegateWithNote:@"------"];
        NSString *note = [NSString stringWithFormat:@"TRY TO BUY %@", statisticForNote];

        [self informBuyDelegateWithNote:note];
        NSDecimalNumber *btcAmountToBuy= [self btcBuyAmountForOrder:dataOfInterest];
        [self tryToBuy:dataOfInterest btcAmountToBuy:btcAmountToBuy];
        return YES;
    }
}

- (BOOL)checkForSellableOrder {
    if (self.sellOrderBook.count < 2) {
        NSString *note = [NSString stringWithFormat:@"no sell - too less entries with payOption 1 or 3 in sellOrderBook (count: %tu)"
                          , self.sellOrderBook.count];
        [self informSellDelegateWithNote:note];
        return NO;
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
        return NO;
    }
    else {
        [self informSellDelegateWithNote:@"------"];
        NSString *note = [NSString stringWithFormat:@"TRY TO SELL %@", statisticForNote];
        [self informSellDelegateWithNote:note];

        NSDecimalNumber *btcAmountToSell = [self btcSellAmountForOrder:dataOfInterest];
        [self tryToSell:dataOfInterest btcAmountToSell:btcAmountToSell];
        return YES;
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

    if (btcAmountToBuy) {
        // TODO: compare to offer minAmount
        NSDecimalNumber *potentialSellBalanceTradeAmount = [self potentialSellBalanceTradeAmountForBuyAmount:btcAmountToBuy
                                                                                                    forPrice:orderToBuy.orderInformation_price];
        btcAmountToBuy = potentialSellBalanceTradeAmount;

        /*
         28.06.17, 13:34:27: TRY TO SELL - type order - ID A4TNUM - minAmo 0,10 ₿ - maxAmo 0,20 ₿ - p0 2.199,00 € - p1 2.197,36 € - iR 0.074
         28.06.17, 13:34:27: ----------------------------
         28.06.17, 13:34:27: Start potentialBuyBalanceTradeAmountForSellAmount: 0.11257325 sellPrice: 2199
         28.06.17, 13:34:27: sellPriceWithFee: 2207.796
         28.06.17, 13:34:27: buyOrder.orderInformation_price: 2198 (idx: 0)
         28.06.17, 13:34:27: [buyOrder.orderInformation_minAmount 0.08 isLessThanOrEqualTo:remainingBitcoinAmount 0.11257325] => look for amountToBuy
         28.06.17, 13:34:27: amountToBuy 0.08 => new remainingBitcoinAmount 0.03257325
         28.06.17, 13:34:27: buyOrder.orderInformation_price: 2200 (idx: 1)
         28.06.17, 13:34:27: buyOrder.orderInformation_price: 2200 (idx: 2)
         28.06.17, 13:34:27: buyOrder.orderInformation_price: 2200 (idx: 3)
         28.06.17, 13:34:27: buyOrder.orderInformation_price: 2219 (idx: 4)
         28.06.17, 13:34:27: buyOrder.orderInformation_price isGreaterThan:sellPriceWithFee => break
         28.06.17, 13:34:27: potentialBuyBalanceTradeAmount = 0.08 => return this value
         28.06.17, 13:34:27: ----------------------------
         28.06.17, 13:34:27: SELL possible: orderMinAmo 0,10 ₿ < avaBTC 0,11257325 ₿ (figure out btcToBuyAmount now ...) potBuyAmount: 0.08
         28.06.17, 13:34:27: SELL btcAmount: 0,08 ₿ for 175,92 €
         28.06.17, 13:34:27: EXECUTE SELL not allowed - so I don't sell.
         */
    }

    note = [note stringByAppendingString:[NSString stringWithFormat:@" potSellAmount: %@"
                                          , btcAmountToBuy]];
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

    if (btcAmountToSell) {
        NSDecimalNumber *potentialBuyBalanceTradeAmount = [self potentialBuyBalanceTradeAmountForSellAmount:btcAmountToSell
                                                                                                   forPrice:orderToSell.orderInformation_price];
        btcAmountToSell = potentialBuyBalanceTradeAmount;
    }

    note = [note stringByAppendingString:[NSString stringWithFormat:@" potBuyAmount: %@"
                                          , btcAmountToSell]];


    [self informSellDelegateWithNote:note];
    return btcAmountToSell;
}

- (NSDecimalNumber *)potentialBuyBalanceTradeAmountForSellAmount:(NSDecimalNumber *)btcAmountToSell
                                                        forPrice:(NSDecimalNumber *)sellPrice {
    NSString *note = @"----------------------------";
    [self informSellDelegateWithNote:note];
    note = [NSString stringWithFormat:@"Start potentialBuyBalanceTradeAmountForSellAmount: %@ sellPrice: %@"
                      , btcAmountToSell
                      , sellPrice];
    [self informSellDelegateWithNote:note];

    NSDecimalNumber *remainingBitcoinAmount = [btcAmountToSell copy];

    // add fee to price
    NSDecimalNumber *sellPriceWithFee = [sellPrice decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"1.008016"]];

    note = [NSString stringWithFormat:@"sellPriceWithFee (0,8%%): %@"
            , sellPriceWithFee];
    [self informSellDelegateWithNote:note];

    for (NSUInteger idx = 0; idx < self.buyOrderBook.count; idx++) {
        SOXShowOrderbookData *buyOrder = [self.buyOrderBook objectAtIndex:idx];

        note = [NSString stringWithFormat:@"buyOrder.orderInformation_price: %@ - minA: %@ - maxA: %@ (idx: %tu)"
                , buyOrder.orderInformation_price
                , buyOrder.orderInformation_minAmount
                , buyOrder.orderInformation_maxAmount
                , idx];
        [self informSellDelegateWithNote:note];

        if ([buyOrder.orderInformation_price isGreaterThan:sellPriceWithFee]) {
            note = [NSString stringWithFormat:@"buyOrder.orderInformation_price isGreaterThan:sellPriceWithFee => break"];
            [self informSellDelegateWithNote:note];

            break;
        }

        if ([buyOrder.orderInformation_minAmount isLessThanOrEqualTo:remainingBitcoinAmount]) {
            note = [NSString stringWithFormat:@"[buyOrder.orderInformation_minAmount %@ isLessThanOrEqualTo:remainingBitcoinAmount %@] => look for amountToBuy"
                    , buyOrder.orderInformation_minAmount
                    , remainingBitcoinAmount];
            [self informSellDelegateWithNote:note];

            NSDecimalNumber *amountToBuy = [SOXFormatters lesserDecimalNumberFrom:remainingBitcoinAmount
                                                                              and:buyOrder.orderInformation_maxAmount];
            remainingBitcoinAmount = [remainingBitcoinAmount decimalNumberBySubtracting:amountToBuy];

            note = [NSString stringWithFormat:@"amountToBuy %@ => new remainingBitcoinAmount %@"
                    , amountToBuy
                    , remainingBitcoinAmount];
            [self informSellDelegateWithNote:note];

            if ([remainingBitcoinAmount isEqualTo:[NSDecimalNumber zero]]) {
                note = [NSString stringWithFormat:@"remainingBitcoinAmount == 0 => break"];
                [self informSellDelegateWithNote:note];
                break;
            }
            else if ([remainingBitcoinAmount isLessThan:[NSDecimalNumber zero]]) {
                NSString *note = [NSString stringWithFormat:@"!!!! ERROR !!!!"];
                [self informSellDelegateWithNote:note];
                note = [NSString stringWithFormat:@"remainingBitcoinAmount %@ is less than 0! (in potentialBuyBalanceTradeAmountForSellAmount)",
                        remainingBitcoinAmount];
                [self informSellDelegateWithNote:note];
                note = [NSString stringWithFormat:@"!!!! ERROR !!!!"];
                [self informSellDelegateWithNote:note];
            }
        }
        else {
            note = [NSString stringWithFormat:@"minAmout too less"];
        }
    }

    NSDecimalNumber *potentialBuyBalanceTradeAmount = [btcAmountToSell decimalNumberBySubtracting:remainingBitcoinAmount];

    note = [NSString stringWithFormat:@"potentialBuyBalanceTradeAmount = %@ => return this value"
            , potentialBuyBalanceTradeAmount];
    [self informSellDelegateWithNote:note];

    note = @"----------------------------";
    [self informSellDelegateWithNote:note];

    return potentialBuyBalanceTradeAmount;
}

- (NSDecimalNumber *)potentialSellBalanceTradeAmountForBuyAmount:(NSDecimalNumber *)btcAmountToBuy
                                                        forPrice:(NSDecimalNumber *)buyPrice {

    NSString *note = @"----------------------------";
    [self informBuyDelegateWithNote:note];
    note = [NSString stringWithFormat:@"Start potentialSellBalanceTradeAmountForBuyAmount: %@ buyPrice: %@"
            , btcAmountToBuy
            , buyPrice];
    [self informBuyDelegateWithNote:note];

    NSDecimalNumber *remainingBitcoinAmount = [btcAmountToBuy copy];

    // add fee to price
    NSDecimalNumber *buyPriceWithFee = [buyPrice decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"1.008016"]];

    note = [NSString stringWithFormat:@"buyPriceWithFee (0,8%%): %@"
            , buyPriceWithFee];
    [self informBuyDelegateWithNote:note];

    for (NSUInteger idx = 0; idx < self.sellOrderBook.count; idx++) {
        SOXShowOrderbookData *sellOrder = [self.sellOrderBook objectAtIndex:idx];

        note = [NSString stringWithFormat:@"sellOrder.orderInformation_price: %@ (idx: %tu)"
                , sellOrder.orderInformation_price
                , idx];
        [self informBuyDelegateWithNote:note];

        if ([sellOrder.orderInformation_price isLessThan:buyPriceWithFee]) {
            note = [NSString stringWithFormat:@"sellOrder.orderInformation_price isLessThan:buyPriceWithFee => break"];
            [self informBuyDelegateWithNote:note];
            break;
        }

        if ([sellOrder.orderInformation_minAmount isLessThanOrEqualTo:remainingBitcoinAmount]) {
            note = [NSString stringWithFormat:@"[sellOrder.orderInformation_minAmount %@ isLessThanOrEqualTo:remainingBitcoinAmount %@] => look for amountToSell"
                    , sellOrder.orderInformation_minAmount
                    , remainingBitcoinAmount];
            [self informBuyDelegateWithNote:note];


            NSDecimalNumber *amountToSell = [SOXFormatters lesserDecimalNumberFrom:remainingBitcoinAmount
                                                                               and:sellOrder.orderInformation_maxAmount];
            remainingBitcoinAmount = [remainingBitcoinAmount decimalNumberBySubtracting:amountToSell];

            note = [NSString stringWithFormat:@"amountToSell %@ => new remainingBitcoinAmount %@"
                    , amountToSell
                    , remainingBitcoinAmount];
            [self informBuyDelegateWithNote:note];

            if ([remainingBitcoinAmount isEqualTo:[NSDecimalNumber zero]]) {
                note = [NSString stringWithFormat:@"remainingBitcoinAmount == 0 => break"];
                [self informBuyDelegateWithNote:note];
                break;
            }
            else if ([remainingBitcoinAmount isLessThan:[NSDecimalNumber zero]]) {
                NSString *note = [NSString stringWithFormat:@"!!!! ERROR !!!!"];
                [self informBuyDelegateWithNote:note];
                note = [NSString stringWithFormat:@"remainingBitcoinAmount %@ is less than 0! (in potentialSellBalanceTradeAmountForBuyAmount)",
                        remainingBitcoinAmount];
                [self informBuyDelegateWithNote:note];
                note = [NSString stringWithFormat:@"!!!! ERROR !!!!"];
                [self informBuyDelegateWithNote:note];
            }
        }
    }

    NSDecimalNumber *potentialSellBalanceTradeAmount = [btcAmountToBuy decimalNumberBySubtracting:remainingBitcoinAmount];

    note = [NSString stringWithFormat:@"potentialSellBalanceTradeAmount = %@ => return this value"
            , potentialSellBalanceTradeAmount];
    [self informBuyDelegateWithNote:note];

    note = @"----------------------------";
    [self informBuyDelegateWithNote:note];

    return potentialSellBalanceTradeAmount;
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
