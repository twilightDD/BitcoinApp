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

+ (void)unRegisterController:(id)controller
      forUpdatesForOrderType:(BitcoinDE_OrderType)orderType {
    if (!controller) {
        return;
    }
    
    SOXAutomaticTrading_BitcoinDE_Core *tradingCore = [SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore];
    tradingCore.orderType = orderType;
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

#pragma mark - Private class methods
+ (instancetype)sharedTradingCore {
    static id sharedTradingCore;
    
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        sharedTradingCore = [[self class] new];
        [(SOXAutomaticTrading_BitcoinDE_Core *)sharedTradingCore setBuyDelegates:[[NSHashTable alloc] init]];
        [(SOXAutomaticTrading_BitcoinDE_Core *)sharedTradingCore setSellDelegates:[[NSHashTable alloc] init]];
        [(SOXAutomaticTrading_BitcoinDE_Core *)sharedTradingCore setOrderDataToCheckLater:[NSMutableDictionary dictionary]];
        [(SOXAutomaticTrading_BitcoinDE_Core *)sharedTradingCore setBuyInterestRate:5];
        [(SOXAutomaticTrading_BitcoinDE_Core *)sharedTradingCore setSellInterestRate:5];
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

    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowBuyOrderbookCommandType
                                                respondTo:core];
    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowSellOrderbookCommandType
                                                respondTo:core];
}

#pragma mark | OrderData handling
+ (void)checkOfferData:(SOXShowOrderbookData *)offerData {
    SOXAutomaticTrading_BitcoinDE_Core *core = [SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore];
    
    NSString *executeTradeText = @"";
    // Debug
    NSString *orderInfo = [SOXAutomaticTrading_BitcoinDE_Core informationStringOfOrderbookData:offerData];
    
    double orderPrice = offerData.orderInformation_price.doubleValue;
    
    BOOL buyThisOffer = orderPrice < core.buyLowestPrice;
    if (!buyThisOffer) {
        executeTradeText = [NSString stringWithFormat:@"no buy %@", orderInfo];
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
                [SOXAutomaticTrading_BitcoinDE_Core tryBuyOffer:offerData];
                
                break;
            default:
                break;
        }
    }
//    [core.orderDataToCheckLater setObject:offerData
//                                   forKey:offerData.orderInformation_socketOrderObjectID];
    // inform delegate
    for (NSObject *buyDelegate in core.buyDelegates) {
        [buyDelegate performSelector:@selector(executedTrade:)
                          withObject:executeTradeText];
        
    }
//    for (NSObject *sellDelegate in core.sellDelegates) {
//        [sellDelegate performSelector:@selector(currentLimitHasChangedTo:)
//                           withObject:@(core.sellHighestPrice)];
//    }
}

+ (void)checkOrderData:(SOXShowOrderbookData *)orderData {
    SOXAutomaticTrading_BitcoinDE_Core *core = [SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore];
    
    NSString *executeTradeText = @"";
    NSString *orderInfo = [SOXAutomaticTrading_BitcoinDE_Core informationStringOfOrderbookData:orderData];
    
    double orderPrice = orderData.orderInformation_price.doubleValue;

    BOOL sellThisOffer = orderPrice > core.sellHighestPrice;
    if (!sellThisOffer) {
        executeTradeText = [NSString stringWithFormat:@"no sell %@", orderInfo];
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
//    for (NSObject *buyDelegate in core.buyDelegates) {
//        [buyDelegate performSelector:@selector(currentLimitHasChangedTo:)
//                          withObject:@(core.sellHighestPrice)];
//    }
    for (NSObject *sellDelegate in core.sellDelegates) {
        [sellDelegate performSelector:@selector(executedTrade:)
                           withObject:executeTradeText];
    }
    
    
}

+ (void)tryBuyOffer:(SOXShowOrderbookData *)buyOffer {
    SOXAutomaticTrading_BitcoinDE_Core *core = [SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore];
    // debug
    {
        NSString *executeTradesString = [NSString stringWithFormat:@"Try to buy offer with ID: %@", buyOffer.orderInformation_orderID];
        for (NSObject *buyDelegate in core.buyDelegates) {
            [buyDelegate performSelector:@selector(executedTrade:)
                              withObject:executeTradesString];
        }
    }
    // 1. check price => already done in -(void)checkOrderData
    // 2. check paymentOption => already done in -(void)checkOrderData
    // 3. check for available BTCamount
    if (core.freeBitcoins > buyOffer.orderInformation_minAmount.doubleValue) {
        
        double bitcoinAmount = 0;
        if (core.freeBitcoins < buyOffer.orderInformation_maxAmount.doubleValue) {
            bitcoinAmount = core.freeBitcoins;
        }
        else {
            bitcoinAmount = buyOffer.orderInformation_maxAmount.doubleValue;
        }
        
//        SOXTradeJob_BitcoinDE_Data *tradeJobData = [SOXTradeJob_BitcoinDE_Data tradeJobForOrderID:buyOffer.orderInformation_orderID
//                                                                                             type:BitcoinDE_BuyOrderType
//                                                                                    bitcoinAmount:@(bitcoinAmount)];
        
        NSDictionary *parameterDictionary = [SOXTradeJob_BitcoinDE_Data parameterForOrderID:buyOffer.orderInformation_orderID
                                                                                  orderType:BitcoinDE_BuyOrderType
                                                                              bitcoinAmount:@(bitcoinAmount)];
        
        [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ExecuteTrade
                                                withParameter:parameterDictionary
                                                    respondTo:core];
    }
    else {
        // debug
        {
            NSString *executeTradesString = [NSString stringWithFormat:@"Buy for ID: %@ not possible; too less btc", buyOffer.orderInformation_orderID];
            for (NSObject *buyDelegate in core.buyDelegates) {
                [buyDelegate performSelector:@selector(executedTrade:)
                                  withObject:executeTradesString];
            }
        }
    }
}


+ (void)trySellOffer:(SOXShowOrderbookData *)sellOffer {

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
    NSLog(@"startRefetchOrderBook for type: %tu", self.orderType);
    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowBuyOrderbookCommandType
                                                respondTo:self];
    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowSellOrderbookCommandType
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

- (void)calculateNewBuyLowestPriceForCurrentHighestSellPrice:(double)currentHighestSellPrice {
    // debug
    
    currentHighestSellPrice -=0.0001;
    double oldBuyLowestPrice = self.buyLowestPrice;
    
    if (self.buyLowestPrice == 0) {
        self.buyLowestPrice = currentHighestSellPrice * (1 - self.buyInterestRate/100);
    }
    else if (currentHighestSellPrice > 0) { // just in case
        SOXAutomaticTrading_BitcoinDE_Core *core = [SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore];
        double potentialNewLowestBuyPrice = currentHighestSellPrice * (1 - core.buyInterestRate/100);
        if (self.buyLowestPrice > potentialNewLowestBuyPrice) {
            self.buyLowestPrice = potentialNewLowestBuyPrice;
        }
    }
    else {
        return;
    }
    // Inform delegates about change
    // Debug
    NSString *priceUpdateText = [NSString stringWithFormat:@"new BUY limit alt: %0.2f neu: %0.2f",
                                 oldBuyLowestPrice , self.buyLowestPrice];
    
    for (NSObject *buyDelegate in self.buyDelegates) {
        [buyDelegate performSelector:@selector(currentLimitHasChangedTo:)
                          withObject:@(self.buyLowestPrice)];
        // Debug
        [buyDelegate performSelector:@selector(executedTrade:)
                          withObject:priceUpdateText];
    }
    
}

- (void)calculateNewSellHighestPriceForCurrentLowestBuyPrice:(double)currentLowestBuyPrice {
    currentLowestBuyPrice +=0.0001;
    double oldSellHighestPrice = self.sellHighestPrice;
    
    if (self.sellHighestPrice == 0) {
        self.sellHighestPrice = currentLowestBuyPrice * (1 + self.sellInterestRate/100);
    }
    else if (currentLowestBuyPrice > 0) { // just in case
        SOXAutomaticTrading_BitcoinDE_Core *core = [SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore];
        double potentialNewSellHighestPrice = currentLowestBuyPrice * (1 + core.sellInterestRate/100);
        if (self.sellHighestPrice < potentialNewSellHighestPrice) {
            self.sellHighestPrice = potentialNewSellHighestPrice;
        }
    }
    else {
        return;
    }
    
    // Debug
    NSString *priceUpdateText = [NSString stringWithFormat:@"new SELL limit alt: %0.2f neu: %0.2f", oldSellHighestPrice, self.sellHighestPrice];
    
    for (NSObject *sellDelegate in self.sellDelegates) {
        [sellDelegate performSelector:@selector(currentLimitHasChangedTo:)
                           withObject:@(self.sellHighestPrice)];
        // Debug
        [sellDelegate performSelector:@selector(executedTrade:)
                           withObject:priceUpdateText];
    }
}

#pragma mark - SOXMarketCoreServerRequestProtocol
- (void)answerOfServerRequest:(NSDictionary *)answerOfServerRequest {
    SOXAutomaticTrading_BitcoinDE_Core *core = [SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore];
    
    NSDictionary *payloadDictionary = [answerOfServerRequest objectForKey:ServerAnswerPayloadKey];
    NSMutableArray *orderBook = [SOXShowOrderbook_BitcoinDE_Data orderbookDataArrayForShowOrderbookDictionary:payloadDictionary];
    
    if ([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ShowBuyOrderbookCommandType)]
        && orderBook.count > 0) {
        // get lowest price from incoming orderDatas ...
        double currentLowestBuyPrice = [SOXShowOrderbook_BitcoinDE_Data lowestPriceOfOrderBookDatas:orderBook];
        //  ... compare to currently highest sell price
        
        [self calculateNewSellHighestPriceForCurrentLowestBuyPrice:currentLowestBuyPrice];
        
        [SOXSocketIO_BitcoinDE_Core registerForOrderUpdatesForUpdateType:BitcoinDE_UpdateType_SellOrderChanges
                                                                delegate:core];
        [core startRefetchOrderBookTimer]; // once for sharedCore
    }
    else if([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ShowSellOrderbookCommandType)]
            && orderBook.count > 0) {
        // get highest price from incoming orderDatas ...
        double currentHighestSellPrice = [SOXShowOrderbook_BitcoinDE_Data highestPriceOfOrderBookDatas:orderBook];
        // ... compare to currently lowest buy price
        [self calculateNewBuyLowestPriceForCurrentHighestSellPrice:currentHighestSellPrice];

        [SOXSocketIO_BitcoinDE_Core registerForOrderUpdatesForUpdateType:BitcoinDE_UpdateType_BuyOrderChanges
                                                                delegate:core];
    }
    
    [SOXSocketIO_BitcoinDE_Core registerForOrderUpdatesForUpdateType:BitcoinDE_UpdateType_RemoveOrderChanges
                                                            delegate:core];
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
    [[SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore].orderDataToCheckLater removeObjectForKey:orderID];
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
