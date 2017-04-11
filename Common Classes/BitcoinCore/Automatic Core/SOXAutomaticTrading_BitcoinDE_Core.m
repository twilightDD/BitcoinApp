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
@end

@implementation SOXAutomaticTrading_BitcoinDE_Core

+ (instancetype)sharedTradingCore {
    static id sharedTradingCore;
    
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        sharedTradingCore = [[self class] new];
        [(SOXAutomaticTrading_BitcoinDE_Core *)sharedTradingCore setBuyDelegates:[[NSHashTable alloc] init]];
        [(SOXAutomaticTrading_BitcoinDE_Core *)sharedTradingCore setSellDelegates:[[NSHashTable alloc] init]];
    });
    
    return sharedTradingCore;
}

+ (void)registerController:(id <SOXAutomaticTradingCoreProtocol>)controller forUpdatesForType:(BitcoinDE_OrderType)orderType {
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
}

+ (void)startAutomaticTrading {
    // setup sharedCore
    SOXAutomaticTrading_BitcoinDE_Core *core = [SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore];
    [core registerForWebSocketUpdates];
}

+ (void)stopAutomaticTrading {
    // setup sharedCore
//    SOXAutomaticTrading_BitcoinDE_Core *core = [SOXAutomaticTrading_BitcoinDE_Core sharedTradingCore];
//    [core registerForWebSocketUpdates];
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
    self.buyInterestRate = 5;
    self.sellInterestRate = 5;
    double orderPrice = addOrderData.orderInformation_price.doubleValue;
    double rateWeight = [SOXMarket_BitcoinDE_Core sharedCore].rate_weighted.doubleValue;
    
    if ([addOrderData.orderInformation_type isEqualToString:@"offer"]) {
        NSString *line = [NSString stringWithFormat:@"No buy: %@", addOrderData.orderInformation_price];
        line = [NSString stringWithFormat:@"NO buy: %@€, maxBTC: %@ (threshhold: %0.5f)"
                , addOrderData.orderInformation_price
                , addOrderData.orderInformation_maxAmount
                , rateWeight * (1 - self.buyInterestRate/100)
                ];
        if (orderPrice < rateWeight * (1 - self.buyInterestRate/100)) {
            NSLog(@"### BUY offer with ID: %@", addOrderData.orderInformation_orderID);
            line = [NSString stringWithFormat:@"buy: %@€, maxBTC: %@"
                    , addOrderData.orderInformation_price
                    , addOrderData.orderInformation_maxAmount
                    
                    ];
                   }
        else {
            NSLog(@"### no buy ID: %@", addOrderData.orderInformation_orderID);
        }
        for (NSObject *buyDelegate in self.buyDelegates) {
            [buyDelegate performSelector:@selector(executedTrade:)
                              withObject:line];
        }

    }
    else if ([addOrderData.orderInformation_type isEqualToString:@"order"]) {
        NSString *line = [NSString stringWithFormat:@"No sell: %@", addOrderData.orderInformation_price];
        line = [NSString stringWithFormat:@"NO sell: %@€, maxBTC: %@ (threshhold: %0.5f)"
                , addOrderData.orderInformation_price
                , addOrderData.orderInformation_maxAmount
                , rateWeight * (1 + self.sellInterestRate/100)
                ];
        if (orderPrice > rateWeight * (1 + self.sellInterestRate/100)) {
            NSLog(@"### SELL offer with ID: %@", addOrderData.orderInformation_orderID);
            line = [NSString stringWithFormat:@"sell: %@€, maxBTC: %@"
                    , addOrderData.orderInformation_price
                    , addOrderData.orderInformation_maxAmount];
        }
        else {
            NSLog(@"### no sell offer with ID: %@", addOrderData.orderInformation_orderID);
        }
        for (NSObject *sellDelegate in self.sellDelegates) {
            [sellDelegate performSelector:@selector(executedTrade:)
                              withObject:line];
        }

    }
    // look out for lower/higher price
}

//- (void)removedOrderWithOrderID:(NSString *)orderID {
//    // TODO: TODO find better implementation
//    // buyOrderBook
//    NSMutableArray *foundBuyOrders = [NSMutableArray array];
//    for (SOXShowOrderbookData *orderbookData in self.buyOrderBook) {
//        if ([orderbookData.orderInformation_orderID isEqualToString:orderID]) {
//            [foundBuyOrders addObject:orderbookData];
//        }
//    }
//    for (SOXShowOrderbookData *foundOrder in foundBuyOrders) {
//        [self.buyOrderBook removeObject:foundOrder];
//    }
//    
//    // sellOrderBook
//    NSMutableArray *foundSellOrders = [NSMutableArray array];
//    for (SOXShowOrderbookData *orderbookData in self.sellOrderBook) {
//        if ([orderbookData.orderInformation_orderID isEqualToString:orderID]) {
//            [foundSellOrders addObject:orderbookData];
//        }
//    }
//    for (SOXShowOrderbookData *foundOrder in foundSellOrders) {
//        [self.sellOrderBook removeObject:foundOrder];
//    }
//}
//
//-(void)updateOrderWithSocketOrderObjectID:(NSString *)orderObjectID withValues:(NSDictionary *)changesDictionary {
//    for (SOXShowOrderbook_BitcoinDE_Data *orderbookData in self.buyOrderBook) {
//        if ([orderbookData.orderInformation_socketOrderObjectID isEqualToString:orderObjectID]) {
//            // ist data object mit orderObjectID vorhanden? Ja: updaten!
//            [orderbookData updateOrderbookDataWith:changesDictionary];
//        }
//    }
//    
//    for (SOXShowOrderbook_BitcoinDE_Data *orderbookData in self.sellOrderBook) {
//        if ([orderbookData.orderInformation_socketOrderObjectID isEqualToString:orderObjectID]) {
//            // ist data object mit orderObjectID vorhanden? Ja: updaten!
//            [orderbookData updateOrderbookDataWith:changesDictionary];
//        }
//    }
//    
//    // watch for paymentOption
//
//}
@end
