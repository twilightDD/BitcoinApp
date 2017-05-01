//
//  SOXAutomaticTrading_BitcoinDE_Core.m
//  BitcoinApp
//
//  Created by Peter Hauke on 11.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXAutomaticTrading_BitcoinDE_Core.h"

#import "SOXMarket_BitcoinDE_Core.h"
#import "SOXSocketIO_BitcoinDE_Core.h"

#import "SOXShowOrderbook_BitcoinDE_Data.h"
#import "SOXTradeJob_BitcoinDE_Data.h"

#pragma mark - Interface
@interface SOXAutomaticTrading_BitcoinDE_Core () <SOXSocketIOCoreProtocol, SOXMarketCoreServerRequestProtocol>
@property (strong, nonatomic) NSHashTable *buyDelegates;
@property (strong, nonatomic) NSHashTable *sellDelegates;
@property (strong, nonatomic) NSMutableDictionary *orderDataToCheckLater;

@property (strong, nonatomic) NSTimer *orderbookTimer;

@property (strong, nonatomic) NSMutableDictionary *buyOrderBookDatas;
@property (strong, nonatomic) NSMutableDictionary *sellOrderBookDatas;


@property (strong, nonatomic) NSNumber *buyInterestRate;
@property (strong, nonatomic) NSNumber *buyCurrentLowestPrice;
@property (strong, nonatomic) NSNumber *buyMaximalEuroInvestment;

@property (strong, nonatomic) NSNumber *sellInterestRate;
@property (strong, nonatomic) NSNumber *sellCurrentHighestPrice;
@property (strong, nonatomic) NSNumber *sellMaximalBTCInvestment;

@property (strong, nonatomic) NSNumber *freeReservation;
@property (strong, nonatomic) NSNumber *freeBitcoins;

@end

#pragma mark - Implementation
@implementation SOXAutomaticTrading_BitcoinDE_Core
#pragma mark - Public class methods
+ (void)registerController:(id <SOXAutomaticTradingCoreProtocol>)controller
    forUpdatesForOrderType:(BitcoinDE_OrderType)orderType {

    if (!controller) {
        return;
    }
    
    SOXAutomaticTrading_BitcoinDE_Core *tradingCore = [SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore];
    
    switch (orderType) {
        case BitcoinDE_BuyOrderType:
            [tradingCore.buyDelegates addObject:controller];
            
            break;
        case BitcoinDE_SellOrderType:
            [tradingCore.sellDelegates addObject:controller];
            
            break;
        default:
            NSLog(@"ERROR - (void)registerForUpdatesForType:(BitcoinDE_OrderType)orderType");
            break;
    }
    
    [SOXAutomaticTrading_BitcoinDE_Core registerForWebSocketUpdates];
}

+ (void)unRegisterController:(id)controller forUpdatesForOrderType:(BitcoinDE_OrderType)orderType {
    if (!controller) {
        return;
    }
    
    SOXAutomaticTrading_BitcoinDE_Core *tradingCore = [SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore];
    
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

+ (void)setBuyInterestRate:(NSNumber *)buyInterestRate {
    if (buyInterestRate) {
        [SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore].buyInterestRate = buyInterestRate;
    }
}

+ (void)setSellInterestRate:(NSNumber *)sellInterestRate {
    if (sellInterestRate) {
        [SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore].sellInterestRate = sellInterestRate;
    }
}

+ (void)setBuyMaximalEuro:(NSNumber *)buyMaximalEuro {
    if (buyMaximalEuro) {
        [SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore].buyMaximalEuroInvestment = buyMaximalEuro;
    }
}

+ (void)setSellMaximalBTC:(NSNumber *)sellMaximalBTC {
    if (sellMaximalBTC) {
        [SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore].sellMaximalBTCInvestment = sellMaximalBTC;
    }
}

#pragma mark - Private class methods
+ (instancetype)sharedTradingCore {
    static id sharedTradingCore;
    
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        sharedTradingCore = [[self class] new];
        [(SOXAutomaticTrading_BitcoinDE_Core *)sharedTradingCore setBuyDelegates:[[NSHashTable alloc] init]];
        [(SOXAutomaticTrading_BitcoinDE_Core *)sharedTradingCore setSellDelegates:[[NSHashTable alloc] init]];
        [(SOXAutomaticTrading_BitcoinDE_Core *)sharedTradingCore setOrderDataToCheckLater:[NSMutableDictionary dictionary]];
    });
    
    return sharedTradingCore;
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

#pragma mark | OrderData handling
+ (void)checkOfferData:(SOXShowOrderbookData *)offerData {
    SOXAutomaticTrading_BitcoinDE_Core *core = [SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore];
    
    NSString *executeTradeText = @"";
    // Debug
    NSString *orderInfo = [SOXAutomaticTrading_BitcoinDE_Core informationStringOfOrderbookData:offerData];
    
    BOOL buyThisOffer = [offerData.orderInformation_price isLessThan:core.buyCurrentLowestPrice];
    if (!buyThisOffer) {
        executeTradeText = [NSString stringWithFormat:@"no buy %@", orderInfo];
        [core.buyOrderBookDatas setObject:offerData
                                   forKey:offerData.orderInformation_orderID];
    }
    else {
        // check for payment option
        NSInteger paymentOption = offerData.orderRequirements_paymentOption.integerValue;
        switch (paymentOption) {
            case BitcoinDE_PaymentOptionUnknown:
            case BitcoinDE_PaymentOptionSEPAOnly:
                 // keep info for paymentOption update
                [core.orderDataToCheckLater setObject:offerData
                                               forKey:offerData.orderInformation_socketOrderObjectID];
                executeTradeText = [NSString stringWithFormat:@"buy maybe later %@", orderInfo];
                break;
            case BitcoinDE_PaymentOptionExpressOnly:
            case BitcoinDE_PaymentOptionExpressAndSepa:
                // buy offer
                executeTradeText = [NSString stringWithFormat:@"BUY %@", orderInfo];
//                [SOXAutomaticTrading_BitcoinDE_Core tryBuyOffer:offerData];
                
                break;
            default:
                break;
        }
    }

    // inform delegate
    for (NSObject *buyDelegate in core.buyDelegates) {
        [buyDelegate performSelector:@selector(executedTrade:)
                          withObject:executeTradeText];
        
    }
}

+ (void)checkOrderData:(SOXShowOrderbookData *)orderData {
    SOXAutomaticTrading_BitcoinDE_Core *core = [SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore];
    
    NSString *executeTradeText = @"";
    NSString *orderInfo = [SOXAutomaticTrading_BitcoinDE_Core informationStringOfOrderbookData:orderData];

    BOOL sellThisOffer = [orderData.orderInformation_price isGreaterThan:core.sellCurrentHighestPrice];
    if (!sellThisOffer) {
        executeTradeText = [NSString stringWithFormat:@"no sell %@", orderInfo];
        [core.sellOrderBookDatas setObject:orderData
                                    forKey:orderData.orderInformation_orderID];
    }
    else {
        // check for payment option
        NSInteger paymentOption = orderData.orderRequirements_paymentOption.integerValue;
        switch (paymentOption) {
            case BitcoinDE_PaymentOptionUnknown:
            case BitcoinDE_PaymentOptionSEPAOnly:
                // keep info for paymentOption update
                //                [self.orderDataToCheckLater setObject:orderData
                //                                               forKey:orderData.orderInformation_socketOrderObjectID];
                executeTradeText = [NSString stringWithFormat:@"sell maybe later %@", orderInfo];
                break;
            case BitcoinDE_PaymentOptionExpressOnly:
            case BitcoinDE_PaymentOptionExpressAndSepa:
                // sell offer
                executeTradeText = [NSString stringWithFormat:@"SELL direct %@", orderInfo];
                [SOXAutomaticTrading_BitcoinDE_Core trySellOffer:orderData];
                break;
            default:
                break;
        }
    }
    [core.orderDataToCheckLater setObject:orderData
                                   forKey:orderData.orderInformation_socketOrderObjectID];
    // inform delegate
    for (NSObject *sellDelegate in core.sellDelegates) {
        [sellDelegate performSelector:@selector(executedTrade:)
                           withObject:executeTradeText];
    }
}

+ (void)trySellOffer:(SOXShowOrderbookData *)sellOffer {
    SOXAutomaticTrading_BitcoinDE_Core *core = [SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore];
    // debug
    {
        NSString *executeTradesString = [NSString stringWithFormat:@"Try to sell offer with ID: %@", sellOffer.orderInformation_orderID];
        for (NSObject *sellDelegate in core.sellDelegates) {
            [sellDelegate performSelector:@selector(executedTrade:)
                              withObject:executeTradesString];
        }
    }
    // 1. check price => already done in -(void)checkOrderData
    // 2. check paymentOption => already done in -(void)checkOrderData
    // 3. check for available BTCamount
    if ([core.freeBitcoins isGreaterThan:sellOffer.orderInformation_minAmount]) {
        
        NSNumber *bitcoinAmount = nil;
        if ([core.freeBitcoins isLessThan:sellOffer.orderInformation_maxAmount]) {
            bitcoinAmount = core.freeBitcoins;
        }
        else {
            bitcoinAmount = sellOffer.orderInformation_maxAmount;
        }
        
        NSDictionary *parameterDictionary = [SOXTradeJob_BitcoinDE_Data parameterForOrderID:sellOffer.orderInformation_orderID
                                                                                  orderType:BitcoinDE_SellOrderType
                                                                              bitcoinAmount:bitcoinAmount];
        NSString *executeTradesString = [NSString stringWithFormat:@"EXECUTE: Sell with parameters:\n%@", parameterDictionary];
        for (NSObject *buyDelegate in core.buyDelegates) {
            [buyDelegate performSelector:@selector(executedTrade:)
                              withObject:executeTradesString];
        }
//        [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ExecuteTrade
//                                                withParameter:parameterDictionary
//                                                    respondTo:core];
    }
    else {
        // debug
        {
            NSString *executeTradesString = [NSString stringWithFormat:@"Sell for ID: %@ not possible; too less btc (you have %@ and need at least %@ BTC)"
                                             , sellOffer.orderInformation_orderID
                                             , core.freeBitcoins
                                             , sellOffer.orderInformation_minAmount
                                             ];
            for (NSObject *buyDelegate in core.buyDelegates) {
                [buyDelegate performSelector:@selector(executedTrade:)
                                  withObject:executeTradesString];
            }
        }
    }
}

#pragma mark | Helper methods
+ (NSString *)informationStringOfOrderbookData:(SOXShowOrderbookData *)orderbookData {
    NSString *paymentOptionString;
    NSInteger paymentOption = orderbookData.orderRequirements_paymentOption.integerValue;
    switch (paymentOption) {
        case BitcoinDE_PaymentOptionUnknown:
            paymentOptionString = @"Unknown";
            break;
        case BitcoinDE_PaymentOptionSEPAOnly:
            paymentOptionString = @"SEPA";
            break;
        case BitcoinDE_PaymentOptionExpressOnly:
            paymentOptionString = @"Express";
            break;
        case BitcoinDE_PaymentOptionExpressAndSepa:
            paymentOptionString = @"Express&Sepa";
            break;
        default:
            break;
    }
    
    NSString *orderDataInformation;
    orderDataInformation = [NSString stringWithFormat:@"ID: %@, price: %@€, maxBTC: %@, payOpt: %@, timeStamp: %@"
                            , orderbookData.orderInformation_socketOrderObjectID
                            , orderbookData.orderInformation_price
                            , orderbookData.orderInformation_maxAmount
                            , paymentOptionString
                            , [NSDate date]
                            ];
    
    return orderDataInformation;
}
#pragma mark - Private methods
- (void)startRefetchOrderBookTimer {
    if ((self.buyDelegates.count > 0 || self.sellDelegates.count > 0)
        && !self.orderbookTimer) {
        SOXAutomaticTrading_BitcoinDE_Core *core = [SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore];
        NSLog(@"startRefetchOrderBookTimer");
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:15
                                                               target:core
                                                             selector:@selector(startRefetchOrderBook)
                                                             userInfo:nil
                                                              repeats:NO];
        timer.tolerance = 1;
        [[NSRunLoop mainRunLoop] addTimer:timer
                                  forMode:NSDefaultRunLoopMode];
        self.orderbookTimer = timer;
    }

}

- (void)startRefetchOrderBook {
    // buy
    NSDictionary *buyParameters = [SOXShowOrderbook_BitcoinDE_Data parametersForOrderType:BitcoinDE_BuyOrderType
                                                                 onlyExpressPaymentOption:YES];
    
    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowBuyOrderbookCommandType
                                            withParameter:buyParameters
                                                respondTo:self];
    // sell
    NSDictionary *sellParameters = [SOXShowOrderbook_BitcoinDE_Data parametersForOrderType:BitcoinDE_SellOrderType
                                                                  onlyExpressPaymentOption:YES];
    
    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowSellOrderbookCommandType
                                            withParameter:sellParameters
                                                    respondTo:self];
    
    NSString *infoString = @"Fetching orderbook ...";
    for (NSObject *buyDelegate in self.buyDelegates) {
        [buyDelegate performSelector:@selector(executedTrade:)
                          withObject:infoString];
    }
    for (NSObject *sellDelegate in self.sellDelegates) {
        [sellDelegate performSelector:@selector(executedTrade:)
                           withObject:infoString];
    }
    
    [self.orderbookTimer invalidate];
    self.orderbookTimer = nil;

}

- (void)calculateNewBuyLowestPriceForCurrentHighestSellPrice:(NSNumber *)currentHighestSellPrice {
    // debug
    
    currentHighestSellPrice = @(currentHighestSellPrice.doubleValue -0.0001);
    NSNumber *oldBuyLowestPrice = self.buyCurrentLowestPrice;
    
    if ([self.buyCurrentLowestPrice isEqualToNumber:@0]) {
        self.buyCurrentLowestPrice = @(currentHighestSellPrice.doubleValue * (1 - self.buyInterestRate.doubleValue/100));
    }
    else if (currentHighestSellPrice > 0) { // just in case
        SOXAutomaticTrading_BitcoinDE_Core *core = [SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore];
        NSNumber *potentialNewLowestBuyPrice = @(currentHighestSellPrice.doubleValue * (1 - core.buyInterestRate.doubleValue/100));
        if ([self.buyCurrentLowestPrice isGreaterThan:potentialNewLowestBuyPrice]) {
            self.buyCurrentLowestPrice = potentialNewLowestBuyPrice;
        }
    }
    else {
        return;
    }
    // Inform delegates about change
    // Debug
    NSString *priceUpdateText = [NSString stringWithFormat:@"new BUY limit alt: %@ neu: %@",
                                 oldBuyLowestPrice , self.buyCurrentLowestPrice];
    
    for (NSObject *buyDelegate in self.buyDelegates) {
        [buyDelegate performSelector:@selector(currentLimitHasChangedTo:)
                          withObject:self.buyCurrentLowestPrice];
        // Debug
        [buyDelegate performSelector:@selector(executedTrade:)
                          withObject:priceUpdateText];
    }
    
}

- (void)calculateNewSellHighestPriceForCurrentLowestBuyPrice:(NSNumber *)currentLowestBuyPrice {
    currentLowestBuyPrice = @(currentLowestBuyPrice.doubleValue -0.0001);
    NSNumber *oldSellHighestPrice = self.sellCurrentHighestPrice;
    
    if ([self.sellCurrentHighestPrice isEqualToNumber:@0]) {
        self.sellCurrentHighestPrice = @(currentLowestBuyPrice.doubleValue * (1 + self.sellInterestRate.doubleValue/100));
    }
    else if (currentLowestBuyPrice > 0) { // just in case
        SOXAutomaticTrading_BitcoinDE_Core *core = [SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore];
        NSNumber *potentialNewSellHighestPrice = @(currentLowestBuyPrice.doubleValue * (1 + core.sellInterestRate.doubleValue/100));
        if ([self.sellCurrentHighestPrice isLessThan:potentialNewSellHighestPrice]) {
            self.sellCurrentHighestPrice = potentialNewSellHighestPrice;
        }
    }
    else {
        return;
    }
    
    // Debug
    NSString *priceUpdateText = [NSString stringWithFormat:@"new SELL limit alt: %@ neu: %@"
                                 , oldSellHighestPrice
                                 , self.sellCurrentHighestPrice
                                 ];
    
    for (NSObject *sellDelegate in self.sellDelegates) {
        [sellDelegate performSelector:@selector(currentLimitHasChangedTo:)
                           withObject:self.sellCurrentHighestPrice];
        // Debug
        [sellDelegate performSelector:@selector(executedTrade:)
                           withObject:priceUpdateText];
    }
}

#pragma mark - SOXMarketCoreServerRequestProtocol
- (void)answerOfServerRequest:(NSDictionary *)answerOfServerRequest {
    id errorMessage = [answerOfServerRequest objectForKey:ServerAnswerErrorKey];
    if (errorMessage) {
        NSLog(@"SOXAutomaticTrading_BitcoinDE_Core - answerOfServerRequest with error:\n%@", errorMessage);
        return;
    }
    
    SOXAutomaticTrading_BitcoinDE_Core *core = [SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore];
    
    NSDictionary *payloadDictionary = [answerOfServerRequest objectForKey:ServerAnswerPayloadKey];
    NSMutableArray <SOXShowOrderbook_BitcoinDE_Data *> *orderBookDatas;
    orderBookDatas = [SOXShowOrderbook_BitcoinDE_Data orderbookDataArrayForShowOrderbookDictionary:payloadDictionary];
    
    BitcoinDE_UpdateType updateTypeToRegister = BitcoinDE_UpdateType_Unknown;
    NSMutableDictionary *orderBookDictionary = nil;
    if ([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ShowBuyOrderbookCommandType)]
        && orderBookDatas.count > 0) {
        updateTypeToRegister = BitcoinDE_UpdateType_SellOrderChanges; // sell correct here
        orderBookDictionary = self.buyOrderBookDatas;
    }
    else if([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ShowSellOrderbookCommandType)]
            && orderBookDatas.count > 0) {
        updateTypeToRegister = BitcoinDE_UpdateType_BuyOrderChanges; // buy correct here
        orderBookDictionary = self.sellOrderBookDatas;
    }
    
    if (orderBookDictionary) {
        [orderBookDatas enumerateObjectsUsingBlock:^(SOXShowOrderbook_BitcoinDE_Data * _Nonnull orderBookData, NSUInteger idx, BOOL * _Nonnull stop) {
            [orderBookDictionary setObject:orderBookData
                                    forKey:orderBookData.orderInformation_orderID];
        }];
    }
    
    if (updateTypeToRegister != BitcoinDE_UpdateType_Unknown) {
        [SOXSocketIO_BitcoinDE_Core registerForOrderUpdatesForUpdateType:updateTypeToRegister
                                                                delegate:core];
        [SOXSocketIO_BitcoinDE_Core registerForOrderUpdatesForUpdateType:BitcoinDE_UpdateType_RemoveOrderChanges
                                                                delegate:core];
    }
    
}

#pragma mark - SOXSocketIOCoreProtocol
- (void)addedOrder:(SOXShowOrderbookData *)addOrderData {
    if ([addOrderData.orderInformation_type isEqualToString:@"offer"]) {
        [SOXAutomaticTrading_BitcoinDE_Core checkOfferData:addOrderData];
    }
    else if ([addOrderData.orderInformation_type isEqualToString:@"order"]) {
        [SOXAutomaticTrading_BitcoinDE_Core checkOrderData:addOrderData];
    }
}

- (void)removedOrderWithOrderID:(NSString *)orderID {
    SOXAutomaticTrading_BitcoinDE_Core *core = [SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore];
    
    [core.buyOrderBookDatas removeObjectForKey:orderID];
    [core.sellOrderBookDatas removeObjectForKey:orderID];
    
    [core.orderDataToCheckLater removeObjectForKey:orderID];
    
    NSLog(@"Removed order with orderID: %@ from orderDataToCheckLater", orderID);
}

- (void)updateOrderWithSocketOrderObjectID:(NSString *)orderObjectID withValues:(NSDictionary *)changesDictionary {
    SOXShowOrderbook_BitcoinDE_Data *dataForOrderObjectID = [self.orderDataToCheckLater objectForKey:orderObjectID];
    if (!dataForOrderObjectID ) {
        NSLog(@"Update, but data for ID %@ not found in orderDataToCheckLater", orderObjectID);
    }
    else {
        [dataForOrderObjectID updateOrderbookDataWith:changesDictionary];
        if ([dataForOrderObjectID.orderInformation_type isEqualToString:@"offer"]) {
            [SOXAutomaticTrading_BitcoinDE_Core checkOfferData:dataForOrderObjectID];
        }
        else if ([dataForOrderObjectID.orderInformation_type isEqualToString:@"order"]) {
            [SOXAutomaticTrading_BitcoinDE_Core checkOrderData:dataForOrderObjectID];
        }
    }
}

@end
