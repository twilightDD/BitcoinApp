//
//  SOXAutomaticTrading_BitcoinDE_Core.m
//  BitcoinApp
//
//  Created by Peter Hauke on 07.06.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXAutomaticTrading_BitcoinDE_Core.h"

#import "SOXMarket_BitcoinDE_Core.h"
#import "SOXSocketIO_BitcoinDE_Core.h"

#import "SOXMarket_BitcoinDE_DefTypes.h"

#import "SOXShowOrderbook_BitcoinDE_Data.h"
#import "SOXTradeJob_BitcoinDE_Data.h"

#import "SOXFormatters.h"

@import AppKit;

@interface SOXAutomaticTrading_BitcoinDE_Core () <SOXMarketCoreServerRequestProtocol, SOXSocketIOCoreProtocol>

@property (strong, nonatomic) NSHashTable *buyDelegates;
@property (strong, nonatomic) NSHashTable *sellDelegates;

@property (strong, nonatomic) NSMutableArray *buyOrderBook;
@property (strong, nonatomic) NSMutableArray *sellOrderBook;
@property (strong, nonatomic) NSMutableSet *buySEPAOrderBook; // as cache for SEPA offers
@property (strong, nonatomic) NSMutableSet *sellSEPAOrderBook;  // as cache for SEPA orders

@property (nonatomic) BOOL executeBuyTrades;
@property (nonatomic) BOOL executeSellTrades;

@property (strong, nonatomic) NSDecimalNumber *buyInterestRate;
@property (strong, nonatomic) NSDecimalNumber *buyInterestFactor;
@property (strong, nonatomic) NSDecimalNumber *buyMaximalFidorAmountInvestment;
@property (strong, nonatomic) NSDecimalNumber *sellInterestRate;
@property (strong, nonatomic) NSDecimalNumber *sellInterestFactor;
@property (strong, nonatomic) NSDecimalNumber *sellMaximalBTCInvestment;

@end

@implementation SOXAutomaticTrading_BitcoinDE_Core
+ (instancetype)sharedTradingCore {
    static id sharedTradingCore;

    static dispatch_once_t pred;

    dispatch_once(&pred, ^{
        sharedTradingCore = [[self class] new];
        [(SOXAutomaticTrading_BitcoinDE_Core *)sharedTradingCore setBuyDelegates:[[NSHashTable alloc] init]];
        [(SOXAutomaticTrading_BitcoinDE_Core *)sharedTradingCore setSellDelegates:[[NSHashTable alloc] init]];
        [(SOXAutomaticTrading_BitcoinDE_Core *)sharedTradingCore setBuyInterestRate:[NSDecimalNumber one]];
        [(SOXAutomaticTrading_BitcoinDE_Core *)sharedTradingCore setBuyInterestFactor:[NSDecimalNumber one]];
        [(SOXAutomaticTrading_BitcoinDE_Core *)sharedTradingCore setSellInterestRate:[NSDecimalNumber one]];
        [(SOXAutomaticTrading_BitcoinDE_Core *)sharedTradingCore setSellInterestFactor:[NSDecimalNumber one]];
        [(SOXAutomaticTrading_BitcoinDE_Core *)sharedTradingCore setBuySEPAOrderBook:[NSMutableSet set]];
        [(SOXAutomaticTrading_BitcoinDE_Core *)sharedTradingCore setSellSEPAOrderBook:[NSMutableSet set]];
    });

    return sharedTradingCore;
}
#pragma mark - Public class methods
+ (void)executeTrades:(BOOL)executeTrades forOrderType:(BitcoinDE_OrderType)orderType {
    SOXAutomaticTrading_BitcoinDE_Core *core = [SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore];

    switch (orderType) {
        case BitcoinDE_BuyOrderType:
            core.executeBuyTrades = executeTrades;
            [core informBuyDelegateWithNote:[NSString stringWithFormat:@"Execute trades %@"
                                             , executeTrades ? @"enabled" : @"disabled"]];
            break;
        case BitcoinDE_SellOrderType:
            core.executeBuyTrades = executeTrades;
            [core informSellDelegateWithNote:[NSString stringWithFormat:@"Execute trades %@"
                                              , executeTrades ? @"enabled" : @"disabled"]];
            break;
        default:
            break;
    }
}

+ (void)registerController:(id <SOXAutomaticTradingCoreProtocol>)controller
    forUpdatesForOrderType:(BitcoinDE_OrderType)orderType {

    if (!controller) {
        return;
    }

    SOXAutomaticTrading_BitcoinDE_Core *tradingCore = [SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore];
    switch (orderType) {
        case BitcoinDE_BuyOrderType: {
            [tradingCore.buyDelegates addObject:controller];

            NSString *note = [NSString stringWithFormat:@"START: Maximal Fidor trading amount %@"
                              , [SOXFormatters currencyStringForNumber:tradingCore.buyMaximalFidorAmountInvestment
                                                          roundingMode:NSNumberFormatterRoundDown]];
            [tradingCore informBuyDelegateWithNote:note];
            NSString *note2 = [NSString stringWithFormat:@"START: Interest rate %@%%", tradingCore.buyInterestRate];
            [tradingCore informBuyDelegateWithNote:note2];
        }
            break;
        case BitcoinDE_SellOrderType: {
            [tradingCore.sellDelegates addObject:controller];
            NSString *note = [NSString stringWithFormat:@"START: Maximal BTC trading amount %@ BTC"
                              , [SOXFormatters stringForBTCNumber:tradingCore.sellMaximalBTCInvestment]];
            [tradingCore informSellDelegateWithNote:note];

            NSString *note2 = [NSString stringWithFormat:@"START: Interest rate %@%%", tradingCore.sellInterestRate];
            [tradingCore informSellDelegateWithNote:note2];
        }
            break;
        default:
            NSLog(@"ERROR - (void)registerForUpdatesForType:(BitcoinDE_OrderType)orderType");
            break;
    }

    [SOXAutomaticTrading_BitcoinDE_Core registerForWebSocketUpdates];
}
+ (void)registerForWebSocketUpdates {
    SOXAutomaticTrading_BitcoinDE_Core *core = [SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore];

    NSDictionary *buyParameters = [SOXShowOrderbook_BitcoinDE_Data parametersForOrderType:BitcoinDE_BuyOrderType
                                                                 onlyExpressPaymentOption:YES];

    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowBuyOrderbookCommandType
                                            withParameter:buyParameters
                                                respondTo:core];
    NSDictionary *sellParameters = [SOXShowOrderbook_BitcoinDE_Data parametersForOrderType:BitcoinDE_SellOrderType
                                                                  onlyExpressPaymentOption:YES];

    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowSellOrderbookCommandType
                                            withParameter:sellParameters
                                                respondTo:core];
}

#pragma mark - Manual setters
+ (void)setBuyInterestRate:(NSDecimalNumber *)buyInterestRate {
    if (buyInterestRate) {
        SOXAutomaticTrading_BitcoinDE_Core *core = [SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore];
        core.buyInterestRate = buyInterestRate;
        NSDecimalNumber *buyInterestRatePercent = [buyInterestRate decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"100"]];
        core.buyInterestFactor = [[NSDecimalNumber one] decimalNumberBySubtracting:buyInterestRatePercent];
        NSString *note = [NSString stringWithFormat:@"UPDATE VALUE: Set interest factor to %@", core.buyInterestRate];
        [core informBuyDelegateWithNote:note];
    }
}

+ (void)setSellInterestRate:(NSDecimalNumber *)sellInterestRate {
    if (sellInterestRate) {
        SOXAutomaticTrading_BitcoinDE_Core *core = [SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore];
        core.sellInterestRate = sellInterestRate;
        NSDecimalNumber *sellInterestRatePercent = [sellInterestRate decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"100"]];
        core.sellInterestFactor = [[NSDecimalNumber one] decimalNumberByAdding:sellInterestRatePercent];
        NSString *note = [NSString stringWithFormat:@"UPDATE VALUE: Set interest factor to %@", core.sellInterestRate];
        [core informSellDelegateWithNote:note];
    }
}

+ (void)setBuyMaximalFidorAmount:(NSDecimalNumber *)buyMaximalEuro {
    if (buyMaximalEuro) {
        SOXAutomaticTrading_BitcoinDE_Core *core = [SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore];
        [SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore].buyMaximalFidorAmountInvestment = buyMaximalEuro;
        NSString *note = [NSString stringWithFormat:@"UPDATE VALUE: Set maximal trading volume to %@ €", buyMaximalEuro];
        [core informBuyDelegateWithNote:note];
    }
}

+ (void)setSellMaximalBTCAmount:(NSDecimalNumber *)sellMaximalBTC {
    if (sellMaximalBTC) {
        SOXAutomaticTrading_BitcoinDE_Core *core = [SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore];
        [SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore].sellMaximalBTCInvestment = sellMaximalBTC;
        NSString *note = [NSString stringWithFormat:@"UPDATE VALUE: Set maximal trading amount to %@ BTC", sellMaximalBTC];
        [core informSellDelegateWithNote:note];
    }
}

#pragma mark - Private class methods
+ (NSMutableArray *)sortedOrderBook:(NSMutableArray *)orderBookDatas forOrderType:(BitcoinDE_OrderType)orderType {
    switch (orderType) {
        case BitcoinDE_BuyOrderType: {
            [orderBookDatas sortUsingComparator:^NSComparisonResult(SOXShowOrderbook_BitcoinDE_Data *_Nonnull obj1, SOXShowOrderbook_BitcoinDE_Data  *_Nonnull obj2) {
                if ([obj1.orderInformation_price isLessThan:obj2.orderInformation_price]) {
                    return NSOrderedAscending;
                }
                else if ([obj1.orderInformation_price isGreaterThan:obj2.orderInformation_price]) {
                    return NSOrderedDescending;
                }

                return NSOrderedSame;
            }];
            break;
        }
        case BitcoinDE_SellOrderType: {
            [orderBookDatas sortUsingComparator:^NSComparisonResult(SOXShowOrderbook_BitcoinDE_Data *_Nonnull obj1, SOXShowOrderbook_BitcoinDE_Data  *_Nonnull obj2) {
                if ([obj1.orderInformation_price isLessThan:obj2.orderInformation_price]) {
                    return NSOrderedDescending;
                }
                else if ([obj1.orderInformation_price isGreaterThan:obj2.orderInformation_price]) {
                    return NSOrderedAscending;
                }

                return NSOrderedSame;
            }];
            break;
        }
        default:
            break;
    }

    return orderBookDatas;
}
#pragma mark - Private methods
- (void)playSound {
    NSSound *mySound = [NSSound soundNamed:@"ka-ching"];
    [mySound play];

}

#pragma mark - Automatic trading methods
- (void)checkForBuyableOrder {
    SOXShowOrderbook_BitcoinDE_Data *dataOfInterest = [self.buyOrderBook objectAtIndex: 0];
    SOXShowOrderbook_BitcoinDE_Data *referenceData  = [self.buyOrderBook objectAtIndex:1];
    NSDecimalNumber *effectivInterestRate           = [self effectiveBuyInterestRateFor:dataOfInterest toReference:referenceData];

    NSString *statisticForNote = [NSString stringWithFormat:@"- type %@ - orderID %@ - minAmount %@ - maxAmount %@ - price0 %@ - price1 %@ - interest %@"
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
        [self informBuyDelegateWithNote:@"------"];
        NSString *note = [NSString stringWithFormat:@"TRY TO BUY %@", statisticForNote];

        [self informBuyDelegateWithNote:note];
        [self tryToExecuteBuyOrder:dataOfInterest];
    }
}

- (void)checkForSellableOrder {
    SOXShowOrderbook_BitcoinDE_Data *dataOfInterest = [self.sellOrderBook objectAtIndex:0];
    SOXShowOrderbook_BitcoinDE_Data *referenceData  = [self.sellOrderBook objectAtIndex:1];
    NSDecimalNumber *effectivInterestRate           = [self effectiveSellInterestRateFor:dataOfInterest toReference:referenceData];

    NSString *statisticForNote = [NSString stringWithFormat:@"- type %@ - orderID %@ - minAmount %@ - maxAmount %@ - price0 %@ - price1 %@ - interest %@"
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
        [self tryToExecuteSellOrder:dataOfInterest];
    }
}

- (void)tryToExecuteBuyOrder:(SOXShowOrderbook_BitcoinDE_Data *)orderToBuy {
    /*
     # Vorgegebenen MaxAmount beachten
     # auf ServerAnswer warten
         => Gegenkauf/käufe auslösen
     FRAGE: was passiert mit der Order, die executed wurde? Wann wird die aus dem array entfernt?
     */
    // figure out amountToBuy
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
        note = [NSString stringWithFormat:@"NO BUY possible: order_minVolume %@ > availableFidorAmount %@ (not enough fidor amount)"
                , [SOXFormatters currencyStringForNumber:orderToBuyMinVolume roundingMode:NSNumberFormatterRoundDown]
                , [SOXFormatters currencyStringForNumber:availableFidorAmount roundingMode:NSNumberFormatterRoundDown]];

    }
    else if ([orderToBuyMinVolume isEqual:availableFidorAmount]) {
        // minVolume = availableAmount => buy minAmount
        note = [NSString stringWithFormat:@"BUY possible: order_minVolume %@ = availableFidorAmount %@ (buy order.minAmount)"
                , [SOXFormatters currencyStringForNumber:orderToBuyMinVolume roundingMode:NSNumberFormatterRoundDown]
                , [SOXFormatters currencyStringForNumber:availableFidorAmount roundingMode:NSNumberFormatterRoundDown]];

        btcAmountToBuy = orderToBuy.orderInformation_minAmount;
    }
    else if ([orderToBuyMinVolume isLessThan:availableFidorAmount]) {
        // minVolume < availableAmount => buy more than minAmount (figure out, how much)
        note = [NSString stringWithFormat:@"BUY possible: order_minVolume %@ < availableFidorAmount %@ (figure out btcToBuyAmount now ...)"
                , [SOXFormatters currencyStringForNumber:orderToBuyMinVolume roundingMode:NSNumberFormatterRoundDown]
                , [SOXFormatters currencyStringForNumber:availableFidorAmount roundingMode:NSNumberFormatterRoundDown]];

        NSDecimalNumber *volumeToBuy = [SOXFormatters lesserDecimalNumberFrom:orderToBuy.orderInformation_maxVolume
                                                                          and:availableFidorAmount];
        btcAmountToBuy = [volumeToBuy decimalNumberByDividingBy:orderToBuy.orderInformation_price];
    }
    [self informBuyDelegateWithNote:note];

    if (btcAmountToBuy
        && [btcAmountToBuy isGreaterThan:[NSDecimalNumber zero]]) {
        NSDecimalNumber *priceForBTCAmountToBuy = [btcAmountToBuy decimalNumberByMultiplyingBy:orderToBuy.orderInformation_price];
        NSString *note = [NSString stringWithFormat:@"BUY btcAmount: %@ for %@"
                          , [SOXFormatters stringForBTCNumber:btcAmountToBuy]
                          , [SOXFormatters currencyStringForNumber:priceForBTCAmountToBuy roundingMode:NSNumberFormatterRoundDown]];
        [self informBuyDelegateWithNote:note];

        if (self.executeBuyTrades) {
            note = [NSString stringWithFormat:@"EXECUTE BUY allowed => TRY BUY."];
            NSDictionary *parameters = [SOXTradeJob_BitcoinDE_Data parameterForOrderID:orderToBuy.orderInformation_orderID
                                                                             orderType:BitcoinDE_BuyOrderType
                                                                         bitcoinAmount:btcAmountToBuy];
            [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ExecuteTrade
                                                    withParameter:parameters
                                                        respondTo:self];
            [self playSound];
        }
        else {
            note = [NSString stringWithFormat:@"EXECUTE BUY not allowed - so I don't buy."];
            NSBeep();
        }

        [self informBuyDelegateWithNote:note];
    }

    [self informBuyDelegateWithNote:@"------"];
}

- (void)tryToExecuteSellOrder:(SOXShowOrderbook_BitcoinDE_Data *)orderToSell {
    /*
     1. amountToSell herausfinden
     2. executeBuy
     3. auf ServerAnswer warten
     => Gegenkauf/käufe auslösen
     FRAGE: was passiert mit der Order, die executed wurde? Wann wird die aus dem array entfernt?
     */

    NSDecimalNumber *orderMinAmountToSell = orderToSell.orderInformation_minAmount;

    NSDecimalNumber *availableBTCAmount = [SOXMarket_BitcoinDE_Core sharedCore].availableBitcoinAmount;
    if (self.sellMaximalBTCInvestment) {
        availableBTCAmount = [SOXFormatters lesserDecimalNumberFrom:self.sellMaximalBTCInvestment
                                                                and:availableBTCAmount];
    }

    NSDecimalNumber *btcAmountToSell;
    NSString *note = @"error in tryToExecuteSellOrder";
    if ([orderMinAmountToSell isGreaterThan:availableBTCAmount]) {
        // minAmountToSell > availableBTCAmount => no sell possible
        note = [NSString stringWithFormat:@"NO SELL possible: orderMinAmount %@ > availableBTCAmount %@ (not enough fidor amount)"
                , [SOXFormatters stringForBTCNumber:orderMinAmountToSell]
                , [SOXFormatters stringForBTCNumber:availableBTCAmount]];
    }
    else if ([orderMinAmountToSell isEqualToNumber:availableBTCAmount]) {
        // minAmountToSell = availableBTCAmount => sell minAmount
        note = [NSString stringWithFormat:@"SELL possible: orderMinAmount %@ = availableBTCAmount %@ (sell order.minAmount)"
                , [SOXFormatters stringForBTCNumber:orderMinAmountToSell]
                , [SOXFormatters stringForBTCNumber:availableBTCAmount]];

        btcAmountToSell = orderToSell.orderInformation_minAmount;
    }
    else if ([orderMinAmountToSell isLessThan:availableBTCAmount]) {
        // minAmountToSell < availableBTCAmount => sell more than minAmount (figure out, how much)
        note = [NSString stringWithFormat:@"SELL possible: orderMinAmount %@ < availableBTCAmount %@ (figure out btcToBuyAmount now ...)"
                , [SOXFormatters stringForBTCNumber:orderMinAmountToSell]
                , [SOXFormatters stringForBTCNumber:availableBTCAmount]];
        NSDecimalNumber *volumeToSell = [SOXFormatters lesserDecimalNumberFrom:orderToSell.orderInformation_maxAmount
                                                                           and:availableBTCAmount];
        btcAmountToSell = volumeToSell;

    }

    [self informSellDelegateWithNote:note];

    if (btcAmountToSell
        && [btcAmountToSell isGreaterThan:[NSDecimalNumber zero]]) {
        NSDecimalNumber *priceForBTCAmountToSell = [btcAmountToSell decimalNumberByMultiplyingBy:orderToSell.orderInformation_price];
        NSString *note = [NSString stringWithFormat:@"SELL btcAmount: %@ for %@"
                          , [SOXFormatters stringForBTCNumber:btcAmountToSell]
                          , [SOXFormatters currencyStringForNumber:priceForBTCAmountToSell roundingMode:NSNumberFormatterRoundDown]];
        [self informSellDelegateWithNote:note];

        if (self.executeSellTrades) {
            note = [NSString stringWithFormat:@"EXECUTE SELL allowed => TRY SELL."];

            NSDictionary *parameters = [SOXTradeJob_BitcoinDE_Data parameterForOrderID:orderToSell.orderInformation_orderID
                                                                             orderType:BitcoinDE_SellOrderType
                                                                         bitcoinAmount:btcAmountToSell];
            [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ExecuteTrade
                                                    withParameter:parameters
                                                        respondTo:self];
            [self playSound];
        }
        else {
            note = [NSString stringWithFormat:@"EXECUTE SELL not allowed - so I don't sell."];
            NSBeep();
        }

        [self informSellDelegateWithNote:note];
    }
    [self informSellDelegateWithNote:@"------"];
}

#pragma mark - SOXMarketCoreServerRequestProtocol
- (void)answerOfServerRequest:(NSDictionary * _Nonnull)answerOfServerRequest {
    id errorMessage = [answerOfServerRequest objectForKey:ServerAnswerErrorKey];
    if (errorMessage) {
        NSLog(@"SOXAutomaticTrading_BitcoinDE_Core - answerOfServerRequest with error:\n%@", errorMessage);
        return;
    }

    SOXAutomaticTrading_BitcoinDE_Core *core = [SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore];

    NSDictionary *payloadDictionary = [answerOfServerRequest objectForKey:ServerAnswerPayloadKey];
    NSMutableArray <SOXShowOrderbook_BitcoinDE_Data *> *orderBookDatas;
    orderBookDatas = [SOXShowOrderbook_BitcoinDE_Data orderbookDataArrayForShowOrderbookDictionary:payloadDictionary];
    if (orderBookDatas.count == 0) {
        return;
    }

    if ([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ShowBuyOrderbookCommandType)]) {
        NSMutableArray *buyOrderBookDatas = [NSMutableArray array];
        for (SOXShowOrderbook_BitcoinDE_Data *orderBookData in orderBookDatas) {
            if ([self checkForExpressOrder:orderBookData]) {
                [buyOrderBookDatas addObject:orderBookData];
            }
        }

        self.buyOrderBook = [SOXAutomaticTrading_BitcoinDE_Core sortedOrderBook:buyOrderBookDatas
                                                                 forOrderType:BitcoinDE_BuyOrderType];
        [SOXSocketIO_BitcoinDE_Core registerForOrderUpdatesForUpdateType:BitcoinDE_UpdateType_BuyOrderChanges
                                                                delegate:core];
        [SOXSocketIO_BitcoinDE_Core registerForOrderUpdatesForUpdateType:BitcoinDE_UpdateType_RemoveOrderChanges
                                                                delegate:core];

        SOXShowOrderbook_BitcoinDE_Data *dataOfInterest = self.buyOrderBook.firstObject;
        NSString *note = [NSString stringWithFormat:@"START in BUY - firstObject: type %@ oID %@ minAmount %@ price %@",
                          dataOfInterest.orderInformation_type
                          , dataOfInterest.orderInformation_orderID
                          , dataOfInterest.orderInformation_minAmount
                          , dataOfInterest.orderInformation_price];
        [self informBuyDelegateWithNote:note];

        [self updateBuyStatus];
    }
    else if([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ShowSellOrderbookCommandType)]) {
        NSMutableArray *sellOrderBookDatas = [NSMutableArray array];
        for (SOXShowOrderbook_BitcoinDE_Data *orderBookData in orderBookDatas) {
            if ([self checkForExpressOrder:orderBookData]) {
                [sellOrderBookDatas addObject:orderBookData];
            }
        }

        self.sellOrderBook = [SOXAutomaticTrading_BitcoinDE_Core sortedOrderBook:sellOrderBookDatas
                                                                  forOrderType:BitcoinDE_SellOrderType];
        [SOXSocketIO_BitcoinDE_Core registerForOrderUpdatesForUpdateType:BitcoinDE_UpdateType_SellOrderChanges
                                                                delegate:core];
        [SOXSocketIO_BitcoinDE_Core registerForOrderUpdatesForUpdateType:BitcoinDE_UpdateType_RemoveOrderChanges
                                                                delegate:core];

        SOXShowOrderbook_BitcoinDE_Data *dataOfInterest = self.sellOrderBook.firstObject;
        NSString *note = [NSString stringWithFormat:@"START in SELL - firstObject: type %@ oID %@ minAmount %@ price %@",
                          dataOfInterest.orderInformation_type
                          , dataOfInterest.orderInformation_orderID
                          , dataOfInterest.orderInformation_minAmount
                          , dataOfInterest.orderInformation_price];
        [self informSellDelegateWithNote:note];
        [self updateSellStatus];
    }
}

- (NSDecimalNumber *)effectiveBuyInterestRateFor:(SOXShowOrderbookData *)orderOfInterest toReference:(SOXShowOrderbookData *)reference {
    NSDecimalNumber *effectivInteresRate;
    effectivInteresRate = [orderOfInterest.orderInformation_price decimalNumberByDividingBy:reference.orderInformation_price];
    effectivInteresRate = [[NSDecimalNumber one] decimalNumberBySubtracting:effectivInteresRate];
    effectivInteresRate = [effectivInteresRate decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"100"]
                                                               withBehavior:[SOXFormatters interestRateNumberHandler]];
    return effectivInteresRate;
}

- (NSDecimalNumber *)effectiveSellInterestRateFor:(SOXShowOrderbookData *)orderOfInterest toReference:(SOXShowOrderbookData *)reference {
    NSDecimalNumber *effectivInteresRate;
    effectivInteresRate = [reference.orderInformation_price decimalNumberByDividingBy:orderOfInterest.orderInformation_price];
    effectivInteresRate = [[NSDecimalNumber one] decimalNumberBySubtracting:effectivInteresRate];
    effectivInteresRate = [effectivInteresRate decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"100"]
                            withBehavior:[SOXFormatters interestRateNumberHandler]];
    return effectivInteresRate;
}

#pragma mark - SOXSocketIOCoreProtocol
- (void)addedOrder:(SOXShowOrderbookData *)addOrderData {
    if ([self checkForExpressOrder:addOrderData]) {
        [self addOrderBookData:addOrderData];
    }
    else {
        [self addSEPAOrderBookData:addOrderData];
    }
}

- (void)removedOrderWithOrderID:(NSString *)orderID {
    if ([self removeOrderWithOrderID:orderID fromOrderBook:self.buyOrderBook]) {
        [self updateBuyStatus];
    }

    if ([self removeOrderWithOrderID:orderID fromOrderBook:self.sellOrderBook]) {
        [self updateSellStatus];
    }
}

- (void)updateOrderWithSocketOrderObjectID:(NSString *)orderObjectID withValues:(NSDictionary *)changesDictionary {
    NSArray *updatesBuyOrders = [self updateOrderWithSocketOrderObjectID:orderObjectID
                                                             inOrderBook:self.buyOrderBook
                                                              withValues:changesDictionary];
    for (SOXShowOrderbookData *updatedOrder in updatesBuyOrders) {
        [self addedOrder:updatedOrder];
        [self.buySEPAOrderBook removeObject:updatedOrder];
    }

    NSArray *updatesSellOrders = [self updateOrderWithSocketOrderObjectID:orderObjectID
                                                              inOrderBook:self.sellOrderBook
                                                               withValues:changesDictionary];

    for (SOXShowOrderbookData *updatedOrder in updatesSellOrders) {
        [self addedOrder:updatedOrder];
        [self.sellSEPAOrderBook removeObject:updatedOrder];
    }

    updatesBuyOrders = [self updateOrderWithSocketOrderObjectID:orderObjectID
                                                             inOrderBook:[self.buySEPAOrderBook.allObjects mutableCopy]
                                                              withValues:changesDictionary];
    for (SOXShowOrderbookData *updatedOrder in updatesBuyOrders) {
        [self addedOrder:updatedOrder];
        [self.buySEPAOrderBook removeObject:updatedOrder];
    }

    updatesSellOrders = [self updateOrderWithSocketOrderObjectID:orderObjectID
                                                              inOrderBook:[self.sellSEPAOrderBook.allObjects mutableCopy]
                                                               withValues:changesDictionary];

    NSLog(@"####");
    NSLog(@"UpdatePaymentOption");
    NSLog(@"before self.sellOrderBook.count %tu self.sellSEPAOrderBook.count %zu", self.sellOrderBook.count, self.sellSEPAOrderBook.count);
    for (SOXShowOrderbookData *updatedOrder in updatesSellOrders) {
        [self addedOrder:updatedOrder];
        [self.sellSEPAOrderBook removeObject:updatedOrder];
    }
    NSLog(@"after self.sellOrderBook.count %tu self.sellSEPAOrderBook.count %zu", self.sellOrderBook.count, self.sellSEPAOrderBook.count);
    NSLog(@"####");
}

#pragma mark | Socket helper methods
- (BOOL)checkForExpressOrder:(SOXShowOrderbookData *)addOrderData {
    if ([addOrderData.orderRequirements_paymentOption isEqual:@(BitcoinDE_PaymentOptionExpressOnly)]
        || [addOrderData.orderRequirements_paymentOption isEqual:@(BitcoinDE_PaymentOptionExpressAndSepa)]) {
        return YES;
    }

    return NO;
}

- (BOOL)removeOrderWithOrderID:(NSString *)orderID fromOrderBook:(NSMutableArray *)orderBook {
    NSMutableArray *foundOrders = [NSMutableArray array];
    // check for orderbookData with correct orderID
    for (SOXShowOrderbookData *orderbookData in orderBook) {
        if ([orderbookData.orderInformation_orderID isEqualToString:orderID]) {
            [foundOrders addObject:orderbookData];
        }
    }

    BOOL didRemoveOrders = NO;
    // remove orderbookData from arrayController
    for (id foundOrder in foundOrders) {
        [orderBook removeObject:foundOrder];
        didRemoveOrders = YES;
    }
    return didRemoveOrders;
};

- (NSArray *)updateOrderWithSocketOrderObjectID:(NSString *)orderObjectID
                               inOrderBook:(NSMutableArray *)orderBook
                                withValues:(NSDictionary *)changesDictionary {
    NSMutableArray *updatesOrders = [NSMutableArray array];
    for (SOXShowOrderbook_BitcoinDE_Data *orderbookData in orderBook) {
        NSLog(@"%@ - %@", orderObjectID, orderbookData.orderInformation_socketOrderObjectID);
        if ([orderbookData.orderInformation_socketOrderObjectID isEqualToString:orderObjectID]) {
            NSNumber *oldPaymentOption = orderbookData.orderRequirements_paymentOption;
            // ist data object mit orderObjectID vorhanden? Ja: updaten!
            [orderbookData updateOrderbookDataWith:changesDictionary];
            [updatesOrders addObject:orderbookData];

            NSString *note = [NSString stringWithFormat:@"~ update paymentOption - orderID: %@ - oldPayOp: %@ - newPayOp: %@"
                              , orderbookData.orderInformation_orderID
                              , oldPaymentOption
                              , orderbookData.orderRequirements_paymentOption];
            NSString *orderInformationType = orderbookData.orderInformation_type;
            if ([orderInformationType isEqualToString:@"offer"]) {
                [self informBuyDelegateWithNote:note];
            }
            else if ([orderInformationType isEqualToString:@"order"]) {
                [self informSellDelegateWithNote:note];
            }
        }
    }
    return [updatesOrders copy];
}

- (void)addOrderBookData:(SOXShowOrderbookData *)addOrderData {
    NSString *orderInformationType = addOrderData.orderInformation_type;
    NSString *addOrderDataOrderID = addOrderData.orderInformation_orderID;
    NSString *addOrderDataPrice   = [SOXFormatters currencyStringForNumber:addOrderData.orderInformation_price
                                                              roundingMode:NSNumberFormatterRoundDown];
    // Buy
    if ([orderInformationType isEqualToString:@"offer"]) {
        [self.buyOrderBook addObject:addOrderData];
        self.buyOrderBook = [SOXAutomaticTrading_BitcoinDE_Core sortedOrderBook:self.buyOrderBook
                                                                   forOrderType:BitcoinDE_BuyOrderType];

        NSString *note = [NSString stringWithFormat:@"added buy order - orderID: %@ - payOp: %@ - type: offer - index %tu - price: %@ - interest %@"
                          , addOrderDataOrderID
                          , addOrderData.orderRequirements_paymentOption
                          , [self.buyOrderBook indexOfObject:addOrderData]
                          , addOrderDataPrice
                          , [self effectiveBuyInterestRateFor:addOrderData
                                                  toReference:self.buyOrderBook.firstObject]];
        [self informBuyDelegateWithNote:note];

        if ([[self.buyOrderBook objectAtIndex:0] isEqual:addOrderData]) {
            [self updateBuyStatus];
            [self checkForBuyableOrder];
        }
    }
    // Sell
    else if ([orderInformationType isEqualToString:@"order"]) {
        [self.sellOrderBook addObject:addOrderData];
        self.sellOrderBook = [SOXAutomaticTrading_BitcoinDE_Core sortedOrderBook:self.sellOrderBook
                                                                    forOrderType:BitcoinDE_SellOrderType];

        NSString *note = [NSString stringWithFormat:@"added sell order - orderID: %@ - payOpt: %@ - type: order - index %tu - price: %@ - interest %@"
                          , addOrderDataOrderID
                          , addOrderData.orderRequirements_paymentOption
                          , [self.sellOrderBook indexOfObject:addOrderData]
                          , addOrderDataPrice
                          , [self effectiveSellInterestRateFor:addOrderData
                                                   toReference:self.sellOrderBook.firstObject]];
        [self informSellDelegateWithNote:note];

        if ([[self.sellOrderBook objectAtIndex:0] isEqual:addOrderData]) {
            [self updateSellStatus];
            [self checkForSellableOrder];
        }
    }
}

- (void)addSEPAOrderBookData:(SOXShowOrderbookData *)addSEPAOrderData {
    NSString *orderInformationType = addSEPAOrderData.orderInformation_type;
    if ([orderInformationType isEqualToString:@"offer"]) {
        [self.buySEPAOrderBook addObject:addSEPAOrderData];
        NSString *note = [NSString stringWithFormat:@"~ new SEPA order - orderID: %@ - payOp: %@ - type offer - interest %@"
                          , addSEPAOrderData.orderInformation_orderID
                          , addSEPAOrderData.orderRequirements_paymentOption
                          , [SOXFormatters currencyStringForNumber:addSEPAOrderData.orderInformation_price roundingMode:NSNumberFormatterRoundDown]];
        [self informBuyDelegateWithNote:note];
    }
    else if ([orderInformationType isEqualToString:@"order"]) {
        [self.sellSEPAOrderBook addObject:addSEPAOrderData];
        NSString *note = [NSString stringWithFormat:@"~ new SEPA order - orderID: %@ - payOp: %@ - type order - interest %@"
                          , addSEPAOrderData.orderInformation_orderID
                          , addSEPAOrderData.orderRequirements_paymentOption
                          , [SOXFormatters currencyStringForNumber:addSEPAOrderData.orderInformation_price roundingMode:NSNumberFormatterRoundDown]];
        [self informSellDelegateWithNote:note];
    }
}
#pragma mark - Inform delegates
- (void)informBuyDelegateWithNote:(NSString *)note {
    if (note) {
        for (NSObject <SOXAutomaticTradingCoreProtocol> *delegate in self.buyDelegates) {
            [delegate performSelector:@selector(logLine:)
                           withObject:note
             ];
        }
    }
}
- (void)informSellDelegateWithNote:(NSString *)note {
    if (note) {
        for (NSObject <SOXAutomaticTradingCoreProtocol> *delegate in self.sellDelegates) {
            [delegate performSelector:@selector(logLine:)
                           withObject:note
             ];
        }
    }
}

- (void)informBuyDelegateWithStatus:(NSString *)status {
    if (status) {
        for (NSObject <SOXAutomaticTradingCoreProtocol> *delegate in self.buyDelegates) {
            [delegate performSelector:@selector(statusUpdate:)
                           withObject:status
             ];
        }
    }
}

- (void)informSellDelegateWithStatus:(NSString *)status {
    if (status) {
        for (NSObject <SOXAutomaticTradingCoreProtocol> *delegate in self.sellDelegates) {
            [delegate performSelector:@selector(statusUpdate:)
                           withObject:status
             ];
        }
    }
}

#pragma mark | Helpers
- (void)updateBuyStatus {
    SOXShowOrderbook_BitcoinDE_Data *bestOrderData = self.buyOrderBook.firstObject;
    NSDecimalNumber *bestOrderDataPrice = bestOrderData.orderInformation_price;
    NSDecimalNumber *buyLowerThanPrice = [bestOrderDataPrice decimalNumberByMultiplyingBy:self.buyInterestFactor];
    NSString *status = [NSString stringWithFormat:@"Best: price %@, buy less than %@",
                        [SOXFormatters currencyStringForNumber:bestOrderDataPrice roundingMode:NSNumberFormatterRoundDown]
                        , [SOXFormatters currencyStringForNumber:buyLowerThanPrice roundingMode:NSNumberFormatterRoundDown]];
    [self informBuyDelegateWithStatus:status];
}

- (void)updateSellStatus {
    SOXShowOrderbook_BitcoinDE_Data *bestOrderData = self.sellOrderBook.firstObject;
    NSDecimalNumber *bestOrderDataPrice = bestOrderData.orderInformation_price;
    NSDecimalNumber *sellGreaterThanPrice = [bestOrderDataPrice decimalNumberByMultiplyingBy:self.sellInterestFactor];
    NSString *status = [NSString stringWithFormat:@"Best: price %@, sell greater than %@",
                        [SOXFormatters currencyStringForNumber:bestOrderDataPrice roundingMode:NSNumberFormatterRoundDown]
                        , [SOXFormatters currencyStringForNumber:sellGreaterThanPrice roundingMode:NSNumberFormatterRoundDown]];
    [self informSellDelegateWithStatus:status];
}

@end
