//
//  SOXStatisticsSummaryViewController.h
//  BitcoinApp
//
//  Created by Peter Hauke on 11.12.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SOXAccountLedger_BitcoinDE_StatisticData;

@interface SOXStatisticsSummaryViewController : NSViewController

- (void)updateWithStatisticsDatas:(NSArray<SOXAccountLedger_BitcoinDE_StatisticData *> *)statisticDatas;

@end
