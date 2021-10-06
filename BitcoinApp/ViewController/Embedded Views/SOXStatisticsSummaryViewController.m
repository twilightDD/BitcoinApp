//
//  SOXStatisticsSummaryViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 11.12.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXStatisticsSummaryViewController.h"

#import "SOXFormatters.h"

#import "SOXMarket_BitcoinDE_DefTypes.h"

#import "SOXAccountLedger_BitcoinDE_StatisticData.h"

#pragma mark - Interface
@interface SOXStatisticsSummaryViewController ()

#pragma mark | IBOutlets

#pragma mark Headline 1
@property (strong) IBOutlet NSTextField *currenciesDescriptionTextField;
@property (strong) IBOutlet NSTextField *kickbackDescriptionTextField;
@property (strong) IBOutlet NSTextField *feeDescriptionTextField;
@property (strong) IBOutlet NSTextField *winLoseDescriptionTextField;

#pragma mark Headline 2
@property (strong) IBOutlet NSTextField *head2CurrencyDescriptionTextField;
@property (strong) IBOutlet NSTextField *head2KickbackCountTextField;
@property (strong) IBOutlet NSTextField *head2KickbackAmountTextField;
@property (strong) IBOutlet NSTextField *head2FeeBitcoinDETextField;
@property (strong) IBOutlet NSTextField *head2FeeFidorTextField;
@property (strong) IBOutlet NSTextField *head2FeeAppTextField;
@property (strong) IBOutlet NSTextField *head2WinLoseBeforeFeesTextField;
@property (strong) IBOutlet NSTextField *head2WinLoseAfterFeeTextField;

#pragma mark Currency BTC
@property (strong) IBOutlet NSTextField *btcCurrencyDescriptionTextField;
@property (strong) IBOutlet NSTextField *btcKickbackCountTextField;
@property (strong) IBOutlet NSTextField *btcKickbackAmountTextField;
@property (strong) IBOutlet NSTextField *btcFeeBitcoinDETextField;
@property (strong) IBOutlet NSTextField *btcFeeFidorTextField;
@property (strong) IBOutlet NSTextField *btcFeeAppTextField;
@property (strong) IBOutlet NSTextField *btcWinLoseBeforeFeesTextField;
@property (strong) IBOutlet NSTextField *btcWinLoseAfterFeeTextField;

#pragma mark Currency BCH
@property (strong) IBOutlet NSTextField *bchCurrencyDescriptionTextField;
@property (strong) IBOutlet NSTextField *bchKickbackCountTextField;
@property (strong) IBOutlet NSTextField *bchKickbackAmountTextField;
@property (strong) IBOutlet NSTextField *bchFeeBitcoinDETextField;
@property (strong) IBOutlet NSTextField *bchFeeFidorTextField;
@property (strong) IBOutlet NSTextField *bchFeeAppTextField;
@property (strong) IBOutlet NSTextField *bchWinLoseBeforeFeesTextField;
@property (strong) IBOutlet NSTextField *bchWinLoseAfterFeeTextField;

#pragma mark Currency BSV
@property (strong) IBOutlet NSTextField *bsvCurrencyDescriptionTextField;
@property (strong) IBOutlet NSTextField *bsvKickbackCountTextField;
@property (strong) IBOutlet NSTextField *bsvKickbackAmountTextField;
@property (strong) IBOutlet NSTextField *bsvFeeBitcoinDETextField;
@property (strong) IBOutlet NSTextField *bsvFeeFidorTextField;
@property (strong) IBOutlet NSTextField *bsvFeeAppTextField;
@property (strong) IBOutlet NSTextField *bsvWinLoseBeforeFeesTextField;
@property (strong) IBOutlet NSTextField *bsvWinLoseAfterFeeTextField;

#pragma mark Currency BTG
@property (strong) IBOutlet NSTextField *btgCurrencyDescriptionTextField;
@property (strong) IBOutlet NSTextField *btgKickbackCountTextField;
@property (strong) IBOutlet NSTextField *btgKickbackAmountTextField;
@property (strong) IBOutlet NSTextField *btgFeeBitcoinDETextField;
@property (strong) IBOutlet NSTextField *btgFeeFidorTextField;
@property (strong) IBOutlet NSTextField *btgFeeAppTextField;
@property (strong) IBOutlet NSTextField *btgWinLoseBeforeFeesTextField;
@property (strong) IBOutlet NSTextField *btgWinLoseAfterFeeTextField;

#pragma mark Currency ETH
@property (strong) IBOutlet NSTextField *ethCurrencyDescriptionTextField;
@property (strong) IBOutlet NSTextField *ethKickbackCountTextField;
@property (strong) IBOutlet NSTextField *ethKickbackAmountTextField;
@property (strong) IBOutlet NSTextField *ethFeeBitcoinDETextField;
@property (strong) IBOutlet NSTextField *ethFeeFidorTextField;
@property (strong) IBOutlet NSTextField *ethFeeAppTextField;
@property (strong) IBOutlet NSTextField *ethWinLoseBeforeFeesTextField;
@property (strong) IBOutlet NSTextField *ethWinLoseAfterFeeTextField;

#pragma mark Currency LTC
@property (strong) IBOutlet NSTextField *ltcCurrencyDescriptionTextField;
@property (strong) IBOutlet NSTextField *ltcKickbackCountTextField;
@property (strong) IBOutlet NSTextField *ltcKickbackAmountTextField;
@property (strong) IBOutlet NSTextField *ltcFeeBitcoinDETextField;
@property (strong) IBOutlet NSTextField *ltcFeeFidorTextField;
@property (strong) IBOutlet NSTextField *ltcFeeAppTextField;
@property (strong) IBOutlet NSTextField *ltcWinLoseBeforeFeesTextField;
@property (strong) IBOutlet NSTextField *ltcWinLoseAfterFeeTextField;

#pragma mark Currency XRP
@property (strong) IBOutlet NSTextField *xrpCurrencyDescriptionTextField;
@property (strong) IBOutlet NSTextField *xrpKickbackCountTextField;
@property (strong) IBOutlet NSTextField *xrpKickbackAmountTextField;
@property (strong) IBOutlet NSTextField *xrpFeeBitcoinDETextField;
@property (strong) IBOutlet NSTextField *xrpFeeFidorTextField;
@property (strong) IBOutlet NSTextField *xrpFeeAppTextField;
@property (strong) IBOutlet NSTextField *xrpWinLoseBeforeFeesTextField;
@property (strong) IBOutlet NSTextField *xrpWinLoseAfterFeeTextField;

#pragma mark Currency DOGE
@property (strong) IBOutlet NSTextField *dogCurrencyDescriptionTextField;
@property (strong) IBOutlet NSTextField *dogKickbackCountTextField;
@property (strong) IBOutlet NSTextField *dogKickbackAmountTextField;
@property (strong) IBOutlet NSTextField *dogFeeBitcoinDETextField;
@property (strong) IBOutlet NSTextField *dogFeeFidorTextField;
@property (strong) IBOutlet NSTextField *dogFeeAppTextField;
@property (strong) IBOutlet NSTextField *dogWinLoseBeforeFeesTextField;
@property (strong) IBOutlet NSTextField *dogWinLoseAfterFeeTextField;

#pragma mark Sum
@property (strong) IBOutlet NSTextField *sumCurrencyDescriptionTextField;
@property (strong) IBOutlet NSTextField *sumKickbackCountTextField;
@property (strong) IBOutlet NSTextField *sumKickbackAmountTextField;
@property (strong) IBOutlet NSTextField *sumFeeBitcoinDETextField;
@property (strong) IBOutlet NSTextField *sumFeeFidorTextField;
@property (strong) IBOutlet NSTextField *sumFeeAppTextField;
@property (strong) IBOutlet NSTextField *sumWinLoseBeforeFeesTextField;
@property (strong) IBOutlet NSTextField *sumWinLoseAfterFeeTextField;

#pragma mark | Properties
@end

#pragma mark - Implementation
@implementation SOXStatisticsSummaryViewController

#pragma mark Init & Co.
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupLabelFormat];
    [self resetUI];
}

#pragma mark - Private Methods
#pragma mark | Setup
- (void)setupLabelFormat {
    NSArray<NSTextField *> *allTextFields = [self allTextFieldsInView:self.view];

    NSLog(@"allTextFields: %tu", allTextFields.count);

    NSFont *font = [NSFont systemFontOfSize:[NSFont systemFontSize]];
    if ([NSFont respondsToSelector:@selector(monospacedDigitSystemFontOfSize:weight:)]) {
        font = [NSFont monospacedDigitSystemFontOfSize:[NSFont systemFontSize]
                                                weight:NSFontWeightRegular];
    }
    for (NSTextField *textField in allTextFields) {
        //        NSLog(@"font before: %@", textField.font);
        [textField setFont:font];
        //        NSLog(@"font after: %@", textField.font);
        //        NSLog(@"--");
    }
}
- (void)resetUI {
    
    // Header 1
    {
        self.currenciesDescriptionTextField.stringValue = @"Currency";
        self.kickbackDescriptionTextField.stringValue   = @"Kickback";
        self.feeDescriptionTextField.stringValue        = @"Fee";
        self.winLoseDescriptionTextField.stringValue    = @"Win/Lose";
    }

    // Header 2
    {
        self.head2CurrencyDescriptionTextField.stringValue = @"Name";
        self.head2KickbackCountTextField.stringValue       = @"Payments";
        self.head2KickbackAmountTextField.stringValue      = @"Amount";
        self.head2FeeBitcoinDETextField.stringValue        = @"BitcoinDE";
        self.head2FeeFidorTextField.stringValue            = @"Fidor";
        self.head2FeeAppTextField.stringValue              = @"<Appname>";
        self.head2WinLoseBeforeFeesTextField.stringValue   = @"Before Fees";
        self.head2WinLoseAfterFeeTextField.stringValue     = @"After Fees";
    }

    // BTC
    {
        self.btcCurrencyDescriptionTextField.stringValue = [SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:BitcoinDE_CurrencyTypeBitcoin];
        self.btcKickbackCountTextField.stringValue       = @"0";
        self.btcKickbackAmountTextField.stringValue      = [SOXFormatters stringEightDigitsForBTCNumber:[NSDecimalNumber zero]];
        self.btcFeeBitcoinDETextField.stringValue        = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
        self.btcFeeFidorTextField.stringValue            = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
        self.btcFeeAppTextField.stringValue              = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
        self.btcWinLoseBeforeFeesTextField.stringValue   = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
        self.btcWinLoseAfterFeeTextField.stringValue     = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
    }

    // BCH
    {
        self.bchCurrencyDescriptionTextField.stringValue = [SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:BitcoinDE_CurrencyTypeBitcoinCash];
        self.bchKickbackCountTextField.stringValue       = @"0";
        self.bchKickbackAmountTextField.stringValue      = [SOXFormatters stringEightDigitsForBTCNumber:[NSDecimalNumber zero]];
        self.bchFeeBitcoinDETextField.stringValue        = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
        self.bchFeeFidorTextField.stringValue            = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
        self.bchFeeAppTextField.stringValue              = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
        self.bchWinLoseBeforeFeesTextField.stringValue   = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
        self.bchWinLoseAfterFeeTextField.stringValue     = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
    }

    // BSV
    {
        self.bsvCurrencyDescriptionTextField.stringValue = [SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:BitcoinDE_CurrencyTypeBitcoinCashSV];
        self.bsvKickbackCountTextField.stringValue       = @"0";
        self.bsvKickbackAmountTextField.stringValue      = [SOXFormatters stringEightDigitsForBTCNumber:[NSDecimalNumber zero]];
        self.bsvFeeBitcoinDETextField.stringValue        = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
        self.bsvFeeFidorTextField.stringValue            = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
        self.bsvFeeAppTextField.stringValue              = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
        self.bsvWinLoseBeforeFeesTextField.stringValue   = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
        self.bsvWinLoseAfterFeeTextField.stringValue     = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
    }

    // BTG
    {
        self.btgCurrencyDescriptionTextField.stringValue = [SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:BitcoinDE_CurrencyTypeBitcoinGold];
        self.btgKickbackCountTextField.stringValue       = @"0";
        self.btgKickbackAmountTextField.stringValue      = [SOXFormatters stringEightDigitsForBTCNumber:[NSDecimalNumber zero]];
        self.btgFeeBitcoinDETextField.stringValue        = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
        self.btgFeeFidorTextField.stringValue            = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
        self.btgFeeAppTextField.stringValue              = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
        self.btgWinLoseBeforeFeesTextField.stringValue   = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
        self.btgWinLoseAfterFeeTextField.stringValue     = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
    }

    // ETH
    {
        self.ethCurrencyDescriptionTextField.stringValue = [SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:BitcoinDE_CurrencyTypeEthereum];
        self.ethKickbackCountTextField.stringValue       = @"0";
        self.ethKickbackAmountTextField.stringValue      = [SOXFormatters stringEightDigitsForBTCNumber:[NSDecimalNumber zero]];
        self.ethFeeBitcoinDETextField.stringValue        = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
        self.ethFeeFidorTextField.stringValue            = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
        self.ethFeeAppTextField.stringValue              = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
        self.ethWinLoseBeforeFeesTextField.stringValue   = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
        self.ethWinLoseAfterFeeTextField.stringValue     = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
    }
    
    // LTC
    {
    self.ltcCurrencyDescriptionTextField.stringValue = [SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:BitcoinDE_CurrencyTypeLitecoin];
    self.ltcKickbackCountTextField.stringValue       = @"0";
    self.ltcKickbackAmountTextField.stringValue      = [SOXFormatters stringEightDigitsForBTCNumber:[NSDecimalNumber zero]];
    self.ltcFeeBitcoinDETextField.stringValue        = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
    self.ltcFeeFidorTextField.stringValue            = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
    self.ltcFeeAppTextField.stringValue              = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
    self.ltcWinLoseBeforeFeesTextField.stringValue   = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
    self.ltcWinLoseAfterFeeTextField.stringValue     = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
    }
    
    // XRP
    {
    self.xrpCurrencyDescriptionTextField.stringValue = [SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:BitcoinDE_CurrencyTypeRipple];
    self.xrpKickbackCountTextField.stringValue       = @"0";
    self.xrpKickbackAmountTextField.stringValue      = [SOXFormatters stringEightDigitsForBTCNumber:[NSDecimalNumber zero]];
    self.xrpFeeBitcoinDETextField.stringValue        = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
    self.xrpFeeFidorTextField.stringValue            = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
    self.xrpFeeAppTextField.stringValue              = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
    self.xrpWinLoseBeforeFeesTextField.stringValue   = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
    self.xrpWinLoseAfterFeeTextField.stringValue     = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
    }
    
    // XRP
    {
    self.dogCurrencyDescriptionTextField.stringValue = [SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:BitcoinDE_CurrencyTypeDoge];
    self.dogKickbackCountTextField.stringValue       = @"0";
    self.dogKickbackAmountTextField.stringValue      = [SOXFormatters stringEightDigitsForBTCNumber:[NSDecimalNumber zero]];
    self.dogFeeBitcoinDETextField.stringValue        = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
    self.dogFeeFidorTextField.stringValue            = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
    self.dogFeeAppTextField.stringValue              = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
    self.dogWinLoseBeforeFeesTextField.stringValue   = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
    self.dogWinLoseAfterFeeTextField.stringValue     = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
    }
    
    // Sum Row
    {
        self.sumCurrencyDescriptionTextField.stringValue = @"Sum";
        self.sumKickbackCountTextField.stringValue       = @"0";
        self.sumKickbackAmountTextField.stringValue      = [SOXFormatters stringEightDigitsForBTCNumber:[NSDecimalNumber zero]];
        self.sumFeeBitcoinDETextField.stringValue        = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
        self.sumFeeFidorTextField.stringValue            = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
        self.sumFeeAppTextField.stringValue              = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
        self.sumWinLoseBeforeFeesTextField.stringValue   = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
        self.sumWinLoseAfterFeeTextField.stringValue     = [SOXFormatters currencyStringForNumber:[NSDecimalNumber zero]];
    }
}
#pragma mark - Public Methods
- (void)updateWithStatisticsDatas:(NSArray<SOXAccountLedger_BitcoinDE_StatisticData *> *)statisticDatas {

}

#pragma mark - Private Methods


- (void)updateUISumwithStatisticDatas:(NSArray<SOXAccountLedger_BitcoinDE_StatisticData *> *)statisticDatas {
    NSDecimalNumber *feeVolumeSum             = [statisticDatas valueForKeyPath:@"@sum.feeVolumeSum"];
    self.sumFeeBitcoinDETextField.objectValue = [SOXFormatters currencyStringForNumber:feeVolumeSum];
}


- (NSArray<NSTextField *> *)allTextFieldsInView:(NSView *)view {
    NSMutableArray<NSTextField *> *textFields = [NSMutableArray array];
    Class textFieldClass                      = [NSTextField class];
    Class stackViewClass                      = [NSStackView class];
    for (NSView *subView in view.subviews) {
        if ([subView isKindOfClass:textFieldClass]) {
            [textFields addObject:(NSTextField *)subView];
        }
        else if ([subView isKindOfClass:stackViewClass]) {
            [textFields addObjectsFromArray:[self allTextFieldsInView:subView]];
        }
    }

    return [textFields copy];
}
@end
