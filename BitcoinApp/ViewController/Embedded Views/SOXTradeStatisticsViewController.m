//
//  SOXTradeStatisticsViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 25.10.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXTradeStatisticsViewController.h"

#import "SOXAccountLedger_BitcoinDE_Data.h"
#import "SOXAccountLedger_BitcoinDE_Data_Private.h"

@interface SOXTradeStatisticsViewController ()
@property (strong) IBOutlet NSTextField *totalCountDescriptionTextField;
@property (strong) IBOutlet NSTextField *totalCountValueTextField;

@property (strong) IBOutlet NSTextField *selectedCountDescriptionTextField;
@property (strong) IBOutlet NSTextField *selectedCountValueTextField;

@property (strong) IBOutlet NSTextField *coinSumDescriptionTextField;
@property (strong) IBOutlet NSTextField *coinSumValueTextField;

@property (strong) IBOutlet NSTextField *volumeSumDescriptionTextField;
@property (strong) IBOutlet NSTextField *volumeSumValueTextField;

@end

@implementation SOXTradeStatisticsViewController

#pragma mark - Public Methods
- (void)updateInfosForArrangedObjects:(NSArray *)arrangedObjects
                  withSelectedObjects:(NSArray *)selectedObjects
                    forCurrencyString:(NSString *)currencyString {
    self.totalCountValueTextField.stringValue = [NSString stringWithFormat:@"%tu", arrangedObjects.count];
    self.selectedCountValueTextField.stringValue = [NSString stringWithFormat:@"%tu", selectedObjects.count];

    [self updateInfosForSelectedObjects:selectedObjects];

}

#pragma mark - Private Methods
- (void)updateInfosForSelectedObjects:(NSArray *)selectedObjects {
    id anyObject = selectedObjects.firstObject;
    if ([anyObject isKindOfClass:[SOXAccountLedger_BitcoinDE_Data class]]) {
        [self updateInfosForAccountLedgerDatas:selectedObjects];
    }
}

- (void)updateInfosForAccountLedgerDatas:(NSArray <SOXAccountLedger_BitcoinDE_Data *> *)accountLedgerDatas {
    NSDecimalNumber *coinSum = [NSDecimalNumber zero];
    NSDecimalNumber *volumeBuySum = [NSDecimalNumber zero];
    NSDecimalNumber *volumeSellSum = [NSDecimalNumber zero];
    NSDecimalNumber *feeVolumeSum = [NSDecimalNumber zero];
    for (SOXAccountLedger_BitcoinDE_Data *accountLedgerData in accountLedgerDatas) {
        NSLog(@"%@", accountLedgerData.tradeDetails_Euro_before_fee);
        NSLog(@"%@", accountLedgerData.tradeDetails_Euro_after_fee );
        NSLog(@"%@", accountLedgerData.positionDetails_Cashflow    );
        NSLog(@"%@", accountLedgerData.positionDetails_Type        );
        NSLog(@"--");


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

        }
//        else if (accountLedgerData.positionDetails_Type isEqualToString: BitcoinDE_AccountLedgerParameter_OutgoingFeeVoluntaryOrderTypeKey) {
//
//        }




/*
 tradeDetails_Euro_before_fee
 tradeDetails_Euro_after_fee
 positionDetails_Cashflow
 positionDetails_Type
 */
    }

    self.coinSumValueTextField.stringValue = coinSum.stringValue;
    NSDecimalNumber *winLostSum = [volumeSellSum decimalNumberBySubtracting:volumeBuySum];
    self.volumeSumValueTextField.stringValue = winLostSum.stringValue;

    self.selectedCountValueTextField.stringValue = feeVolumeSum.stringValue;

}
@end
