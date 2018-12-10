//
//  SOXAccountLedger_BitcoinDE_Data.m
//  BitcoinApp
//
//  Created by Peter Hauke on 28.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXAccountLedger_BitcoinDE_Data.h"
#import "SOXAbstractData_Private.h"
#import "SOXAccountLedger_BitcoinDE_Data_Private.h"

#import "SOXKeys_BitcoinDE.h"

#import "SOXFormatters.h"



static NSString *AccountLedgerParameter_TypeKey         = @"type";
static NSString *AccountLedgerParameter_Currency        = @"currency";
static NSString *AccountLedgerParameter_DateStartKey    = @"datetime_start";
static NSString *AccountLedgerParameter_DateEndKey      = @"datetime_end";
static NSString *AccountLedgerParameter_PageKey         = @"page";

#pragma mark - Interface
@interface SOXAccountLedger_BitcoinDE_Data ()

#pragma mark Properties
@property (strong, nonatomic, readwrite) NSDate *positionDetails_Date;
@property (strong, nonatomic, readwrite) NSString *positionDetails_Type;
@property (strong, nonatomic, readwrite) NSString *positionDetails_Reference;
@property (strong, nonatomic, readwrite) NSDecimalNumber *positionDetails_Cashflow;
@property (strong, nonatomic, readwrite) NSDecimalNumber *positionDetails_Balance;

@property (strong, nonatomic, readwrite) NSString *tradeDetails_Trade_id;
@property (strong, nonatomic, readwrite) NSDecimalNumber *tradeDetails_Price;
@property (strong, nonatomic, readwrite) NSDecimalNumber *tradeDetails_BTC_before_fee;
@property (strong, nonatomic, readwrite) NSDecimalNumber *tradeDetails_BTC_after_fee;
@property (strong, nonatomic, readwrite) NSDecimalNumber *tradeDetails_Euro_before_fee;
@property (strong, nonatomic, readwrite) NSDecimalNumber *tradeDetails_Euro_after_fee;
@property (strong, nonatomic, readwrite) NSString *tradeDetails_trading_pair;

@end

#pragma mark - Implementation
@implementation SOXAccountLedger_BitcoinDE_Data

+ (NSMutableArray *)accountLedgerDataArrayForAccountLedgerDictionary:(NSDictionary *)payloadDictionary
                                                     forCurrencyType:(BitcoinDE_CurrencyType)currencyType {
    NSMutableArray *accountLedgerDataArray = [NSMutableArray array];
    
    NSArray *accountLedgerDictionaries = [payloadDictionary objectForKey:BitcoinDE_ShowAccountLedger_Main];
    for (NSDictionary *aAccountLedgerDictionary in accountLedgerDictionaries) {
        [accountLedgerDataArray addObject:[self accountLedgerDataForAccountLedgerDictionary:aAccountLedgerDictionary
                                                                            forCurrencyType:currencyType]
         ];
    }
    
    return accountLedgerDataArray;
}

+ (NSDictionary *)parameterForOrderType:(BitcoinDE_AccountLedgerParameter_OrderType)orderType
                        forCurrencyType:(BitcoinDE_CurrencyType)currencyType
                              startDate:(NSDate *)startDate
                                endDate:(NSDate *)endDate
                                   page:(NSInteger)page {
    NSString *orderTypeString = [self orderTypeStringForOrderType:orderType];

    NSString *currencyTypeString = [SOXMarket_BitcoinDE_DefTypes tradingPairShortStringLowerCaseForCurrencyType:currencyType];
    NSNumber *pageNumber = @(page);

    NSString *startDateString = [SOXFormatters rfc3339PostDateTimeStringDate:startDate];

    // fix endDate for AccountLedger: must be younger than yesterday. API fuck up!!! (10.12.18;ph)
    endDate = [endDate earlierDate:[SOXFormatters dateBeforeMidnightForDate:[NSDate dateWithTimeIntervalSinceNow:-86400]]];
    NSString *endDateString   = [SOXFormatters rfc3339PostDateTimeStringDate:endDate];

    NSDictionary *parameterDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   orderTypeString,       AccountLedgerParameter_TypeKey
                                   , currencyTypeString,  AccountLedgerParameter_Currency
                                   , startDateString,     AccountLedgerParameter_DateStartKey
                                   , endDateString,       AccountLedgerParameter_DateEndKey
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
+ (SOXAccountLedger_BitcoinDE_Data *)accountLedgerDataForAccountLedgerDictionary:(NSDictionary *)aAccountLedgerDictionary
                                                                 forCurrencyType:(BitcoinDE_CurrencyType)currencyType {
    SOXAccountLedger_BitcoinDE_Data *accountLedgerData = [[SOXAccountLedger_BitcoinDE_Data alloc] init];
    [accountLedgerData setupMyAccountLedgerDataForAccountLedgerDictionary:aAccountLedgerDictionary
                                                          forCurrencyType:currencyType];
    
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
- (void)setupMyAccountLedgerDataForAccountLedgerDictionary:(NSDictionary *)aAccountLedgerDictionary
                                           forCurrencyType:(BitcoinDE_CurrencyType)currencyType {
    { // Ledger Position Details
        self.positionDetails_Date = [SOXFormatters dateForRFC3339DateTimeString:[aAccountLedgerDictionary objectForKey:BitcoinDE_ShowAccountLedger_Date]];
        self.positionDetails_Type = [aAccountLedgerDictionary objectForKey:BitcoinDE_ShowAccountLedger_Type];
        self.positionDetails_Reference = [aAccountLedgerDictionary objectForKey:BitcoinDE_ShowAccountLedger_Reference];
        self.positionDetails_Cashflow = [self convertToNumber:[aAccountLedgerDictionary objectForKey:BitcoinDE_ShowAccountLedger_Cashflow]];
        self.positionDetails_Balance = [self convertToNumber:[aAccountLedgerDictionary objectForKey:BitcoinDE_ShowAccountLedger_Balance]];
    }
    
    { // Trade details
        NSDictionary *tradeDetails = [aAccountLedgerDictionary objectForKey:BitcoinDE_ShowAccountLedger_Trade];
        if (tradeDetails) {
            self.tradeDetails_Trade_id = [tradeDetails objectForKey:BitcoinDE_ShowAccountLedger_Trade_TradeID];
            self.tradeDetails_Price = [self convertToNumber:[tradeDetails objectForKey:BitcoinDE_ShowAccountLedger_Trade_Price]];
            self.tradeDetails_trading_pair = [tradeDetails objectForKey:BitcoinDE_ShowAccountLedger_Trading_Pair];

            NSDictionary *btcDetails = [tradeDetails objectForKey:BitcoinDE_ShowAccountLedger_Trade_BTC];
            self.tradeDetails_BTC_before_fee = [self convertToNumber:[btcDetails objectForKey:BitcoinDE_ShowAccountLedger_Trade_BTC_BeforeFee]];
            self.tradeDetails_BTC_after_fee = [self convertToNumber:[btcDetails objectForKey:BitcoinDE_ShowAccountLedger_Trade_BTC_AfterFee]];

            NSDictionary *euroDetails = [tradeDetails objectForKey:BitcoinDE_ShowAccountLedger_Trade_Euro];
            self.tradeDetails_Euro_before_fee = [self convertToNumber:[euroDetails objectForKey:BitcoinDE_ShowAccountLedger_Trade_Euro_BeforeFee]];
            self.tradeDetails_Euro_after_fee = [self convertToNumber:[euroDetails objectForKey:BitcoinDE_ShowAccountLedger_Trade_BTC_AfterFee]];

        }
        else {
            self.tradeDetails_trading_pair = [SOXMarket_BitcoinDE_DefTypes tradingPairStringForCurrencyType:currencyType];
        }
    }
}

@end
