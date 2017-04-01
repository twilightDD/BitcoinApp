//
//  SOXShowOrderbook_BitcoinDE_Data.m
//  BitcoinApp
//
//  Created by Peter Hauke on 21.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXShowOrderbook_BitcoinDE_Data.h"

#import "SOXKeys_BitcoinDE.h"

#pragma mark - Interface
@interface SOXShowOrderbook_BitcoinDE_Data ()

#pragma mark Properties
#pragma mark | Order information
@property (strong, nonatomic, readwrite) NSString   *orderInformation_orderID;
@property (strong, nonatomic, readwrite) NSString   *orderInformation_socketOrderID;
@property (strong, nonatomic, readwrite) NSString   *orderInformation_type;
@property (strong, nonatomic, readwrite) NSNumber   *orderInformation_maxAmount;
@property (strong, nonatomic, readwrite) NSNumber   *orderInformation_minAmount;
@property (strong, nonatomic, readwrite) NSNumber   *orderInformation_price;
@property (strong, nonatomic, readwrite) NSNumber   *orderInformation_maxVolume;
@property (strong, nonatomic, readwrite) NSNumber   *orderInformation_minVolume;
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
@synthesize orderInformation_orderID, orderInformation_socketOrderID, orderInformation_type, orderInformation_maxAmount, orderInformation_minAmount, orderInformation_price, orderInformation_maxVolume, orderInformation_minVolume, orderInformation_orderRequirementsFullfilled;
@synthesize tradingPartnerInformation_username, tradingPartnerInformation_isKYCFull, tradingPartnerInformation_trustLevel, tradingPartnerInformation_bankName, tradingPartnerInformation_bic, tradingPartnerInformation_rating, tradingPartnerInformation_amountTrades;
@synthesize orderRequirements_minTrustLevel, orderRequirements_onlyKYCFull, orderRequirements_seatOfBank, orderRequirements_paymentOption;

#pragma mark - Init & Co.
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
    orderbookData.orderInformation_socketOrderID = [addOrderSocketIODictionary objectForKey:BitcoinDE_WebSocket_AddOrder_SocketObjectID];
    orderbookData.orderInformation_type = [addOrderSocketIODictionary objectForKey:BitcoinDE_ShowMyOrders_Type];
    orderbookData.orderInformation_maxAmount = @([[addOrderSocketIODictionary objectForKey:@"amount"] floatValue]);
    orderbookData.orderInformation_minAmount = @([[addOrderSocketIODictionary objectForKey:BitcoinDE_WebSocket_AddOrder_MinAmount] floatValue]);
    orderbookData.orderInformation_price = @([[addOrderSocketIODictionary objectForKey:BitcoinDE_WebSocket_AddOrder_Price] floatValue]);
    
    orderbookData.orderInformation_maxVolume = @(orderbookData.orderInformation_price.doubleValue * orderbookData.orderInformation_maxAmount.doubleValue);
    orderbookData.orderInformation_minVolume = @(orderbookData.orderInformation_price.doubleValue * orderbookData.orderInformation_minAmount.doubleValue);
    
    orderbookData.orderRequirements_minTrustLevel = [addOrderSocketIODictionary objectForKey:BitcoinDE_WebSocket_AddOrder_MinTustLevel];
    orderbookData.orderRequirements_onlyKYCFull = [[addOrderSocketIODictionary objectForKey:BitcoinDE_WebSocket_AddOrder_OnlyKYCFull] boolValue];
    orderbookData.orderRequirements_paymentOption = @([[addOrderSocketIODictionary objectForKey:BitcoinDE_WebSocket_AddOrder_PaymentOption] floatValue]);
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

#pragma mark - Class methods
+ (SOXShowOrderbookData *)orderbookDataForOrderDictionary:(NSDictionary *)orderDictionary {
    SOXShowOrderbook_BitcoinDE_Data *orderbookData = [[SOXShowOrderbook_BitcoinDE_Data alloc] init];
    [orderbookData setupOrderbookDataForOrderDictionary:orderDictionary];
     
    return orderbookData;
}

#pragma mark - Instance methods
- (void)setupOrderbookDataForOrderDictionary:(NSDictionary *)orderDictionary {
    // Order information
    {
        self.orderInformation_orderID                      = [orderDictionary objectForKey:BitcoinDE_ShowOrderbook_OrderID];
        self.orderInformation_type                         = [orderDictionary objectForKey:BitcoinDE_ShowOrderbook_Type];
        self.orderInformation_maxAmount                    = @([[orderDictionary objectForKey:BitcoinDE_ShowOrderbook_MaxAmount] floatValue]);
        self.orderInformation_minAmount                    = @([[orderDictionary objectForKey:BitcoinDE_ShowOrderbook_MinAmount] floatValue]);
        self.orderInformation_price                        = @([[orderDictionary objectForKey:BitcoinDE_ShowOrderbook_Price] floatValue]);
        self.orderInformation_maxVolume                    = @([[orderDictionary objectForKey:BitcoinDE_ShowOrderbook_MaxVolume] floatValue]);
        self.orderInformation_minVolume                    = @([[orderDictionary objectForKey:BitcoinDE_ShowOrderbook_MinVolume] floatValue]);
        self.orderInformation_orderRequirementsFullfilled  = [[orderDictionary objectForKey:BitcoinDE_ShowOrderbook_OrderRequirementsFullfilled] boolValue];
    }

    // Trading Partner Information
    {
        self.tradingPartnerInformation_username     = [orderDictionary objectForKey:BitcoinDE_ShowOrderbook_TradingPartnerInformation_Username];
        self.tradingPartnerInformation_isKYCFull    = [[orderDictionary objectForKey:BitcoinDE_ShowOrderbook_TradingPartnerInformation_IsKYCFull] boolValue];
        self.tradingPartnerInformation_trustLevel   = [orderDictionary objectForKey:BitcoinDE_ShowOrderbook_TradingPartnerInformation_TrustLevel];
        self.tradingPartnerInformation_bankName     = [orderDictionary objectForKey:BitcoinDE_ShowOrderbook_TradingPartnerInformation_BankName];
        self.tradingPartnerInformation_bic          = [orderDictionary objectForKey:BitcoinDE_ShowOrderbook_TradingPartnerInformation_BIC];
        self.tradingPartnerInformation_rating       = @([[orderDictionary objectForKey:BitcoinDE_ShowOrderbook_TradingPartnerInformation_Rating] floatValue]);
        self.tradingPartnerInformation_amountTrades = @([[orderDictionary objectForKey:BitcoinDE_ShowOrderbook_TradingPartnerInformation_AmountTrades] floatValue]);
    }
    
    // Order Requirements
    {
        self.orderRequirements_minTrustLevel = [orderDictionary objectForKey:BitcoinDE_ShowOrderbook_OrderRequirements_MinTrustLevel];
        self.orderRequirements_onlyKYCFull   = [[orderDictionary objectForKey:BitcoinDE_ShowOrderbook_OrderRequirements_OnlyKYCFull] boolValue];
        self.orderRequirements_seatOfBank    = [orderDictionary objectForKey:BitcoinDE_ShowOrderbook_OrderRequirements_SeatOfBank];
        self.orderRequirements_paymentOption = @([[orderDictionary objectForKey:BitcoinDE_ShowOrderbook_OrderRequirements_PaymentOptions] floatValue]);
    }
}

@end
