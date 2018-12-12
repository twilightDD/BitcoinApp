//
//  SOXDataStatistics.m
//  BitcoinApp
//
//  Created by Peter Hauke on 05.12.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXDataStatistics.h"

#import "SOXAccountLedger_BitcoinDE_Data.h"
#import "SOXAccountLedger_BitcoinDE_Data_Private.h"

@implementation SOXDataStatistics

+ (NSDictionary *)statisticsForAccountLedgerDatas:(NSArray <SOXAccountLedger_BitcoinDE_Data *> *)accountLedgerDatas {
    NSDecimalNumber *coinSum = [NSDecimalNumber zero];
    NSDecimalNumber *volumeBuySum = [NSDecimalNumber zero];
    NSDecimalNumber *volumeSellSum = [NSDecimalNumber zero];
    NSDecimalNumber *feeVolumeSum = [NSDecimalNumber zero];
    NSDecimalNumber *kickbackSum = [NSDecimalNumber zero];
    NSInteger kickbackCount = 0;

    NSMutableSet *tradingPairs = [NSMutableSet set];
    for (SOXAccountLedger_BitcoinDE_Data *accountLedgerData in accountLedgerDatas) {

        if ([accountLedgerData.positionDetails_Type isEqualToString:BitcoinDE_AccountLedgerParameter_AllOrderTypeKey]) {

        }
        else if ([accountLedgerData.positionDetails_Type isEqualToString: BitcoinDE_AccountLedgerParameter_BuyOrderTypeKey]) {
            coinSum = [coinSum decimalNumberByAdding:accountLedgerData.positionDetails_Cashflow];
            volumeBuySum = [volumeBuySum decimalNumberByAdding:accountLedgerData.tradeDetails_Euro_after_fee];
            NSDecimalNumber *fee = [accountLedgerData.tradeDetails_Euro_before_fee decimalNumberBySubtracting:accountLedgerData.tradeDetails_Euro_after_fee];
            feeVolumeSum = [feeVolumeSum decimalNumberByAdding:fee];
        }
        else if ([accountLedgerData.positionDetails_Type isEqualToString: BitcoinDE_AccountLedgerParameter_SellOrderTypeKey]) {
            coinSum = [coinSum decimalNumberByAdding:accountLedgerData.positionDetails_Cashflow];
            volumeSellSum = [volumeSellSum decimalNumberByAdding:accountLedgerData.tradeDetails_Euro_after_fee];
            NSDecimalNumber *fee = [accountLedgerData.tradeDetails_Euro_before_fee decimalNumberBySubtracting:accountLedgerData.tradeDetails_Euro_after_fee];
            feeVolumeSum = [feeVolumeSum decimalNumberByAdding:fee];
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
        else if ([accountLedgerData.positionDetails_Type isEqualToString: BitcoinDE_AccountLedgerParameter_KickbackOrderTypeKey]) {
            kickbackSum = [kickbackSum decimalNumberByAdding:accountLedgerData.positionDetails_Cashflow];
            kickbackCount++;
         //   [tradingPairs addObject:accountLedgerData.tradeDetails_trading_pair];
        }
        //        else if (accountLedgerData.positionDetails_Type isEqualToString: BitcoinDE_AccountLedgerParameter_OutgoingFeeVoluntaryOrderTypeKey) {
        //
        //        }

    }
    NSDecimalNumber *winLostSum = [volumeSellSum decimalNumberBySubtracting:volumeBuySum];
    NSDictionary *statisticsDictionary;
    statisticsDictionary = @{@"coinSum" : coinSum,
                             @"volumeBuySum" : volumeBuySum,
                             @"winLostSum" : winLostSum,
                             @"feeVolumeSum" : feeVolumeSum,
                             @"kickbackSum" : kickbackSum,
                             @"kickbackCount" : @(kickbackCount)
                             };

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

    return statisticsDictionary;
}

@end
