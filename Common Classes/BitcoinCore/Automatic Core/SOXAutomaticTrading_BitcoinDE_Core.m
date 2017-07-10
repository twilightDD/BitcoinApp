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

#import "SOXSocketIO_BitcoinDE_Core.h"

#import "SOXAccountInfoData.h"
#import "SOXShowOrderbook_BitcoinDE_Data.h"

@import AppKit;

#pragma mark - Interface
@interface SOXAutomaticTrading_BitcoinDE_Core () <SOXMarketCoreServerRequestProtocol, SOXSocketIOCoreProtocol>

#pragma mark | Properties
@property (strong, nonatomic) id requestShowAccountInfoNotification;

@property (strong, nonatomic) NSDecimalNumber *debugNewAvailBTC; // TODO: debug

@property (nonatomic) BOOL useBannerUpdateMechanicForBalanceTrades; // to use toggle balance trade mechanic

@end

#pragma mark - Implementation
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
            [core informBuyDelegateWithNote:[NSString stringWithFormat:@"!!! EXECUTE TRADES %@ !!!"
                                             , executeTrades ? @"enabled" : @"disabled"]];
            break;
        }
        case BitcoinDE_SellOrderType: {
            core.executeSellTrades = executeTrades;
            [core informSellDelegateWithNote:[NSString stringWithFormat:@"!!! EXECUTE TRADES %@ !!!"
                                             , executeTrades ? @"enabled" : @"disabled"]];
            break;
        }
        default:
            break;
    }
}

+ (void)executeAutomaticTrades:(BOOL)executeTrades forOrderType:(BitcoinDE_OrderType)orderType {
    SOXAutomaticTrading_BitcoinDE_Core *core = [SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore];

    switch (orderType) {
        case BitcoinDE_BuyOrderType: {
            core.executeAutomaticTradesForBuyTrades = executeTrades;
            [core informBuyDelegateWithNote:[NSString stringWithFormat:@"!!! EXECUTE AUTOMATIC TRADES %@ !!!"
                                             , executeTrades ? @"enabled" : @"disabled"]];
            break;
        }
        case BitcoinDE_SellOrderType: {
            core.executeAutomaticTradesForSellTrades = executeTrades;
            [core informSellDelegateWithNote:[NSString stringWithFormat:@"!!! EXECUTE AUTOMATIC TRADES %@ !!!"
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
            [core informBuyDelegateWithNote:[NSString stringWithFormat:@"!!! EXECUTE BALANCE TRADES %@ !!!"
                                             , executeBalanceTrades ? @"enabled" : @"disabled"]];
            break;
        }
        case BitcoinDE_SellOrderType: {
            core.executeBalanceTradesForSellTrades = executeBalanceTrades;
            [core informSellDelegateWithNote:[NSString stringWithFormat:@"!!! EXECUTE BALANCE TRADES %@ !!!"
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
            NSString *note3;
            if ([SOXAutomaticTrading_BitcoinDE_Core registerForWebSocketUpdates]) {
                note3 = @"Fetching Orderbooks ...";
            }
            else {
                note3 = @"Orderbooks already fetched";
            }
            [tradingCore informBuyDelegateWithNote:note3];
        }
            break;
        case BitcoinDE_SellOrderType: {
            [tradingCore.sellDelegates addObject:controller];
            NSString *note = [NSString stringWithFormat:@"START: Maximal BTC trading amount %@ BTC"
                              , [SOXFormatters stringForBTCNumber:tradingCore.sellMaximalBTCInvestment]];
            [tradingCore informSellDelegateWithNote:note];

            NSString *note2 = [NSString stringWithFormat:@"START: Interest rate %@%%", tradingCore.sellInterestRate];
            [tradingCore informSellDelegateWithNote:note2];
            NSString *note3;
            if ([SOXAutomaticTrading_BitcoinDE_Core registerForWebSocketUpdates]) {
                note3 = @"Fetching Orderbooks ...";
            }
            else {
                note3 = @"Orderbooks already fetched";
            }
            [tradingCore informSellDelegateWithNote:note3];
        }
            break;
        default:
            NSLog(@"ERROR - (void)registerForUpdatesForType:(BitcoinDE_OrderType)orderType");
            break;
    }


}

+ (void)deRegisterController:(id)controller forUpdatesForOrderType:(BitcoinDE_OrderType)orderType {
    if (!controller) {
        return;
    }

    SOXAutomaticTradingCore *tradingCore = [self sharedTradingCore];

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
+ (BOOL)registerForWebSocketUpdates {
    SOXAutomaticTrading_BitcoinDE_Core *core = [SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore];

    if (core.automaticTradingIsRunning) {
        return NO;
    }

    { // get buyOrderBook
        NSDictionary *buyParameters = [SOXShowOrderbook_BitcoinDE_Data parametersForOrderType:BitcoinDE_BuyOrderType
                                                                     onlyExpressPaymentOption:YES];

        NSMutableDictionary *newBuyParameters = [buyParameters mutableCopy];
        [newBuyParameters setObject:@1 forKey:BitcoinDE_ShowMyOrders_OrderRequirements_OnlyKYCFull];

        [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowBuyOrderbookCommandType
                                                withParameter:[newBuyParameters copy]
                                                    respondTo:core];
    }

    { // get sellOrderBook
        NSDictionary *sellParameters = [SOXShowOrderbook_BitcoinDE_Data parametersForOrderType:BitcoinDE_SellOrderType
                                                                      onlyExpressPaymentOption:YES];
        
        NSMutableDictionary *newSellParameters = [sellParameters mutableCopy];
        [newSellParameters setObject:@1 forKey:BitcoinDE_ShowMyOrders_OrderRequirements_OnlyKYCFull];
        [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowSellOrderbookCommandType
                                                withParameter:[newSellParameters copy]
                                                    respondTo:core];
    }

    // register for banner update notifications
    core.requestShowAccountInfoNotification = [[NSNotificationCenter defaultCenter] addObserverForName:BitcoinDE_Notification_RequestShowAccountInfo
                                                                                                object:nil
                                                                                                 queue:[NSOperationQueue mainQueue]
                                                                                            usingBlock:^(NSNotification * _Nonnull note) {
                                                                                                [core bannerWasUpdated:note.object];
                                                                                            }
                                               ];

    core.automaticTradingIsRunning = YES;

    return YES;
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
//    NSSound *mySound = [NSSound soundNamed:@"ka-ching"];
//    [mySound play];
}


- (void)tryToBuy:(SOXShowOrderbookData *)orderToBuy btcAmountToBuy:(NSDecimalNumber *)btcAmountToBuy {
    if (btcAmountToBuy
        && [btcAmountToBuy isGreaterThan:[NSDecimalNumber zero]]) {

        // create buyParameters
        NSDecimalNumber *priceForBTCAmountToBuy = [btcAmountToBuy decimalNumberByMultiplyingBy:orderToBuy.orderInformation_price
                                                                                  withBehavior:[SOXFormatters btcNumberHandler]];
        NSDictionary *buyParameters = [SOXTradeJob_BitcoinDE_Data parameterAutomaticTradingForOrderID:orderToBuy.orderInformation_orderID
                                                                                            orderType:BitcoinDE_BuyOrderType
                                                                                        bitcoinAmount:btcAmountToBuy
                                                                                                price:orderToBuy.orderInformation_price];

        { // DEBUG
            NSString *note = [NSString stringWithFormat:@"BUY btcAmount: %@ for %@"
                              , [SOXFormatters stringForBTCNumber:btcAmountToBuy]
                              , [SOXFormatters currencyStringForNumber:priceForBTCAmountToBuy roundingMode:NSNumberFormatterRoundDown]];
            [self informBuyDelegateWithNote:note];
        }

        if (self.executeBuyTrades) {
            { // DEBUG
                NSString *note = [NSString stringWithFormat:@"executeBuyTrades allowed"];
                [self informBuyDelegateWithNote:note];
            }

            if (self.executeAutomaticTradesForBuyTrades) {
                { // DEBUG
                    NSString *note = [NSString stringWithFormat:@"autoBUY allowed => EXECUTE BUY NOW."];
                    [self informBuyDelegateWithNote:note];
                }

                [self.runningAutomaticBuyTradeParameters addObject:buyParameters];

                [self informBuyDelegateAboutRunningQueues];

                [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ExecuteTrade
                                                        withParameter:buyParameters
                                                            respondTo:self];
            }
            else {
                { // DEBUG
                    NSString *note = [NSString stringWithFormat:@"autoBUY not allowed - so I don't buy"];
                    [self informBuyDelegateWithNote:note];
                }
                // TODO: automatic Trading OFF
            }
        }
        else {
            // TODO: autoTrade is running OFF
            { // DEBUG
                NSString *note = [NSString stringWithFormat:@"executeBuyTrades not allowed"];
                [self informBuyDelegateWithNote:note];
            }
            if (self.executeBalanceTradesForBuyTrades) {
                {
                    { // DEBUG
                        NSString *note = [NSString stringWithFormat:@"autoBUY not allowed, but I fake and try to balance out ;)"];
                        [self informBuyDelegateWithNote:note];
                    }
                    [self.runningBalanceBuyTradeParameters addObject:buyParameters];
                    [self fakeServerAnswerForBuyParameters:buyParameters];
                }
            }
        }
    }
    else {
        { // DEBUG
            NSString *note = [NSString stringWithFormat:@"NO BUY - btcAmountToBuy is not valid: %@"
                              , btcAmountToBuy];
            [self informBuyDelegateWithNote:note];
        }
    }

    [self informBuyDelegateWithNote:@"   ------"];
}

- (void)tryToSell:(SOXShowOrderbookData *)orderToSell btcAmountToSell:(NSDecimalNumber *)btcAmountToSell {
    if (btcAmountToSell
        && [btcAmountToSell isGreaterThan:[NSDecimalNumber zero]]) {

        // create sellParameters
        NSDecimalNumber *priceForBTCAmountToSell = [btcAmountToSell decimalNumberByMultiplyingBy:orderToSell.orderInformation_price
                                                                                    withBehavior:[SOXFormatters currencyNumberHandler]];
        NSDictionary *sellParameters = [SOXTradeJob_BitcoinDE_Data parameterAutomaticTradingForOrderID:orderToSell.orderInformation_orderID
                                                                                             orderType:BitcoinDE_SellOrderType
                                                                                         bitcoinAmount:btcAmountToSell
                                                                                                 price:orderToSell.orderInformation_price];

        { // DEBUG
            NSString *note = [NSString stringWithFormat:@"SELL btcAmount: %@ for %@"
                              , [SOXFormatters stringForBTCNumber:btcAmountToSell]
                              , [SOXFormatters currencyStringForNumber:priceForBTCAmountToSell roundingMode:NSNumberFormatterRoundDown]];
            [self informSellDelegateWithNote:note];
        }

        if (self.executeSellTrades) {
            { // DEBUG
                NSString *note = [NSString stringWithFormat:@"executeSellTrades allowed"];
                [self informSellDelegateWithNote:note];
            }

            if (self.executeAutomaticTradesForSellTrades) {
                { // DEBUG
                    NSString *note = [NSString stringWithFormat:@"autoSELL allowed => EXECUTE SELL NOW."];
                    [self informSellDelegateWithNote:note];
                }

                [self.runningAutomaticSellTradeParameters addObject:sellParameters];

                [self informSellDelegateAboutRunningQueues];

                [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ExecuteTrade
                                                        withParameter:sellParameters
                                                            respondTo:self];
            }
            else {
                { // DEBUG
                    NSString *note = [NSString stringWithFormat:@"autoSELL not allowed - so I don't sell"];
                    [self informSellDelegateWithNote:note];
                }
            }
        }
        else {
            { // DEBUG
                NSString *note = [NSString stringWithFormat:@"executeSellTrades not allowed"];
                [self informSellDelegateWithNote:note];
            }
            if (self.executeBalanceTradesForSellTrades) {
                {
                    { // DEBUG
                        NSString *note = [NSString stringWithFormat:@"autoSELL not allowed, but I fake and try to balance out ;)"];
                        [self informSellDelegateWithNote:note];
                    }
                    [self fakeServerAnswerForSellParameters:sellParameters];
                }
            }
        }
    }
    else {
        { // DEBUG
            NSString *note = [NSString stringWithFormat:@"NO SELL - btcAmountToSell is not valid: %@"
                              , btcAmountToSell];
            [self informSellDelegateWithNote:note];
        }
    }

    [self informSellDelegateWithNote:@"   ------"];
    // ------------------------------------
}

#pragma mark - Balance trade methods
- (void)createBalanceTradesForBoughtTrades {
    // Called only, if no active automatic or balance trades
    NSString *keyPath = [NSString stringWithFormat:@"@sum.%@", BitcoinDE_ExecuteTrade_BitcoinAmount];
    NSDecimalNumber *boughtBTCSum = [self.boughtTradeParametersBacklog valueForKeyPath:keyPath];
    NSDecimalNumber *averagePrice = [self averagePriceOfBacklogParameters:self.boughtTradeParametersBacklog];

    // consider fee
    NSDecimalNumber *bitcoinFee = [NSDecimalNumber decimalNumberWithString:@"0.996"];
    boughtBTCSum = [boughtBTCSum decimalNumberByMultiplyingBy:bitcoinFee
                                                 withBehavior:[SOXFormatters btcNumberHandler]];

    // TODO: ist das hier die richtige Stelle (s.u)
    [self.boughtTradeParametersBacklog removeAllObjects];

    if ([boughtBTCSum isGreaterThan:[NSDecimalNumber zero]] ) {
        NSDictionary *substitutedBuyParameters = [SOXTradeJob_BitcoinDE_Data parameterBalanceTradingForOrderID:@"substitutedBuyOrder"
                                                                                                     orderType:BitcoinDE_BuyOrderType
                                                                                                 bitcoinAmount:boughtBTCSum
                                                                                                         price:averagePrice];
        { // DEBUG
            NSString *note = [NSString stringWithFormat:@"createBalanceTradesForBoughtTrades - substituteBuyParameters:\n%@"
                              , substitutedBuyParameters];
            [self informSellDelegateWithNote:note];
        }

        [self createBalanceTradesForTradeParameters:substitutedBuyParameters];
        // TODO: oder nicht doch lieber erst hier?
    }

    // TODO: oder hier?

}

- (void)createBalanceTradesForSoldTrades {
    // Called only, if no active automatic or balance trades


    NSString *keyPath = [NSString stringWithFormat:@"@sum.%@", BitcoinDE_ExecuteTrade_BitcoinAmount];
    NSDecimalNumber *soldBTCSum = [self.soldTradeParametersBacklog valueForKeyPath:keyPath];
    NSDecimalNumber *averagePrice = [self averagePriceOfBacklogParameters:self.soldTradeParametersBacklog];

    // consider fee -> we have to buy more than we sold
    NSDecimalNumber *bitcoinFee = [NSDecimalNumber decimalNumberWithString:@"0.996"];
    soldBTCSum = [soldBTCSum decimalNumberByDividingBy:bitcoinFee
                                             withBehavior:[SOXFormatters btcNumberHandler]];

    [self.soldTradeParametersBacklog removeAllObjects];

    if ([soldBTCSum isGreaterThan:[NSDecimalNumber zero]] ) {
        NSDictionary *substituteSellParameters = [SOXTradeJob_BitcoinDE_Data parameterBalanceTradingForOrderID:@"substitutedSellOrder"
                                                                                                     orderType:BitcoinDE_SellOrderType
                                                                                                 bitcoinAmount:soldBTCSum
                                                                                                         price:averagePrice];
        { // DEBUG
            NSString *note = [NSString stringWithFormat:@"createBalanceTradesForSoldTrades - substituteSellParameters:\n%@",
                              substituteSellParameters];
            [self informBuyDelegateWithNote:note];
        }

        [self createBalanceTradesForTradeParameters:substituteSellParameters];
    }

}
- (NSDecimalNumber *)averagePriceOfBacklogParameters:(NSMutableArray <NSDictionary *>*)tradeParametersBacklog {
    { // DEBUG

        if (tradeParametersBacklog == self.boughtTradeParametersBacklog) {
            [self informSellDelegateWithNote:@".............."];
            NSString *note = [NSString stringWithFormat:@"createBuyBalanceTrades - calc average values - buyBalanceTradeParametersBacklog.count: %tu"
                              , self.boughtTradeParametersBacklog.count];
            [self informSellDelegateWithNote:note];
        }
        else {
            [self informBuyDelegateWithNote:@".............."];
            NSString *note = [NSString stringWithFormat:@"createSellBalanceTrades - calc average values - buyBalanceTradeParametersBacklog.count: %tu"
                              , self.soldTradeParametersBacklog.count];
            [self informBuyDelegateWithNote:note];
        }
    }

    NSString *keyPath = [NSString stringWithFormat:@"@sum.%@", BitcoinDE_ExecuteTrade_BitcoinAmount];
    NSDecimalNumber *buyBTCSum    = [tradeParametersBacklog valueForKeyPath:keyPath];
    NSDecimalNumber *averagePrice = [NSDecimalNumber zero];

    if (tradeParametersBacklog.count == 1) {
        NSDictionary *backlogParameter = tradeParametersBacklog.firstObject;
        averagePrice = [backlogParameter objectForKey:BitcoinDE_ExecuteTrade_Price];
    }
    else {
        for (NSDictionary *backlogParameter in tradeParametersBacklog) {
            // for all buyBacklogs: add buyBTC and calculate average price
            NSDecimalNumber *bitcoinAmount = [backlogParameter objectForKey:BitcoinDE_ExecuteTrade_BitcoinAmount];
            NSDecimalNumber *price         = [backlogParameter objectForKey:BitcoinDE_ExecuteTrade_Price];
            NSDecimalNumber *volume        = [bitcoinAmount decimalNumberByMultiplyingBy:price
                                              withBehavior:[SOXFormatters currencyNumberHandler]];
            NSDecimalNumber *average       = [volume decimalNumberByDividingBy:buyBTCSum
                                                                  withBehavior:[SOXFormatters currencyNumberHandler]];
            averagePrice = [averagePrice decimalNumberByAdding:average
                                                  withBehavior:[SOXFormatters currencyNumberHandler]];

            { // DEBUG
                NSString *note = [NSString stringWithFormat:@"btc: %@ - price: %@"
                                  , bitcoinAmount
                                  , price];
                if (tradeParametersBacklog == self.boughtTradeParametersBacklog) {
                    [self informSellDelegateWithNote:note];
                }
                else {
                    [self informBuyDelegateWithNote:note];
                }
            }
        }
    }

    { // DEBUG
        NSString *note = [NSString stringWithFormat:@"==> btcSum inlc. fee: %@ - averagePrice: %@"
                          , buyBTCSum
                          , averagePrice];
        if (tradeParametersBacklog == self.boughtTradeParametersBacklog) {
            [self informSellDelegateWithNote:note];
            [self informSellDelegateWithNote:@".............."];
        }
        else {
            [self informBuyDelegateWithNote:note];
            [self informBuyDelegateWithNote:@".............."];
        }
    }

    return averagePrice;
}

- (void)createBalanceTradesForTradeParameters:(NSDictionary *)parameters {
    if (!parameters
        || parameters.allKeys.count == 0) {
        return;
    }

    NSString *orderTypeString = [parameters objectForKey:BitcoinDE_ExecuteTrade_Type];
    BitcoinDE_OrderType automaticTradeHadOrderType = [SOXMarket_BitcoinDE_DefTypes orderTypeForOrderTypeString:orderTypeString];
    if (automaticTradeHadOrderType != BitcoinDE_BuyOrderType
        && automaticTradeHadOrderType != BitcoinDE_SellOrderType) {
        return;
    }

    NSArray *parametersToExecute;

    if (automaticTradeHadOrderType == BitcoinDE_BuyOrderType) {
        parametersToExecute = [self sellBalanceTradeParametersForBuyAmount:[parameters objectForKey:BitcoinDE_ExecuteTrade_BitcoinAmount]
                                                               forBuyPrice:[parameters objectForKey:BitcoinDE_ExecuteTrade_Price]
                                                 createPotentialParameters:NO];
    }
    else if (automaticTradeHadOrderType == BitcoinDE_SellOrderType) {
        parametersToExecute = [self buyBalanceTradeParametersForSellAmount:[parameters objectForKey:BitcoinDE_ExecuteTrade_BitcoinAmount]
                                                              forSellPrice:[parameters objectForKey:BitcoinDE_ExecuteTrade_Price]
                                                 createPotentialParameters:NO];
    }

    // Execute Balance Trades
    [self tryToExecuteBalanceTradesWithParameters:parametersToExecute
                                     forOrderType:automaticTradeHadOrderType];
}

- (void)addBuyBacklogForRemainingBitcoinAmountToBuy:(NSDecimalNumber *)remainingBitcoinAmountToBuy
                                       forSoldPrice:(NSDecimalNumber *)soldPrice {
    NSDictionary *soldParameters = [SOXTradeJob_BitcoinDE_Data parameterBalanceTradingForOrderID:@"remainingToBuy"
                                                                                         orderType:BitcoinDE_SellOrderType
                                                                                     bitcoinAmount:remainingBitcoinAmountToBuy
                                                                                             price:soldPrice];
    [self.soldTradeParametersBacklog addObject:soldParameters];

}

- (void)addSellBacklogForRemainingBitcoinAmountToSell:(NSDecimalNumber *)remainingBitcoinAmountToSell
                                       forBoughtPrice:(NSDecimalNumber *)boughtPrice {
    NSDictionary *boughtParameters = [SOXTradeJob_BitcoinDE_Data parameterBalanceTradingForOrderID:@"remainingToSell"
                                                                                         orderType:BitcoinDE_BuyOrderType
                                                                                     bitcoinAmount:remainingBitcoinAmountToSell
                                                                                             price:boughtPrice];
    [self.boughtTradeParametersBacklog addObject:boughtParameters];
}

- (void)tryToExecuteBalanceTradesWithParameters:(NSArray *)parametersToExecute
                                   forOrderType:(BitcoinDE_OrderType)orderType {
    NSDecimalNumber *sum = [NSDecimalNumber zero];
    for (NSDictionary *parameters in parametersToExecute) {
        { // DEBUG
            if (orderType == BitcoinDE_BuyOrderType) {
                NSString *note = [NSString stringWithFormat:@"BuyBlanceTrade: ID %@ - amount %@"
                                  , [parameters objectForKey:BitcoinDE_ExecuteTrade_OrderID]
                                  , [parameters objectForKey:BitcoinDE_ExecuteTrade_BitcoinAmount]];
                sum = [sum decimalNumberByAdding:[parameters objectForKey:BitcoinDE_ExecuteTrade_BitcoinAmount]];
                [self informSellDelegateWithNote:note];

            }
            else if (orderType == BitcoinDE_SellOrderType) {
                NSString *note = [NSString stringWithFormat:@"SellBalanceTrade: ID %@ - amount %@"
                                  , [parameters objectForKey:BitcoinDE_ExecuteTrade_OrderID]
                                  , [parameters objectForKey:BitcoinDE_ExecuteTrade_BitcoinAmount]];
                sum = [sum decimalNumberByAdding:[parameters objectForKey:BitcoinDE_ExecuteTrade_BitcoinAmount]];
                [self informBuyDelegateWithNote:note];

            }
        }

        // Execute BalanceTrade
        if (orderType == BitcoinDE_BuyOrderType) {
            if (self.executeBuyTrades
                && self.executeBalanceTradesForSellTrades) {
                { // DEBUG
                    NSString *note = [NSString stringWithFormat:@"Try to execute buyBalance for sold - ID: %@ - price: %@ - amount: %@"
                                      , [parameters objectForKey:BitcoinDE_ExecuteTrade_OrderID]
                                      , [parameters objectForKey:BitcoinDE_ExecuteTrade_Price]
                                      , [parameters objectForKey:BitcoinDE_ExecuteTrade_BitcoinAmount]
                                      ];
                    [self informSellDelegateWithNote:note];

                }

                [self.runningBalanceBuyTradeParameters addObject:parameters];
                [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ExecuteTrade
                                                        withParameter:parameters
                                                            respondTo:self];

            }
            else {
                { // DEBUG
                    [self informSellDelegateWithNote:@"We should never read this, but: Execute Balance Trades for sell not allowed (if you can read this: inform Peter"];
                }
            }
        }
        else if (orderType == BitcoinDE_SellOrderType) {
            if (self.executeBuyTrades
                && self.executeBalanceTradesForBuyTrades) {
                { // DEBUG
                    NSString *note = [NSString stringWithFormat:@"Try to execute sellBalance for bought - ID: %@ - price: %@ - amount: %@"
                                      , [parameters objectForKey:BitcoinDE_ExecuteTrade_OrderID]
                                      , [parameters objectForKey:BitcoinDE_ExecuteTrade_Price]
                                      , [parameters objectForKey:BitcoinDE_ExecuteTrade_BitcoinAmount]
                                      ];
                    [self informBuyDelegateWithNote:note];
                }

                [self.runningBalanceSellTradeParameters addObject:parameters];

                [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ExecuteTrade
                                                        withParameter:parameters
                                                            respondTo:self];
            }
            else {
                { // DEBUG
                    [self informBuyDelegateWithNote:@"We should never read this, but: Execute Balance Trades for buy not allowed (if you can read this: inform Peter"];
                }
            }
        }
    }

    { // DEBUG
        NSString *note = [NSString stringWithFormat:@"Balances - sum of amount: %@", sum];
        if (orderType == BitcoinDE_BuyOrderType) {
            [self informSellDelegateWithNote:note];
        }
        else if (orderType == BitcoinDE_SellOrderType) {
            [self informBuyDelegateWithNote:note];
        }
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
        // Update banner after successful trade
        self.availableBitcoinAmountBeforeBannerUpdate = [SOXMarket_BitcoinDE_Core sharedCore].availableBitcoinAmount;
        [self updateBanner];


        NSDictionary *tradeParameters = [answerOfServerRequest objectForKey:ServerAnswerParametersKey]; // parameters of executed trade

        NSString *orderTypeString = [tradeParameters objectForKey:BitcoinDE_ExecuteTrade_Type];  //=> buy oder sell
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
                                       , [tradeParameters objectForKey:BitcoinDE_ExecuteTrade_IsAutomaticTrade] ? @"Auto" : @"Balance"
                                       , [tradeParameters objectForKey:BitcoinDE_ExecuteTrade_Type]
                                       , [tradeParameters objectForKey:BitcoinDE_ExecuteTrade_OrderID]
                                       , [tradeParameters objectForKey:BitcoinDE_ExecuteTrade_BitcoinAmount]
                                       , [tradeParameters objectForKey:BitcoinDE_ExecuteTrade_Price]];
            note = [note stringByAppendingString:noteExtension];
            if (orderType == BitcoinDE_BuyOrderType) {
                [self informBuyDelegateWithNote:note];
            }
            else if (orderType == BitcoinDE_SellOrderType) {
                [self informSellDelegateWithNote:note];
            }
        }


        BOOL wasAutoTrade = [[tradeParameters objectForKey:BitcoinDE_ExecuteTrade_IsAutomaticTrade] isEqualTo:@YES];
        if (wasAutoTrade) {
            if (!errorMessage) {
                if (orderType == BitcoinDE_BuyOrderType) {
                    [self successfulAutomaticBuyTrade:tradeParameters];
                }
                else {
                    [self successfulAutomaticSellTrade:tradeParameters];
                }
            }
            else {
                // TODO: autotrade OFF
                if (orderType == BitcoinDE_BuyOrderType) {
                    [self unSuccessfulAutomaticBuyTrade:tradeParameters];
                }
                else {
                    [self unSuccessfulAutomaticSellTrade:tradeParameters];
                }
            }
        }
        else {
            if (!errorMessage) {
                if (orderType == BitcoinDE_BuyOrderType) {
                    [self successfulBalanceBuyTrade:tradeParameters];
                }
                else {
                    [self successfulBalanceSellTrade:tradeParameters];
                }
            }
            else {
                if (orderType == BitcoinDE_BuyOrderType) {
                    [self unSuccessfulBalanceBuyTrade:tradeParameters];
                }
                else {
                    [self unSuccessfulBalanceSellTrade:tradeParameters];
                }
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

        NSString *keyPath = [NSString stringWithFormat:@"@sum.self.orderInformation_maxAmount"];
        NSDecimalNumber *buyBTCSum    = [self.buyOrderBook valueForKeyPath:keyPath];
        NSDecimalNumber *averagePrice = [NSDecimalNumber zero];
        for (SOXShowOrderbookData *buyBalanceTradeParameter in self.buyOrderBook) {
            // for all buyBacklogs: add buyBTC and calculate average price
            NSDecimalNumber *bitcoinAmount = buyBalanceTradeParameter.orderInformation_maxAmount;
            NSDecimalNumber *price         = buyBalanceTradeParameter.orderInformation_price;
            NSDecimalNumber *average = [bitcoinAmount decimalNumberByMultiplyingBy:price
                                                                      withBehavior:[SOXFormatters currencyNumberHandler]];
            average = [average decimalNumberByDividingBy:buyBTCSum
                                            withBehavior:[SOXFormatters currencyNumberHandler]];
            averagePrice = [averagePrice decimalNumberByAdding:average
                                                  withBehavior:[SOXFormatters currencyNumberHandler]];
        }
        NSLog(@"buySum: %@ averagePrice: %@", buyBTCSum, averagePrice);
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
- (void)addedOrder:(SOXShowOrderbookData *)addOrderData {
    if (!addOrderData.tradingPartnerInformation_isKYCFull) {
        NSLog(@"### NO KYC: orderID: %@, type: %@, minA: %@, maxA: %@"
              , addOrderData.orderInformation_orderID
              , addOrderData.orderInformation_type
              , addOrderData.orderInformation_minAmount
              , addOrderData.orderInformation_maxAmount);
        return;
    }

    if ([self checkForExpressOrder:addOrderData]) {
        [self addOrderBookData:addOrderData];
    }
    else {
        [self addSEPAOrderBookData:addOrderData];
    }
}

- (void)removedOrderWithOrderID:(NSDictionary *)payloadDictionary {
    NSLog(@"--------------------");
    NSLog(@"payload:\n%@", payloadDictionary);
    NSLog(@"--------------------");
    NSString *orderID = [payloadDictionary objectForKey:BitcoinDE_WebSocket_RemoveOrder_OrderID];
    NSString *note = nil;
    NSString *noteExtension = nil;
    if ([payloadDictionary objectForKey:BitcoinDE_WebSocket_RemoveOrder_Amount]) {
        NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString:[payloadDictionary objectForKey:BitcoinDE_WebSocket_RemoveOrder_Amount]];
        NSDecimalNumber *price = [NSDecimalNumber decimalNumberWithString:[payloadDictionary objectForKey:BitcoinDE_WebSocket_RemoveOrder_Price]];
        noteExtension = [NSString stringWithFormat:@" (traded: %@ - price: %@)"
                         , [SOXFormatters stringForBTCNumber:amount]
                         , [SOXFormatters currencyStringForNumber:price
                                                     roundingMode:NSNumberFormatterRoundHalfUp]];
        NSLog(@"%@", noteExtension);
    }
    // buyOrderBook
    SOXShowOrderbookData *orderToRemove = [self orderToRemoveWithOrderID:orderID fromOrderBook:self.buyOrderBook];
    if (orderToRemove) {
        NSUInteger idx = [self.buyOrderBook indexOfObject:orderToRemove];
        [self.buyOrderBook removeObject:orderToRemove];
        note = [NSString stringWithFormat:@"- removed order - orderID %@ - idx: %tu - bOB.count: %tu"
                , orderID
                , idx
                , self.buyOrderBook.count];
        if (noteExtension) {
            note = [note stringByAppendingString:noteExtension];
        }
        [self informBuyDelegateWithNote:note];

        if (idx == 0) {
            [self updateBuyStatus];
        }

        return;
    }

    // sellOrderBook
    orderToRemove = [self orderToRemoveWithOrderID:orderID fromOrderBook:self.sellOrderBook];
    if (orderToRemove) {
        NSUInteger idx = [self.sellOrderBook indexOfObject:orderToRemove];
        [self.sellOrderBook removeObject:orderToRemove];
        note = [NSString stringWithFormat:@"- removed order - orderID %@ - idx: %tu - sOB.count: %tu"
                , orderID
                , idx
                , self.sellOrderBook.count];
        if (noteExtension) {
            note = [note stringByAppendingString:noteExtension];
        }
        [self informSellDelegateWithNote:note];

        if (idx == 0) {
            [self updateSellStatus];
        }

        return;
    }

    // buySEPAOrderBook
    orderToRemove = [self orderToRemoveWithOrderID:orderID fromOrderBook:self.buySEPAOrderBook.allObjects];
    if (orderToRemove) {
        [self.buySEPAOrderBook removeObject:orderToRemove];
        note = [NSString stringWithFormat:@"~ removed SEPA order - orderID %@ - buySEPAOB.count: %tu"
                , orderID
                , self.buySEPAOrderBook.count];
        if (noteExtension) {
            note = [note stringByAppendingString:noteExtension];
        }
        [self informBuyDelegateWithNote:note];
        return;
    }

    // sellSEPAOrderBook
    orderToRemove = [self orderToRemoveWithOrderID:orderID fromOrderBook:self.sellSEPAOrderBook.allObjects];
    if (orderToRemove) {
        [self.sellSEPAOrderBook removeObject:orderToRemove];
        note = [NSString stringWithFormat:@"~ removed SEPA order - orderID %@ - sellSEPAOB.count: %tu"
                , orderID
                , self.sellSEPAOrderBook.count];
        if (noteExtension) {
            note = [note stringByAppendingString:noteExtension];
        }
        [self informSellDelegateWithNote:note];
        return;
    }
}

- (void)updateOrderWithSocketOrderObjectID:(NSString *)orderObjectID withValues:(NSDictionary *)changesDictionary {
    // update buyOrders
    NSArray *updatesBuyOrders = [self updateOrderWithSocketOrderObjectID:orderObjectID
                                                             inOrderBook:self.buyOrderBook
                                                              withValues:changesDictionary];
    for (SOXShowOrderbookData *updatedOrder in updatesBuyOrders) {
        [self addedOrder:updatedOrder];
        [self.buySEPAOrderBook removeObject:updatedOrder];
    }

    // update sellOrders
    NSArray *updatesSellOrders = [self updateOrderWithSocketOrderObjectID:orderObjectID
                                                              inOrderBook:self.sellOrderBook
                                                               withValues:changesDictionary];

    for (SOXShowOrderbookData *updatedOrder in updatesSellOrders) {
        [self addedOrder:updatedOrder];
        [self.sellSEPAOrderBook removeObject:updatedOrder];
    }

    //  update buy SEPA orders
    updatesBuyOrders = [self updateOrderWithSocketOrderObjectID:orderObjectID
                                                    inOrderBook:[self.buySEPAOrderBook.allObjects mutableCopy]
                                                     withValues:changesDictionary];
    for (SOXShowOrderbookData *updatedOrder in updatesBuyOrders) {
        [self addedOrder:updatedOrder];
        [self.buySEPAOrderBook removeObject:updatedOrder];
    }

    //  update buy SEPA orders
    updatesSellOrders = [self updateOrderWithSocketOrderObjectID:orderObjectID
                                                     inOrderBook:[self.sellSEPAOrderBook.allObjects mutableCopy]
                                                      withValues:changesDictionary];

    for (SOXShowOrderbookData *updatedOrder in updatesSellOrders) {
        [self addedOrder:updatedOrder];
        [self.sellSEPAOrderBook removeObject:updatedOrder];
    }
}

#pragma mark | Socket helper methods
- (BOOL)checkForExpressOrder:(SOXShowOrderbookData *)addOrderData {
    if ([addOrderData.orderRequirements_paymentOption isEqual:@(BitcoinDE_PaymentOptionExpressOnly)]
        || [addOrderData.orderRequirements_paymentOption isEqual:@(BitcoinDE_PaymentOptionExpressAndSepa)]) {
        return YES;
    }

    return NO;
}

- (SOXShowOrderbookData *)orderToRemoveWithOrderID:(NSString *)orderID fromOrderBook:(NSArray <SOXShowOrderbookData*> *)orderBook {
    __block SOXShowOrderbookData *orderToRemove = nil;
    // check for orderbookData with correct orderID
    [orderBook enumerateObjectsUsingBlock:^(SOXShowOrderbookData * _Nonnull orderbookData, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([orderbookData.orderInformation_orderID isEqualToString:orderID]) {
            orderToRemove = orderbookData;
            *stop = YES;
        }
    }];
    return orderToRemove;

}

- (NSArray *)updateOrderWithSocketOrderObjectID:(NSString *)orderObjectID
                                    inOrderBook:(NSMutableArray *)orderBook
                                     withValues:(NSDictionary *)changesDictionary {
    NSMutableArray *updatesOrders = [NSMutableArray array];
    for (SOXShowOrderbook_BitcoinDE_Data *orderbookData in orderBook) {
        if ([orderbookData.orderInformation_socketOrderObjectID isEqualToString:orderObjectID]) {
            NSNumber *oldPaymentOption = orderbookData.orderRequirements_paymentOption;
            // ist data object mit orderObjectID vorhanden? Ja: updaten!
            [orderbookData updateOrderbookDataWith:changesDictionary];
            [updatesOrders addObject:orderbookData];

            NSString *note = [NSString stringWithFormat:@"* update paymentOption - ID: %@ - oldPO: %@ - newPO: %@"
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

        SOXShowOrderbookData *firstBuyOrderBookData = self.buyOrderBook.firstObject;
        { // DEBUG
            NSString *note = [NSString stringWithFormat:@"+ added buy (bOB.count: %tu)- ID: %@ - pO: %@ - type: offer - idx %tu - p: %@ - minA: %@ - maxA: %@ - p@idx0: %@ - iR %@"
                              , self.buyOrderBook.count
                              , addOrderDataOrderID
                              , addOrderData.orderRequirements_paymentOption
                              , [self.buyOrderBook indexOfObject:addOrderData]
                              , addOrderDataPrice
                              , addOrderData.orderInformation_minAmount
                              , addOrderData.orderInformation_maxAmount
                              , [SOXFormatters currencyStringForNumber:firstBuyOrderBookData.orderInformation_price
                                                          roundingMode:NSNumberFormatterRoundDown]
                              , [self effectiveBuyInterestRateForData:addOrderData
                                                      toReferenceData:firstBuyOrderBookData ]];
            [self informBuyDelegateWithNote:note];
        }

        // Update Status text, if needed
        if ([[self.buyOrderBook objectAtIndex:0] isEqual:addOrderData]) {
            [self updateBuyStatus];
        }

        if (self.runningAutomaticBuyTradeParameters.count > 0
            || self.runningAutomaticSellTradeParameters.count > 0
            || self.runningBalanceSellTradeParameters.count > 0
            || self.runningBalanceBuyTradeParameters.count > 0) {

            [self informBuyDelegateAboutRunningQueues];

            return;
        }


        // Look for interesting new orders
        BOOL tryToAutoBuy = NO;
        if ([[self.buyOrderBook objectAtIndex:0] isEqual:addOrderData]) {
            tryToAutoBuy = [self checkForBuyableOrder];
        }

        if (!tryToAutoBuy
//            && !self.waitingForBannerUpdate
            && self.boughtTradeParametersBacklog.count > 0) {
                [self informBuyDelegateWithNote:@"~~~~~~~~~~~~~~~~"];
                [self informBuyDelegateWithNote:@"createBalanceTradesForBoughtTrades: try to create new sellBalanceTrades to even buyAutoTradeBacklog"];
                [self createBalanceTradesForBoughtTrades];
                [self informBuyDelegateWithNote:@"~~~~~~~~~~~~~~~~"];
        }
    }
    // Sell
    else if ([orderInformationType isEqualToString:BitcoinDE_WebSocket_SellOrderType]) {
        [self.sellOrderBook addObject:addOrderData];
        self.sellOrderBook = [SOXAutomaticTrading_BitcoinDE_Core sortedOrderBook:self.sellOrderBook
                                                                    forOrderType:BitcoinDE_SellOrderType];

        SOXShowOrderbookData *firstSellOrderBookData = self.sellOrderBook.firstObject;
        NSString *note = [NSString stringWithFormat:@"+ added sell (sOB.count: %tu)- ID: %@ - pO: %@ - type: offer - idx %tu - p: %@ - minA: %@ - maxA: %@ - p@idx0: %@ - iR %@"
                          , self.sellOrderBook.count
                          , addOrderDataOrderID
                          , addOrderData.orderRequirements_paymentOption
                          , [self.sellOrderBook indexOfObject:addOrderData]
                          , addOrderDataPrice
                          , addOrderData.orderInformation_minAmount
                          , addOrderData.orderInformation_maxAmount
                          , [SOXFormatters currencyStringForNumber:firstSellOrderBookData.orderInformation_price
                                                      roundingMode:NSNumberFormatterRoundDown]
                          , [self effectiveSellInterestRateForData:addOrderData
                                                   toReferenceData:firstSellOrderBookData]];
        [self informSellDelegateWithNote:note];

        // Update Status text, if needed
        if ([[self.sellOrderBook objectAtIndex:0] isEqual:addOrderData]) {
            [self updateSellStatus];
        }

        if (self.runningAutomaticBuyTradeParameters.count > 0
            || self.runningAutomaticSellTradeParameters.count > 0
            || self.runningBalanceSellTradeParameters.count > 0
            || self.runningBalanceBuyTradeParameters.count > 0) {

            [self informSellDelegateAboutRunningQueues];

            return;
        }

        // Look for interesting new orders

        BOOL tryToAutoSell = NO;
        if ([[self.sellOrderBook objectAtIndex:0] isEqual:addOrderData]) {
            tryToAutoSell = [self checkForSellableOrder];
        }

        if (!tryToAutoSell
//            && !self.waitingForBannerUpdate
            && self.soldTradeParametersBacklog.count > 0) {
            // create balancePayments
            [self informBuyDelegateWithNote:@"~~~~~~~~~~~~~~~~"];
            [self informBuyDelegateWithNote:@"createBalanceTradesForSoldTrades: try to create new buyBalanceTrades to even sellAutoTrade backlog"];
            [self createBalanceTradesForSoldTrades];
            [self informBuyDelegateWithNote:@"~~~~~~~~~~~~~~~~"];
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

        NSString *note = [NSString stringWithFormat:@"~ new SEPA (bSepa.count: %tu): type offer - orderID: %@ - price: %@ € - payO: %@ - IR %@"
                          , self.buySEPAOrderBook.count
                          , addSEPAOrderData.orderInformation_orderID
                          , addSEPAOrderData.orderInformation_price
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
        NSString *note = [NSString stringWithFormat:@"~ new SEPA (sSepa.count: %tu): type order - orderID: %@ - price: %@ € - payO: %@ - IR %@"
                          , self.sellSEPAOrderBook.count
                          , addSEPAOrderData.orderInformation_orderID
                          , addSEPAOrderData.orderInformation_price
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

    [self fakeServerAnswerForSellParameters:autoParameters];
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
    [self.runningAutomaticSellTradeParameters addObject:parameters];
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
    if (!self.waitingForBannerUpdate) {
        return;
    }

    // buyParameters
    NSDecimalNumber *buyBTCBacklog = [self sumOfBitcoinsOfParameters:self.soldTradeParametersBacklog];
    NSDecimalNumber *bitcoinFee = [NSDecimalNumber decimalNumberWithString:@"0.996"];
    buyBTCBacklog = [buyBTCBacklog decimalNumberByDividingBy:bitcoinFee
                                                withBehavior:[SOXFormatters btcNumberHandler]];

    // sellParameters
    NSDecimalNumber *sellBTCBacklog = [self sumOfBitcoinsOfParameters:self.boughtTradeParametersBacklog];


    NSDecimalNumber *effectiveBacklog = [buyBTCBacklog decimalNumberBySubtracting:sellBTCBacklog
                                                                     withBehavior:[SOXFormatters btcNumberHandler]];

    NSDecimalNumber *estBTC = [self.availableBitcoinAmountBeforeBannerUpdate decimalNumberByAdding:effectiveBacklog
                                                                                      withBehavior:[SOXFormatters btcNumberHandler]];
    NSDecimalNumber *btcSpectrum = [NSDecimalNumber decimalNumberWithString:@"0.0000001"];
    NSDecimalNumber *estBTClow = [estBTC decimalNumberBySubtracting:btcSpectrum
                                                       withBehavior:[SOXFormatters btcNumberHandler]];
    NSDecimalNumber *estBTChigh = [estBTC decimalNumberByAdding:btcSpectrum
                                                   withBehavior:[SOXFormatters btcNumberHandler]];

    SOXAccountInfoData *accountInfoData = [serverAnswer objectForKey:ServerAnswerPayloadKey];
    NSDecimalNumber *newAvailBTC = accountInfoData.btcBalance_availableAmount;

    // TODO: Debug
    {
        if (self.debugNewAvailBTC) {
            newAvailBTC = estBTC;
        }
    }

    NSString *note = [NSString stringWithFormat:@"BannerUpdated - bBack: %@ sBack: %@ diff: %@ estL: %@ est: %@ estH: new: %@"
                      , buyBTCBacklog
                      , sellBTCBacklog
                      , estBTClow
                      , estBTC
                      , estBTChigh
                      , newAvailBTC
                      ];
    if (self.boughtTradeParametersBacklog.count > 0) {
        [self informSellDelegateWithNote:note];
    }
    if (self.soldTradeParametersBacklog.count > 0) {
        [self informBuyDelegateWithNote:note];
    }

    // weil wir nur ein estimatedBTC haben, es aber zu kleinen Abweichungen kommen kann,
    // wird hier mit einer "Unschärfe" gearbeitet um den neuen availBTCAmount zu prüfen
    if ([estBTClow isLessThan:newAvailBTC]
        && [estBTChigh isGreaterThan:newAvailBTC]) {

        self.waitingForBannerUpdate = NO;

        NSString *note = [NSString stringWithFormat:@"BannerUpdated SUCCESSFUL!"];
        if (self.boughtTradeParametersBacklog.count > 0) {
            [self informSellDelegateWithNote:note];
            if (self.useBannerUpdateMechanicForBalanceTrades) {
                [self createBalanceTradesForBoughtTrades];
            }
        }
        if (self.soldTradeParametersBacklog.count > 0) {
            [self informBuyDelegateWithNote:note];
            if (self.useBannerUpdateMechanicForBalanceTrades) {
                [self createBalanceTradesForSoldTrades];
            }
        }
    }
    else {
        NSString *note = [NSString stringWithFormat:@"BannerUpdated UNsuccessful! - reload banner in 2 sec"];
        if (self.boughtTradeParametersBacklog.count > 0) {
            [self informSellDelegateWithNote:note];
        }
        else if (self.soldTradeParametersBacklog.count > 0) {
            [self informBuyDelegateWithNote:note];
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
