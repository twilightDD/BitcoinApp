//
//  SOXAutomaticTrading_BitcoinDE_Core.m
//  BitcoinApp
//
//  Created by Peter Hauke on 07.06.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXAutomaticTrading_BitcoinDE_Core.h"
#import "SOXAutomaticTradingCore_Private.h"

#import "SOXKeys_BitcoinDE.h"

#import "SOXMarket_BitcoinDE_Core.h"
#import "SOXSocketIO_BitcoinDE_Core.h"

#import "SOXMarket_BitcoinDE_DefTypes.h"

#import "SOXAccountInfoData.h"
#import "SOXShowOrderbook_BitcoinDE_Data.h"
#import "SOXTradeJob_BitcoinDE_Data.h"


@import AppKit;

@interface SOXAutomaticTrading_BitcoinDE_Core () <SOXMarketCoreServerRequestProtocol, SOXSocketIOCoreProtocol>

@property (strong, nonatomic) id requestShowAccountInfoNotification;
@property (nonatomic) BOOL waitingForBannerUpdate;

@property (strong, nonatomic) NSDecimalNumber *debugNewAvailBTC; // TODO: debug


@property (nonatomic) BOOL useBannerUpdateMechanicForBalanceTrades; // to use toggle balance trade mechanic

@end

@implementation SOXAutomaticTrading_BitcoinDE_Core

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.requestShowAccountInfoNotification];
}

#pragma mark - Public class methods
+ (instancetype)sharedTradingCore {
    static id sharedTradingCore;

    static dispatch_once_t pred;

    dispatch_once(&pred, ^{
        sharedTradingCore = [SOXAutomaticTrading_BitcoinDE_Core new];
        [sharedTradingCore setupProperties];

        // TODO: toggle balance trade mechanic
        [(SOXAutomaticTrading_BitcoinDE_Core *)sharedTradingCore setUseBannerUpdateMechanicForBalanceTrades:NO];
    });

    return sharedTradingCore;
}

+ (void)executeTrades:(BOOL)executeTrades forOrderType:(BitcoinDE_OrderType)orderType {
    SOXAutomaticTrading_BitcoinDE_Core *core = [SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore];

    switch (orderType) {
        case BitcoinDE_BuyOrderType: {
            core.executeBuyTrades = executeTrades;
            [core informBuyDelegateWithNote:[NSString stringWithFormat:@"!!! EXECUTE TRADE %@ !!!"
                                             , executeTrades ? @"enabled" : @"disabled"]];
            break;
        }
        case BitcoinDE_SellOrderType: {
            core.executeSellTrades = executeTrades;
            [core informSellDelegateWithNote:[NSString stringWithFormat:@"!!! EXECUTE TRADE %@ !!!"
                                              , executeTrades ? @"enabled" : @"disabled"]];
            break;
        }
        default:
            break;
    }
}

+ (void)executeBalanceTrades:(BOOL)executeBalanceTrades forOrderType:(BitcoinDE_OrderType)orderType {
    SOXAutomaticTrading_BitcoinDE_Core *core = [SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore];

    switch (orderType) {
        case BitcoinDE_BuyOrderType: {
            core.executeBalanceTradesForBuyTrades = executeBalanceTrades;
            [core informBuyDelegateWithNote:[NSString stringWithFormat:@"!!! EXECUTE BALANCE TRADE %@ !!!"
                                             , executeBalanceTrades ? @"enabled" : @"disabled"]];
            break;
        }
        case BitcoinDE_SellOrderType: {
            core.executeBalanceTradesForSellTrades = executeBalanceTrades;
            [core informSellDelegateWithNote:[NSString stringWithFormat:@"!!! EXECUTE BALANCE TRADE %@ !!!"
                                              , executeBalanceTrades ? @"enabled" : @"disabled"]];
            break;
        }
        default:
            break;
    }
}

+ (void)registerController:(id <SOXAutomaticTradingCoreProtocol>)controller
    forUpdatesForOrderType:(BitcoinDE_OrderType)orderType {

    if (!controller) {
        return;
    }

    SOXAutomaticTradingCore *tradingCore = [self sharedTradingCore];
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

+ (void)deRegisterController:(id)controller forUpdatesForOrderType:(BitcoinDE_OrderType)orderType {
    if (!controller) {
        return;
    }

    SOXAutomaticTradingCore *tradingCore = [SOXAutomaticTradingCore sharedTradingCore];

    switch (orderType) {
        case BitcoinDE_BuyOrderType:
            [tradingCore.buyDelegates removeObject:controller];
            break;
        case BitcoinDE_SellOrderType:
            [tradingCore.sellDelegates removeObject:controller];
            break;
        default:
            NSLog(@"ERROR - (void)registerForUpdatesForType:(BitcoinDE_OrderType)orderType");
            break;
    }

    [SOXAutomaticTrading_BitcoinDE_Core checkRegisterForSocketUpdatesStatus];
}

#pragma mark - WebSocket methods
+ (void)registerForWebSocketUpdates {
    SOXAutomaticTrading_BitcoinDE_Core *core = [SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore];

    NSDictionary *buyParameters = [SOXShowOrderbook_BitcoinDE_Data parametersForOrderType:BitcoinDE_BuyOrderType
                                                                 onlyExpressPaymentOption:YES];

    NSMutableDictionary *newBuyParameters = [buyParameters mutableCopy];
    [newBuyParameters setObject:@1 forKey:BitcoinDE_ShowMyOrders_OrderRequirements_OnlyKYCFull];

    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowBuyOrderbookCommandType
                                            withParameter:[newBuyParameters copy]
                                                respondTo:core];
    NSDictionary *sellParameters = [SOXShowOrderbook_BitcoinDE_Data parametersForOrderType:BitcoinDE_SellOrderType
                                                                  onlyExpressPaymentOption:YES];

    NSMutableDictionary *newSellParameters = [sellParameters mutableCopy];
    [newSellParameters setObject:@1 forKey:BitcoinDE_ShowMyOrders_OrderRequirements_OnlyKYCFull];
    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowSellOrderbookCommandType
                                            withParameter:[newSellParameters copy]
                                                respondTo:core];

    // register for banner update notifications
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];

    core.requestShowAccountInfoNotification = [[NSNotificationCenter defaultCenter] addObserverForName:BitcoinDE_Notification_RequestShowAccountInfo
                                                                                                object:nil
                                                                                                 queue:mainQueue
                                                                                            usingBlock:^(NSNotification * _Nonnull note) {
                                                                                                [[SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore] bannerWasUpdated:note.object];
                                                                                            }
                                               ];
}

+ (void)checkRegisterForSocketUpdatesStatus {
    SOXAutomaticTrading_BitcoinDE_Core *core = [SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore];

    // buy updates
    if (core.buyDelegates.count > 0) {
        [SOXSocketIO_BitcoinDE_Core registerForOrderUpdatesForUpdateType:BitcoinDE_UpdateType_BuyOrderChanges
                                                                delegate:core];
        [SOXSocketIO_BitcoinDE_Core registerForOrderUpdatesForUpdateType:BitcoinDE_UpdateType_RemoveOrderChanges
                                                                delegate:core];
    }
    else {
        [SOXSocketIO_BitcoinDE_Core unRegisterForOrderUpdatesForUpdateType:BitcoinDE_UpdateType_BuyOrderChanges
                                                                  delegate:core];
    }

    // sell updates
    if (core.sellDelegates.count > 0) {
        [SOXSocketIO_BitcoinDE_Core registerForOrderUpdatesForUpdateType:BitcoinDE_UpdateType_SellOrderChanges
                                                                delegate:core];

    }
    else {
        [SOXSocketIO_BitcoinDE_Core unRegisterForOrderUpdatesForUpdateType:BitcoinDE_UpdateType_SellOrderChanges
                                                                  delegate:core];
    }

    // remove updates
    if (core.buyDelegates.count == 0
        && core.sellDelegates.count == 0) {
        [SOXSocketIO_BitcoinDE_Core unRegisterForOrderUpdatesForUpdateType:BitcoinDE_UpdateType_RemoveOrderChanges
                                                                  delegate:core];
    }
    else {
        [SOXSocketIO_BitcoinDE_Core registerForOrderUpdatesForUpdateType:BitcoinDE_UpdateType_RemoveOrderChanges
                                                                delegate:core];
    }
}

#pragma mark - Private class methods
+ (NSMutableArray *)sortedOrderBook:(NSMutableArray <SOXShowOrderbookData *> *)orderBookDatas forOrderType:(BitcoinDE_OrderType)orderType {
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


- (void)tryToBuy:(SOXShowOrderbookData *)orderToBuy btcAmountToBuy:(NSDecimalNumber *)btcAmountToBuy {
    if (btcAmountToBuy
        && [btcAmountToBuy isGreaterThan:[NSDecimalNumber zero]]) {
        NSDecimalNumber *priceForBTCAmountToBuy = [btcAmountToBuy decimalNumberByMultiplyingBy:orderToBuy.orderInformation_price];
        NSString *note = [NSString stringWithFormat:@"BUY btcAmount: %@ for %@"
                          , [SOXFormatters stringForBTCNumber:btcAmountToBuy]
                          , [SOXFormatters currencyStringForNumber:priceForBTCAmountToBuy roundingMode:NSNumberFormatterRoundDown]];
        [self informBuyDelegateWithNote:note];

        if (self.executeBuyTrades) {
            note = [NSString stringWithFormat:@"EXECUTE BUY allowed => TRY BUY."];
            NSDictionary *parameters = [SOXTradeJob_BitcoinDE_Data parameterAutomaticTradingForOrderID:orderToBuy.orderInformation_orderID
                                                                                             orderType:BitcoinDE_BuyOrderType
                                                                                         bitcoinAmount:btcAmountToBuy
                                                                                                 price:orderToBuy.orderInformation_price];


            [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ExecuteTrade
                                                    withParameter:parameters
                                                        respondTo:self];
            [self playSound];
        }
        else {
            note = [NSString stringWithFormat:@"EXECUTE BUY not allowed - so I don't buy"];
            // TODO: Fake
            {
                note = [note stringByAppendingString:@" - BUT try BALANCE methods ;)"];


            }

            NSBeep();
        }

        [self informBuyDelegateWithNote:note];
    }

    [self informBuyDelegateWithNote:@"------"];
}

- (void)tryToSell:(SOXShowOrderbookData *)orderToSell btcAmountToSell:(NSDecimalNumber *)btcAmountToSell {
    if (btcAmountToSell
        && [btcAmountToSell isGreaterThan:[NSDecimalNumber zero]]) {
        NSDecimalNumber *priceForBTCAmountToSell = [btcAmountToSell decimalNumberByMultiplyingBy:orderToSell.orderInformation_price];
        NSString *note = [NSString stringWithFormat:@"SELL btcAmount: %@ for %@"
                          , [SOXFormatters stringForBTCNumber:btcAmountToSell]
                          , [SOXFormatters currencyStringForNumber:priceForBTCAmountToSell roundingMode:NSNumberFormatterRoundDown]];
        [self informSellDelegateWithNote:note];

        if (self.executeSellTrades) {
            note = [NSString stringWithFormat:@"EXECUTE SELL allowed => TRY SELL."];

            NSDictionary *parameters = [SOXTradeJob_BitcoinDE_Data parameterAutomaticTradingForOrderID:orderToSell.orderInformation_orderID
                                                                                             orderType:BitcoinDE_SellOrderType
                                                                                         bitcoinAmount:btcAmountToSell
                                                                                                 price:orderToSell.orderInformation_price];

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

#pragma mark - Balance trade methods
- (void)createBalanceTrades {
    // buyParameters
    {
        NSDecimalNumber *buyBTCSum = [NSDecimalNumber zero];
        for (NSDictionary *buyBalanceTradeParameter in self.buyBalanceTradeParameters) {
            buyBTCSum = [buyBTCSum decimalNumberByAdding:[buyBalanceTradeParameter objectForKey:BitcoinDE_ExecuteTrade_BitcoinAmount]];
        }
        NSDecimalNumber *bitcoinFee = [NSDecimalNumber decimalNumberWithString:@"0.996"];
        buyBTCSum = [buyBTCSum decimalNumberByMultiplyingBy:bitcoinFee];

        [self.buyBalanceTradeParameters removeAllObjects];

        if ([buyBTCSum isGreaterThan:[NSDecimalNumber zero]] ) {
            // new Paramater

            NSDictionary *parameters = [SOXTradeJob_BitcoinDE_Data parameterAutomaticTradingForOrderID:@"dummyBuyOrderID"
                                                                                             orderType:BitcoinDE_BuyOrderType
                                                                                         bitcoinAmount:buyBTCSum
                                                                                                 price:[NSDecimalNumber zero]];
            [self createBalanceTradesForTradeParameters:parameters];
        }
    }

    // sellParameters
    {
        NSDecimalNumber *sellBTCSum = [NSDecimalNumber zero];
        for (NSDictionary *sellBalanceTradeParameter in self.sellBalanceTradeParameters) {
            sellBTCSum = [sellBTCSum decimalNumberByAdding:[sellBalanceTradeParameter objectForKey:BitcoinDE_ExecuteTrade_BitcoinAmount]];
        }

        [self.sellBalanceTradeParameters removeAllObjects];

        if ([sellBTCSum isGreaterThan:[NSDecimalNumber zero]] ) {
            NSDictionary *parameters = [SOXTradeJob_BitcoinDE_Data parameterAutomaticTradingForOrderID:@"dummySellOrderID"
                                                                                             orderType:BitcoinDE_SellOrderType
                                                                                         bitcoinAmount:sellBTCSum
                                                                                                 price:[NSDecimalNumber zero]];
            [self createBalanceTradesForTradeParameters:parameters];
        }
    }
}

- (void)createBalanceTradesForTradeParameters:(NSDictionary *)parameters {
    if (!parameters
        || parameters.allKeys.count == 0) {
        return;
    }

    NSString *orderTypeString = [parameters objectForKey:BitcoinDE_ExecuteTrade_Type];
    BitcoinDE_OrderType orderType = [SOXMarket_BitcoinDE_DefTypes orderTypeForOrderTypeString:orderTypeString];
    if (orderType != BitcoinDE_BuyOrderType
        && orderType != BitcoinDE_SellOrderType) {
        return;
    }

    NSArray *parametersToExecute;

    if (orderType == BitcoinDE_BuyOrderType) {
        parametersToExecute = [self sellBalanceParametersForTradeParameters:parameters];
    }
    else if (orderType == BitcoinDE_SellOrderType) {
        parametersToExecute = [self buyBalanceParametersForTradeParameters:parameters];
    }

    // Execute Balance Trades
    [self tryToExecuteBalanceTradesWithParameters:parametersToExecute
                                     forOrderType:orderType];
}

- (void)createNewBalanceTradeForBalanceTradeParameters:(NSDictionary *)balanceParameters {
    if (!balanceParameters
        || balanceParameters.allKeys.count == 0) {
        return;
    }

    NSString *orderTypeString = [balanceParameters objectForKey:BitcoinDE_ExecuteTrade_Type];
    BitcoinDE_OrderType orderType = [SOXMarket_BitcoinDE_DefTypes orderTypeForOrderTypeString:orderTypeString];
    if (orderType != BitcoinDE_BuyOrderType
        && orderType != BitcoinDE_SellOrderType) {
        return;
    }

    NSArray *parametersToExecute;

    if (orderType == BitcoinDE_BuyOrderType) {
        parametersToExecute = [self buyBalanceParametersForTradeParameters:balanceParameters];
    }
    else if (orderType == BitcoinDE_SellOrderType) {
        parametersToExecute = [self sellBalanceParametersForTradeParameters:balanceParameters];
    }

    // Execute Balance Trades
    [self tryToExecuteBalanceTradesWithParameters:parametersToExecute
                                     forOrderType:orderType];
}

- (NSArray *)buyBalanceParametersForTradeParameters:(NSDictionary *)parameters {
    NSString *note = [NSString stringWithFormat:@"New remainingBuyBitcoinAmount: %@ (old+remainingFromLastSell)"
                      , [self.remainingBuyBitcoinAmount decimalNumberByAdding:[parameters objectForKey:BitcoinDE_ExecuteTrade_BitcoinAmount]]];
    [self informSellDelegateWithNote:note];


    NSMutableArray *balanceBuyParameters = [NSMutableArray array];

    NSDecimalNumber *remainingBitcoinAmount = [self.remainingBuyBitcoinAmount decimalNumberByAdding:[parameters objectForKey:BitcoinDE_ExecuteTrade_BitcoinAmount]];
    NSDecimalNumber *oldSellPrice = [parameters objectForKey:BitcoinDE_ExecuteTrade_Price];

    NSMutableArray *buyOrderBookDatasToRemove = [NSMutableArray array];

    for (NSUInteger idx = 0; idx < self.buyOrderBook.count; idx++) {
        SOXShowOrderbookData *buyOrder = [self.buyOrderBook objectAtIndex:idx];

        //        if ([oldSellPrice isLessThanOrEqualTo:buyOrder.orderInformation_price]  ) { // TODO: interestRate!!!
        //            break;
        //        }


        if ([buyOrder.orderInformation_minAmount isLessThanOrEqualTo:remainingBitcoinAmount]) {
            NSDecimalNumber *amountToBuy = [SOXFormatters lesserDecimalNumberFrom:remainingBitcoinAmount
                                                                              and:buyOrder.orderInformation_maxAmount];

            NSDictionary *parameters = [SOXTradeJob_BitcoinDE_Data parameterForOrderID:buyOrder.orderInformation_orderID
                                                                             orderType:BitcoinDE_BuyOrderType
                                                                         bitcoinAmount:amountToBuy];
            [balanceBuyParameters addObject:parameters];
            [buyOrderBookDatasToRemove addObject:buyOrder];

            remainingBitcoinAmount = [remainingBitcoinAmount decimalNumberBySubtracting:amountToBuy];
            if ([remainingBitcoinAmount isEqualTo:[NSDecimalNumber zero]]) {
                break;
            }
        }
    }
    // TODO: dont remove on nonbannerMechanics
    if (self.useBannerUpdateMechanicForBalanceTrades) {
        [self.buyOrderBook removeObjectsInArray:buyOrderBookDatasToRemove];
    }

    self.remainingBuyBitcoinAmount = remainingBitcoinAmount;

    return [balanceBuyParameters copy];
}

- (NSArray *)sellBalanceParametersForTradeParameters:(NSDictionary *)parameters {
    NSString *note = [NSString stringWithFormat:@"New remainingSellBitcoinAmount: %@ (old+remainingFromLastBuy)"
                      , [self.remainingSellBitcoinAmount decimalNumberByAdding:[parameters objectForKey:BitcoinDE_ExecuteTrade_BitcoinAmount]]];
    [self informBuyDelegateWithNote:note];

    NSMutableArray *balanceSellParameters = [NSMutableArray array];

    NSDecimalNumber *remainingBitcoinAmount = [self.remainingSellBitcoinAmount decimalNumberByAdding:[parameters objectForKey:BitcoinDE_ExecuteTrade_BitcoinAmount]];
    NSDecimalNumber *oldBuyPrice = [parameters objectForKey:BitcoinDE_ExecuteTrade_Price];

    NSMutableArray *sellOrderBookDatasToRemove = [NSMutableArray array];

    for (NSUInteger idx = 0; idx < self.sellOrderBook.count; idx++) {
        SOXShowOrderbookData *sellOrder = [self.sellOrderBook objectAtIndex:idx];

//        NSDecimalNumber *effectiveInterestRate = [self effectiveSellInterestRateForPrice:oldBuyPrice
//                                                                        toReferencePrice:sellOrder.orderInformation_price];
        //        if ([oldBuyPrice isGreaterThanOrEqualTo:sellOrder.orderInformation_price]  ) { // TODO: interestRate!!!
        //            break;
        //        }


        if ([sellOrder.orderInformation_minAmount isLessThanOrEqualTo:remainingBitcoinAmount]) {
            NSDecimalNumber *amountToSell = [SOXFormatters lesserDecimalNumberFrom:remainingBitcoinAmount
                                                                               and:sellOrder.orderInformation_maxAmount];

            NSDictionary *parameters = [SOXTradeJob_BitcoinDE_Data parameterForOrderID:sellOrder.orderInformation_orderID
                                                                             orderType:BitcoinDE_SellOrderType
                                                                         bitcoinAmount:amountToSell];
            [balanceSellParameters addObject:parameters];

            remainingBitcoinAmount = [remainingBitcoinAmount decimalNumberBySubtracting:amountToSell];

            [sellOrderBookDatasToRemove addObject:sellOrder];

            if ([remainingBitcoinAmount isEqualTo:[NSDecimalNumber zero]]) {
                break;
            }
        }
    }
    self.remainingSellBitcoinAmount = remainingBitcoinAmount;

    // TODO: dont remove on nonbannerMechanics
    if (self.useBannerUpdateMechanicForBalanceTrades) {
        [self.sellOrderBook removeObjectsInArray:sellOrderBookDatasToRemove];
    }

    return [balanceSellParameters copy];
}

- (void)tryToExecuteBalanceTradesWithParameters:(NSArray *)parametersToExecute
                                   forOrderType:(BitcoinDE_OrderType)orderType {
    NSDecimalNumber *sum = [NSDecimalNumber zero];
    for (NSDictionary *parameters in parametersToExecute) {
        { // Debug logout
            if (orderType == BitcoinDE_BuyOrderType) {
                NSString *note = [NSString stringWithFormat:@"SellBalancePayment: ID %@ - amount %@"
                                  , [parameters objectForKey:BitcoinDE_ExecuteTrade_OrderID]
                                  , [parameters objectForKey:BitcoinDE_ExecuteTrade_BitcoinAmount]];
                sum = [sum decimalNumberByAdding:[parameters objectForKey:BitcoinDE_ExecuteTrade_BitcoinAmount]];
                [self informBuyDelegateWithNote:note];
            }
            else if (orderType == BitcoinDE_SellOrderType) {
                NSString *note = [NSString stringWithFormat:@"BuyBalancePayment: ID %@ - amount %@"
                                  , [parameters objectForKey:BitcoinDE_ExecuteTrade_OrderID]
                                  , [parameters objectForKey:BitcoinDE_ExecuteTrade_BitcoinAmount]];
                sum = [sum decimalNumberByAdding:[parameters objectForKey:BitcoinDE_ExecuteTrade_BitcoinAmount]];
                [self informSellDelegateWithNote:note];
            }
        }

        // Execute BalanceTrade
        {
            if (orderType == BitcoinDE_BuyOrderType) {
                if (self.executeBalanceTradesForBuyTrades) {
                    NSString *note = [NSString stringWithFormat:@"Would try to execute"];
                    [self informBuyDelegateWithNote:note];
//                    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ExecuteTrade
//                                                            withParameter:parameters
//                                                                respondTo:self];
                }
                else {
                    [self fakeServerAnswerForSellParameters:parameters];
                }
            }
            else if (orderType == BitcoinDE_SellOrderType) {
                if (self.executeBalanceTradesForSellTrades) {
                    NSString *note = [NSString stringWithFormat:@"Would try to execute"];
                    [self informSellDelegateWithNote:note];
//                    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ExecuteTrade
//                                                            withParameter:parameters
//                                                                respondTo:self];
                }
                else {
                    for (NSDictionary *parameters in parametersToExecute) {
                        [self fakeServerAnswerForBuyParameters:parameters];
                    }
                }
            }
        }


    }
    NSString *note = [NSString stringWithFormat:@"sum of amount: %@", sum];
    if (orderType == BitcoinDE_BuyOrderType) {
        [self informBuyDelegateWithNote:note];
    }
    else if (orderType == BitcoinDE_SellOrderType) {
        [self informSellDelegateWithNote:note];
    }


}


#pragma mark - SOXMarketCoreServerRequestProtocol
- (void)answerOfServerRequest:(NSDictionary * _Nonnull)answerOfServerRequest {
    id errorMessage = [answerOfServerRequest objectForKey:ServerAnswerErrorKey];
    if (errorMessage) {
        NSLog(@"SOXAutomaticTrading_BitcoinDE_Core - answerOfServerRequest with error:\n%@", errorMessage);

    }

    // Answer for execute Trade
    if ([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ExecuteTrade)]) {
        NSDictionary *parameters = [answerOfServerRequest objectForKey:ServerAnswerParametersKey]; // parameters of executed trade

        NSString *orderTypeString = [parameters objectForKey:BitcoinDE_ExecuteTrade_Type];  //=> buy oder sell
        BitcoinDE_OrderType orderType = [SOXMarket_BitcoinDE_DefTypes orderTypeForOrderTypeString:orderTypeString];

        { // Inform user about success status
            NSString *note;
            if (errorMessage) {
                note = @"Trade UNSUCCESSFUL: ";
            }
            else {
                note = @"Trade SUCCESSFUL: ";
            }
            NSString *noteExtension = [NSString stringWithFormat:@"type: %@-%@ - ID: %@ - btc: %@ - price: %@"
                                       , [parameters objectForKey:BitcoinDE_ExecuteTrade_IsAutomaticTrade] ? @"Auto" : @"Balance"
                                       , [parameters objectForKey:BitcoinDE_ExecuteTrade_Type]
                                       , [parameters objectForKey:BitcoinDE_ExecuteTrade_OrderID]
                                       , [parameters objectForKey:BitcoinDE_ExecuteTrade_BitcoinAmount]
                                       , [parameters objectForKey:BitcoinDE_ExecuteTrade_Price]];
            note = [note stringByAppendingString:noteExtension];
            if (orderType == BitcoinDE_BuyOrderType) {
                [self informBuyDelegateWithNote:note];
            }
            else if (orderType == BitcoinDE_SellOrderType) {
                [self informSellDelegateWithNote:note];
            }
        }


        BOOL wasAutoTrade = [[parameters objectForKey:BitcoinDE_ExecuteTrade_IsAutomaticTrade] isEqualTo:@YES];
        if (!errorMessage
            && wasAutoTrade) { // if success and was autoTrade: update Banner and then create balance trades
            // Keep current availableBitcoinAmount
            self.availableBitcoinAmountBeforeBannerUpdate = [SOXMarket_BitcoinDE_Core sharedCore].availableBitcoinAmount;

            // Keep parameters to create balance trades after banner update
            if (orderType == BitcoinDE_BuyOrderType) {
                [self.buyBalanceTradeParameters addObject:parameters];
            }
            else if (orderType == BitcoinDE_SellOrderType) {
                [self.sellBalanceTradeParameters addObject:parameters];
            }

            // update banner
            [self updateBanner];
            if (!self.useBannerUpdateMechanicForBalanceTrades) {
                [self createBalanceTrades];
            }

        }
        else if (!errorMessage
                 && !wasAutoTrade) { // if no success and was balanceTrade: keep parameters for further balance trades
            NSString *note = [NSString stringWithFormat:@"BALANCE TRADE SUCCESSFUL type: %@-%@ - ID: %@ - btc: %@ - price: %@"
                              , [parameters objectForKey:BitcoinDE_ExecuteTrade_IsAutomaticTrade] ? @"Auto" : @"Balance"
                              , [parameters objectForKey:BitcoinDE_ExecuteTrade_Type]
                              , [parameters objectForKey:BitcoinDE_ExecuteTrade_OrderID]
                              , [parameters objectForKey:BitcoinDE_ExecuteTrade_BitcoinAmount]
                              , [parameters objectForKey:BitcoinDE_ExecuteTrade_Price]];
            if (orderType == BitcoinDE_BuyOrderType) {
                [self informSellDelegateWithNote:note];
            }
            else if (orderType == BitcoinDE_SellOrderType) {
                [self informBuyDelegateWithNote:note];
            }
        }
        else if (errorMessage
                 && !wasAutoTrade) { // if no success and was balanceTrade: keep parameters for further balance trades

            if (orderType == BitcoinDE_BuyOrderType) {
                [self.buyBalanceTradeParameters addObject:parameters];
            }
            else if (orderType == BitcoinDE_SellOrderType) {
                [self.sellBalanceTradeParameters addObject:parameters];
            }
        }
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
            else {
                NSString *note = [NSString stringWithFormat:@"!!! SEPA only on orderBook: %@"
                                  , orderBookData.orderInformation_orderID];
                [self informBuyDelegateWithNote:note];
                [self.buySEPAOrderBook addObject:orderBookData];
            }

            NSLog(@"answer buy: %@ %@ - payOp: %@"
                  , orderBookData.orderInformation_orderID
                  , orderBookData.tradingPartnerInformation_isKYCFull ? @"YES" : @"NO"
                  , orderBookData.orderRequirements_paymentOption);
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
            else {
                NSString *note = [NSString stringWithFormat:@"!!! SEPA only on orderBook: %@"
                                  , orderBookData.orderInformation_orderID];
                [self informSellDelegateWithNote:note];
                [self.sellSEPAOrderBook addObject:orderBookData];
            }
            NSLog(@"answer buy: %@ %@ - payOp: %@"
                  , orderBookData.orderInformation_orderID
                  , orderBookData.tradingPartnerInformation_isKYCFull ? @"YES" : @"NO"
                  , orderBookData.orderRequirements_paymentOption);
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

#pragma mark - SOXSocketIOCoreProtocol
- (void)socketIODidConnect:(NSString *)socketStatus {
    [self informBuyDelegateWithNote:socketStatus];
    [self informSellDelegateWithNote:socketStatus];
}

- (void)socketIODidDisconnect:(NSString *)socketStatus {
    [self informBuyDelegateWithNote:socketStatus];
    [self informSellDelegateWithNote:socketStatus];
}

- (void)addedOrder:(SOXShowOrderbookData *)addOrderData {
    if (!addOrderData.tradingPartnerInformation_isKYCFull) {
        NSLog(@"### NO KYC: orderID: %@", addOrderData.orderInformation_orderID);
        return;
    }

    if ([self checkForExpressOrder:addOrderData]) {
        [self addOrderBookData:addOrderData];
    }
    else {
        [self addSEPAOrderBookData:addOrderData];
    }
}

- (void)removedOrderWithOrderID:(NSString *)orderID {
    NSString *note = [NSString stringWithFormat:@"removed order - orderID %@", orderID];
    if ([self removeOrderWithOrderID:orderID fromOrderBook:self.buyOrderBook]) {
        [self updateBuyStatus];
        note = [note stringByAppendingString:[NSString stringWithFormat:@" (bOB.count: %tu)"
                                              ,self.buyOrderBook.count]];
        [self informBuyDelegateWithNote:note];
    }

    else if ([self removeOrderWithOrderID:orderID fromOrderBook:self.sellOrderBook]) {
        [self updateSellStatus];
        note = [note stringByAppendingString:[NSString stringWithFormat:@" (sOB.count: %tu)"
                                              ,self.sellOrderBook.count]];
        [self informSellDelegateWithNote:note];
    }
    else {
        [self removeSEPAOrderWithOrderID:orderID];
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

- (BOOL)removeOrderWithOrderID:(NSString *)orderID fromOrderBook:(NSMutableArray <SOXShowOrderbookData*> *)orderBook {
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

- (void)removeSEPAOrderWithOrderID:(NSString *)orderID {
    NSString *note = [NSString stringWithFormat:@"~ removed SEPA order - orderID %@", orderID];
    NSPredicate* orderWithOrderIDPredicate = [NSPredicate predicateWithFormat:@"orderInformation_orderID == %@",orderID ];
    NSSet *filteredBuySEPAOrderbook = [self.buySEPAOrderBook filteredSetUsingPredicate:orderWithOrderIDPredicate];
    for (SOXShowOrderbookData *orderbookData in filteredBuySEPAOrderbook) {
        [self.buySEPAOrderBook removeObject:orderbookData];
        [self informBuyDelegateWithNote:note];
    }
    NSSet *filteredSellSEPAOrderbook = [self.sellSEPAOrderBook filteredSetUsingPredicate:orderWithOrderIDPredicate];
    for (SOXShowOrderbookData *orderbookData in filteredSellSEPAOrderbook) {
        [self.sellSEPAOrderBook removeObject:orderbookData];
        [self informSellDelegateWithNote:note];
    }
}

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

            NSString *note = [NSString stringWithFormat:@"~ update paymentOption - ID: %@ - oldPO: %@ - newPO: %@"
                              , orderbookData.orderInformation_orderID
                              , oldPaymentOption
                              , orderbookData.orderRequirements_paymentOption];
            NSString *orderInformationType = orderbookData.orderInformation_type;
            if ([orderInformationType isEqualToString:BitcoinDE_WebSocket_BuyOrderType]) {
                [self informBuyDelegateWithNote:note];
            }
            else if ([orderInformationType isEqualToString:BitcoinDE_WebSocket_SellOrderType]) {
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
    if ([orderInformationType isEqualToString:BitcoinDE_WebSocket_BuyOrderType]) {
        [self.buyOrderBook addObject:addOrderData];
        self.buyOrderBook = [SOXAutomaticTrading_BitcoinDE_Core sortedOrderBook:self.buyOrderBook
                                                                   forOrderType:BitcoinDE_BuyOrderType];

        NSString *note = [NSString stringWithFormat:@"added buy (bOB.count: %tu)- ID: %@ - pO: %@ - type: offer - idx %tu - p: %@ - minA: %@ - maxA: %@ - iR %@"
                          , self.buyOrderBook.count
                          , addOrderDataOrderID
                          , addOrderData.orderRequirements_paymentOption
                          , [self.buyOrderBook indexOfObject:addOrderData]
                          , addOrderDataPrice
                          , addOrderData.orderInformation_minAmount
                          , addOrderData.orderInformation_maxAmount
                          , [self effectiveBuyInterestRateForData:addOrderData
                                                  toReferenceData:self.buyOrderBook.firstObject]];
        [self informBuyDelegateWithNote:note];

        if ([[self.buyOrderBook objectAtIndex:0] isEqual:addOrderData]) {
            [self updateBuyStatus];
            [self checkForBuyableOrder];
            return;
        }
        else if (!self.waitingForBannerUpdate
                 && (self.sellBalanceTradeParameters.count > 0
                     || [self.remainingSellBitcoinAmount isGreaterThan:[NSDecimalNumber zero]])) {
            // create balancePayments
            [self informBuyDelegateWithNote:@"~~~~~~~~~~~~~~~~"];
            NSString *note = [NSString stringWithFormat:@"Socket addOrder BUY & remainingSellBitcoinAmount %@", self.remainingSellBitcoinAmount];
            [self informBuyDelegateWithNote:note];
            [self informBuyDelegateWithNote:@"try to create new balanceTrades to SELL"];
            [self createBalanceTrades];
            [self informBuyDelegateWithNote:@"~~~~~~~~~~~~~~~~"];
        }
        if (self.buyOrderBook.count > 0
            && self.sellOrderBook.count > 0) {
            { // TODO: Fake
                if (!self.executeBalanceTradesForBuyTrades) {
                    SOXShowOrderbookData *buyOrder = [self.buyOrderBook objectAtIndex:0];
                    [self createFakeServerAnswerForBuyOrder:buyOrder];
                }
            }
        }


    }
    // Sell
    else if ([orderInformationType isEqualToString:BitcoinDE_WebSocket_SellOrderType]) {
        [self.sellOrderBook addObject:addOrderData];
        self.sellOrderBook = [SOXAutomaticTrading_BitcoinDE_Core sortedOrderBook:self.sellOrderBook
                                                                    forOrderType:BitcoinDE_SellOrderType];

        NSString *note = [NSString stringWithFormat:@"added sell (sOB.count: %tu)- ID: %@ - pO: %@ - type: offer - idx %tu - p: %@ - minA: %@ - maxA: %@ - iR %@"
                          , self.sellOrderBook.count
                          , addOrderDataOrderID
                          , addOrderData.orderRequirements_paymentOption
                          , [self.sellOrderBook indexOfObject:addOrderData]
                          , addOrderDataPrice
                          , addOrderData.orderInformation_minAmount
                          , addOrderData.orderInformation_maxAmount
                          , [self effectiveSellInterestRateForData:addOrderData
                                                   toReferenceData:self.sellOrderBook.firstObject]];
        [self informSellDelegateWithNote:note];

        if ([[self.sellOrderBook objectAtIndex:0] isEqual:addOrderData]) {
            [self updateSellStatus];
            [self checkForSellableOrder];
            return;
        }
        else if (!self.waitingForBannerUpdate
                 && (self.buyBalanceTradeParameters.count > 0
                     || [self.remainingBuyBitcoinAmount isGreaterThan:[NSDecimalNumber zero]])) {
            // create balancePayments
            [self informSellDelegateWithNote:@"~~~~~~~~~~~~~~~~"];
            NSString *note = [NSString stringWithFormat:@"Socket addOrder SELL & remainingBuyBitcoinAmount %@", self.remainingBuyBitcoinAmount];
            [self informSellDelegateWithNote:note];
            [self informSellDelegateWithNote:@"try to create new balanceTrades to BUY"];
            [self createBalanceTrades];
            [self informBuyDelegateWithNote:@"~~~~~~~~~~~~~~~~"];
        }
        if (self.buyOrderBook.count > 0
            && self.sellOrderBook.count > 0) {
            { // TODO: Fake
                if (!self.executeBalanceTradesForSellTrades) {
                    SOXShowOrderbookData *sellOrder = [self.sellOrderBook objectAtIndex:0];
                    [self createFakeServerAnswerForSellOrder:sellOrder];
                }
            }
        }
    }
}

- (void)addSEPAOrderBookData:(SOXShowOrderbookData *)addSEPAOrderData {
    NSString *orderInformationType = addSEPAOrderData.orderInformation_type;
    if ([orderInformationType isEqualToString:BitcoinDE_WebSocket_BuyOrderType]) {
        [self.buySEPAOrderBook addObject:addSEPAOrderData];

        NSDecimalNumber *effectiveBuyInterestRate;
        if (self.buyOrderBook.count > 1) {
            effectiveBuyInterestRate = [self effectiveBuyInterestRateForData:addSEPAOrderData
                                                             toReferenceData:[self.buyOrderBook objectAtIndex:1]];
        }

        NSString *note = [NSString stringWithFormat:@"~ new SEPA (bSepa.count: %tu): type offer - order - orderID: %@ - payO: %@ - IR %@"
                          , self.buySEPAOrderBook.count
                          , addSEPAOrderData.orderInformation_orderID
                          , addSEPAOrderData.orderRequirements_paymentOption
                          , effectiveBuyInterestRate ? effectiveBuyInterestRate : @"NaN (buyOrderBook has too less entries"];
        [self informBuyDelegateWithNote:note];
    }
    else if ([orderInformationType isEqualToString:BitcoinDE_WebSocket_SellOrderType]) {
        [self.sellSEPAOrderBook addObject:addSEPAOrderData];
        NSDecimalNumber *effectiveSellInterestRate;
        if (self.sellOrderBook.count > 1) {
            effectiveSellInterestRate = [self effectiveSellInterestRateForData:addSEPAOrderData
                                                               toReferenceData:[self.sellOrderBook objectAtIndex:1]];
        }
        NSString *note = [NSString stringWithFormat:@"~ new SEPA (sSepa.count: %tu): type order - orderID: %@ - payO: %@ - IR %@"
                          , self.sellSEPAOrderBook.count
                          , addSEPAOrderData.orderInformation_orderID
                          , addSEPAOrderData.orderRequirements_paymentOption
                          , effectiveSellInterestRate ? effectiveSellInterestRate : @"NaN (sellOrderBook has too less entries"];
        [self informSellDelegateWithNote:note];
    }
}

#pragma mark - FAKE
- (void)createFakeServerAnswerForBuyOrder:(SOXShowOrderbookData *)buyOrder {
    NSDictionary *autoParameters = [SOXTradeJob_BitcoinDE_Data parameterAutomaticTradingForOrderID:buyOrder.orderInformation_orderID
                                                                                     orderType:BitcoinDE_BuyOrderType
                                                                                 bitcoinAmount:buyOrder.orderInformation_maxAmount
                                                                                         price:buyOrder.orderInformation_price];

    NSDictionary *balanceParameters = [SOXTradeJob_BitcoinDE_Data parameterBalanceTradingForOrderID:buyOrder.orderInformation_orderID
                                                                                          orderType:BitcoinDE_BuyOrderType
                                                                                      bitcoinAmount:buyOrder.orderInformation_maxAmount
                                                                                              price:buyOrder.orderInformation_price];

    [self fakeServerAnswerForBuyParameters:autoParameters];
}

- (void)createFakeServerAnswerForSellOrder:(SOXShowOrderbookData *)sellOrder {
    NSDictionary *autoParameters = [SOXTradeJob_BitcoinDE_Data parameterAutomaticTradingForOrderID:sellOrder.orderInformation_orderID
                                                                                         orderType:BitcoinDE_SellOrderType
                                                                                     bitcoinAmount:sellOrder.orderInformation_maxAmount
                                                                                             price:sellOrder.orderInformation_price];

    NSDictionary *balanceParameters = [SOXTradeJob_BitcoinDE_Data parameterBalanceTradingForOrderID:sellOrder.orderInformation_orderID
                                                                                          orderType:BitcoinDE_SellOrderType
                                                                                      bitcoinAmount:sellOrder.orderInformation_maxAmount
                                                                                              price:sellOrder.orderInformation_price];

    [self fakeServerAnswerForSellParameters:balanceParameters];
}

- (void)fakeServerAnswerForBuyParameters:(NSDictionary *)parameters {
    NSMutableDictionary *fakeAnswerDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           @(BitcoinDE_ExecuteTrade), ServerAnswerServerCommandKey
                                           , parameters, ServerAnswerParametersKey
                                           //, @"error", ServerAnswerErrorKey
                                           , nil];

    NSString *note = [NSString stringWithFormat:@"!!! FAKE TRADE !!!"];
    [self informBuyDelegateWithNote:note];

    [self answerOfServerRequest:fakeAnswerDict];
}

- (void)fakeServerAnswerForSellParameters:(NSDictionary *)parameters {
    NSMutableDictionary *fakeAnswerDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           @(BitcoinDE_ExecuteTrade), ServerAnswerServerCommandKey
                                           , parameters, ServerAnswerParametersKey
                                           //, @"error", ServerAnswerErrorKey
                                           , nil];

    NSString *note = [NSString stringWithFormat:@"!!! FAKE TRADE !!!"];
    [self informSellDelegateWithNote:note];

    [self answerOfServerRequest:fakeAnswerDict];
}

#pragma mark - Banner updates
- (void)updateBanner {
    self.waitingForBannerUpdate = YES;
    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowAccountInfoCommandType
                                            withParameter:nil
                                                respondTo:nil];
}

- (void)bannerWasUpdated:(NSDictionary *)serverAnswer {

    // buyParameters
    NSDecimalNumber *buyBTCSum = [NSDecimalNumber zero];
    for (NSDictionary *buyBalanceTradeParameter in self.buyBalanceTradeParameters) {
        buyBTCSum = [buyBTCSum decimalNumberByAdding:[buyBalanceTradeParameter objectForKey:BitcoinDE_ExecuteTrade_BitcoinAmount]];
    }
    NSDecimalNumber *bitcoinFee = [NSDecimalNumber decimalNumberWithString:@"0.996"];
    buyBTCSum = [buyBTCSum decimalNumberByMultiplyingBy:bitcoinFee];

    // sellParameters
    NSDecimalNumber *sellBTCSum = [NSDecimalNumber zero];
    for (NSDictionary *sellBalanceTradeParameter in self.sellBalanceTradeParameters) {
        sellBTCSum = [sellBTCSum decimalNumberByAdding:[sellBalanceTradeParameter objectForKey:BitcoinDE_ExecuteTrade_BitcoinAmount]];
    }

    NSDecimalNumber *diff = [buyBTCSum decimalNumberBySubtracting:sellBTCSum];

    NSDecimalNumber *estBTC = [self.availableBitcoinAmountBeforeBannerUpdate decimalNumberByAdding:diff];
    NSDecimalNumber *btcSpectrum = [NSDecimalNumber decimalNumberWithString:@"0.0000001"];
    NSDecimalNumber *estBTClow = [estBTC decimalNumberBySubtracting:btcSpectrum];
    NSDecimalNumber *estBTChigh = [estBTC decimalNumberByAdding:btcSpectrum];

    SOXAccountInfoData *accountInfoData = [serverAnswer objectForKey:ServerAnswerPayloadKey];
    NSDecimalNumber *newAvailBTC = accountInfoData.btcBalance_availableAmount;

    // TODO: Debug
    {
        if (self.debugNewAvailBTC) {
            newAvailBTC = estBTC;
        }
    }

    NSString *note = [NSString stringWithFormat:@"BannerUpdated - bSum: %@ sSell: %@ diff: %@ estL: %@ est: %@ estH: new: %@"
                      , buyBTCSum
                      , sellBTCSum
                      , estBTClow
                      , estBTC
                      , estBTChigh
                      , newAvailBTC
                      ];
    if (self.buyBalanceTradeParameters.count > 0) {
        [self informBuyDelegateWithNote:note];
    }
    else if (self.sellBalanceTradeParameters.count > 0) {
        [self informSellDelegateWithNote:note];
    }

    // weil wir nur ein estimatedBTC haben, es aber zu kleinen Abweichungen kommen kann,
    // wird hier mit einer "Unschärfe" gearbeitet um den neuen availBTCAmount zu prüfen
    if ([estBTClow isLessThan:newAvailBTC]
        && [estBTChigh isGreaterThan:newAvailBTC]) {

        NSString *note = [NSString stringWithFormat:@"BannerUpdated SUCCESSFUL!"];
        if (self.buyBalanceTradeParameters.count > 0) {
            [self informBuyDelegateWithNote:note];
        }
        else if (self.sellBalanceTradeParameters.count > 0) {
            [self informSellDelegateWithNote:note];
        }

        // Banner update erfolgreich
        self.waitingForBannerUpdate = NO;
        if (self.useBannerUpdateMechanicForBalanceTrades) {
            [self createBalanceTrades];
        }
    }
    else {
        NSString *note = [NSString stringWithFormat:@"BannerUpdated UNsuccessful! - reload banner in 2 sec"];
        if (self.buyBalanceTradeParameters.count > 0) {
            [self informBuyDelegateWithNote:note];
        }
        else if (self.sellBalanceTradeParameters.count > 0) {
            [self informSellDelegateWithNote:note];
        }

        // reload banner after a few seconds
        NSTimer *bannerReloadTimer  = [NSTimer scheduledTimerWithTimeInterval:2
                                                                      target:self
                                                                    selector:@selector(updateBanner)
                                                                    userInfo:nil
                                                                     repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:bannerReloadTimer
                                  forMode:NSDefaultRunLoopMode];
        self.debugNewAvailBTC = [NSDecimalNumber zero];
    }
}

@end
