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
@synthesize orderInformation_orderID, orderInformation_type, orderInformation_maxAmount, orderInformation_minAmount, orderInformation_price, orderInformation_maxVolume, orderInformation_minVolume, orderInformation_orderRequirementsFullfilled;
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
        self.orderInformation_maxAmount                    = [orderDictionary objectForKey:BitcoinDE_ShowOrderbook_MaxAmount];
        self.orderInformation_minAmount                    = [orderDictionary objectForKey:BitcoinDE_ShowOrderbook_MinAmount];
        self.orderInformation_price                        = [orderDictionary objectForKey:BitcoinDE_ShowOrderbook_Price];
        self.orderInformation_maxVolume                    = [orderDictionary objectForKey:BitcoinDE_ShowOrderbook_MaxVolume];
        self.orderInformation_minVolume                    = [orderDictionary objectForKey:BitcoinDE_ShowOrderbook_MinVolume];
        self.orderInformation_orderRequirementsFullfilled  = [[orderDictionary objectForKey:BitcoinDE_ShowOrderbook_OrderRequirementsFullfilled] boolValue];
    }

    // Trading Partner Information
    {
        self.tradingPartnerInformation_username     = [orderDictionary objectForKey:BitcoinDE_ShowOrderbook_TradingPartnerInformation_Username];
        self.tradingPartnerInformation_isKYCFull    = [[orderDictionary objectForKey:BitcoinDE_ShowOrderbook_TradingPartnerInformation_IsKYCFull] boolValue];
        self.tradingPartnerInformation_trustLevel   = [orderDictionary objectForKey:BitcoinDE_ShowOrderbook_TradingPartnerInformation_TrustLevel];
        self.tradingPartnerInformation_bankName     = [orderDictionary objectForKey:BitcoinDE_ShowOrderbook_TradingPartnerInformation_BankName];
        self.tradingPartnerInformation_bic          = [orderDictionary objectForKey:BitcoinDE_ShowOrderbook_TradingPartnerInformation_BIC];
        self.tradingPartnerInformation_rating       = [orderDictionary objectForKey:BitcoinDE_ShowOrderbook_TradingPartnerInformation_Rating];
        self.tradingPartnerInformation_amountTrades = [orderDictionary objectForKey:BitcoinDE_ShowOrderbook_TradingPartnerInformation_AmountTrades];
    }
    
    // Order Requirements
    {
        self.orderRequirements_minTrustLevel = [orderDictionary objectForKey:BitcoinDE_ShowOrderbook_OrderRequirements_MinTrustLevel];
        self.orderRequirements_onlyKYCFull   = [[orderDictionary objectForKey:BitcoinDE_ShowOrderbook_OrderRequirements_OnlyKYCFull] boolValue];
        self.orderRequirements_seatOfBank    = [orderDictionary objectForKey:BitcoinDE_ShowOrderbook_OrderRequirements_SeatOfBank];
        self.orderRequirements_paymentOption = [orderDictionary objectForKey:BitcoinDE_ShowOrderbook_OrderRequirements_PaymentOptions];
    }
}

@end
