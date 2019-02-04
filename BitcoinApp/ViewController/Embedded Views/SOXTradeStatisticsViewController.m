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
#import "SOXMyOrderBook_BitcoinDE_Data.h"
#import "SOXMyOrderBook_BitcoinDE_Data_Private.h"
#import "SOXMyTrades_BitcoinDE_Data.h"
#import "SOXMyTrades_BitcoinDE_Data_Private.h"


#import "SOXFormatters.h"

@interface SOXTradeStatisticsViewController ()
// first stack
@property (strong) IBOutlet NSTextField *coinSumDescriptionTextField;
@property (strong) IBOutlet NSTextField *coinSumValueTextField;
@property (strong) IBOutlet NSTextField *kickbackSumDescriptionTextField;
@property (strong) IBOutlet NSTextField *kickbackSumValueTextField;

// second stack
@property (strong) IBOutlet NSTextField *volumeSumDescriptionTextField;
@property (strong) IBOutlet NSTextField *volumeSumValueTextField;
@property (strong) IBOutlet NSTextField *volumeAfterFeeDescriptionTextField;
@property (strong) IBOutlet NSTextField *volumeAfterFeeSumValueTextField;

// third stack
@property (strong) IBOutlet NSTextField *feeSumDescriptionTextField;
@property (strong) IBOutlet NSTextField *feeSumValueTextField;
@property (strong) IBOutlet NSTextField *feeFidorSumDescriptionTextField;
@property (strong) IBOutlet NSTextField *feeFidorSumValueTextField;

// fourth stack
@property (strong) IBOutlet NSTextField *entryCountTextField;

@end

@implementation SOXTradeStatisticsViewController
#pragma mark Init & Co.
- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
}

- (void)setupUI {
    // First stack
    self.coinSumDescriptionTextField.stringValue     = @"Coin balance:";
    self.coinSumValueTextField.stringValue           = @"[-]";
    self.kickbackSumDescriptionTextField.stringValue = @"Kickbacks:";
    self.kickbackSumValueTextField.stringValue       = @"[-]";

    // second stack
    self.volumeSumDescriptionTextField.stringValue      = @"Volume balance after Bitcoin fee:";
    self.volumeSumValueTextField.stringValue            = @"[-]";
    self.volumeAfterFeeDescriptionTextField.stringValue = @"Volume balance after Fidor fee:";
    self.volumeAfterFeeSumValueTextField.stringValue    = @"[-]";

    // third stack
    self.feeSumDescriptionTextField.stringValue      = @"Bitcoin fees:";
    self.feeSumValueTextField.stringValue            = @"[-]";
    self.feeFidorSumDescriptionTextField.stringValue = @"Fidor fees:";
    self.feeFidorSumValueTextField.stringValue       = @"[-]";

    // fourth stack
    self.entryCountTextField.stringValue = @"-/-";
}

#pragma mark - Public Methods
- (void)updateInfosForArrangedObjects:(NSArray *)arrangedObjects
                  withSelectedObjects:(NSArray *)selectedObjects
                    forCurrencyString:(NSString *)currencyString {
    self.entryCountTextField.stringValue = [NSString stringWithFormat:@"%tu/%tu", selectedObjects.count, arrangedObjects.count];

    [self updateInfosForSelectedObjects:selectedObjects];
}

#pragma mark - Private Methods
- (void)updateInfosForSelectedObjects:(NSArray *)selectedObjects {
    id anyObject = selectedObjects.firstObject;
    if ([anyObject isKindOfClass:[SOXAccountLedger_BitcoinDE_Data class]]) {
        [self updateInfosForAccountLedgerDatas:selectedObjects];
    }
    else if ([anyObject isKindOfClass:[SOXMyOrderBook_BitcoinDE_Data class]]) {
        [self updateInfosForMyOrderBookDatas:selectedObjects];
    }
    else if ([anyObject isKindOfClass:[SOXMyTrades_BitcoinDE_Data class]]) {
        [self updateInfosForMyTradesDatas:selectedObjects];
    }
    else {
        [self setupUI];
    }
}

- (void)updateInfosForAccountLedgerDatas:(NSArray<SOXAccountLedger_BitcoinDE_Data *> *)accountLedgerDatas {
    NSDecimalNumber *coinSum       = [NSDecimalNumber zero];
    NSDecimalNumber *volumeBuySum  = [NSDecimalNumber zero];
    NSDecimalNumber *volumeSellSum = [NSDecimalNumber zero];
    NSDecimalNumber *feeVolumeSum  = [NSDecimalNumber zero];
    NSDecimalNumber *kickbackSum   = [NSDecimalNumber zero];

    NSMutableSet *tradingPairs = [NSMutableSet set];
    for (SOXAccountLedger_BitcoinDE_Data *accountLedgerData in accountLedgerDatas) {

        if ([accountLedgerData.positionDetails_Type isEqualToString:BitcoinDE_AccountLedgerParameter_AllOrderTypeKey]) {
        }
        else if ([accountLedgerData.positionDetails_Type isEqualToString:BitcoinDE_AccountLedgerParameter_BuyOrderTypeKey]) {
            coinSum              = [coinSum decimalNumberByAdding:accountLedgerData.positionDetails_Cashflow];
            volumeBuySum         = [volumeBuySum decimalNumberByAdding:accountLedgerData.tradeDetails_Euro_after_fee];
            NSDecimalNumber *fee = [accountLedgerData.tradeDetails_Euro_before_fee decimalNumberBySubtracting:accountLedgerData.tradeDetails_Euro_after_fee];
            feeVolumeSum         = [feeVolumeSum decimalNumberByAdding:fee];
        }
        else if ([accountLedgerData.positionDetails_Type isEqualToString:BitcoinDE_AccountLedgerParameter_SellOrderTypeKey]) {
            coinSum              = [coinSum decimalNumberByAdding:accountLedgerData.positionDetails_Cashflow];
            volumeSellSum        = [volumeSellSum decimalNumberByAdding:accountLedgerData.tradeDetails_Euro_after_fee];
            NSDecimalNumber *fee = [accountLedgerData.tradeDetails_Euro_before_fee decimalNumberBySubtracting:accountLedgerData.tradeDetails_Euro_after_fee];
            feeVolumeSum         = [feeVolumeSum decimalNumberByAdding:fee];
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
            kickbackSum = [kickbackSum decimalNumberByAdding:accountLedgerData.positionDetails_Cashflow];
            [tradingPairs addObject:accountLedgerData.tradeDetails_trading_pair];
        }
        //        else if (accountLedgerData.positionDetails_Type isEqualToString: BitcoinDE_AccountLedgerParameter_OutgoingFeeVoluntaryOrderTypeKey) {
        //
        //        }
    }

    self.coinSumValueTextField.stringValue = [SOXFormatters stringForBTCNumber:coinSum];

    NSDecimalNumber *winLostSum              = [volumeSellSum decimalNumberBySubtracting:volumeBuySum];
    self.volumeSumValueTextField.stringValue = [SOXFormatters currencyStringForNumber:winLostSum
                                                                         roundingMode:NSNumberFormatterRoundHalfUp];

    self.feeSumValueTextField.stringValue = [SOXFormatters currencyStringForNumber:feeVolumeSum
                                                                      roundingMode:NSNumberFormatterRoundHalfUp];

    if (tradingPairs.count > 1) {
        self.kickbackSumValueTextField.stringValue = @"[-]";
    }
    else {
        self.kickbackSumValueTextField.stringValue = [SOXFormatters stringForBTCNumber:kickbackSum];
    }
}

- (void)updateInfosForMyOrderBookDatas:(NSArray<SOXMyOrderBook_BitcoinDE_Data *> *)myOrderBookDatas {
    /*
     orderInformation_maxAmount
     orderInformation_maxVolume

     orderInformation_type
     orderInformation_currencyType
     */
    NSDecimalNumber *coinSum       = [NSDecimalNumber zero];
    NSDecimalNumber *volumeBuySum  = [NSDecimalNumber zero];
    NSDecimalNumber *volumeSellSum = [NSDecimalNumber zero];
    NSMutableSet *currencyTypes    = [NSMutableSet set];
    for (SOXMyOrderBook_BitcoinDE_Data *myOrderBookData in myOrderBookDatas) {
        if ([myOrderBookData.orderInformation_type isEqualToString:MyOrderBookParameter_OrderTypeBuyKey]) {
            coinSum      = [coinSum decimalNumberByAdding:[NSDecimalNumber decimalNumberWithDecimal:myOrderBookData.orderInformation_maxAmount.decimalValue]];
            volumeBuySum = [volumeBuySum decimalNumberByAdding:[NSDecimalNumber decimalNumberWithDecimal:myOrderBookData.orderInformation_maxVolume.decimalValue]];
            [currencyTypes addObject:@(myOrderBookData.orderInformation_currencyType)];
        }
        else if ([myOrderBookData.orderInformation_type isEqualToString:MyOrderBookParameter_OrderTypeSellKey]) {
            coinSum       = [coinSum decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithDecimal:myOrderBookData.orderInformation_maxAmount.decimalValue]];
            volumeSellSum = [volumeSellSum decimalNumberByAdding:[NSDecimalNumber decimalNumberWithDecimal:myOrderBookData.orderInformation_maxVolume.decimalValue]];
            [currencyTypes addObject:@(myOrderBookData.orderInformation_currencyType)];
        }
    }

    if (currencyTypes.count > 1) {
        self.coinSumValueTextField.stringValue = @"[-]";
    }
    else {
        self.coinSumValueTextField.stringValue = [SOXFormatters stringForBTCNumber:coinSum];
    }

    NSDecimalNumber *winLostSum              = [volumeSellSum decimalNumberBySubtracting:volumeBuySum];
    self.volumeSumValueTextField.stringValue = [SOXFormatters currencyStringForNumber:winLostSum
                                                                         roundingMode:NSNumberFormatterRoundHalfUp];
}

- (void)updateInfosForMyTradesDatas:(NSArray<SOXMyTrades_BitcoinDE_Data *> *)myTradeDatas {
    /*
     amount
     volume
     feeEur
     */
    NSDecimalNumber *coinSum             = [NSDecimalNumber zero];
    NSDecimalNumber *volumeSum           = [NSDecimalNumber zero];
    NSDecimalNumber *feeBitcoinVolumeSum = [NSDecimalNumber zero];
    NSDecimalNumber *feeFidorVolumeSum   = [NSDecimalNumber zero];

    NSMutableSet *tradingPairs = [NSMutableSet set];

    for (SOXMyTrades_BitcoinDE_Data *myTradeData in myTradeDatas) {
        coinSum             = [coinSum decimalNumberByAdding:myTradeData.amount];
        volumeSum           = [volumeSum decimalNumberByAdding:myTradeData.ownCalc_bookingVolume];
        feeBitcoinVolumeSum = [feeBitcoinVolumeSum decimalNumberByAdding:myTradeData.feeEur];
        feeFidorVolumeSum   = [feeFidorVolumeSum decimalNumberByAdding:myTradeData.ownCalc_fidorFee];
        [tradingPairs addObject:myTradeData.trading_pair];
    }
    if (tradingPairs.count > 1) {
        self.coinSumValueTextField.stringValue = @"[-]";
    }
    else {
        self.coinSumValueTextField.stringValue = [SOXFormatters stringForBTCNumber:coinSum];
    }


    self.volumeSumValueTextField.stringValue         = [SOXFormatters currencyStringForNumber:volumeSum
                                                                         roundingMode:NSNumberFormatterRoundHalfUp];
    NSDecimalNumber *volumeAfterFeeSum               = [volumeSum decimalNumberBySubtracting:feeFidorVolumeSum];
    self.volumeAfterFeeSumValueTextField.stringValue = [SOXFormatters currencyStringForNumber:volumeAfterFeeSum
                                                                                 roundingMode:NSNumberFormatterRoundHalfUp];

    self.feeSumValueTextField.stringValue      = [SOXFormatters currencyStringForNumber:feeBitcoinVolumeSum
                                                                      roundingMode:NSNumberFormatterRoundHalfUp];
    self.feeFidorSumValueTextField.stringValue = [SOXFormatters currencyStringForNumber:feeFidorVolumeSum
                                                                           roundingMode:NSNumberFormatterRoundHalfUp];
}

@end
