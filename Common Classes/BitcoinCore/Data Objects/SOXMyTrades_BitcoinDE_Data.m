//
//  SOXMyTrades_BitcoinDE_Data.m
//  BitcoinApp
//
//  Created by Peter Hauke on 03.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXMyTrades_BitcoinDE_Data.h"
#import "SOXMyTrades_BitcoinDE_Data_Private.h"
#import "SOXAbstractData_Private.h"

#import "SOXFormatters.h"
#import "SOXKeys_BitcoinDE.h"

@interface SOXMyTrades_BitcoinDE_Data () 

@property (strong, nonatomic, readwrite) NSString *tradeID;
@property (strong, nonatomic, readwrite) NSString *type;
@property (strong, nonatomic, readwrite) NSDecimalNumber *amount;
@property (strong, nonatomic, readwrite) NSDecimalNumber *price;
@property (strong, nonatomic, readwrite) NSDecimalNumber *volume;
@property (strong, nonatomic, readwrite) NSDecimalNumber *feeEur;
@property (strong, nonatomic, readwrite) NSDecimalNumber *feeBTC;
@property (strong, nonatomic, readwrite) NSString *aNewOrderIDForRemainingAmount;
@property (strong, nonatomic, readwrite) NSNumber *state;
@property (strong, nonatomic, readwrite) NSString *myRatingForTradingPartner;
@property (strong, nonatomic, readwrite) NSString *createdAt;
@property (strong, nonatomic, readwrite) NSDate *successfullyFinishedAt;
@property (strong, nonatomic, readwrite) NSString *cancelledAt;
@property (strong, nonatomic, readwrite) NSNumber *paymentMethod;
@property (strong, nonatomic, readwrite) NSString *trading_pair;

@property (strong, nonatomic, readwrite) NSString *tradingPartnerInfo_Username;
@property (nonatomic, readwrite)         BOOL      tradingPartnerInfo_IsKYCFull;
@property (strong, nonatomic, readwrite) NSString *tradingPartnerInfo_TrustLevel;
@property (strong, nonatomic, readwrite) NSString *tradingPartnerInfo_BankName;
@property (strong, nonatomic, readwrite) NSString *tradingPartnerInfo_BIC;
@property (strong, nonatomic, readwrite) NSString *tradingPartnerInfo_SeatOfBank;
@property (strong, nonatomic, readwrite) NSNumber *tradingPartnerInfo_amountTrades;
@property (strong, nonatomic, readwrite) NSNumber *tradingPartnerInfo_Rating;

@property (strong, nonatomic, readwrite) NSDecimalNumber *ownCalc_bookingVolume;
@property (strong, nonatomic, readwrite) NSDecimalNumber *ownCalc_fidorFee;
@end

@implementation SOXMyTrades_BitcoinDE_Data

+ (NSDictionary *)parameterForOrderType:(BitcoinDE_MyTradeHistoryParameter_OrderType)orderType
                             tradeState:(BitcoinDE_MyTradeHistoryParameter_TradeStateType)tradeState
                           currencyType:(BitcoinDE_CurrencyType)currencyType
                              startDate:(NSDate *)startDate
                                endDate:(NSDate *)endDate
                                   page:(NSInteger)page {

    NSString *orderTypeString;
    switch (orderType) {
        case BitcoinDE_MyTradeHistoryParameter_BuyOrderType:
            orderTypeString = MyTradeHistoryParameter_OrderTypeBuyKey;
            break;
        case BitcoinDE_MyTradeHistoryParameter_SellOrderType:
            orderTypeString = MyTradeHistoryParameter_OrderTypeSellKey;
        default:
            break;
    }
    
    NSNumber *tradeStateNumber;
    switch (tradeState) {
        case BitcoinDE_MyTradeHistoryParameter_CancelledTradeStateType:
            tradeStateNumber = @(-1);
            break;
        case BitcoinDE_MyTradeHistoryParameter_PendingTradeStateType:
            tradeStateNumber = @(0);
            break;
        case BitcoinDE_MyTradeHistoryParameter_SuccessfulTradeStateType:
            tradeStateNumber = @(1);
            break;
        default:
            break;
    }

    NSString *currencyTypeString = [SOXMarket_BitcoinDE_DefTypes tradingPairStringForCurrencyType:currencyType];

    NSString *startDateString = [SOXFormatters rfc3339GetDateTimeStringDate:startDate];
    NSString *endDateString   = [SOXFormatters rfc3339GetDateTimeStringDate:endDate];
    
    NSNumber *pageNumber = @(page);
    
    return [self parameterDictionaryForOrderType:orderTypeString
                                      tradeState:tradeStateNumber
                                    currencyType:currencyTypeString
                                       startDate:startDateString
                                         endDate:endDateString
                                            page:pageNumber];
}

+ (NSMutableArray *)myTradesDataArrayForMyTradeHistoryDictionary:(NSDictionary *)payloadDictionary {
    NSMutableArray *myTradesDataArray = [NSMutableArray array];
    
    NSDictionary *tradeDetailsDictionaries = [payloadDictionary objectForKey:BitcoinDE_ShowMyTrades_Trades_MainKey];
    for (NSDictionary *tradeDetailsDictionary in tradeDetailsDictionaries) {
        [myTradesDataArray addObject:[self myTradeDataFormyTradeHistoryDictionary:tradeDetailsDictionary]];
    }
    
    return myTradesDataArray;
}

+ (NSString *)titleForOrderType:(BitcoinDE_MyTradeHistoryParameter_OrderType)orderType {
    static NSArray *titlesForOrderType;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        titlesForOrderType = @[@"Unknown"
                               , @"All"
                               , @"Buy"
                               , @"Sell"
                               ];
    });

    NSString *titleForOrderType = [titlesForOrderType objectAtIndex:orderType];
    return titleForOrderType;
}

+ (NSString *)titleForTradeStateType:(BitcoinDE_MyTradeHistoryParameter_TradeStateType)tradeStateType {
    static NSArray *titlesForTradeStateType;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        titlesForTradeStateType = @[@"Unknown"
                                    , @"Successful"
                                    , @"Pending"
                                    , @"Cancelled"
                                    ];
    });

    NSString *titleForTradeStateType = [titlesForTradeStateType objectAtIndex:tradeStateType];
    return titleForTradeStateType;
}

+ (NSString *)titleForPaymentMethodType:(BitcoinDE_MyTradeHistoryParameter_PaymentMethodType)paymentMethodType {
    static NSArray *titlesForPaymentMethodType;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        titlesForPaymentMethodType = @[@"Unknown"
                                    , @"SEPA"
                                    , @"Express"
                                    ];
    });

    NSString *titleForPaymentMethodType = [titlesForPaymentMethodType objectAtIndex:paymentMethodType];
    return titleForPaymentMethodType;
}

#pragma mark | Pasteboard
+ (NSString *)pasteboardStringForTrades:(NSArray <SOXMyTrades_BitcoinDE_Data *> *)trades {

    /*
     Datum    OrderID    BTC bestellt    BTC (Zu/Abgang)    Kickback    Fehlersumme    €/BTC    Volumen        Summe    Ertrag    Ertrag pP.    Rate    Anmerkung*/

    NSString *pbString = @"";
    for (SOXMyTrades_BitcoinDE_Data *trade in trades) {
        BOOL isBuyTrade = [trade.type isEqualToString:MyTradeHistoryParameter_OrderTypeBuyKey];
        
        // Datum
        NSDate *date = trade.successfullyFinishedAt;
        pbString = [pbString stringByAppendingString:[SOXFormatters shortDateMediumTimeStringForDate:date]];
        pbString = [pbString stringByAppendingString:@"\t"];

        // OrderID
        pbString = [pbString stringByAppendingString:trade.tradeID];
        pbString = [pbString stringByAppendingString:@"\t"];

        // BTC bestellt
        NSString *amountString = [[SOXFormatters bitcoinNumberWithoutCurrencySymbolFormatter] stringFromNumber:trade.amount];
        if (isBuyTrade) {
            pbString = [pbString stringByAppendingString:amountString];
        }
        pbString = [pbString stringByAppendingString:@"\t"];

        // BTC Zu/Abgang
        if (isBuyTrade == NO) {
            pbString = [pbString stringByAppendingString:@"-"];
            pbString = [pbString stringByAppendingString:amountString];
        }
        pbString = [pbString stringByAppendingString:@"\t"];

        // Kickback
        pbString = [pbString stringByAppendingString:@"\t"];

        // Fehlersumme
        pbString = [pbString stringByAppendingString:@"\t"];

        // Preis (€/Coin)
        NSString *priceString = [SOXFormatters currencyStringForNumber:trade.price
                                                           roundingMode:NSNumberFormatterRoundHalfEven];
        pbString = [pbString stringByAppendingString:priceString];
        pbString = [pbString stringByAppendingString:@"\t"];

        // thats all
        pbString = [pbString stringByAppendingString:@"\n"];
    }

    return pbString;
}

#pragma mark - Private class methods
+ (NSDictionary *)parameterDictionaryForOrderType:(NSString *)orderTypeString
                                       tradeState:(NSNumber *)tradeStateNumber
                                     currencyType:(NSString *)currencyTypeString
                                        startDate:(NSString *)startDateString
                                          endDate:(NSString *)endDateString
                                             page:(NSNumber *)pageNumber {
    NSMutableDictionary *parameterDictHelper = [NSMutableDictionary dictionary];

    if (orderTypeString) {
        [parameterDictHelper setObject:orderTypeString forKey:MyTradeHistoryParameter_TypeKey];
    }

    if (tradeStateNumber) {
        [parameterDictHelper setObject:tradeStateNumber forKey:MyTradeHistoryParameter_StateKey];
    }

    if (currencyTypeString) {
        [parameterDictHelper setObject:currencyTypeString forKey:MyTradeHistoryParameter_TradingPair];
    }

    if (startDateString) {
        [parameterDictHelper setObject:startDateString forKey:MyTradeHistoryParameter_DateStartKey];
    }

    if (endDateString) {
        [parameterDictHelper setObject:endDateString forKey:MyTradeHistoryParameter_DateEndKey];
    }

    if (pageNumber) {
        [parameterDictHelper setObject:pageNumber forKey:MyTradeHistoryParameter_PageKey];
    }
    
    return [parameterDictHelper copy];
}

+ (SOXMyTrades_BitcoinDE_Data *)myTradeDataFormyTradeHistoryDictionary:(NSDictionary *)tradeDetailsDictionary {
    SOXMyTrades_BitcoinDE_Data *myTradeData = [[SOXMyTrades_BitcoinDE_Data alloc] init];
    [myTradeData setupMyTradeDataForTradeDetailsDictionary:tradeDetailsDictionary];
    
    return myTradeData;
}

#pragma mark - Private Instance methods
- (void)setupMyTradeDataForTradeDetailsDictionary:(NSDictionary *)tDD {
    // My Trade Details
    {
        self.tradeID                        = [tDD objectForKey:BitcoinDE_ShowMyTrades_TradeID];
        self.type                           = [tDD objectForKey:BitcoinDE_ShowMyTrades_Type];
        // amount
        NSDecimalNumber *showMyTrades_Amount = [self convertToNumber:[tDD objectForKey:BitcoinDE_ShowMyTrades_Amount]];
        if ([self.type isEqualToString:MyTradeHistoryParameter_OrderTypeSellKey]) {
            showMyTrades_Amount = [showMyTrades_Amount decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"-1"]];
        }
        self.amount                         = showMyTrades_Amount;
        self.price                          = [self convertToNumber:[tDD objectForKey:BitcoinDE_ShowMyTrades_Price]];

        NSDecimalNumber *volume = [self convertToNumber:[tDD objectForKey:BitcoinDE_ShowMyTrades_Volume]];
        if ([self.type isEqualToString:MyTradeHistoryParameter_OrderTypeBuyKey]) {
            volume = [volume decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"-1"]];
        }
        self.volume                         = volume;
        self.feeEur                         = [self convertToNumber:[tDD objectForKey:BitcoinDE_ShowMyTrades_FeeEur]];
        self.feeBTC                         = [self convertToNumber:[tDD objectForKey:BitcoinDE_ShowMyTrades_FeeBTC]];
        self.aNewOrderIDForRemainingAmount  = [tDD objectForKey:BitcoinDE_ShowMyTrades_NewOrderIDForRemainingAmount];
        self.state                          = [tDD objectForKey:BitcoinDE_ShowMyTrades_State];
        self.myRatingForTradingPartner      = [tDD objectForKey:BitcoinDE_ShowMyTrades_MyRatingForTradingPartner];
        self.createdAt                      = [SOXFormatters stringDateTimeStringForRFC3339DateTimeString:[tDD objectForKey:BitcoinDE_ShowMyTrades_CreatedAt]];
        self.successfullyFinishedAt         = [SOXFormatters dateForRFC3339DateTimeString:[tDD objectForKey:BitcoinDE_ShowMyTrades_SuccessfullyFinishedAt]];
        self.cancelledAt                    = [SOXFormatters stringDateTimeStringForRFC3339DateTimeString:[tDD objectForKey:BitcoinDE_ShowMyTrades_CancelledAt]];
        self.paymentMethod                  = [tDD objectForKey:BitcoinDE_ShowMyTrades_PaymentMethod];
        self.trading_pair                   = [tDD objectForKey:BitcoinDE_ShowMyTrades_TradingPair];
    }
    
    // Trading Partner Information
    {
        NSDictionary *tPI = [tDD objectForKey:BitcoinDE_ShowMyTrades_TradingPartnerInformation];
        self.tradingPartnerInfo_Username        = [tPI objectForKey:BitcoinDE_ShowMyTrades_TradingPartnerInformation_Username];
        self.tradingPartnerInfo_IsKYCFull       = [[tPI objectForKey:BitcoinDE_ShowMyTrades_TradingPartnerInformation_IsKYCFull] boolValue];
        self.tradingPartnerInfo_TrustLevel      = [tPI objectForKey:BitcoinDE_ShowMyTrades_TradingPartnerInformation_TrustLevel];
        self.tradingPartnerInfo_BankName        = [tPI objectForKey:BitcoinDE_ShowMyTrades_TradingPartnerInformation_BankName];
        self.tradingPartnerInfo_BIC             = [tPI objectForKey:BitcoinDE_ShowMyTrades_TradingPartnerInformation_BIC];
        self.tradingPartnerInfo_SeatOfBank      = [tPI objectForKey:BitcoinDE_ShowMyTrades_TradingPartnerInformation_SeatOfBank];
        self.tradingPartnerInfo_amountTrades    = [tPI objectForKey:BitcoinDE_ShowMyTrades_TradingPartnerInformation_AmountTrades];
        self.tradingPartnerInfo_Rating          = [tPI objectForKey:BitcoinDE_ShowMyTrades_TradingPartnerInformation_Rating];
    }

    // Own calculations
    NSDecimalNumber *feeFaktor = [NSDecimalNumber decimalNumberWithString:@"0.996"];
    NSDecimalNumber *volumeSelf = [self.amount decimalNumberByMultiplyingBy:self.price];
//    NSLog(@"amount * price = %@ * %@ = %@"
//          , self.amount
//          , self.price
//          , volumeSelf);
    NSDecimalNumber *volumeSelfMinusFee = [volumeSelf decimalNumberByMultiplyingBy:feeFaktor];
//    NSLog(@"volumeSelf - fee = %@ * %@ = %@"
//          , volumeSelf
//          , feeFaktor
//          , volumeSelfMinusFee);
    NSDecimalNumber *volumeSelfRounded;
    if ([self.type isEqualToString:MyTradeHistoryParameter_OrderTypeBuyKey]) {
          volumeSelfRounded = [volumeSelfMinusFee decimalNumberByRoundingAccordingToBehavior:[SOXFormatters currencyNumberHandlerRoundDown]];
    }
    else {
        volumeSelfRounded = [volumeSelfMinusFee decimalNumberByRoundingAccordingToBehavior:[SOXFormatters currencyNumberHandlerRoundUp]];
    }
    volumeSelfRounded = [volumeSelfRounded decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"-1"]];
    self.ownCalc_bookingVolume = volumeSelfRounded;
//    NSLog(@"volumeSelfMinusFee rounded down: %@ -> %@"
//          , volumeSelfMinusFee
//          , self.ownCalc_bookingVolume);


    if (self.paymentMethod.unsignedIntegerValue == BitcoinDE_MyTradeHistoryParameter_ExpressPaymentMethodType) {
        self.ownCalc_fidorFee = [self.feeEur decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"4"]
                                                          withBehavior:[SOXFormatters currencyNumberHandlerRoundDown]];
    }
    else {
        self.ownCalc_fidorFee = [NSDecimalNumber zero];
    }


    NSLog(@"tradeID: %@, vol %@, fee %@ (%@), ownBookVol %@"
          , self.tradeID
          , self.volume
          , self.feeEur
          , [tDD objectForKey:BitcoinDE_ShowMyTrades_FeeEur]
          , self.ownCalc_bookingVolume);

}



@end
