//
//  SOXAccountLedger_BitcoinDE_StatisticData.m
//  BitcoinApp
//
//  Created by Peter Hauke on 05.12.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXAccountLedger_BitcoinDE_StatisticData.h"
#import "SOXAccountLedger_BitcoinDE_Data.h"
#import "SOXAccountLedger_BitcoinDE_Data_Private.h"

#import "SOXDataStatistics.h"
#import "SOXPageData.h"

#pragma mark -
@interface SOXAccountLedger_BitcoinDE_StatisticData ()

#pragma mark | Public Properties
@property (nonatomic, readwrite) BitcoinDE_CurrencyType currencyType;
@property (strong, nonatomic, readwrite) NSString *currencyName;
@property (strong, nonatomic, readwrite) NSDecimalNumber *coinSum;
@property (strong, nonatomic, readwrite) NSDecimalNumber *volumeBuySum;
@property (strong, nonatomic, readwrite) NSDecimalNumber *volumeSellSum;
@property (strong, nonatomic, readwrite) NSDecimalNumber *bitcoinFeeVolumeSum;
@property (strong, nonatomic, readwrite) NSDecimalNumber *cashFlowVolumeSum;
@property (strong, nonatomic, readwrite) NSDecimalNumber *fidorFeeVolumeSum;
@property (strong, nonatomic, readwrite) NSDecimalNumber *appFeeVolumeSum;
@property (strong, nonatomic, readwrite) NSDecimalNumber *incomeVolumeSum;
@property (strong, nonatomic, readwrite) NSDecimalNumber *kickbackSum;
@property (strong, nonatomic, readwrite) NSNumber *kickbackCount;
@property (strong, nonatomic, readwrite) NSMutableArray<SOXAccountLedger_BitcoinDE_Data *> *accountLedgerDatas;


@property (nonatomic, readwrite) NSInteger currentPage;
@property (nonatomic, readwrite) NSInteger lastPage;
@property (strong, nonatomic, readwrite) NSColor *textColor;

#pragma mark | Private Properties


@end

#pragma mark -
@implementation SOXAccountLedger_BitcoinDE_StatisticData

#pragma mark Init & Co.
- (instancetype)init {
    self = [super self];

    if (self) {
        _currencyName        = @"Sum";
        _volumeBuySum        = [NSDecimalNumber zero];
        _volumeSellSum       = [NSDecimalNumber zero];
        _bitcoinFeeVolumeSum = [NSDecimalNumber zero];
        _cashFlowVolumeSum   = [NSDecimalNumber zero];
        _fidorFeeVolumeSum   = [NSDecimalNumber zero];
        _appFeeVolumeSum     = [NSDecimalNumber zero];
        _incomeVolumeSum     = [NSDecimalNumber zero];
        _accountLedgerDatas  = [NSMutableArray array];

        _coinSum       = [NSDecimalNumber zero];
        _kickbackSum   = [NSDecimalNumber zero];
        _kickbackCount = 0;

        _state       = SOXStatisticData_StateType_New;
        _currentPage = 0;
        _lastPage    = 0;
    }

    return self;
}
- (instancetype)initWithCurrencyType:(BitcoinDE_CurrencyType)currencyType {
    self = [self init];

    if (self) {
        _currencyType = currencyType;
        _currencyName = [SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:currencyType];
    }

    return self;
}

#pragma mark - Public Methods
- (void)addAccountLedgerDatas:(NSMutableArray *)accountLedgerDatas {
    if (accountLedgerDatas.count > 0) {
        [self.accountLedgerDatas addObjectsFromArray:accountLedgerDatas];
    }
    [self updateProperties];
}

- (void)updatedWithPageData:(SOXPageData *)pageData {
    self.currentPage = pageData.pageCurrent;
    self.lastPage    = pageData.pageLast;
    if (pageData.pageCurrent == pageData.pageLast) {
        self.state = SOXStatisticData_StateType_FullyLoaded;
    }
}

#pragma mark - Private Methods
- (void)updateProperties {

    for (SOXAccountLedger_BitcoinDE_Data *accountLedgerData in self.accountLedgerDatas) {

        if ([accountLedgerData.positionDetails_Type isEqualToString:BitcoinDE_AccountLedgerParameter_AllOrderTypeKey]) {
        }
        else if ([accountLedgerData.positionDetails_Type isEqualToString:BitcoinDE_AccountLedgerParameter_BuyOrderTypeKey]) {
            self.coinSum             = [self.coinSum decimalNumberByAdding:accountLedgerData.positionDetails_Cashflow];
            self.volumeBuySum        = [self.volumeBuySum decimalNumberBySubtracting:accountLedgerData.tradeDetails_Euro_after_fee];
            NSDecimalNumber *fee     = [accountLedgerData.tradeDetails_Euro_before_fee decimalNumberBySubtracting:accountLedgerData.tradeDetails_Euro_after_fee];
            self.bitcoinFeeVolumeSum = [self.bitcoinFeeVolumeSum decimalNumberByAdding:fee];
        }
        else if ([accountLedgerData.positionDetails_Type isEqualToString:BitcoinDE_AccountLedgerParameter_SellOrderTypeKey]) {
            self.coinSum             = [self.coinSum decimalNumberByAdding:accountLedgerData.positionDetails_Cashflow];
            self.volumeSellSum       = [self.volumeSellSum decimalNumberByAdding:accountLedgerData.tradeDetails_Euro_after_fee];
            NSDecimalNumber *fee     = [accountLedgerData.tradeDetails_Euro_before_fee decimalNumberBySubtracting:accountLedgerData.tradeDetails_Euro_after_fee];
            self.bitcoinFeeVolumeSum = [self.bitcoinFeeVolumeSum decimalNumberByAdding:fee];
        }
        //        else if (accountLedgerData.positionDetails_Type isEqualToString: BitcoinDE_AccountLedgerParameter_InpaymentOrderTypeKey) {
        //
        //        }
        //        else if (accountLedgerData.positionDetails_Type isEqualToString: BitcoinDE_AccountLedgerParameter_PayoutOrderTypeKey) {
        //
        //        }
        //        else if (accountLedgerData.positionDetails_Type isEqualToString: BitcoinDE_AccountLedgerParameter_AffiliateOrderTypeKey) {
        //
        //        }
        //        else if (accountLedgerData.positionDetails_Type isEqualToString: BitcoinDE_AccountLedgerParameter_WelcomeBTCOrderTypeKey) {
        //
        //        }
        //        else if (accountLedgerData.positionDetails_Type isEqualToString: BitcoinDE_AccountLedgerParameter_BuyYubiKeyOrderTypeKey) {
        //
        //        }
        //        else if (accountLedgerData.positionDetails_Type isEqualToString: BitcoinDE_AccountLedgerParameter_BuyGoldshopOrderTypeKey) {
        //
        //        }
        //        else if (accountLedgerData.positionDetails_Type isEqualToString: BitcoinDE_AccountLedgerParameter_BuyDiamondshopOrderTypeKey) {
        //
        //        }
        else if ([accountLedgerData.positionDetails_Type isEqualToString:BitcoinDE_AccountLedgerParameter_KickbackOrderTypeKey]) {
            self.kickbackSum = [self.kickbackSum decimalNumberByAdding:accountLedgerData.positionDetails_Cashflow];
            self.kickbackCount = @(self.kickbackCount.integerValue + 1);
            //   [tradingPairs addObject:accountLedgerData.tradeDetails_trading_pair];
        }
        //        else if (accountLedgerData.positionDetails_Type isEqualToString: BitcoinDE_AccountLedgerParameter_OutgoingFeeVoluntaryOrderTypeKey) {
        //
        //        }
    }
    self.cashFlowVolumeSum = [self.volumeSellSum decimalNumberByAdding:self.volumeBuySum];


    //    self.coinSumValueTextField.stringValue = [SOXFormatters stringForBTCNumber:coinSum];
    //
    //    NSDecimalNumber *winLostSum = [volumeSellSum decimalNumberBySubtracting:volumeBuySum];
    //    self.volumeSumValueTextField.stringValue = [SOXFormatters currencyStringForNumber:winLostSum
    //                                                                         roundingMode:NSNumberFormatterRoundHalfUp];
    //
    //    self.feeSumValueTextField.stringValue = [SOXFormatters currencyStringForNumber:feeVolumeSum
    //                                                                      roundingMode:NSNumberFormatterRoundHalfUp];
    //
    //    if (tradingPairs.count > 1) {
    //        self.kickbackSumValueTextField.stringValue = @"[-]";
    //    }
    //    else {
    //        self.kickbackSumValueTextField.stringValue = [SOXFormatters stringForBTCNumber:kickbackSum];
    //    }
}

- (NSColor *)textColor {
    if (self.state == SOXStatisticData_StateType_FullyLoaded) {
        return [NSColor textColor];
    }
    else {
        return [NSColor lightGrayColor];
    }
}


@end
