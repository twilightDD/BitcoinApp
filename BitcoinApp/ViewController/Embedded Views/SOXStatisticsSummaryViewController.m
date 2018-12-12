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

#pragma mark 1. Stack: Currencies

#pragma mark 2. Stack: Kickback

#pragma mark 3. Stack: Fees

#pragma mark 4. Stack: WinLose


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
