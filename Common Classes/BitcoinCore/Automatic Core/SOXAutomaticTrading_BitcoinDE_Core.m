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

@interface SOXAutomaticTrading_BitcoinDE_Core () <SOXSocketIOCoreProtocol>
@property (strong, nonatomic) NSHashTable *buyDelegates;
@property (strong, nonatomic) NSHashTable *sellDelegates;

@property (strong, nonatomic) NSMutableDictionary *orderDataToCheckLater;



@end

@implementation SOXAutomaticTrading_BitcoinDE_Core

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

+ (void)registerController:(id <SOXAutomaticTradingCoreProtocol>)controller
    forUpdatesForOrderType:(BitcoinDE_OrderType)orderType {
    if (!controller) {
        return;
    }

    SOXAutomaticTrading_BitcoinDE_Core *tradingCore = [SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore];
    tradingCore.orderType = orderType;
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
    
    [SOXAutomaticTrading_BitcoinDE_Core checkRegisterForSocketUpdatesStatus];
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

//+ (void)startAutomaticTradingForOrderType:(BitcoinDE_OrderType)orderType {
//    // setup sharedCore
//    
//    SOXAutomaticTrading_BitcoinDE_Core *core = [SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore];
//    core.buyInterestRate = 0.01;
//    core.sellInterestRate = 0.01;
//    
//    [core registerForWebSocketUpdates];
//}

//+ (void)stopAutomaticTradingForOrderType:(BitcoinDE_OrderType)orderType {
//    // setup sharedCore
////    SOXAutomaticTrading_BitcoinDE_Core *core = [SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore];
////    [core registerForWebSocketUpdates];
//}

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

- (void)registerForWebSocketUpdates {
    [SOXSocketIO_BitcoinDE_Core registerForOrderUpdatesForUpdateType:BitcoinDE_UpdateType_BuyOrderChanges
                                                            delegate:self];
    [SOXSocketIO_BitcoinDE_Core registerForOrderUpdatesForUpdateType:BitcoinDE_UpdateType_RemoveOrderChanges
                                                            delegate:self];
    [SOXSocketIO_BitcoinDE_Core registerForOrderUpdatesForUpdateType:BitcoinDE_UpdateType_SellOrderChanges
                                                            delegate:self];
}

#pragma mark - SOXSocketIOCoreProtocol
- (void)addedOrder:(SOXShowOrderbookData *)addOrderData {
    if ([addOrderData.orderInformation_type isEqualToString:@"offer"]) {
        [self checkOfferData:addOrderData];
    }
    else if ([addOrderData.orderInformation_type isEqualToString:@"order"]) {
        [self checkOrderData:addOrderData];
    }
    // look out for lower/higher price
}

- (void)removedOrderWithOrderID:(NSString *)orderID {
    [self.orderDataToCheckLater removeObjectForKey:orderID];
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
            [self checkOfferData:dataForOrderObjectID];
        }
        else if ([dataForOrderObjectID.orderInformation_type isEqualToString:@"order"]) {
            [self checkOrderData:dataForOrderObjectID];
        }
    }
}

- (NSString *)informationStringOfOrderbookData:(SOXShowOrderbookData *)orderbookData {
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
    orderDataInformation = [NSString stringWithFormat:@"ID: %@, price: %@€, maxBTC: %@, payOpt: %@"
                            , orderbookData.orderInformation_socketOrderObjectID
                            , orderbookData.orderInformation_price
                            , orderbookData.orderInformation_maxAmount
                            , paymentOptionString
                            ];
    
    return orderDataInformation;
}

- (void)checkOfferData:(SOXShowOrderbookData *)offerData {
    NSString *executeTradeText = @"";
    NSString *orderInfo = [self informationStringOfOrderbookData:offerData];
    
    double orderPrice = offerData.orderInformation_price.doubleValue;
    double rateWeight = [SOXMarket_BitcoinDE_Core sharedCore].rate_weighted.doubleValue;
    
    BOOL buyThisOffer = orderPrice < (rateWeight * (1 - self.buyInterestRate/100));
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
//                [self.orderDataToCheckLater setObject:offerData
//                                               forKey:offerData.orderInformation_socketOrderObjectID];
                executeTradeText = [NSString stringWithFormat:@"buy maybe later %@", orderInfo];
                break;
            case BitcoinDE_PaymentOptionExpressOnly:
            case BitcoinDE_PaymentOptionExpressAndSepa:
                // buy offer
                executeTradeText = [NSString stringWithFormat:@"BUY %@", orderInfo];
                break;
            default:
                break;
        }
    }
    [self.orderDataToCheckLater setObject:offerData
                                   forKey:offerData.orderInformation_socketOrderObjectID];
    // inform delegate
    for (NSObject *buyDelegate in self.buyDelegates) {
        [buyDelegate performSelector:@selector(executedTrade:)
                          withObject:executeTradeText];
    }

}
- (void)checkOrderData:(SOXShowOrderbookData *)orderData {
    NSString *executeTradeText = @"";
    NSString *orderInfo = [self informationStringOfOrderbookData:orderData];
    
    double orderPrice = orderData.orderInformation_price.doubleValue;
    double rateWeight = [SOXMarket_BitcoinDE_Core sharedCore].rate_weighted.doubleValue;
    
    BOOL buyThisOffer = orderPrice > rateWeight * (1 + self.sellInterestRate/100);
    if (!buyThisOffer) {
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
                break;
            default:
                break;
        }
    }
    [self.orderDataToCheckLater setObject:orderData
                                   forKey:orderData.orderInformation_socketOrderObjectID];
    // inform delegate
    for (NSObject *sellDelegate in self.sellDelegates) {
        [sellDelegate performSelector:@selector(executedTrade:)
                          withObject:executeTradeText];
    }
}

@end
