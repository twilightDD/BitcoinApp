//
//  SOXStatisticsAbstractViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 25.10.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXStatisticsAbstractViewController.h"

#import "SOXTradeStatisticsViewController.h"

@interface SOXStatisticsAbstractViewController () <NSTableViewDelegate>

@property (nonatomic, strong, readwrite) SOXTradeStatisticsViewController *tradeStatisticsViewController;

@end

@implementation SOXStatisticsAbstractViewController

#pragma mark - Segue handling
- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationController isKindOfClass:[SOXTradeStatisticsViewController class]]) {
        self.tradeStatisticsViewController = segue.destinationController;
    }
}

#pragma mark - NSTableViewDelegate
- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    if (self.tableView == notification.object) {
        [self.tradeStatisticsViewController updateInfosForArrangedObjects:self.arrayController.arrangedObjects
                                                      withSelectedObjects:self.arrayController.selectedObjects
                                                        forCurrencyString:@"bubus"];
    }
}

@end
