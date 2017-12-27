//
//  SOXAccountLedger_BitcoinDE_Data.m
//  BitcoinApp
//
//  Created by Peter Hauke on 28.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXAccountLedger_BitcoinDE_Data.h"

#import "SOXKeys_BitcoinDE.h"

#import "SOXFormatters.h"

static NSString *BitcoinDE_AccountLedgerParameter_AllOrderTypeKey = @"all";
static NSString *BitcoinDE_AccountLedgerParameter_BuyOrderTypeKey = @"buy";
static NSString *BitcoinDE_AccountLedgerParameter_SellOrderTypeKey = @"sell";
static NSString *BitcoinDE_AccountLedgerParameter_InpaymentOrderTypeKey = @"inpayment";
static NSString *BitcoinDE_AccountLedgerParameter_PayoutOrderTypeKey = @"payout";
static NSString *BitcoinDE_AccountLedgerParameter_AffiliateOrderTypeKey = @"affiliate";
static NSString *BitcoinDE_AccountLedgerParameter_WelcomeBTCOrderTypeKey = @"welcome_btc";
static NSString *BitcoinDE_AccountLedgerParameter_BuyYubiKeyOrderTypeKey = @"buy_yubikey";
static NSString *BitcoinDE_AccountLedgerParameter_BuyGoldshopOrderTypeKey = @"buy_goldshop";
static NSString *BitcoinDE_AccountLedgerParameter_BuyDiamondshopOrderTypeKey = @"buy_diamondshop";
static NSString *BitcoinDE_AccountLedgerParameter_KickbackOrderTypeKey = @"kickback";
static NSString *BitcoinDE_AccountLedgerParameter_OutgoingFeeVoluntaryOrderTypeKey = @"outgoing_fee_voluntary";

static NSString *AccountLedgerParameter_TypeKey         = @"type";
static NSString *AccountLedgerParameter_Currency        = @"currency";
static NSString *AccountLedgerParameter_DateStartKey    = @"datetime_start";
static NSString *AccountLedgerParameter_DateEndKey      = @"datetime_end";
static NSString *AccountLedgerParameter_PageKey         = @"page";

#pragma mark - Interface
@interface SOXAccountLedger_BitcoinDE_Data ()

#pragma mark Properties
@property (strong, nonatomic, readwrite) NSString *positionDetails_Date;
@property (strong, nonatomic, readwrite) NSString *positionDetails_Type;
@property (strong, nonatomic, readwrite) NSString *positionDetails_Reference;
@property (strong, nonatomic, readwrite) NSString *positionDetails_Cashflow;
@property (strong, nonatomic, readwrite) NSString *positionDetails_Balance;

@property (strong, nonatomic, readwrite) NSString *tradeDetails_Trade_id;
@property (strong, nonatomic, readwrite) NSString *tradeDetails_Price;
@property (strong, nonatomic, readwrite) NSString *tradeDetails_BTC_before_fee;
@property (strong, nonatomic, readwrite) NSString *tradeDetails_BTC_after_fee;
@property (strong, nonatomic, readwrite) NSString *tradeDetails_Euro_before_fee;
@property (strong, nonatomic, readwrite) NSString *tradeDetails_Euro_after_fee;

@end

#pragma mark - Implementation
@implementation SOXAccountLedger_BitcoinDE_Data

+ (NSMutableArray *)accountLedgerDataArrayForAccountLedgerDictionary:(NSDictionary *)payloadDictionary {
    NSMutableArray *accountLedgerDataArray = [NSMutableArray array];
    
    NSDictionary *accountLedgerDictionaries = [payloadDictionary objectForKey:BitcoinDE_ShowAccountLedger_Main];
    for (NSDictionary *aAccountLedgerDictionary in accountLedgerDictionaries) {
        [accountLedgerDataArray addObject:[self accountLedgerDataForAccountLedgerDictionary:aAccountLedgerDictionary]];
    }
    
    return accountLedgerDataArray;
}

+ (NSDictionary *)parameterForOrderType:(BitcoinDE_AccountLedgerParameter_OrderType)orderType
                        forCurrencyType:(BitcoinDE_CurrencyType)currencyType
                              startDate:(NSDate *)startDate
                                endDate:(NSDate *)endDate
                                   page:(NSInteger)page {
    NSString *orderTypeString = [self orderTypeStringForOrderType:orderType];

    NSString *currencyTypeString = [SOXMarket_BitcoinDE_DefTypes tradingPairShortStringForCurrencyType:currencyType];
    NSString *startDateString = [SOXFormatters rfc3339DateTimeStringDate:startDate];
    NSString *endDateString   = [SOXFormatters rfc3339DateTimeStringDate:endDate];
    
    NSNumber *pageNumber = @(page);
// DOKU Format gemäß RFC 3339 (Bsp: 2015-01-20T15:00:00+02:00)
    startDateString = @"2017-12-19T00:00:00"; //@"2017-10-06T00:00:00+02:00";
    endDateString   = @"2017-12-27T20:24:58Z"; // @"2017-12-12T00:00:00+02:00";

    NSDictionary *parameterDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   orderTypeString,       AccountLedgerParameter_TypeKey
                                   , currencyTypeString,  AccountLedgerParameter_Currency
//                                   , startDateString,     AccountLedgerParameter_DateStartKey
//                                   , endDateString,       AccountLedgerParameter_DateEndKey
                                   , pageNumber,          AccountLedgerParameter_PageKey
                                   , nil];
    
    return parameterDict;
}

+ (NSString *)titleForAccountLedgerOrderType:(BitcoinDE_AccountLedgerParameter_OrderType)orderType {
    static NSArray *titlesForAccountLedgerOrderType;

    static dispatch_once_t pred;

    dispatch_once(&pred, ^{
        titlesForAccountLedgerOrderType = @[@"Unknown"
                                            , @"All"
                                            , @"Buy"
                                            , @"Sell"
                                            , @"Inpayment"
                                            , @"Payout"
                                            , @"Affiliate"
                                            , @"Welcome btc"
                                            , @"Buy Yubikey"
                                            , @"Buy Goldshop"
                                            , @"Buy Diamondshop"
                                            , @"Kickback"
                                            , @"Outgoing_fee_voluntary"
                                            ];
    });
    
    NSString *titleForAccountLedgerOrderType = [titlesForAccountLedgerOrderType objectAtIndex:orderType];
    return titleForAccountLedgerOrderType;
}

#pragma mark - Private Class methods
+ (SOXAccountLedger_BitcoinDE_Data *)accountLedgerDataForAccountLedgerDictionary:(NSDictionary *)aAccountLedgerDictionary {
    SOXAccountLedger_BitcoinDE_Data *accountLedgerData = [[SOXAccountLedger_BitcoinDE_Data alloc] init];
    [accountLedgerData setupMyAccountLedgerDataForAccountLedgerDictionary:aAccountLedgerDictionary];
    
    return accountLedgerData;
}

+ (NSString *)orderTypeStringForOrderType:(BitcoinDE_AccountLedgerParameter_OrderType)orderType {
    NSString *orderTypeString = nil;
    switch (orderType) {
        case BitcoinDE_AccountLedgerParameter_AllOrderType:
            orderTypeString = BitcoinDE_AccountLedgerParameter_AllOrderTypeKey;
            break;
        case BitcoinDE_AccountLedgerParameter_BuyOrderType:
            orderTypeString = BitcoinDE_AccountLedgerParameter_BuyOrderTypeKey;
            break;
        case BitcoinDE_AccountLedgerParameter_SellOrderType:
            orderTypeString = BitcoinDE_AccountLedgerParameter_SellOrderTypeKey;
            break;
        case BitcoinDE_AccountLedgerParameter_InpaymentOrderType:
            orderTypeString = BitcoinDE_AccountLedgerParameter_InpaymentOrderTypeKey;
            break;
        case BitcoinDE_AccountLedgerParameter_PayoutOrderType:
            orderTypeString = BitcoinDE_AccountLedgerParameter_PayoutOrderTypeKey;
            break;
        case BitcoinDE_AccountLedgerParameter_AffiliateOrderType:
            orderTypeString = BitcoinDE_AccountLedgerParameter_AffiliateOrderTypeKey;
            break;
        case BitcoinDE_AccountLedgerParameter_WelcomeBTCOrderType:
            orderTypeString = BitcoinDE_AccountLedgerParameter_WelcomeBTCOrderTypeKey;
            break;
        case BitcoinDE_AccountLedgerParameter_BuyYubiKeyOrderType:
            orderTypeString = BitcoinDE_AccountLedgerParameter_BuyYubiKeyOrderTypeKey;
            break;
        case BitcoinDE_AccountLedgerParameter_BuyGoldshopOrderType:
            orderTypeString = BitcoinDE_AccountLedgerParameter_BuyGoldshopOrderTypeKey;
            break;
        case BitcoinDE_AccountLedgerParameter_BuyDiamondshopOrderType:
            orderTypeString = BitcoinDE_AccountLedgerParameter_BuyDiamondshopOrderTypeKey;
            break;
        case BitcoinDE_AccountLedgerParameter_KickbackOrderType:
            orderTypeString = BitcoinDE_AccountLedgerParameter_KickbackOrderTypeKey;
            break;
        case BitcoinDE_AccountLedgerParameter_OutgoingFeeVoluntaryOrderType:
            orderTypeString = BitcoinDE_AccountLedgerParameter_OutgoingFeeVoluntaryOrderTypeKey;
            break;
        default:
            DDLogInfo(@"Unknown BitcoinDE_AccountLedgerParameter_OrderType: %tu", orderType);
            break;
    };

    return orderTypeString;
}

#pragma mark - Instance methods
- (void)setupMyAccountLedgerDataForAccountLedgerDictionary:(NSDictionary *)aAccountLedgerDictionary {
    { // Ledger Position Details
        self.positionDetails_Date = [SOXFormatters stringDateTimeStringForRFC3339DateTimeString:[aAccountLedgerDictionary objectForKey:BitcoinDE_ShowAccountLedger_Date]];
        self.positionDetails_Type = [aAccountLedgerDictionary objectForKey:BitcoinDE_ShowAccountLedger_Type];
        self.positionDetails_Reference = [aAccountLedgerDictionary objectForKey:BitcoinDE_ShowAccountLedger_Reference];
        self.positionDetails_Cashflow = [aAccountLedgerDictionary objectForKey:BitcoinDE_ShowAccountLedger_Cashflow];
        self.positionDetails_Balance = [aAccountLedgerDictionary objectForKey:BitcoinDE_ShowAccountLedger_Balance];
    }
    
    { // Trade details
        NSDictionary *tradeDetails = [aAccountLedgerDictionary objectForKey:BitcoinDE_ShowAccountLedger_Trade];
        if (tradeDetails) {
            self.tradeDetails_Trade_id = [tradeDetails objectForKey:BitcoinDE_ShowAccountLedger_Trade_TradeID];
            self.tradeDetails_Price = [tradeDetails objectForKey:BitcoinDE_ShowAccountLedger_Trade_Price];
            NSDictionary *btcDetails = [tradeDetails objectForKey:BitcoinDE_ShowAccountLedger_Trade_BTC];
            self.tradeDetails_BTC_before_fee = [btcDetails objectForKey:BitcoinDE_ShowAccountLedger_Trade_BTC_BeforeFee];
            self.tradeDetails_BTC_after_fee = [btcDetails objectForKey:BitcoinDE_ShowAccountLedger_Trade_BTC_AfterFee];
            NSDictionary *euroDetails = [tradeDetails objectForKey:BitcoinDE_ShowAccountLedger_Trade_Euro];
            self.tradeDetails_Euro_before_fee = [euroDetails objectForKey:BitcoinDE_ShowAccountLedger_Trade_Euro_BeforeFee];
            self.tradeDetails_Euro_after_fee = [euroDetails objectForKey:BitcoinDE_ShowAccountLedger_Trade_BTC_AfterFee];
        }
    }
}

@end
