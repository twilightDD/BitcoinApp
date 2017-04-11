//
//  SOXMyOrderBook_BitcoinDE_Data.m
//  BitcoinApp
//
//  Created by Peter Hauke on 27.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXMyOrderBook_BitcoinDE_Data.h"

#import "SOXDateFormatter.h"
#import "SOXKeys_BitcoinDE.h"

@interface SOXMyOrderBook_BitcoinDE_Data()

#pragma mark Properties
#pragma mark | Order Details
@property (strong, nonatomic, readwrite) NSString *orderInformation_orderID;
@property (strong, nonatomic, readwrite) NSString *orderInformation_type;
@property (strong, nonatomic, readwrite) NSNumber *orderInformation_maxAmount;
@property (strong, nonatomic, readwrite) NSNumber *orderInformation_minAmount;
@property (strong, nonatomic, readwrite) NSNumber *orderInformation_price;
@property (strong, nonatomic, readwrite) NSNumber *orderInformation_maxVolume;
@property (strong, nonatomic, readwrite) NSNumber *orderInformation_minVolume;
@property (strong, nonatomic, readwrite) NSString *orderInformation_createdAt;
@property (strong, nonatomic, readwrite) NSString *orderInformation_endDateTime;
@property (nonatomic, readwrite)         BOOL     orderInformation_newOrderForRemainingAmount;
@property (strong, nonatomic, readwrite) NSNumber *orderInformation_state;

#pragma mark | Order Requirements
@property (strong, nonatomic, readwrite) NSString *orderRequirements_minTrustLevel;
@property (nonatomic, readwrite)         BOOL     orderRequirements_onlyKYCFull;
@property (strong, nonatomic, readwrite) NSString *orderRequirements_paymentOption;
@property (strong, nonatomic, readwrite) NSArray  *orderRequirements_seatOfBank;

#pragma mark | Page information
@property (strong, nonatomic, readwrite) NSNumber *page_current;
@property (strong, nonatomic, readwrite) NSNumber *page_last;

@end


@implementation SOXMyOrderBook_BitcoinDE_Data
@synthesize orderInformation_orderID, orderInformation_type, orderInformation_maxAmount, orderInformation_minAmount, orderInformation_price, orderInformation_maxVolume, orderInformation_minVolume, orderInformation_createdAt, orderInformation_endDateTime, orderInformation_newOrderForRemainingAmount, orderInformation_state;
@synthesize orderRequirements_minTrustLevel, orderRequirements_onlyKYCFull, orderRequirements_paymentOption, orderRequirements_seatOfBank;
@synthesize page_current, page_last;

+ (NSMutableArray *)myOrderbookDataArrayForMyOrderbookDictionary:(NSDictionary *)payloadDictionary {
    NSMutableArray *myOrderbookDataArray = [NSMutableArray array];
    
    NSDictionary *myOrderbookDictionary = [payloadDictionary objectForKey:BitcoinDE_ShowMyOrders_MainKey];
    for (NSDictionary *myOrderDictionary in myOrderbookDictionary) {
        [myOrderbookDataArray addObject:[self myOrderbookDataForOrderDictionary:myOrderDictionary]];
    }
    
    return myOrderbookDataArray;
}

+ (NSDictionary *)myOrderBookDataForCreateInfoDictionary:(NSDictionary *)payloadDictionary {
    NSString *newOrderID = [payloadDictionary objectForKey:BitcoinDE_ShowOrderbook_OrderID];
    
    NSDictionary *myOrderBookData = [NSDictionary dictionaryWithObjectsAndKeys:
                                     newOrderID, BitcoinDE_ShowOrderbook_OrderID
                                     ,nil];
    
    return myOrderBookData;
}

+ (NSArray <NSDictionary *> *)parametersForDeletingMyOrderBookDatas:(NSArray <SOXMyOrderBook_BitcoinDE_Data *>*)myOrderBookDatas {
    NSMutableArray *parameters = [NSMutableArray array];
    for (SOXMyOrderBook_BitcoinDE_Data *myOrderBookData in myOrderBookDatas) {
        NSString *myOrderbookDataOrderID = myOrderBookData.orderInformation_orderID;
        NSDictionary *parameter = [SOXMyOrderBook_BitcoinDE_Data parameterForDeletingOrderWithOrderID:myOrderbookDataOrderID];
        [parameters addObject:parameter];
    }
    
    return [parameters copy];
}

+ (NSDictionary *)parameterForDeletingOrderWithOrderID:(NSString *)orderID {
    NSDictionary *parameter = [NSDictionary dictionaryWithObjectsAndKeys:
                               orderID, @"order_id"
                               , nil];
    
    return parameter;
}

+ (NSDictionary *)parameterForNewOrderWithOrderType:(BitcoinDE_OrderType )type
                                         max_amount:(NSNumber *)max_amount
                                              price:(NSNumber *)price
                                         min_amount:(NSNumber *)min_amount
                                       end_datetime:(NSDate *)end_datetime
                     new_order_for_remaining_amount:(BOOL)new_order_for_remaining_amount
                                    min_trust_level:(BitcoinDE_MinimalTrustLevel )min_trust_level
                                      only_kyc_full:(BOOL)only_kyc_full
                                     payment_option:(BitcoinDE_PaymentOption )payment_option
                                       seat_of_bank:(NSArray <NSString *> *)seat_of_bank {
    
    // TODO: only for testing: @"sell"
    /* save values :
     @"sell", @"type"
     ,@(0.1) , @"max_amount"
     ,@(1500) , @"price"
     */
    NSString *typeString = @"sell";
    max_amount = @(0.1);
    min_amount = @(0.1);
    price = @(1500);
    
    
    
    // convert date
    NSString *endDateString = [SOXDateFormatter rfc3339DateTimeStringDate:end_datetime];
    
    NSDictionary *parameter = [NSDictionary dictionaryWithObjectsAndKeys:
                               typeString, @"type"
                               ,max_amount , @"max_amount"
                               ,price , @"price"
                               ,min_amount , @"min_amount"
                               //,endDateString , @"end_datetime"
                               ,@(new_order_for_remaining_amount) , @"new_order_for_remaining_amount"
                               ,@"gold" , @"min_trust_level"
                               ,@(only_kyc_full) , @"only_kyc_full"
                               ,@(payment_option) , @"payment_option"
//                               ,seat_of_bank , @"seat_of_bank"
                               , nil];

//    parameter = [NSDictionary dictionary];
    return parameter;
}

#pragma mark - Class methods
+ (SOXMyOrderBookData *)myOrderbookDataForOrderDictionary:(NSDictionary *)myOrderDictionary {
    SOXMyOrderBook_BitcoinDE_Data *myOrderbookData = [[SOXMyOrderBook_BitcoinDE_Data alloc] init];
    [myOrderbookData setupMyOrderbookDataForOrderDictionary:myOrderDictionary];
    
    return myOrderbookData;
}

#pragma mark - Instance methods
- (void)setupMyOrderbookDataForOrderDictionary:(NSDictionary *)myOrderDictionary {
    // Order information
    {
        self.orderInformation_orderID                       = [myOrderDictionary objectForKey:BitcoinDE_ShowMyOrders_OrderID];
        self.orderInformation_type                          = [myOrderDictionary objectForKey:BitcoinDE_ShowMyOrders_Type];
        self.orderInformation_maxAmount                     = [myOrderDictionary objectForKey:BitcoinDE_ShowMyOrders_MaxAmount];
        self.orderInformation_minAmount                     = [myOrderDictionary objectForKey:BitcoinDE_ShowMyOrders_MinAmount];
        self.orderInformation_price                         = [myOrderDictionary objectForKey:BitcoinDE_ShowMyOrders_Price];
        self.orderInformation_maxVolume                     = [myOrderDictionary objectForKey:BitcoinDE_ShowMyOrders_MaxVolume];
        self.orderInformation_minVolume                     = [myOrderDictionary objectForKey:BitcoinDE_ShowMyOrders_MinVolume];
        self.orderInformation_createdAt                     = [SOXDateFormatter stringDateTimeStringForRFC3339DateTimeString:[myOrderDictionary objectForKey:BitcoinDE_ShowMyOrders_CreatedAt]];
        self.orderInformation_endDateTime                   = [SOXDateFormatter stringDateTimeStringForRFC3339DateTimeString:[myOrderDictionary objectForKey:BitcoinDE_ShowMyOrders_EndDateTime]];
        self.orderInformation_newOrderForRemainingAmount    = [[myOrderDictionary objectForKey:BitcoinDE_ShowMyOrders_NewOrderForRemainingAmount] boolValue];
        self.orderInformation_state                         = [myOrderDictionary objectForKey:BitcoinDE_ShowMyOrders_State];
    }

    // Order Requirements
    {
        self.orderRequirements_minTrustLevel = [myOrderDictionary objectForKey:BitcoinDE_ShowMyOrders_OrderRequirements_MinTrustLevel];
        self.orderRequirements_onlyKYCFull   = [[myOrderDictionary objectForKey:BitcoinDE_ShowMyOrders_OrderRequirements_OnlyKYCFull] boolValue];
        self.orderRequirements_paymentOption = [myOrderDictionary objectForKey:BitcoinDE_ShowMyOrders_OrderRequirements_PaymentOption];
        self.orderRequirements_seatOfBank    = [myOrderDictionary objectForKey:BitcoinDE_ShowMyOrders_OrderRequirements_SeatOfBank];
    }
    
    // Page information
    {
        self.page_current = [myOrderDictionary objectForKey:BitcoinDE_ShowMyOrders_Page_Current];
        self.page_last    = [myOrderDictionary objectForKey:BitcoinDE_ShowMyOrders_Page_Last];
    }
}

@end
