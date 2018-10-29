//
//  SOXStatisticsAbstractViewController_Private.h
//  BitcoinApp
//
//  Created by Peter Hauke on 25.10.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXStatisticsAbstractViewController.h"

@class SOXTradeStatisticsViewController;

@interface SOXStatisticsAbstractViewController()

@property (nonatomic, strong, readonly) SOXTradeStatisticsViewController *tradeStatisticsViewController;

- (void)updateTradeStatistics;

@end
