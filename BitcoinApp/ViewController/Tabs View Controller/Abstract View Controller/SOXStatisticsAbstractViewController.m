//
//  SOXStatisticsAbstractViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 25.10.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXStatisticsAbstractViewController.h"
#import "SOXPagingAbstractViewController_Private.h"

#import "SOXTradeStatisticsViewController.h"

@interface SOXStatisticsAbstractViewController () <NSTableViewDelegate>

@property (nonatomic, strong, readwrite) SOXTradeStatisticsViewController *tradeStatisticsViewController;

@end

@implementation SOXStatisticsAbstractViewController

#pragma mark - Segue handling
- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender]; // call superClass!

    if ([segue.destinationController isKindOfClass:[SOXTradeStatisticsViewController class]]) {
        self.tradeStatisticsViewController = segue.destinationController;
    }
}

#pragma mark - NSTableViewDelegate
- (void)tableViewSelectionIsChanging:(NSNotification *)notification {
    // responds to mouse events only
    if (self.tableView == notification.object) {
        [self updateTradeStatistics];
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    // Needed for selection changes via keyboard
    if (self.tableView == notification.object) {
        [self updateTradeStatistics];
    }
}

- (void)updateTradeStatistics {
    // in case of tableViewSelectionIsChanging the arrayController returns no selectedObjects
    NSIndexSet *selectedRowIndexes = self.tableView.selectedRowIndexes;
    NSArray *arrangedObjects = self.arrayController.arrangedObjects;
    NSArray *selectedObjects = [arrangedObjects objectsAtIndexes:selectedRowIndexes];
    [self.tradeStatisticsViewController updateInfosForArrangedObjects:arrangedObjects
                                                  withSelectedObjects:selectedObjects
                                                    forCurrencyString:@"bubus"];
}

@end
