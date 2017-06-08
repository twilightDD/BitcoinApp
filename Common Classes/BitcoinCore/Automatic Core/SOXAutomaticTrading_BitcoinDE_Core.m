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

@interface SOXAutomaticTrading_BitcoinDE_Core () <SOXMarketCoreServerRequestProtocol, SOXSocketIOCoreProtocol>

@property (strong, nonatomic) NSHashTable *buyDelegates;
@property (strong, nonatomic) NSHashTable *sellDelegates;

@property (strong, nonatomic) NSMutableArray *buyOrderBook;
@property (strong, nonatomic) NSMutableArray *sellOrderBook;

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
- (NSMutableArray *)sortedOrderBook:(NSMutableArray *)orderBookDatas forOrderType:(BitcoinDE_OrderType)orderType {
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
        self.buyOrderBook = [self sortedOrderBook:orderBookDatas forOrderType:BitcoinDE_BuyOrderType];
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
    }
    else if([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ShowSellOrderbookCommandType)]) {

        self.sellOrderBook = [self sortedOrderBook:orderBookDatas forOrderType:BitcoinDE_SellOrderType];
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
    }
}

- (void)checkForBuyableOrder {
    SOXShowOrderbook_BitcoinDE_Data *dataOfInterest = self.buyOrderBook.firstObject;
    SOXShowOrderbook_BitcoinDE_Data *referenceData = [self.buyOrderBook objectAtIndex:1];
    NSDecimalNumber *dataOfInterest_price = dataOfInterest.orderInformation_price;
    NSDecimalNumber *interest = [NSDecimalNumber decimalNumberWithString:@"1"];
    NSDecimalNumber *referenceData_price = [referenceData.orderInformation_price decimalNumberByDividingBy:interest];

    if ([dataOfInterest_price isLessThan:referenceData_price]) {
        NSString *note = [NSString stringWithFormat:@"BUY type %@ oID %@ miA%@",
                          dataOfInterest.orderInformation_type
                          , dataOfInterest.orderInformation_orderID
                          , dataOfInterest.orderInformation_minAmount];
        [self informBuyDelegateWithNote:note];
    }
    else {
        NSString *note = [NSString stringWithFormat:@"no buy type %@ oID %@ miA%@",
                          dataOfInterest.orderInformation_type
                          , dataOfInterest.orderInformation_orderID
                          , dataOfInterest.orderInformation_minAmount];
        [self informBuyDelegateWithNote:note];
    }

}

- (void)checkForSellableOrder {
    SOXShowOrderbook_BitcoinDE_Data *dataOfInterest = self.sellOrderBook.firstObject;
    SOXShowOrderbook_BitcoinDE_Data *referenceData = [self.sellOrderBook objectAtIndex:1];
    NSDecimalNumber *dataOfInterest_price = dataOfInterest.orderInformation_price;
    NSDecimalNumber *interest = [NSDecimalNumber decimalNumberWithString:@"1"];
    NSDecimalNumber *referenceData_price = [referenceData.orderInformation_price decimalNumberByMultiplyingBy:interest];
    if ([dataOfInterest_price isGreaterThan:referenceData_price]) {
        NSString *note = [NSString stringWithFormat:@"SELL type %@ oID %@ minAmount %@ price %@",
                          dataOfInterest.orderInformation_type
                          , dataOfInterest.orderInformation_orderID
                          , dataOfInterest.orderInformation_minAmount
                          , dataOfInterest.orderInformation_price];
        [self informSellDelegateWithNote:note];
    }
    else {
        NSString *note = [NSString stringWithFormat:@"no sell type %@ oID %@ minAmount %@  price %@",
                          dataOfInterest.orderInformation_type
                          , dataOfInterest.orderInformation_orderID
                          , dataOfInterest.orderInformation_minAmount
                          , dataOfInterest.orderInformation_price];

        [self informSellDelegateWithNote:note];

    }
}

#pragma mark - SOXSocketIOCoreProtocol
- (void)addedOrder:(SOXShowOrderbookData *)addOrderData {
    if ([addOrderData.orderInformation_type isEqualToString:@"order"]) {
        [self.sellOrderBook addObject:addOrderData];
        self.sellOrderBook = [self sortedOrderBook:self.sellOrderBook forOrderType:BitcoinDE_SellOrderType];
        if ([[self.sellOrderBook objectAtIndex:0] isEqual:addOrderData]) {
            [self checkForSellableOrder];
        }
        else {
            NSString *note = [NSString stringWithFormat:@"added sell order 'type: order' at idx %tu (price: %@)"
                              , [self.sellOrderBook indexOfObject:addOrderData]
                              , addOrderData.orderInformation_price];
            [self informSellDelegateWithNote:note];

        }

    }
    else if ([addOrderData.orderInformation_type isEqualToString:@"offer"]) {
        [self.buyOrderBook addObject:addOrderData];
        self.buyOrderBook = [self sortedOrderBook:self.buyOrderBook forOrderType:BitcoinDE_BuyOrderType];
        if ([[self.buyOrderBook objectAtIndex:0] isEqual:addOrderData]) {
            [self checkForBuyableOrder];
        }
        else {
            NSString *note = [NSString stringWithFormat:@"added buy order 'type: offer' at idx %tu (price: %@)"
                              , [self.buyOrderBook indexOfObject:addOrderData]
                              , addOrderData.orderInformation_price];
            [self informBuyDelegateWithNote:note];

        }
    }
}

- (void)removedOrderWithOrderID:(NSString *)orderID {
    [self removeOrderWithOrderID:orderID fromOrderBook:self.buyOrderBook];
    [self removeOrderWithOrderID:orderID fromOrderBook:self.sellOrderBook];
}

- (void)updateOrderWithSocketOrderObjectID:(NSString *)orderObjectID withValues:(NSDictionary *)changesDictionary {
    [self updateOrderWithSocketOrderObjectID:orderObjectID
                                 inOrderBook:self.buyOrderBook
                                  withValues:changesDictionary];

    [self updateOrderWithSocketOrderObjectID:orderObjectID
                                 inOrderBook:self.sellOrderBook
                                  withValues:changesDictionary];
}

#pragma mark | Socket helper methods
- (void)removeOrderWithOrderID:(NSString *)orderID fromOrderBook:(NSMutableArray *)orderBook {
    NSMutableArray *foundOrders = [NSMutableArray array];
    // check for orderbookData with correct orderID
    for (SOXShowOrderbookData *orderbookData in orderBook) {
        if ([orderbookData.orderInformation_orderID isEqualToString:orderID]) {
            [foundOrders addObject:orderbookData];
        }
    }

    // remove orderbookData from arrayController
    for (id foundOrder in foundOrders) {
        [orderBook removeObject:foundOrder];
    }
}

- (void)updateOrderWithSocketOrderObjectID:(NSString *)orderObjectID
                               inOrderBook:(NSMutableArray *)orderBook
                                withValues:(NSDictionary *)changesDictionary {
    for (SOXShowOrderbook_BitcoinDE_Data *orderbookData in orderBook) {
        if ([orderbookData.orderInformation_socketOrderObjectID isEqualToString:orderObjectID]) {
            // ist data object mit orderObjectID vorhanden? Ja: updaten!
            [orderbookData updateOrderbookDataWith:changesDictionary];
        }
    }
}

#pragma mark | Inform delegates

- (void)informBuyDelegateWithNote:(NSString *)note {
    if (note) {
        for (NSObject *delegate in self.buyDelegates) {
            [delegate performSelector:@selector(logLine:)
                           withObject:note
             ];
        }
    }
}
- (void)informSellDelegateWithNote:(NSString *)note {
    if (note) {
        for (NSObject *delegate in self.sellDelegates) {
            [delegate performSelector:@selector(logLine:)
                           withObject:note
             ];
        }
    }
}

@end
