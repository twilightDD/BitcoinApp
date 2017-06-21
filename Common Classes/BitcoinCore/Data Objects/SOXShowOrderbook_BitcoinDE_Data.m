//
//  SOXShowOrderbook_BitcoinDE_Data.m
//  BitcoinApp
//
//  Created by Peter Hauke on 21.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXShowOrderbook_BitcoinDE_Data.h"

#import "SOXKeys_BitcoinDE.h"
#import "SOXMarket_BitcoinDE_DefTypes.h"

#pragma mark - Interface
@interface SOXShowOrderbook_BitcoinDE_Data ()

#pragma mark Properties
#pragma mark | Order information
@property (strong, nonatomic, readwrite) NSString   *orderInformation_orderID;
@property (strong, nonatomic, readwrite) NSString   *orderInformation_socketOrderObjectID;
@property (strong, nonatomic, readwrite) NSString   *orderInformation_type;
@property (strong, nonatomic, readwrite) NSDecimalNumber   *orderInformation_maxAmount;
@property (strong, nonatomic, readwrite) NSDecimalNumber   *orderInformation_minAmount;
@property (strong, nonatomic, readwrite) NSDecimalNumber   *orderInformation_price;
@property (strong, nonatomic, readwrite) NSDecimalNumber   *orderInformation_maxVolume;
@property (strong, nonatomic, readwrite) NSDecimalNumber   *orderInformation_minVolume;
@property (nonatomic, readwrite)         BOOL       orderInformation_orderRequirementsFullfilled;

#pragma mark | Trading Partner Information
@property (strong, nonatomic, readwrite) NSString   *tradingPartnerInformation_username;
@property (nonatomic, readwrite)         BOOL       tradingPartnerInformation_isKYCFull;
@property (strong, nonatomic, readwrite) NSString   *tradingPartnerInformation_trustLevel;
@property (strong, nonatomic, readwrite) NSString   *tradingPartnerInformation_bankName;
@property (strong, nonatomic, readwrite) NSString   *tradingPartnerInformation_bic;
@property (strong, nonatomic, readwrite) NSNumber   *tradingPartnerInformation_rating;
@property (strong, nonatomic, readwrite) NSNumber   *tradingPartnerInformation_amountTrades;

#pragma mark | Order Requirements
@property (strong, nonatomic, readwrite) NSString   *orderRequirements_minTrustLevel;
@property (nonatomic, readwrite)         BOOL       orderRequirements_onlyKYCFull;
@property (strong, nonatomic, readwrite) NSArray    *orderRequirements_seatOfBank;
@property (strong, nonatomic, readwrite) NSNumber   *orderRequirements_paymentOption;

@end
#pragma mark - Implementation
@implementation SOXShowOrderbook_BitcoinDE_Data
#pragma mark Synthesize
@synthesize orderInformation_orderID, orderInformation_socketOrderObjectID, orderInformation_type, orderInformation_maxAmount, orderInformation_minAmount, orderInformation_price, orderInformation_maxVolume, orderInformation_minVolume, orderInformation_orderRequirementsFullfilled;
@synthesize tradingPartnerInformation_username, tradingPartnerInformation_isKYCFull, tradingPartnerInformation_trustLevel, tradingPartnerInformation_bankName, tradingPartnerInformation_bic, tradingPartnerInformation_rating, tradingPartnerInformation_amountTrades;
@synthesize orderRequirements_minTrustLevel, orderRequirements_onlyKYCFull, orderRequirements_seatOfBank, orderRequirements_paymentOption;


#pragma mark - Public Class methods
#pragma mark | Parameter dictionary
+ (NSDictionary *)parametersForAutoTradingForOrderType:(BitcoinDE_OrderType)orderType {
    NSString *orderTypeString = [SOXMarket_BitcoinDE_DefTypes orderTypeStringForOrderType:orderType];
    
    NSDictionary *parametersForAutoTrading = [NSDictionary dictionaryWithObjectsAndKeys:
                                               orderTypeString, BitcoinDE_ShowOrderbook_Type
                                              , nil];

    return parametersForAutoTrading;
}

+ (NSDictionary *)parametersForOrderType:(BitcoinDE_OrderType)orderType
                onlyExpressPaymentOption:(BOOL)onlyExpressPaymentOption {
    NSString *orderTypeString = [SOXMarket_BitcoinDE_DefTypes orderTypeStringForOrderType:orderType];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                orderTypeString, BitcoinDE_ShowOrderbook_Type
                                , @(onlyExpressPaymentOption), @"only_express_orders"
                                , nil];

    return parameters;
}

+ (NSDictionary *)parametersForOrderType:(BitcoinDE_OrderType)orderType
                           bitcoinAmount:(NSNumber *)bitcoinAmount
                                   price:(NSNumber *)price
             orderRequirementsFullfilled:(BOOL)orderRequirementsFullfilled
                             onlyKYCFull:(BOOL)onlyKYCFull
                onlyExpressPaymentOption:(BOOL)onlyExpressPaymentOption
                       onlySameBankGroup:(BOOL)onlySameBankGroup
                             onlySameBIC:(BOOL)onlySameBIC
                              seatOfBank:(NSArray *)seatsOfBank{

    NSString *orderTypeString = [SOXMarket_BitcoinDE_DefTypes orderTypeStringForOrderType:orderType];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                orderTypeString, BitcoinDE_ShowOrderbook_Type
                                , bitcoinAmount, @"amount"
                                , price, @"price"
                                , @(orderRequirementsFullfilled), @"order_requirements_fullfilled"
                                , @(onlyKYCFull), @"only_kyc_full"
                                , @(onlyExpressPaymentOption), @"only_express_orders"
                                , @(onlySameBankGroup), @"only_same_bankgroup"
                                , @(onlySameBIC), @"only_same_bic"
                                , seatsOfBank, @"seat_of_bank"
                                , nil];
    
    return parameters;
}

#pragma mark | OrderBookData
+ (NSMutableArray *)orderbookDataArrayForShowOrderbookDictionary:(NSDictionary *)payloadDictionary {
    NSMutableArray *orderbookDataArray = [NSMutableArray array];
    
    NSDictionary *orderbookDictionary = [payloadDictionary objectForKey:BitcoinDE_ShowOrderbook_MainKey];
    for (NSDictionary *orderDictionary in orderbookDictionary) {
        [orderbookDataArray addObject:[self orderbookDataForOrderDictionary:orderDictionary]];
    }
    
    return orderbookDataArray;
}

+ (instancetype)orderBookDataForSocketIODictionary:(NSDictionary *)addOrderSocketIODictionary {
    SOXShowOrderbook_BitcoinDE_Data *orderbookData = [[SOXShowOrderbook_BitcoinDE_Data alloc] init];
    orderbookData.orderInformation_orderID = [addOrderSocketIODictionary objectForKey:BitcoinDE_WebSocket_AddOrder_OrderID];
    orderbookData.orderInformation_socketOrderObjectID = [addOrderSocketIODictionary objectForKey:BitcoinDE_WebSocket_AddOrder_SocketObjectID];
    orderbookData.orderInformation_type = [addOrderSocketIODictionary objectForKey:BitcoinDE_ShowMyOrders_Type];
    orderbookData.orderInformation_maxAmount = [NSDecimalNumber decimalNumberWithDecimal:[[addOrderSocketIODictionary objectForKey:@"amount"] decimalValue]];
    orderbookData.orderInformation_minAmount = [NSDecimalNumber decimalNumberWithDecimal:[[addOrderSocketIODictionary objectForKey:BitcoinDE_WebSocket_AddOrder_MinAmount]  decimalValue]];
    orderbookData.orderInformation_price = [NSDecimalNumber decimalNumberWithDecimal:[[addOrderSocketIODictionary objectForKey:BitcoinDE_WebSocket_AddOrder_Price]  decimalValue]];
    
    orderbookData.orderInformation_maxVolume = [orderbookData.orderInformation_price decimalNumberByMultiplyingBy:orderbookData.orderInformation_maxAmount];
    orderbookData.orderInformation_minVolume = [orderbookData.orderInformation_price decimalNumberByMultiplyingBy:orderbookData.orderInformation_minAmount];
    
    orderbookData.orderRequirements_minTrustLevel = [addOrderSocketIODictionary objectForKey:BitcoinDE_WebSocket_AddOrder_MinTustLevel];
    orderbookData.orderRequirements_onlyKYCFull = [[addOrderSocketIODictionary objectForKey:BitcoinDE_WebSocket_AddOrder_OnlyKYCFull] boolValue];
    orderbookData.orderRequirements_paymentOption = @([[addOrderSocketIODictionary objectForKey:BitcoinDE_WebSocket_AddOrder_PaymentOption] doubleValue]);
//    orderbookData.orderRequirements_seatOfBank = [addOrderSocketIODictionary objectForKey:BitcoinDE_ShowMyOrders_OrderID];
    
    orderbookData.tradingPartnerInformation_isKYCFull = [[addOrderSocketIODictionary objectForKey:BitcoinDE_WebSocket_AddOrder_IsKYCFull] boolValue];
    orderbookData.tradingPartnerInformation_bic = [addOrderSocketIODictionary objectForKey:BitcoinDE_WebSocket_AddOrder_BICFull];
    
    return orderbookData;
//    orderbookData.trade_to_sepa_country
    
    /* add_order
     
     order_id
     order_type
     amount
     min_amount
     price
     min_trust_level
     only_kyc_full
     is_kyc_full
     seat_of_bank_of_creator
     bic_short
     bic_full
     trade_to_sepa_country
     payment_option
     */

}

+ (SOXShowOrderbookData *)orderbookDataForOrderDictionary:(NSDictionary *)orderDictionary {
    SOXShowOrderbook_BitcoinDE_Data *orderbookData = [[SOXShowOrderbook_BitcoinDE_Data alloc] init];
    [orderbookData setupOrderbookDataForOrderDictionary:orderDictionary];

    return orderbookData;
}

#pragma mark - Public instance methods
- (void)updateOrderbookDataWith:(NSDictionary *)changes {

    NSInteger is_trade_by_fidor_reservation_allowed = [[changes objectForKey:@"is_trade_by_fidor_reservation_allowed"] integerValue];
    NSInteger is_trade_by_sepa_allowed = [[changes objectForKey:@"is_trade_by_sepa_allowed"] integerValue];
    
    /* payment Option
     1 => Express-Only
     2 => SEPA-Only
     3 => Express & SEPA
     */
    NSInteger newPaymentOption = 0;
    
    {
        if (is_trade_by_fidor_reservation_allowed == 1
            && is_trade_by_sepa_allowed == 1) {
            newPaymentOption = 3;
        }
        else if (is_trade_by_fidor_reservation_allowed == 0
                 && is_trade_by_sepa_allowed == 1) {
            newPaymentOption = 2;
        }
        else if (is_trade_by_fidor_reservation_allowed == 1
                 && is_trade_by_sepa_allowed == 0) {
            newPaymentOption = 1;
        }
        else { // (is_trade_by_fidor_reservation_allowed == 0 && is_trade_by_sepa_allowed == 0)
            NSLog(@"Sollte nicht vorkommen");
        }
    }
    
    self.orderRequirements_paymentOption = @(newPaymentOption);
}

#pragma mark - Instance methods
- (void)setupOrderbookDataForOrderDictionary:(NSDictionary *)orderDictionary {
    // Order information
    {
        self.orderInformation_orderID                      = [orderDictionary objectForKey:BitcoinDE_ShowOrderbook_OrderID];
        self.orderInformation_type                         = [orderDictionary objectForKey:BitcoinDE_ShowOrderbook_Type];
        self.orderInformation_maxAmount                    = [NSDecimalNumber decimalNumberWithDecimal:[[orderDictionary objectForKey:BitcoinDE_ShowOrderbook_MaxAmount] decimalValue]];
        self.orderInformation_minAmount                    = [NSDecimalNumber decimalNumberWithDecimal:[[orderDictionary objectForKey:BitcoinDE_ShowOrderbook_MinAmount] decimalValue]];
        self.orderInformation_price                        = [NSDecimalNumber decimalNumberWithDecimal:[[orderDictionary objectForKey:BitcoinDE_ShowOrderbook_Price] decimalValue]];
        self.orderInformation_maxVolume                    = [NSDecimalNumber decimalNumberWithDecimal:[[orderDictionary objectForKey:BitcoinDE_ShowOrderbook_MaxVolume] decimalValue]];
        self.orderInformation_minVolume                    = [NSDecimalNumber decimalNumberWithDecimal:[[orderDictionary objectForKey:BitcoinDE_ShowOrderbook_MinVolume] decimalValue]];
        self.orderInformation_orderRequirementsFullfilled  = [[orderDictionary objectForKey:BitcoinDE_ShowOrderbook_OrderRequirementsFullfilled] boolValue];
    }

    // Trading Partner Information
    {
        NSDictionary *tradingPartnerInformation = [orderDictionary objectForKey:BitcoinDE_ShowOrderbook_TradingPartnerInformation];
        self.tradingPartnerInformation_username     = [tradingPartnerInformation objectForKey:BitcoinDE_ShowOrderbook_TradingPartnerInformation_Username];
        self.tradingPartnerInformation_isKYCFull    = [[tradingPartnerInformation objectForKey:BitcoinDE_ShowOrderbook_TradingPartnerInformation_IsKYCFull] boolValue];
        self.tradingPartnerInformation_trustLevel   = [tradingPartnerInformation objectForKey:BitcoinDE_ShowOrderbook_TradingPartnerInformation_TrustLevel];
        self.tradingPartnerInformation_bankName     = [tradingPartnerInformation objectForKey:BitcoinDE_ShowOrderbook_TradingPartnerInformation_BankName];
        self.tradingPartnerInformation_bic          = [tradingPartnerInformation objectForKey:BitcoinDE_ShowOrderbook_TradingPartnerInformation_BIC];
        self.tradingPartnerInformation_rating       = [tradingPartnerInformation objectForKey:BitcoinDE_ShowOrderbook_TradingPartnerInformation_Rating];
        self.tradingPartnerInformation_amountTrades = [tradingPartnerInformation objectForKey:BitcoinDE_ShowOrderbook_TradingPartnerInformation_AmountTrades];
    }
    
    // Order Requirements
    {
        NSDictionary *orderRequirements = [orderDictionary objectForKey:BitcoinDE_ShowOrderbook_OrderRequirements];
        self.orderRequirements_minTrustLevel = [orderRequirements objectForKey:BitcoinDE_ShowOrderbook_OrderRequirements_MinTrustLevel];
        self.orderRequirements_onlyKYCFull   = [[orderRequirements objectForKey:BitcoinDE_ShowOrderbook_OrderRequirements_OnlyKYCFull] boolValue];
        self.orderRequirements_seatOfBank    = [orderRequirements objectForKey:BitcoinDE_ShowOrderbook_OrderRequirements_SeatOfBank];
        self.orderRequirements_paymentOption = [orderRequirements objectForKey:BitcoinDE_ShowOrderbook_OrderRequirements_PaymentOptions];
    }
}

@end
