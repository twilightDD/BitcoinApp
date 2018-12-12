//
//  SOXStatisticsSummaryViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 11.12.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXStatisticsSummaryViewController.h"

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
    NSArray <NSTextField *> *allTextFields = [self allTextFieldsInView:self.view];

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
    // empty labels
    {

    }

    // Header 1
    {

    }

    // Header 2
    {
    }

    // CurrencyColumn
    {

    }

    // Sum Row
    {

    }
}
#pragma mark - Public Methods
- (void)updateWithStatisticsDatas:(NSArray <SOXAccountLedger_BitcoinDE_StatisticData*> *)statisticDatas {

}

#pragma mark - Private Methods
- (NSArray <NSTextField *> *)allTextFieldsInView:(NSView *)view {
    NSMutableArray <NSTextField *> *textFields = [NSMutableArray array];
    Class textFieldClass = [NSTextField class];
    Class stackViewClass = [NSStackView class];
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
