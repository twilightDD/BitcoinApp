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

    [self setBoughtTradeParametersBacklog:[NSMutableArray array]];
    [self setSoldTradeParametersBacklog:[NSMutableArray array]];

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
    NSDecimalNumber *effectivInterestRate = [self effectiveBuyInterestRateForData:dataOfInterest
                                                                  toReferenceData:referenceData];

    NSString *statisticForNote = [NSString stringWithFormat:@"- type %@ - ID %@ - minAmo %@ - maxAmo %@ - p0 %@ - p1 %@ - iR %@"
                                  , dataOfInterest.orderInformation_type
                                  , dataOfInterest.orderInformation_orderID
                                  , [SOXFormatters stringForBTCNumber:dataOfInterest.orderInformation_minAmount]
                                  , [SOXFormatters stringForBTCNumber:dataOfInterest.orderInformation_maxAmount]
                                  , [SOXFormatters currencyStringForNumber:dataOfInterest.orderInformation_price roundingMode:NSNumberFormatterRoundDown]
                                  , [SOXFormatters currencyStringForNumber:referenceData.orderInformation_price roundingMode:NSNumberFormatterRoundDown]
                                  , effectivInterestRate];

    if ([effectivInterestRate isLessThan:self.buyInterestRate]) {
        { // DEBUG
            NSString *note = [NSString stringWithFormat:@"no buy (iR to less) %@", statisticForNote];
            [self informBuyDelegateWithNote:note];
        }
        return NO;
    }
    else {
        { // DEBUG
            [self informBuyDelegateWithNote:@"   ------"];
            NSString *note = [NSString stringWithFormat:@"TRY TO BUY %@", statisticForNote];
            [self informBuyDelegateWithNote:note];
        }

        // TODO: autoTrade is running ON
        NSDecimalNumber *btcAmountToBuy= [self btcBuyAmountForOrder:dataOfInterest];
        if (btcAmountToBuy) {
            // TODO: autoTrade is running ON
            [self tryToBuy:dataOfInterest btcAmountToBuy:btcAmountToBuy];
        }
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
        NSString *note = [NSString stringWithFormat:@"no sell (iR to less) %@", statisticForNote];
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
        btcAmountToBuy = [volumeToBuy decimalNumberByDividingBy:orderToBuy.orderInformation_price
                                                   withBehavior:[SOXFormatters btcNumberHandler]];
        // TODO:
        // btcAmountToBuy < minAmount
    }

    if (btcAmountToBuy) {
        // TODO: compare to offer minAmount
        btcAmountToBuy = [self potentialSellBalanceTradeAmountForBuyAmount:btcAmountToBuy
                                                               forBuyPrice:orderToBuy.orderInformation_price];


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
                                                                                               forSellPrice:orderToSell.orderInformation_price];
        btcAmountToSell = potentialBuyBalanceTradeAmount;
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
    }

    NSMutableArray *potentialBuyBalanceTradeParameters = [self buyBalanceTradeParametersForSellAmount:sellAmount
                                                                                         forSellPrice:sellPrice
                                                                            createPotentialParameters:YES];

    NSDecimalNumber *buyBalanceTradeAmount = [self sumOfBitcoinsOfParameters:potentialBuyBalanceTradeParameters];

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
        NSString *note = [NSString stringWithFormat:@"Start buyBalanceTradeParametersForSellAmount: %@ forSellPrice: %@"
                          , soldBTCAmount
                          , soldPrice];
        [self informSellDelegateWithNote:note];
    }

    NSDecimalNumber *remainingBitcoinAmountToBuy = [soldBTCAmount copy];

    // add fee to price
    NSDecimalNumber *fee = [NSDecimalNumber decimalNumberWithString:@"1.008016"];
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
                                                                                                   price:buyOrder.orderInformation_price];
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
        { // DEBUG
            [self informBuyDelegateWithNote:@"---------------------------------"];
            NSString *note = [NSString stringWithFormat:@"start potentialBuyBalanceTradeAmountForSellAmount"];
            [self informBuyDelegateWithNote:note];
            note = [NSString stringWithFormat:@"executeBalanceTradesForBuyTrades == NO => we may buy without restriction"];
            [self informBuyDelegateWithNote:note];
            [self informBuyDelegateWithNote:@"---------------------------------"];
        }
        return buyAmount;
    }

    { // DEBUG
        [self informBuyDelegateWithNote:@"---------------------------------"];
        NSString *note = [NSString stringWithFormat:@"start potentialSellBalanceTradeAmountForBuyAmount"];
        [self informBuyDelegateWithNote:note];
    }

    NSMutableArray *potentialSellBalanceTradeParameters = [self sellBalanceTradeParametersForBuyAmount:buyAmount
                                                                                           forBuyPrice:buyPrice
                                                                             createPotentialParameters:YES];

    NSDecimalNumber *sellBalanceTradeAmount = [self sumOfBitcoinsOfParameters:potentialSellBalanceTradeParameters];

    { // DEBUG
        NSString *note = [NSString stringWithFormat:@"found potentialSellBalanceTradeAmountForBuyAmount %@"
                          , sellBalanceTradeAmount];
        [self informBuyDelegateWithNote:note];
        [self informBuyDelegateWithNote:@"---------------------------------"];
    }
    return sellBalanceTradeAmount;
}

- (NSMutableArray *)sellBalanceTradeParametersForBuyAmount:(NSDecimalNumber *)boughtBTCAmount
                                               forBuyPrice:(NSDecimalNumber *)boughtPrice
                                 createPotentialParameters:(BOOL)createPotentialParameters {

    { // DEBUG
        [self informBuyDelegateWithNote:@"   ----------------------------"];
        NSString *note = [NSString stringWithFormat:@"Start sellBalanceTradeParametersForBuyAmount: %@ forBuyPrice: %@"
                          , boughtBTCAmount
                          , boughtPrice];
        [self informBuyDelegateWithNote:note];
    }

    NSDecimalNumber *remainingBitcoinAmountToSell = [boughtBTCAmount copy];

    // add fee to price
    NSDecimalNumber *fee = [NSDecimalNumber decimalNumberWithString:@"1.004"];
    NSDecimalNumber *boughtPriceWithFee = [boughtPrice decimalNumberByMultiplyingBy:fee
                                                                       withBehavior:[SOXFormatters currencyNumberHandler]];

    { // DEBUG
        NSString *note = [NSString stringWithFormat:@"boughtPriceWithFee (0,4%%): %@"
                          , boughtPriceWithFee];
        [self informBuyDelegateWithNote:note];
    }

    NSMutableArray *balanceSellParameters = [NSMutableArray array];

    for (NSUInteger idx = 0; idx < self.sellOrderBook.count; idx++) {
        SOXShowOrderbookData *sellOrder = [self.sellOrderBook objectAtIndex:idx];

        { // DEBUG
            NSString *note = [NSString stringWithFormat:@"sellOrder - price: %@ - minA: %@ - maxA: %@ (idx: %tu)"
                              , sellOrder.orderInformation_price
                              , sellOrder.orderInformation_minAmount
                              , sellOrder.orderInformation_maxAmount
                              , idx];
            [self informBuyDelegateWithNote:note];
        }

        if ([sellOrder.orderInformation_price isLessThan:boughtPriceWithFee]) {
            { // DEBUG
                NSString *note = [NSString stringWithFormat:@"sellOrder.orderInformation_price isLessThan:boughtPriceWithFee => break"];
                [self informBuyDelegateWithNote:note];
            }
            break;
        }

        if ([sellOrder.orderInformation_minAmount isLessThanOrEqualTo:remainingBitcoinAmountToSell]) {
            { // DEBUG
                NSString *note = [NSString stringWithFormat:
                                  @"[sellOrder.orderInformation_minAmount %@ "
                                  "isLessThanOrEqualTo:remainingBitcoinAmount %@] => look for amountToSell"
                                  , sellOrder.orderInformation_minAmount
                                  , remainingBitcoinAmountToSell];
                [self informBuyDelegateWithNote:note];
            }

            // create sellParameter
            NSDecimalNumber *amountToSell = [SOXFormatters lesserDecimalNumberFrom:remainingBitcoinAmountToSell
                                                                               and:sellOrder.orderInformation_maxAmount];
            NSDictionary *sellParameters = [SOXTradeJob_BitcoinDE_Data parameterBalanceTradingForOrderID:sellOrder.orderInformation_orderID
                                                                                               orderType:BitcoinDE_SellOrderType
                                                                                           bitcoinAmount:amountToSell
                                                                                                   price:sellOrder.orderInformation_price];
            [balanceSellParameters addObject:sellParameters];
            remainingBitcoinAmountToSell = [remainingBitcoinAmountToSell decimalNumberBySubtracting:amountToSell
                                                                                       withBehavior:[SOXFormatters btcNumberHandler]];

            { // DEBUG
                NSString *note = [NSString stringWithFormat:@"=> amountToSell %@ => remainingBitcoinAmountToSell %@"
                                  , amountToSell
                                  , remainingBitcoinAmountToSell];
                [self informBuyDelegateWithNote:note];
            }

            if ([remainingBitcoinAmountToSell isEqualTo:[NSDecimalNumber zero]]) {
                { // DEBUG
                    NSString *note = [NSString stringWithFormat:@"remainingBitcoinAmountToSell == 0 => break"];
                    [self informBuyDelegateWithNote:note];
                }
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

    { // DEBUG
        NSString *note = [NSString stringWithFormat:@"found %tu balanceSellParameters (remainingBitcoinAmountToSell: %@)"
                          , balanceSellParameters.count
                          , remainingBitcoinAmountToSell];
        [self informBuyDelegateWithNote:note];
        [self informBuyDelegateWithNote:@"----------------------------"];
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
    [SOXAutomaticTradingCore missedImplementation:
     @"- (void)addBuyBacklogForRemainingBitcoinAmountToBuy:(NSDecimalNumber *)remainingBitcoinAmountToBuy "
     "forSoldPrice:(NSDecimalNumber *)soldPrice"];
}
- (void)addSellBacklogForRemainingBitcoinAmountToSell:(NSDecimalNumber *)remainingBitcoinAmountToSell
                                       forBoughtPrice:(NSDecimalNumber *)boughtPrice {
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

#pragma mark - Handle (un)successful trade responses
#pragma mark | Auto trade responses
- (void)successfulAutomaticBuyTrade:(NSDictionary *)tradeParameters {
    [self.runningAutomaticBuyTradeParameters removeObject:tradeParameters];
    [self.boughtTradeParametersBacklog addObject:tradeParameters];
    [self checkForBalanceTradesForBoughtTrades];
}

- (void)unSuccessfulAutomaticBuyTrade:(NSDictionary *)tradeParameters {
    [self.runningAutomaticBuyTradeParameters removeObject:tradeParameters];
    [self checkForBalanceTradesForBoughtTrades];
}

- (void)successfulAutomaticSellTrade:(NSDictionary *)tradeParameters {
    [self.runningAutomaticSellTradeParameters removeObject:tradeParameters];
    [self.soldTradeParametersBacklog addObject:tradeParameters];
    [self checkForBalanceTradesForSoldTrades];
}

- (void)unSuccessfulAutomaticSellTrade:(NSDictionary *)tradeParameters {
    [self.runningAutomaticSellTradeParameters removeObject:tradeParameters];
    [self checkForBalanceTradesForSoldTrades];
}

#pragma mark | Balance trade responses
- (void)successfulBalanceBuyTrade:(NSDictionary *)tradeParameters {
    [self.runningBalanceBuyTradeParameters removeObject:tradeParameters];
    [self checkForBalanceTradesForBoughtTrades];
}

- (void)unSuccessfulBalanceBuyTrade:(NSDictionary *)tradeParameters {
    [self.runningBalanceBuyTradeParameters removeObject:tradeParameters];
    [self.soldTradeParametersBacklog addObject:tradeParameters];
    [self checkForBalanceTradesForSoldTrades];
}

- (void)successfulBalanceSellTrade:(NSDictionary *)tradeParameters {
    [self.runningBalanceSellTradeParameters removeObject:tradeParameters];
    [self checkForBalanceTradesForSoldTrades];
}

- (void)unSuccessfulBalanceSellTrade:(NSDictionary *)tradeParameters {
    [self.runningBalanceSellTradeParameters removeObject:tradeParameters];
    [self.boughtTradeParametersBacklog addObject:tradeParameters];
    [self checkForBalanceTradesForBoughtTrades];
}

#pragma mark | Helpers
- (void)checkForBalanceTradesForBoughtTrades {
    [self informBuyDelegateAboutRunningQueues];
    if (self.executeBalanceTradesForBuyTrades
        && self.runningAutomaticBuyTradeParameters.count == 0
        && self.runningBalanceBuyTradeParameters.count == 0
        && self.runningBalanceSellTradeParameters.count == 0
        && self.boughtTradeParametersBacklog.count > 0) {
        [self createBalanceTradesForBoughtTrades];
    }
}

- (void)checkForBalanceTradesForSoldTrades {
    [self informSellDelegateAboutRunningQueues];
    if (self.executeBalanceTradesForSellTrades
        && self.runningAutomaticSellTradeParameters.count == 0
        && self.runningBalanceSellTradeParameters.count == 0
        && self.runningBalanceBuyTradeParameters.count == 0
        && self.soldTradeParametersBacklog.count > 0) {
        // TODO:
        [self createBalanceTradesForSoldTrades];
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
                                  , self.boughtTradeParametersBacklog.count
                                  , self.soldTradeParametersBacklog.count];
    return runningQueueNote;
}

- (void)informBuyDelegateAboutRunningQueues {
    [self informBuyDelegateWithNote:[self runningQueueNote]];
}
- (void)informSellDelegateAboutRunningQueues {
    [self informSellDelegateWithNote:[self runningQueueNote]];
}

#pragma mark - SOXSocketIOCoreProtocol
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

@end
