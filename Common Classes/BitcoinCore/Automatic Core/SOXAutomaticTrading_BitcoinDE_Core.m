//
//  SOXAutomaticTrading_BitcoinDE_Core.m
//  BitcoinApp
//
//  Created by Peter Hauke on 07.06.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXAutomaticTrading_BitcoinDE_Core.h"
#import "SOXAutomaticTradingCore_Private.h"

#import "DDLog.h"

#import "SOXKeys_BitcoinDE.h"
#import "SOXMarketHelper.h"

#import "SOXMarket_BitcoinDE_Core.h"
#import "SOXSocketIO_BitcoinDE_Core.h"

#import "SOXErrorMessage_BitcoinDE.h"

#import "SOXAccountInfo_BitcoinDE_Data.h"
#import "SOXShowOrderbook_BitcoinDE_Data.h"

@import AppKit;

#pragma mark - Interface
@interface SOXAutomaticTrading_BitcoinDE_Core () <SOXMarketCoreServerRequestProtocol, SOXSocketIOCoreProtocol>

#pragma mark | Properties


@property (strong, nonatomic) id requestShowAccountInfoNotification;

@property (strong, nonatomic) NSDecimalNumber *debugNewAvailBTC; // TODO: debug

// spectrum for BTC amount after a banner update (to avoid rounding errors)
@property (strong, nonatomic) NSDecimalNumber *availableBTCAfterBannerUpdateLow;
@property (strong, nonatomic) NSDecimalNumber *availableBTCAfterBannerUpdateHigh;
@property (strong, nonatomic) NSDecimalNumber *reservedBTCAfterBannerUpdateLow;
@property (strong, nonatomic) NSDecimalNumber *reservedBTCAfterBannerUpdateHigh;
@property (nonatomic) BOOL expectAvailableBTCChange;
@property (nonatomic) BOOL expectReservedBTCChange;

@property (strong, nonatomic) NSTimer *creditTimer;
@property (strong, nonatomic) NSTimer *reloadOrderBooksTimer;

@end

#pragma mark - Implementation
@implementation SOXAutomaticTrading_BitcoinDE_Core
#pragma mark - Init&Co.
- (instancetype)initForCurrencyTyp:(BitcoinDE_CurrencyType)currencyType {
    self = [super init];
    if (self) {
        self.currencyType = currencyType;
        [self setupProperties];
    }

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.requestShowAccountInfoNotification];
}

#pragma mark - Public methods
- (void)registerControllerForUpdates:(id <SOXAutomaticTradingCoreProtocol>)controller {
    if (!controller) {
        return;
    }

    [self.buyDelegates addObject:controller];

    { // Note max fidor
        NSString *note = [NSString stringWithFormat:@"START: Maximal Fidor trading amount %@"
                          , [SOXFormatters currencyStringForNumber:self.buyMaximalFidorAmountInvestment
                                                      roundingMode:NSNumberFormatterRoundDown]];
        [self informBuyDelegateWithNote:note];
    }

    { // Note interest rate
        NSString *note2 = [NSString stringWithFormat:@"START: Interest rate %@%%", self.buyInterestRate];
        [self informBuyDelegateWithNote:note2];
    }

    { //Note for avail fidor
        NSString *note3 = [NSString stringWithFormat:@"Automatic for %@ availAllocation: %@"
                           , self.currencyTypeString
                           , [SOXMarket_BitcoinDE_Core allocationMaxEurVolumeForCurrency:self.currencyType]];
        [self informBuyDelegateWithNote:note3];
    }

    { // Fetch orderbooks
        NSString *note10;
        if ([self fetchOrderBooks]) {
            note10 = @"Fetching Orderbooks ...";
        }
        else {
            note10 = @"Orderbooks already fetched";
        }
        [self informBuyDelegateWithNote:note10];
    }

    [self startOrderBooksUpdateTimer];
}

- (void)deRegisterControllerForUpdates:(id)controller {
    //    if (!controller) {
    //        return;
    //    }
    //
    //    SOXAutomaticTradingCore *tradingCore = [self sharedTradingCore];
    //
    //    switch (orderType) {
    //        case BitcoinDE_BuyOrderType:
    //            [tradingCore.buyDelegates removeObject:controller];
    //            break;
    //        case BitcoinDE_SellOrderType:
    //            [tradingCore.sellDelegates removeObject:controller];
    //            break;
    //        default:
    //            DDLogInfo(@"ERROR - (void)registerForUpdatesForType:(BitcoinDE_OrderType)orderType");
    //            break;
    //    }
    //
    //    [SOXAutomaticTrading_BitcoinDE_Core checkRegisterForSocketUpdatesStatus];
}

- (void)executeTrades:(BOOL)executeTrades {
    self.executeBuyTrades = executeTrades;

    [self informBuyDelegateWithNote:[NSString stringWithFormat:@"!!! EXECUTE TRADES %@ !!!"
                                     , executeTrades ? @"enabled" : @"disabled"]];
}

- (void)executeAutomaticTrades:(BOOL)executeTrades {
    self.executeAutomaticTradesForBuyTrades = executeTrades;

    [self informBuyDelegateWithNote:[NSString stringWithFormat:@"!!! EXECUTE AUTOMATIC TRADES %@ !!!"
                                     , executeTrades ? @"enabled" : @"disabled"]];
}

- (void)executeBalanceTrades:(BOOL)executeBalanceTrades {
    self.executeBalanceTradesForBuyTrades = executeBalanceTrades;

    [self informBuyDelegateWithNote:[NSString stringWithFormat:@"!!! EXECUTE BALANCE TRADES %@ !!!"
                                     , executeBalanceTrades ? @"enabled" : @"disabled"]];
}

#pragma mark - Private methods
- (void)setupProperties {
    [super setupProperties];
    self.currencyTypeString = [SOXMarket_BitcoinDE_DefTypes tradingPairStringForCurrencyType:self.currencyType];
}

- (void)startOrderBooksUpdateTimer {
    if (!self.reloadOrderBooksTimer) {
        self.reloadOrderBooksTimer = [NSTimer timerWithTimeInterval:800
                                                             target:self
                                                           selector:@selector(orderBooksUpdateTimerFired)
                                                           userInfo:nil
                                                            repeats:YES];

        self.reloadOrderBooksTimer.tolerance = 1;
        [[NSRunLoop mainRunLoop] addTimer:self.reloadOrderBooksTimer
                                  forMode:NSDefaultRunLoopMode];
    }
}
- (void)orderBooksUpdateTimerFired {
    { // DEBUG
        NSString *note = @"reloadOrderBooksTimer says: Time's up";
        [self informBuyDelegateWithNote:note];
    }

    // don't update orderBooks while autoTrading
    if (self.runningAutomaticBuyTradeParameters.count > 0
        || self.runningBalanceSellTradeParameters.count > 0) {
        [self informBuyDelegateAboutRunningQueues];
        return;
    }

    // Update all orderBooks
    [self flushAllOrderBooks];

    [SOXSocketIO_BitcoinDE_Core unRegisterForOrderUpdatesForUpdateType:BitcoinDE_UpdateType_BuyOrderChanges
                                                       forCurrencyType:self.currencyType
                                                              delegate:self];
    [SOXSocketIO_BitcoinDE_Core unRegisterForOrderUpdatesForUpdateType:BitcoinDE_UpdateType_SellOrderChanges
                                                       forCurrencyType:self.currencyType
                                                              delegate:self];
    [SOXSocketIO_BitcoinDE_Core unRegisterForOrderUpdatesForUpdateType:BitcoinDE_UpdateType_RemoveOrderChanges
                                                       forCurrencyType:self.currencyType
                                                              delegate:self];

    [self fetchOrderBooks];

    self.socketIODidDisconnectAppeared = NO;
}

#pragma mark - WebSocket methods
- (BOOL)fetchOrderBooks {
    if (self.automaticTradingIsRunning) {
        return NO;
    }

    // get buyOrderBook
    [self fetchBuyOrderBook]; // after receiving buyOrdeBook, we fetch for sellOrderBook automatically

    return YES;
}

- (void)fetchBuyOrderBook {
    NSLog(@">>>>> fetchBuyOrderBook");
    NSDictionary *buyParameters = [SOXShowOrderbook_BitcoinDE_Data parametersForOrderType:BitcoinDE_BuyOrderType
                                                                             currencyType:self.currencyType
                                                                 onlyExpressPaymentOption:YES];

    NSMutableDictionary *newBuyParameters = [buyParameters mutableCopy];
    [newBuyParameters setObject:@1 forKey:BitcoinDE_ShowMyOrders_OrderRequirements_OnlyKYCFull];

    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowBuyOrderbookCommandType
                                            withParameter:[newBuyParameters copy]
                                                respondTo:self];
}

- (void)fetchSellOrderBook {
    NSLog(@">>>>> fetchSellOrderBook");
    NSDictionary *sellParameters = [SOXShowOrderbook_BitcoinDE_Data parametersForOrderType:BitcoinDE_SellOrderType
                                                                              currencyType:self.currencyType
                                                                  onlyExpressPaymentOption:YES];

    NSMutableDictionary *newSellParameters = [sellParameters mutableCopy];
    [newSellParameters setObject:@1 forKey:BitcoinDE_ShowMyOrders_OrderRequirements_OnlyKYCFull];

    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowSellOrderbookCommandType
                                            withParameter:[newSellParameters copy]
                                                respondTo:self];
}

- (void)fetchAccountInfos {
    NSLog(@">>>>> fetchAccountInfos");

    // register for banner update notifications
    if (self.requestShowAccountInfoNotification == nil) {
        self.requestShowAccountInfoNotification = [[NSNotificationCenter defaultCenter] addObserverForName:BitcoinDE_Notification_RequestShowAccountInfo
                                                                                                    object:nil
                                                                                                     queue:[NSOperationQueue mainQueue]
                                                                                                usingBlock:^(NSNotification * _Nonnull note) {
                                                                                                    [self bannerWasUpdated:note.object];
                                                                                                }
                                                   ];
    }

    [[SOXMarket_BitcoinDE_Core sharedCore] startAccountInfoUpdate];

    self.automaticTradingIsRunning = YES;
}

#pragma mark - Private class methods
+ (NSMutableArray *)sortedOrderBook:(NSMutableArray <SOXShowOrderbookData *> *)orderBookDatas
                       forOrderType:(BitcoinDE_OrderType)orderType {
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

- (void)keepReservedBTCAmount {
    NSDecimalNumber *reservedBTCAmount = [SOXMarket_BitcoinDE_Core reservedAmountForCurrencyType:self.currencyType];

    NSDecimalNumber *btcSpectrum = [NSDecimalNumber decimalNumberWithString:@"0.000001"];
    self.reservedBTCAfterBannerUpdateLow = [reservedBTCAmount decimalNumberBySubtracting:btcSpectrum
                                                                            withBehavior:[SOXFormatters btcNumberHandler]];
    self.reservedBTCAfterBannerUpdateHigh = [reservedBTCAmount decimalNumberByAdding:btcSpectrum
                                                                        withBehavior:[SOXFormatters btcNumberHandler]];
}

- (void)tryToBuy:(SOXShowOrderbookData *)orderToBuy btcAmountToBuy:(NSDecimalNumber *)btcAmountToBuy {
    if (btcAmountToBuy
        && [btcAmountToBuy isGreaterThan:[NSDecimalNumber zero]]) {

        // create buyParameters
        NSDecimalNumber *priceForBTCAmountToBuy = [btcAmountToBuy decimalNumberByMultiplyingBy:orderToBuy.orderInformation_price
                                                                                  withBehavior:[SOXFormatters currencyNumberHandler]];
        NSDictionary *buyParameters = [SOXTradeJob_BitcoinDE_Data parameterAutomaticTradingForOrderID:orderToBuy.orderInformation_orderID
                                                                                            orderType:BitcoinDE_BuyOrderType
                                                                                        bitcoinAmount:btcAmountToBuy
                                                                                                price:orderToBuy.orderInformation_price
                                                                                      forCurrencyType:self.currencyType];

        if (self.executeBuyTrades) {
            if (self.executeAutomaticTradesForBuyTrades) {
                [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ExecuteTrade
                                                        withParameter:buyParameters
                                                            respondTo:self];


                [self.runningAutomaticBuyTradeParameters addObject:buyParameters];

                SOXShowOrderbookData *dataOfInterest  = self.buyOrderBook.firstObject;
                [self.buyOrderBook removeObject:orderToBuy];

                [self updateBuyStatus];
                [self.buyOrderBookInExecution addObject:orderToBuy];
                [self keepReservedBTCAmount];

                [self informBuyDelegateAboutRunningQueues];


                { // DEBUG
                    NSString *note = [NSString stringWithFormat:@"BUY btcAmount: %@ for %@"
                                      , [SOXFormatters stringForBTCNumber:btcAmountToBuy]
                                      , [SOXFormatters currencyStringForNumber:priceForBTCAmountToBuy roundingMode:NSNumberFormatterRoundDown]];
                    [self informBuyDelegateWithNote:note];
                }

                { // DEBUG
                    NSString *note = [NSString stringWithFormat:@"autoBUY allowed => EXECUTE BUY NOW."];
                    [self informBuyDelegateWithNote:note];
                }

                // print sellOrderBook
                SOXShowOrderbookData *referenceData   = self.sellOrderBook.firstObject;
                NSDecimalNumber *effectivInterestRate = [self effectiveBuyInterestRateForData:dataOfInterest
                                                                              toReferenceData:referenceData];

                NSString *statisticForNote = [NSString stringWithFormat:@"- type %@ - ID %@ - minAmo %@ - maxAmo %@ - buyP0 %@ - sellP0 %@ - iR %@"
                                              , dataOfInterest.orderInformation_type
                                              , dataOfInterest.orderInformation_orderID
                                              , [SOXFormatters stringForBTCNumber:dataOfInterest.orderInformation_minAmount]
                                              , [SOXFormatters stringForBTCNumber:dataOfInterest.orderInformation_maxAmount]
                                              , [SOXFormatters currencyStringForNumber:dataOfInterest.orderInformation_price roundingMode:NSNumberFormatterRoundDown]
                                              , [SOXFormatters currencyStringForNumber:referenceData.orderInformation_price roundingMode:NSNumberFormatterRoundDown]
                                              , effectivInterestRate];

                __block NSString *note = [NSString stringWithFormat:@"TRY TO BUY %@\nSELLORDERBOOK", statisticForNote];
                // log first items of sellOrderBook
                [self.sellOrderBook enumerateObjectsUsingBlock:^(SOXShowOrderbookData * _Nonnull sellOrderbookData,
                                                                 NSUInteger idx,
                                                                 BOOL * _Nonnull stop) {
                    note = [note stringByAppendingString:
                            [NSString stringWithFormat:@"\nidx: %tu - oID: %@ - p: %@ - minA: %@ - maxA: %@ - payO: %@"
                             , idx
                             , sellOrderbookData.orderInformation_orderID
                             , [SOXFormatters currencyStringForNumber:sellOrderbookData.orderInformation_price roundingMode:NSNumberFormatterRoundHalfUp]
                             , [SOXFormatters stringForBTCNumber:sellOrderbookData.orderInformation_minAmount]
                             , [SOXFormatters stringForBTCNumber:sellOrderbookData.orderInformation_maxAmount]
                             , sellOrderbookData.orderRequirements_paymentOption]
                            ];

                    if (idx > 10) {
                        *stop = YES;
                    }
                }];

                [self informBuyDelegateWithNote:note];
            }
            else {
                { // DEBUG
                    NSString *note = [NSString stringWithFormat:@"autoBUY not allowed - so I don't buy"];
                    [self informBuyDelegateWithNote:note];
                }
            }
        }
        else {
            { // DEBUG
                NSString *note = [NSString stringWithFormat:@"executeBuyTrades not allowed"];
                [self informBuyDelegateWithNote:note];
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

#pragma mark - Balance trade methods
- (void)createBalanceTradesForBoughtTrades {
    // Called only, if no active automatic or balance trades
    NSString *keyPath = [NSString stringWithFormat:@"@sum.%@", BitcoinDE_ExecuteTrade_BitcoinAmount];
    NSDecimalNumber *boughtBTCSum = [self.successfulAutomaticBuyTradeParameters valueForKeyPath:keyPath];
    NSDecimalNumber *averageAutomaticBoughtPrice = [self averageAutomaticTradePriceOfBacklogParameters:self.successfulAutomaticBuyTradeParameters];
    
    [self.successfulAutomaticBuyTradeParameters removeAllObjects];

    if ([boughtBTCSum isGreaterThan:[NSDecimalNumber zero]] ) {
        NSDictionary *substitutedBuyParameters = [SOXTradeJob_BitcoinDE_Data parameterBalanceTradingForOrderID:@"substitutedBuyOrder"
                                                                                                     orderType:BitcoinDE_BuyOrderType
                                                                                                 bitcoinAmount:boughtBTCSum
                                                                                                         price:averageAutomaticBoughtPrice
                                                                                           automaticTradePrice:averageAutomaticBoughtPrice
                                                                                               forCurrencyType:self.currencyType];
        { // DEBUG
            NSString *note = [NSString stringWithFormat:@"createBalanceTradesForBoughtTrades - substituteBuyParameters:\n%@"
                              , substitutedBuyParameters];
            [self informBuyDelegateWithNote:note];
        }

        [self createBalanceTradesForTradeParameters:substitutedBuyParameters];
    }
}

// TODO: brauchen wir eigentlich nicht, da wir nur ein Event zulassen
- (NSDecimalNumber *)averageAutomaticTradePriceOfBacklogParameters:(NSMutableArray <NSDictionary *>*)tradeParametersBacklog {
    { // DEBUG

        if (tradeParametersBacklog == self.successfulAutomaticBuyTradeParameters) {
            [self informBuyDelegateWithNote:@".............."];
            NSString *note = [NSString stringWithFormat:@"createBuyBalanceTrades - calc average values - boughtTradeParametersBacklog.count: %tu"
                              , self.successfulAutomaticBuyTradeParameters.count];
            [self informBuyDelegateWithNote:note];
        }
    }

    NSString *keyPath = [NSString stringWithFormat:@"@sum.%@", BitcoinDE_ExecuteTrade_BitcoinAmount];
    NSDecimalNumber *buyBTCSum    = [tradeParametersBacklog valueForKeyPath:keyPath];
    NSDecimalNumber *averagePrice = [NSDecimalNumber zero];

    if (tradeParametersBacklog.count == 1) {
        NSDictionary *backlogParameter = tradeParametersBacklog.firstObject;
        averagePrice = [backlogParameter objectForKey:BitcoinDE_ExecuteTrade_AutomaticTradePrice];
    }
    else {
        for (NSDictionary *backlogParameter in tradeParametersBacklog) {
            // for all buyBacklogs: add buyBTC and calculate average price
            NSDecimalNumber *bitcoinAmount = [backlogParameter objectForKey:BitcoinDE_ExecuteTrade_BitcoinAmount];
            NSDecimalNumber *price         = [backlogParameter objectForKey:BitcoinDE_ExecuteTrade_AutomaticTradePrice];
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
                [self informBuyDelegateWithNote:note];
            }
        }
    }

    { // DEBUG
        NSString *note = [NSString stringWithFormat:@"==> btcSum inlc. fee: %@ - averagePrice: %@"
                          , buyBTCSum
                          , averagePrice];

        [self informBuyDelegateWithNote:note];
        [self informBuyDelegateWithNote:@".............."];
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
                                                               forBuyPrice:[parameters objectForKey:BitcoinDE_ExecuteTrade_AutomaticTradePrice]
                                                 createPotentialParameters:NO];
    }

    // Execute Balance Trades
    BitcoinDE_OrderType executeBalanceType = BitcoinDE_UnknownOrderType;
    if (automaticTradeHadOrderType == BitcoinDE_BuyOrderType) {
        executeBalanceType = BitcoinDE_SellOrderType;
    }

    [self tryToExecuteBalanceTradesWithParameters:parametersToExecute
                                     forOrderType:executeBalanceType];
}

- (void)tryToExecuteBalanceTradesWithParameters:(NSArray *)parametersToExecute
                                   forOrderType:(BitcoinDE_OrderType)orderType {

    for (NSDictionary *parameters in parametersToExecute) {
        // Execute BalanceTrade
        if (orderType == BitcoinDE_SellOrderType) {
            if (self.executeBalanceTradesForBuyTrades) {
                [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ExecuteTrade
                                                        withParameter:parameters
                                                            respondTo:self];
                [self.runningBalanceSellTradeParameters addObject:parameters];
            }
        }
    }

    NSDecimalNumber *sum = [NSDecimalNumber zero];

    for (NSDictionary *parameters in parametersToExecute) {
        if (orderType == BitcoinDE_SellOrderType) {
            if (self.executeBalanceTradesForBuyTrades) {
                { // DEBUG
                    NSString *note = [NSString stringWithFormat:@"Try to execute sellBalance for bought - ID: %@ - price: %@ - amount: %@"
                                      , [parameters objectForKey:BitcoinDE_ExecuteTrade_OrderID]
                                      , [parameters objectForKey:BitcoinDE_ExecuteTrade_Price]
                                      , [parameters objectForKey:BitcoinDE_ExecuteTrade_BitcoinAmount]
                                      ];
                    [self informBuyDelegateWithNote:note];
                }

                // move sellOrderBookData
                {
                    SOXShowOrderbookData *sellOrderBookData = [self orderWithOrderID:[parameters objectForKey:BitcoinDE_ExecuteTrade_OrderID]
                                                                      fromOrderBook:self.sellOrderBook];
                    if (!sellOrderBookData) {
                        { // DEBUG
                            NSString *note = [NSString stringWithFormat:@"Could not found sellBalanceOrder in sellOrderBook - ID: %@ - price: %@ - amount: %@"
                                              , [parameters objectForKey:BitcoinDE_ExecuteTrade_OrderID]
                                              , [parameters objectForKey:BitcoinDE_ExecuteTrade_Price]
                                              , [parameters objectForKey:BitcoinDE_ExecuteTrade_BitcoinAmount]
                                              ];
                            [self informBuyDelegateWithNote:note];
                        }
                        break;
                    }
                    [self.sellOrderBookInExecution addObject:sellOrderBookData];
                    [self.sellOrderBook removeObject:sellOrderBookData];
                }
            }
            else {
                { // DEBUG
                    [self informBuyDelegateWithNote:@"We should never read this (if you can read this: inform Peter"];
                }
            }
        }
    }

    { // DEBUG
        NSString *note = [NSString stringWithFormat:@"Balances - sum of amount: %@", sum];
        [self informBuyDelegateWithNote:note];
    }
}

#pragma mark - SOXMarketCoreServerRequestProtocol
- (void)answerOfServerRequest:(NSDictionary * _Nonnull)answerOfServerRequest {
    NSArray *errorArray = [answerOfServerRequest objectForKey:ServerAnswerErrorKey];
    if (errorArray) {
        DDLogInfo(@"SOXAutomaticTrading_BitcoinDE_Core - answerOfServerRequest with error:\n%@", errorArray);

    }

    // Answer for execute Trade
    if ([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ExecuteTrade)]) {
        NSDictionary *tradeParameters = [answerOfServerRequest objectForKey:ServerAnswerParametersKey]; // parameters of executed trade

        { // Inform user about success status
            NSString *note;
            if (errorArray) {
                note = @"Trade UNSUCCESSFUL: ";
            }
            else {
                note = @"Trade SUCCESSFUL: ";
            }
            NSString *noteExtension = [NSString stringWithFormat:@"type: %@-%@ - ID: %@ - btc: %@ - price: %@ - autoPrice: %@"
                                       , [(NSNumber*)[tradeParameters objectForKey:BitcoinDE_ExecuteTrade_IsAutomaticTrade] boolValue] ? @"Auto" : @"Balance"
                                       , [tradeParameters objectForKey:BitcoinDE_ExecuteTrade_Type]
                                       , [tradeParameters objectForKey:BitcoinDE_ExecuteTrade_OrderID]
                                       , [tradeParameters objectForKey:BitcoinDE_ExecuteTrade_BitcoinAmount]
                                       , [tradeParameters objectForKey:BitcoinDE_ExecuteTrade_Price]
                                       , [tradeParameters objectForKey:BitcoinDE_ExecuteTrade_AutomaticTradePrice]];
            note = [note stringByAppendingString:noteExtension];
            [self informBuyDelegateWithNote:note];
        }

        BOOL wasAutoTrade = [[tradeParameters objectForKey:BitcoinDE_ExecuteTrade_IsAutomaticTrade] isEqualTo:@YES];
        if (wasAutoTrade) {
            if (!errorArray) {
                [self successfulAutomaticBuyTrade:tradeParameters];
            }
            else {
                [self unSuccessfulAutomaticBuyTrade:tradeParameters];
            }
        }
        else { // Balance trades
            if (!errorArray) {
                [self successfulBalanceSellTrade:tradeParameters];
            }
            else {
                NSNumber *errorCode = [errorArray.firstObject objectForKey:@"code"];
                [self unSuccessfulBalanceSellTrade:tradeParameters errorCode:errorCode];
            }
        }
        return;
    }


    // Orderbook answer handling
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

            DDLogInfo(@"answer buy: %@ %@ - payOp: %@"
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
        DDLogInfo(@"buySum: %@ averagePrice: %@", buyBTCSum, averagePrice);
        [SOXSocketIO_BitcoinDE_Core registerForOrderUpdatesForUpdateType:BitcoinDE_UpdateType_BuyOrderChanges
                                                         forCurrencyType:self.currencyType
                                                                delegate:self];
        [SOXSocketIO_BitcoinDE_Core registerForOrderUpdatesForUpdateType:BitcoinDE_UpdateType_RemoveOrderChanges
                                                         forCurrencyType:self.currencyType
                                                                delegate:self];

        SOXShowOrderbook_BitcoinDE_Data *dataOfInterest = self.buyOrderBook.firstObject;
        NSString *note = [NSString stringWithFormat:@"BuyOrderBooks arrived - firstObject: type %@ oID %@ minAmount %@ price %@",
                          dataOfInterest.orderInformation_type
                          , dataOfInterest.orderInformation_orderID
                          , dataOfInterest.orderInformation_minAmount
                          , dataOfInterest.orderInformation_price];
        [self informBuyDelegateWithNote:note];

        [self updateBuyStatus];

        // after buyOrderBook get sellOrderBook
        [self fetchSellOrderBook];
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
                [self informBuyDelegateWithNote:note];
                [self.sellSEPAOrderBook addObject:orderBookData];
            }
            DDLogInfo(@"answer sell: %@ %@ - payOp: %@"
                  , orderBookData.orderInformation_orderID
                  , orderBookData.tradingPartnerInformation_isKYCFull ? @"YES" : @"NO"
                  , orderBookData.orderRequirements_paymentOption);
        }

        self.sellOrderBook = [SOXAutomaticTrading_BitcoinDE_Core sortedOrderBook:sellOrderBookDatas
                                                                    forOrderType:BitcoinDE_SellOrderType];
        [SOXSocketIO_BitcoinDE_Core registerForOrderUpdatesForUpdateType:BitcoinDE_UpdateType_SellOrderChanges
                                                         forCurrencyType:self.currencyType
                                                                delegate:self];
        [SOXSocketIO_BitcoinDE_Core registerForOrderUpdatesForUpdateType:BitcoinDE_UpdateType_RemoveOrderChanges
                                                         forCurrencyType:self.currencyType
                                                                delegate:self];

        SOXShowOrderbook_BitcoinDE_Data *dataOfInterest = self.sellOrderBook.firstObject;
        NSString *note = [NSString stringWithFormat:@"SellOrderBooks arrived - firstObject: type %@ oID %@ minAmount %@ price %@",
                          dataOfInterest.orderInformation_type
                          , dataOfInterest.orderInformation_orderID
                          , dataOfInterest.orderInformation_minAmount
                          , dataOfInterest.orderInformation_price];
        [self informBuyDelegateWithNote:note];

        // after sellOrderBook get accountInfos
        [self fetchAccountInfos];
    }
}

#pragma mark - SOXSocketIOCoreProtocol
- (void)addedOrder:(SOXShowOrderbookData *)addOrderData {
    // Check for KYC
    {
        if (!addOrderData.tradingPartnerInformation_isKYCFull) {
            DDLogInfo(@"### NO KYC: orderID: %@, type: %@, minA: %@, maxA: %@"
                  , addOrderData.orderInformation_orderID
                  , addOrderData.orderInformation_type
                  , addOrderData.orderInformation_minAmount
                  , addOrderData.orderInformation_maxAmount);
            return;
        }
    }

    // check for TradingPair
    {
        if (![addOrderData.orderInformation_tradingPair isEqualToString:self.currencyTypeString]) {
            DDLogInfo(@"### tradingPair is %@ - we don't support it right now - ID: %@ - maxA: %@ - p: %@"
                  , addOrderData.orderInformation_tradingPair
                  , addOrderData.orderInformation_orderID
                  , addOrderData.orderInformation_maxAmount
                  , addOrderData.orderInformation_price);
            //NSBeep();
            return;
        }

    }

    if ([self checkForExpressOrder:addOrderData]) {
        // Check for doublettes first
        {
            if ([addOrderData.orderInformation_type isEqualToString:BitcoinDE_WebSocket_BuyOrderType]) {
                // Check for doublettes
                if ([SOXMarketHelper existOrderBookData:addOrderData inOrderBook:self.buyOrderBook]) {
                    { // DEBUG
                        NSString *note = [NSString stringWithFormat:@"### don't add buy, because it exists already in buyOrderBook - ID: %@ - maxA: %@ p: %@"
                                          , addOrderData.orderInformation_orderID
                                          , addOrderData.orderInformation_maxAmount
                                          , addOrderData.orderInformation_price];
                        [self informBuyDelegateWithNote:note];
                    }
                    return;
                }
            }
            else if ([addOrderData.orderInformation_type isEqualToString:BitcoinDE_WebSocket_SellOrderType]) {
                // Check for doublettes
                if ([SOXMarketHelper existOrderBookData:addOrderData inOrderBook:self.sellOrderBook]) {
                    { // DEBUG
                        NSString *note = [NSString stringWithFormat:@"### don't add sell, because it exists already in sellOrderBook - ID: %@ - maxA: %@ p: %@"
                                          , addOrderData.orderInformation_orderID
                                          , addOrderData.orderInformation_maxAmount
                                          , addOrderData.orderInformation_price];
                        [self informBuyDelegateWithNote:note];
                    }
                    return;
                }
            }
        }

        [self addOrderBookData:addOrderData];
    }
    else {
        { // Error handling
            if ([addOrderData.orderInformation_type isEqualToString:BitcoinDE_WebSocket_BuyOrderType]) {

                if ([SOXMarketHelper existOrderBookData:addOrderData inOrderBook:self.buySEPAOrderBook.allObjects]) {
                    { // DEBUG
                        NSString *note = [NSString stringWithFormat:@"### don't add sepaBuy, because it exists already in buySEPAOrderBook - ID: %@ - maxA: %@ p: %@"
                                          , addOrderData.orderInformation_orderID
                                          , addOrderData.orderInformation_maxAmount
                                          , addOrderData.orderInformation_price];
                        [self informBuyDelegateWithNote:note];
                    }
                    return;
                }
            }
            else if ([addOrderData.orderInformation_type isEqualToString:BitcoinDE_WebSocket_SellOrderType]) {
                if ([SOXMarketHelper existOrderBookData:addOrderData inOrderBook:self.sellSEPAOrderBook.allObjects]) {
                    { // DEBUG
                        NSString *note = [NSString stringWithFormat:@"### don't add sepaSell, because it exists already in sellSEPAOrderBook - ID: %@ - maxA: %@ p: %@"
                                          , addOrderData.orderInformation_orderID
                                          , addOrderData.orderInformation_maxAmount
                                          , addOrderData.orderInformation_price];
                        [self informBuyDelegateWithNote:note];
                    }
                    return;
                }
            }
        }

        [self addSEPAOrderBookData:addOrderData];
    }
}

- (void)removedOrderWithOrderID:(NSDictionary *)payloadDictionary {
    DDLogInfo(@"--------------------");
    DDLogInfo(@"payload:\n%@", payloadDictionary);
    DDLogInfo(@"--------------------");
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
        DDLogInfo(@"%@", noteExtension);
    }
    // buyOrderBook
    SOXShowOrderbookData *orderToRemove = [self orderWithOrderID:orderID fromOrderBook:self.buyOrderBook];
    if (orderToRemove) {
        NSUInteger idx = [self.buyOrderBook indexOfObject:orderToRemove];
        [self.buyOrderBook removeObject:orderToRemove];
        note = [NSString stringWithFormat:@"- removed buy order - orderID %@ - idx: %tu - bOB.count: %tu"
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
    orderToRemove = [self orderWithOrderID:orderID fromOrderBook:self.sellOrderBook];
    if (orderToRemove) {
        NSUInteger idx = [self.sellOrderBook indexOfObject:orderToRemove];
        [self.sellOrderBook removeObject:orderToRemove];
        note = [NSString stringWithFormat:@"- removed sell order - orderID %@ - idx: %tu - sOB.count: %tu"
                , orderID
                , idx
                , self.sellOrderBook.count];
        if (noteExtension) {
            note = [note stringByAppendingString:noteExtension];
        }
        [self informBuyDelegateWithNote:note];

        return;
    }

    // buySEPAOrderBook
    orderToRemove = [self orderWithOrderID:orderID fromOrderBook:self.buySEPAOrderBook.allObjects];
    if (orderToRemove) {
        [self.buySEPAOrderBook removeObject:orderToRemove];
        note = [NSString stringWithFormat:@"~ removed buy SEPA order - orderID %@ - buySEPAOB.count: %tu"
                , orderID
                , self.buySEPAOrderBook.count];
        if (noteExtension) {
            note = [note stringByAppendingString:noteExtension];
        }
        [self informBuyDelegateWithNote:note];
        return;
    }

    // sellSEPAOrderBook
    orderToRemove = [self orderWithOrderID:orderID fromOrderBook:self.sellSEPAOrderBook.allObjects];
    if (orderToRemove) {
        [self.sellSEPAOrderBook removeObject:orderToRemove];
        note = [NSString stringWithFormat:@"~ removed sell SEPA order - orderID %@ - sellSEPAOB.count: %tu"
                , orderID
                , self.sellSEPAOrderBook.count];
        if (noteExtension) {
            note = [note stringByAppendingString:noteExtension];
        }
        [self informBuyDelegateWithNote:note];
        return;
    }

    // buyOrderBookInExecution
    orderToRemove = [self orderWithOrderID:orderID fromOrderBook:self.buyOrderBookInExecution];
    if (orderToRemove) {
        [self.buyOrderBookInExecution removeObject:orderToRemove];
        note = [NSString stringWithFormat:@"~ removed EXECUTED order (bought) - orderID %@ - buyOrderBookInExecution.count: %tu"
                , orderID
                , self.buyOrderBookInExecution.count];
        if (noteExtension) {
            note = [note stringByAppendingString:noteExtension];
        }
        [self informBuyDelegateWithNote:note];
        return;
    }

    // sellOrderBookInExecution
    orderToRemove = [self orderWithOrderID:orderID fromOrderBook:self.sellOrderBookInExecution];
    if (orderToRemove) {
        [self.sellOrderBookInExecution removeObject:orderToRemove];
        note = [NSString stringWithFormat:@"~ removed EXECUTED order (sold) - orderID %@ - sellOrderBookInExecution.count: %tu"
                , orderID
                , self.sellOrderBookInExecution.count];
        if (noteExtension) {
            note = [note stringByAppendingString:noteExtension];
        }
        [self informBuyDelegateWithNote:note];
        return;
    }
}

- (void)updateOrderWithSocketOrderObjectID:(NSString *)orderObjectID withValues:(NSDictionary *)changesDictionary {
    // update buyOrders
    NSArray *updatesBuyOrders = [self updateOrderWithSocketOrderObjectID:orderObjectID
                                                             inOrderBook:self.buyOrderBook
                                                              withValues:changesDictionary];
    for (SOXShowOrderbookData *updatedOrder in updatesBuyOrders) {
        [self.buyOrderBook removeObject:updatedOrder];
        [self addedOrder:updatedOrder];
    }

    // update sellOrders
    NSArray *updatesSellOrders = [self updateOrderWithSocketOrderObjectID:orderObjectID
                                                              inOrderBook:self.sellOrderBook
                                                               withValues:changesDictionary];
    for (SOXShowOrderbookData *updatedOrder in updatesSellOrders) {
        [self.sellOrderBook removeObject:updatedOrder];
        [self addedOrder:updatedOrder];
    }

    //  update buy SEPA orders
    NSArray *updatesBuySEPAOrders = [self updateOrderWithSocketOrderObjectID:orderObjectID
                                                                 inOrderBook:[self.buySEPAOrderBook.allObjects mutableCopy]
                                                                  withValues:changesDictionary];
    for (SOXShowOrderbookData *updatedOrder in updatesBuySEPAOrders) {
        [self.buySEPAOrderBook removeObject:updatedOrder];
        [self addedOrder:updatedOrder];
    }

    //  update sell SEPA orders
    NSArray *updatesSellSEPAOrders = [self updateOrderWithSocketOrderObjectID:orderObjectID
                                                                  inOrderBook:[self.sellSEPAOrderBook.allObjects mutableCopy]
                                                                   withValues:changesDictionary];
    for (SOXShowOrderbookData *updatedOrder in updatesSellSEPAOrders) {
        [self.sellSEPAOrderBook removeObject:updatedOrder];
        [self addedOrder:updatedOrder];
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

- (SOXShowOrderbookData *)orderWithOrderID:(NSString *)orderID fromOrderBook:(NSArray <SOXShowOrderbookData*> *)orderBook {
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
            NSNumber *oldPaymentOption = [orderbookData.orderRequirements_paymentOption copy];

            // ist data object mit orderObjectID vorhanden? Ja: updaten!
            [orderbookData updateOrderbookDataWith:changesDictionary];
            [updatesOrders addObject:orderbookData];

            { // DEBUG
                NSString *note = [NSString stringWithFormat:@"* update paymentOption - orderID: %@ - oldPO: %@ - newPO: %@"
                                  , orderbookData.orderInformation_orderID
                                  , oldPaymentOption
                                  , orderbookData.orderRequirements_paymentOption];
                NSString *orderInformationType = orderbookData.orderInformation_type;
                if ([orderInformationType isEqualToString:BitcoinDE_WebSocket_BuyOrderType]) {
                    [self informBuyDelegateWithNote:note];
                }
                else if ([orderInformationType isEqualToString:BitcoinDE_WebSocket_SellOrderType]) {
                    [self informBuyDelegateWithNote:note];
                }
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

        SOXShowOrderbookData *firstSellOrderBookData = self.sellOrderBook.firstObject;
        { // DEBUG
            NSString *note = [NSString stringWithFormat:@"+ added buy (bOB.count: %tu)- ID: %@ - pO: %@ - type: offer - idx %tu - p: %@ - minA: %@ - maxA: %@ - sell@idx0: %@ - iR %@"
                              , self.buyOrderBook.count
                              , addOrderDataOrderID
                              , addOrderData.orderRequirements_paymentOption
                              , [self.buyOrderBook indexOfObject:addOrderData]
                              , addOrderDataPrice
                              , addOrderData.orderInformation_minAmount
                              , addOrderData.orderInformation_maxAmount
                              , [SOXFormatters currencyStringForNumber:firstSellOrderBookData.orderInformation_price
                                                          roundingMode:NSNumberFormatterRoundDown]
                              , [self effectiveBuyInterestRateForData:addOrderData
                                                      toReferenceData:firstSellOrderBookData]];
            [self informBuyDelegateWithNote:note];
        }

        // Update Status text, if needed
        if ([[self.buyOrderBook objectAtIndex:0] isEqual:addOrderData]) {
            [self updateBuyStatus];
        }

        if (self.runningAutomaticBuyTradeParameters.count > 0
            || self.runningBalanceSellTradeParameters.count > 0) {
            [self informBuyDelegateAboutRunningQueues];

            return;
        }

        if (self.waitingForBannerUpdate) {
            [self informBuyDelegateWithNote:@"waitingForBannerUpdate: so we don't look for buyable orders anymore"];
            return;
        }

        // Look for interesting new orders
        BOOL tryToAutoBuy = NO;
        if ([[self.buyOrderBook objectAtIndex:0] isEqual:addOrderData]) {
            tryToAutoBuy = [self checkForBuyableOrder];
            [self updateBuyStatus];
        }

        if (!tryToAutoBuy
            && self.successfulAutomaticBuyTradeParameters.count > 0) {
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

        SOXShowOrderbookData *firstBuyOrderBookData = self.buyOrderBook.firstObject;
        { // DEBUG
            NSString *note = [NSString stringWithFormat:@"+ added sell (sOB.count: %tu)- ID: %@ - pO: %@ - type: offer - idx %tu - p: %@ - minA: %@ - maxA: %@ - buy@idx0: %@ - iR %@"
                              , self.sellOrderBook.count
                              , addOrderDataOrderID
                              , addOrderData.orderRequirements_paymentOption
                              , [self.sellOrderBook indexOfObject:addOrderData]
                              , addOrderDataPrice
                              , addOrderData.orderInformation_minAmount
                              , addOrderData.orderInformation_maxAmount
                              , [SOXFormatters currencyStringForNumber:firstBuyOrderBookData.orderInformation_price
                                                          roundingMode:NSNumberFormatterRoundDown]
                              , [self effectiveSellInterestRateForData:addOrderData
                                                       toReferenceData:firstBuyOrderBookData]];
            [self informBuyDelegateWithNote:note];
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
        [self informBuyDelegateWithNote:note];
    }
}

#pragma mark - Banner updates
- (void)updateBannerAfterSuccessfulAutomaticBuyTrade {
    // Changes in BTC: calculate banner low and high spectrum values
    {
        self.expectAvailableBTCChange = YES;

        NSDecimalNumber *availCoinAmount = [SOXMarket_BitcoinDE_Core availableAmountForCurrencyType:self.currencyType];
        NSDecimalNumber *justBoughtCoinAmount = [self sumOfBitcoinsOfParameters:self.successfulAutomaticBuyTradeParameters];
        NSDecimalNumber *estBTC = [availCoinAmount decimalNumberByAdding:justBoughtCoinAmount
                                                                 withBehavior:[SOXFormatters btcNumberHandler]];


        NSDecimalNumber *btcSpectrum = [NSDecimalNumber decimalNumberWithString:@"0.000001"];
        self.availableBTCAfterBannerUpdateLow = [estBTC decimalNumberBySubtracting:btcSpectrum
                                                             withBehavior:[SOXFormatters btcNumberHandler]];
        self.availableBTCAfterBannerUpdateHigh = [estBTC decimalNumberByAdding:btcSpectrum
                                                         withBehavior:[SOXFormatters btcNumberHandler]];
        { // DEBUG
            NSString *note = [NSString stringWithFormat:@"Start Banner Update after Auto - availBTC: %@  sellBack: %@  estL: %@ est: %@ estH: %@"
                              , availCoinAmount
                              , justBoughtCoinAmount
                              , self.availableBTCAfterBannerUpdateLow
                              , estBTC
                              , self.availableBTCAfterBannerUpdateHigh
                              ];

            [self informBuyDelegateWithNote:note];
        }
    }

    // update banner
    [self updateBanner];
}

- (void)updateBannerAfterSuccessfulBalanceTrades {
    self.expectReservedBTCChange = YES;

    { // DEBUG
        NSString *note = [NSString stringWithFormat:@"Start Banner Update after Balances trades"];
        [self informBuyDelegateWithNote:note];
    }

    // update banner
    [self updateBanner];
}

- (void)updateBanner {
    { // DEBUG
        NSString *note = [NSString stringWithFormat:@"Execute Bannerupdate now."];
        [self informBuyDelegateWithNote:note];
    }

    self.waitingForBannerUpdate = YES;

    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowAccountInfoCommandType
                                            withParameter:nil
                                                respondTo:nil];
    if (self.creditTimer) {
        { // DEBUG
            NSString *note = [NSString stringWithFormat:@"- (void)updateBanner: creditTimer invalidated"];
            [self informBuyDelegateWithNote:note];
        }
        
        [self.creditTimer invalidate];
        self.creditTimer = nil;
    }
    else {
        // DEBUG
        NSString *note = [NSString stringWithFormat:@"- (void)updateBanner: creditTimer not existing"];
        [self informBuyDelegateWithNote:note];
    }
}

- (void)bannerWasUpdated:(NSDictionary *)serverAnswer {
    if (!self.waitingForBannerUpdate) {
        return;
    }

    SOXAccountInfo_BitcoinDE_Data *accountInfoData = [serverAnswer objectForKey:ServerAnswerPayloadKey];
    NSDecimalNumber *newAvailBTC = [accountInfoData availableAmountForCurrencyType:self.currencyType];
    NSDecimalNumber *newReservedBTC = [accountInfoData reservedAmountForCurrencyType:self.currencyType];
    NSDecimalNumber *newAvailableFidorAmount = [accountInfoData allocationMaxEurVolumeForCurrencyType:self.currencyType];

    {// DEBUG
        NSString *note = [NSString stringWithFormat:@"BannerUpdate arrived with values: availBTC %@ - reservedBTC %@ - availFidor %@"
                          , [SOXFormatters stringForBTCNumber:newAvailBTC]
                          , [SOXFormatters stringForBTCNumber:newReservedBTC]
                          , [SOXFormatters currencyStringForNumber:newAvailableFidorAmount roundingMode:NSNumberFormatterRoundHalfUp]];
        [self informBuyDelegateWithNote:note];
    }

    // weil wir nur ein estimatedBTC haben, es aber zu kleinen Abweichungen kommen kann,
    // wird hier mit einer "Unschärfe" gearbeitet um den neuen availBTCAmount zu prüfen
    if (self.expectAvailableBTCChange
        && [self.availableBTCAfterBannerUpdateLow isLessThan:newAvailBTC]
        && [self.availableBTCAfterBannerUpdateHigh isGreaterThan:newAvailBTC]) {

        { // DEBUG
            NSString *note = [NSString stringWithFormat:@"Updated after auto trade: availBTC - new availBTC is %@"
                              , newAvailBTC];
            [self informBuyDelegateWithNote:note];
        }

        self.expectAvailableBTCChange = NO;

        self.availableBTCAfterBannerUpdateLow = nil;
        self.availableBTCAfterBannerUpdateHigh = nil;

        [self.creditTimer invalidate];
        self.creditTimer = nil;
    }

    // weil wir nur ein estimatedBTC haben, es aber zu kleinen Abweichungen kommen kann,
    // wird hier mit einer "Unschärfe" gearbeitet um den neuen availBTCAmount zu prüfen
    if (self.expectReservedBTCChange
        && [self.reservedBTCAfterBannerUpdateLow isLessThan:newReservedBTC]
        && [self.reservedBTCAfterBannerUpdateHigh isGreaterThan:newReservedBTC]) {

        { // DEBUG
            NSString *note = [NSString stringWithFormat:@"Updated after balance trades: reservedBTC - new reservedBTC is %@"
                              , newReservedBTC];
            [self informBuyDelegateWithNote:note];
        }

        self.expectReservedBTCChange = NO;

        self.reservedBTCAfterBannerUpdateLow = nil;
        self.reservedBTCAfterBannerUpdateHigh = nil;

        [self.creditTimer invalidate];
        self.creditTimer = nil;
    }


    if (self.expectAvailableBTCChange
        || self.expectReservedBTCChange) {

        { // DEBUG
            NSString *note = [NSString stringWithFormat:@"BannerUpdated UNsuccessful! - update banner again in 2 sec"];
            [self informBuyDelegateWithNote:note];
        }


        if (!self.creditTimer) {
            { // DEBUG
                NSString *note = [NSString stringWithFormat:@"New creditTimer created"];
                [self informBuyDelegateWithNote:note];
            }

            self.creditTimer = [NSTimer scheduledTimerWithTimeInterval:1.9
                                                                target:self
                                                              selector:@selector(updateBanner)
                                                              userInfo:nil
                                                               repeats:NO];
            self.creditTimer.tolerance = 0.05;
            [[NSRunLoop mainRunLoop] addTimer:self.creditTimer
                                      forMode:NSDefaultRunLoopMode];
        }
        else {
            { // DEBUG
                NSString *note = [NSString stringWithFormat:@"existing creditTimer - so no new one created."];
                [self informBuyDelegateWithNote:note];
            }
        }
    }
    else {
        // Check credit timer
        if (self.creditTimer) {
            { // DEBUG
                NSString *note = [NSString stringWithFormat:@"should never happen: existing creditTimer after successful banner update - so kill it"];
                [self informBuyDelegateWithNote:note];
            }

            [self.creditTimer invalidate];
            self.creditTimer = nil;
        } else {
            { // DEBUG
                NSString *note = [NSString stringWithFormat:@"should be standard case: no existing creditTimer after successful banner update - do nothing"];
                [self informBuyDelegateWithNote:note];
            }
        }

        if (self.successfulAutomaticBuyTradeParameters.count > 0) {
            { // DEBUG
                NSString *note = [NSString stringWithFormat:@"Banner update after %tu autoBuy(s) trade complete"
                                  ,self.successfulAutomaticBuyTradeParameters.count];
                [self informBuyDelegateWithNote:note];
            }
            [self createBalanceTradesForBoughtTrades];
        }

        if (self.successfulBalanceSellTradeParameters.count > 0) {
            { // DEBUG
                NSString *note = [NSString stringWithFormat:@"Banner update after %tu sellBalance trade(s) complete"
                                  , self.successfulBalanceSellTradeParameters.count];
                [self informBuyDelegateWithNote:note];
            }
            [self.successfulBalanceSellTradeParameters removeAllObjects];

            // A poor mans kill switch for "autotrade only once"
            { // DEBUG
                NSString *note = [NSString stringWithFormat:@"Banner update after balances is done so: self.waitingForBannerUpdate = NO;"];
                [self informBuyDelegateWithNote:note];
            }
            self.waitingForBannerUpdate = NO;
        }
    }
}

@end
