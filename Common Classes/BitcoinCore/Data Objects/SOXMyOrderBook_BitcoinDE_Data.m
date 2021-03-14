//
//  SOXMyOrderBook_BitcoinDE_Data.m
//  BitcoinApp
//
//  Created by Peter Hauke on 27.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXMyOrderBook_BitcoinDE_Data.h"
#import "SOXMyOrderBook_BitcoinDE_Data_Private.h"

#import "SOXFormatters.h"
#import "SOXKeys_BitcoinDE.h"

#import "SOXMyTrades_BitcoinDE_Data.h"

@interface SOXMyOrderBook_BitcoinDE_Data ()

#pragma mark Properties
#pragma mark | Order Details
@property (strong, nonatomic, readwrite) NSString *orderInformation_orderID;
@property (strong, nonatomic, readwrite) NSString *orderInformation_type;
@property (strong, nonatomic, readwrite) NSString *orderInformation_tradingPair;
@property (nonatomic, readwrite) BitcoinDE_CurrencyType orderInformation_currencyType;
@property (strong, nonatomic, readwrite) NSDecimalNumber *orderInformation_maxAmount;
@property (strong, nonatomic, readwrite) NSDecimalNumber *orderInformation_minAmount;
@property (strong, nonatomic, readwrite) NSNumber *orderInformation_price;
@property (strong, nonatomic, readwrite) NSNumber *orderInformation_maxVolume;
@property (strong, nonatomic, readwrite) NSNumber *orderInformation_minVolume;
@property (strong, nonatomic, readwrite) NSDate *orderInformation_createdAt;
@property (strong, nonatomic, readwrite) NSDate *orderInformation_endDateTime;
@property (nonatomic, readwrite) BOOL orderInformation_newOrderForRemainingAmount;
@property (strong, nonatomic, readwrite) NSNumber *orderInformation_state;

#pragma mark | Order Requirements
@property (strong, nonatomic, readwrite) NSString *orderRequirements_minTrustLevel;
@property (nonatomic, readwrite) BOOL orderRequirements_onlyKYCFull;
@property (strong, nonatomic, readwrite) NSString *orderRequirements_paymentOption;
@property (strong, nonatomic, readwrite) NSArray *orderRequirements_seatOfBank;

#pragma mark | Page information
@property (strong, nonatomic, readwrite) NSNumber *page_current;
@property (strong, nonatomic, readwrite) NSNumber *page_last;

@end


@implementation SOXMyOrderBook_BitcoinDE_Data
@synthesize orderInformation_orderID, orderInformation_type, orderInformation_tradingPair, orderInformation_currencyType, orderInformation_maxAmount, orderInformation_minAmount, orderInformation_price, orderInformation_maxVolume, orderInformation_minVolume, orderInformation_createdAt, orderInformation_endDateTime, orderInformation_newOrderForRemainingAmount, orderInformation_state;
@synthesize orderRequirements_minTrustLevel, orderRequirements_onlyKYCFull, orderRequirements_paymentOption, orderRequirements_seatOfBank;
@synthesize page_current, page_last;

#pragma mark - OrderBook Object creation
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
                                                      newOrderID, BitcoinDE_ShowOrderbook_OrderID, nil];

    return myOrderBookData;
}


#pragma mark - Parameter methods
#pragma mark | Create new order
+ (NSDictionary *)parameterForNewOrderWithOrderType:(BitcoinDE_OrderType)orderType
                                       currencyType:(BitcoinDE_CurrencyType)currencyType
                                         max_amount:(NSNumber *)max_amount
                                         min_amount:(NSNumber *)min_amount
                                              price:(NSNumber *)price
                                       end_datetime:(NSDate *)end_datetime
                     new_order_for_remaining_amount:(BOOL)new_order_for_remaining_amount
                                    min_trust_level:(BitcoinDE_TrustLevel)min_trust_level
                                      only_kyc_full:(BOOL)only_kyc_full
                                     payment_option:(BitcoinDE_PaymentOption)payment_option
                                       seat_of_bank:(NSArray<NSString *> *)seat_of_bank {


    NSString *orderTypeString       = [SOXMarket_BitcoinDE_DefTypes orderTypeStringForOrderType:orderType];
    NSString *currencyTypeString    = [SOXMarket_BitcoinDE_DefTypes tradingPairStringForCurrencyType:currencyType];
    NSString *minTrustLevelAsString = [SOXMarket_BitcoinDE_DefTypes trustLevelStringForTrustLevel:min_trust_level];
    NSString *endDateString         = [SOXFormatters rfc3339DateTimeStringDate:end_datetime];

    NSDictionary *parameter = [NSDictionary dictionaryWithObjectsAndKeys:
                               orderTypeString, @"type",
                               currencyTypeString, BitcoinDE_ShowOrderbook_TradingPair,
                               max_amount, @"max_amount",
                               price, @"price",
                               min_amount, @"min_amount",
                               endDateString, @"end_datetime",
                               @(new_order_for_remaining_amount), @"new_order_for_remaining_amount",
                               minTrustLevelAsString, @"min_trust_level",
                               @(only_kyc_full), @"only_kyc_full",
                               //seat_of_bank , @"seat_of_bank"
                               nil];

    // only on order with type "sell" we can set paymentOption
    if (orderType == BitcoinDE_OrderTypeSell) {
        NSMutableDictionary *mutableParameter = [parameter mutableCopy];
        [mutableParameter setObject:@(payment_option) forKey:@"payment_option"];

        parameter = [mutableParameter copy];
    }
    return parameter;
}

#pragma mark | Delete Orders
+ (NSDictionary *)parameterForDeletingOrderWithOrderBookData:(SOXMyOrderBook_BitcoinDE_Data *)myOrderBookData {
    NSDictionary *parameter = [NSDictionary dictionaryWithObjectsAndKeys:
                                                myOrderBookData.orderInformation_orderID, BitcoinDE_ShowOrderbook_OrderID, myOrderBookData.orderInformation_tradingPair, BitcoinDE_ShowOrderbook_TradingPair, nil];

    return parameter;
}

+ (NSArray<NSDictionary *> *)parametersForDeletingMyOrderBookDatas:(NSArray<SOXMyOrderBook_BitcoinDE_Data *> *)myOrderBookDatas {
    NSMutableArray *parameters = [NSMutableArray array];
    for (SOXMyOrderBook_BitcoinDE_Data *myOrderBookData in myOrderBookDatas) {
        NSDictionary *parameter = [SOXMyOrderBook_BitcoinDE_Data parameterForDeletingOrderWithOrderBookData:myOrderBookData];
        [parameters addObject:parameter];
    }

    return [parameters copy];
}

+ (NSDictionary *)parameterForOrderType:(BitcoinDE_OrderType)orderType
                           currencyType:(BitcoinDE_CurrencyType)currencyType
                             orderState:(BitcoinDE_OrderStateType)orderState
                              startDate:(NSDate *)startDate
                                endDate:(NSDate *)endDate
                                   page:(NSInteger)page {
    NSString *orderTypeString;
    switch (orderType) {
        case BitcoinDE_OrderTypeBuy:
            orderTypeString = MyOrderBookParameter_OrderTypeBuyKey;
            break;
        case BitcoinDE_OrderTypeSell:
            orderTypeString = MyOrderBookParameter_OrderTypeSellKey;
        default:
            break;
    }

    NSString *currencyTypeString = [SOXMarket_BitcoinDE_DefTypes tradingPairStringForCurrencyType:currencyType];

    NSNumber *orderStateNumber;
    switch (orderState) {
        case BitcoinDE_OrderStateTypeUnknown:
        case BitcoinDE_OrderStateType_EndOfType:
            break;
        default:
            orderStateNumber = @(orderState);
            break;
    }

    NSString *startDateString = [SOXFormatters rfc3339DateTimeStringDate:startDate];
    NSString *endDateString   = [SOXFormatters rfc3339DateTimeStringDate:endDate];

    NSNumber *pageNumber = @(page);

    return [self parameterDictionaryForOrderType:orderTypeString
                                    currencyType:currencyTypeString
                                      orderState:orderStateNumber
                                       startDate:startDateString
                                         endDate:endDateString
                                            page:pageNumber];
}

+ (NSDictionary *)parameterDictionaryForOrderType:(NSString *)orderTypeString
                                     currencyType:(NSString *)currencyTypeString
                                       orderState:(NSNumber *)orderStateNumber
                                        startDate:(NSString *)startDateString
                                          endDate:(NSString *)endDateString
                                             page:(NSNumber *)pageNumber {
    NSMutableDictionary *parameterDictHelper = [NSMutableDictionary dictionary];

    if (orderTypeString) {
        [parameterDictHelper setObject:orderTypeString forKey:MyOrderBookParameter_OrderTypeKey];
    }

    if (currencyTypeString) {
        [parameterDictHelper setObject:currencyTypeString forKey:MyOrderBookParameter_CurrencyType];
    }

    if (orderStateNumber) {
        [parameterDictHelper setObject:orderStateNumber forKey:MyOrderBookParameter_OrderStateKey];
    }

    if (startDateString) {
        [parameterDictHelper setObject:startDateString forKey:MyOrderBookParameter_DateStartKey];
    }

    if (endDateString) {
        [parameterDictHelper setObject:endDateString forKey:MyOrderBookParameter_DateEndKey];
    }

    if (pageNumber) {
        [parameterDictHelper setObject:pageNumber forKey:MyOrderBookParameter_PageKey];
    }

    return [parameterDictHelper copy];
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
        self.orderInformation_orderID                    = [myOrderDictionary objectForKey:BitcoinDE_ShowMyOrders_OrderID];
        self.orderInformation_type                       = [myOrderDictionary objectForKey:BitcoinDE_ShowMyOrders_Type];
        self.orderInformation_tradingPair                = [myOrderDictionary objectForKey:BitcoinDE_ShowOrderbook_TradingPair];
        self.orderInformation_currencyType               = [SOXMarket_BitcoinDE_DefTypes currencyTypeForTradingPairString:self.orderInformation_tradingPair];
        self.orderInformation_maxAmount                  = [NSDecimalNumber decimalNumberWithString:[myOrderDictionary objectForKey:BitcoinDE_ShowMyOrders_MaxAmount]];
        self.orderInformation_minAmount                  = [NSDecimalNumber decimalNumberWithString:[myOrderDictionary objectForKey:BitcoinDE_ShowMyOrders_MinAmount]];
        self.orderInformation_price                      = [myOrderDictionary objectForKey:BitcoinDE_ShowMyOrders_Price];
        self.orderInformation_maxVolume                  = [myOrderDictionary objectForKey:BitcoinDE_ShowMyOrders_MaxVolume];
        self.orderInformation_minVolume                  = [myOrderDictionary objectForKey:BitcoinDE_ShowMyOrders_MinVolume];
        self.orderInformation_createdAt                  = [SOXFormatters dateForRFC3339DateTimeString:[myOrderDictionary objectForKey:BitcoinDE_ShowMyOrders_CreatedAt]];
        self.orderInformation_endDateTime                = [SOXFormatters dateForRFC3339DateTimeString:[myOrderDictionary objectForKey:BitcoinDE_ShowMyOrders_EndDateTime]];
        self.orderInformation_newOrderForRemainingAmount = [[myOrderDictionary objectForKey:BitcoinDE_ShowMyOrders_NewOrderForRemainingAmount] boolValue];
        self.orderInformation_state                      = [myOrderDictionary objectForKey:BitcoinDE_ShowMyOrders_State];
    }

    // Order Requirements
    {
        NSDictionary *orderRequirementsDictionary = [myOrderDictionary objectForKey:BitcoinDE_ShowOrderbook_OrderRequirements];
        self.orderRequirements_minTrustLevel      = [orderRequirementsDictionary objectForKey:BitcoinDE_ShowMyOrders_OrderRequirements_MinTrustLevel];
        self.orderRequirements_onlyKYCFull        = [[orderRequirementsDictionary objectForKey:BitcoinDE_ShowMyOrders_OrderRequirements_OnlyKYCFull] boolValue];
        self.orderRequirements_paymentOption      = [orderRequirementsDictionary objectForKey:BitcoinDE_ShowMyOrders_OrderRequirements_PaymentOption];
        self.orderRequirements_seatOfBank         = [orderRequirementsDictionary objectForKey:BitcoinDE_ShowMyOrders_OrderRequirements_SeatOfBank];
    }

    // Page information
    {
        self.page_current = [myOrderDictionary objectForKey:BitcoinDE_ShowMyOrders_Page_Current];
        self.page_last    = [myOrderDictionary objectForKey:BitcoinDE_ShowMyOrders_Page_Last];
    }
}

@end
