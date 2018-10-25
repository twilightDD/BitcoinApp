//
//  SOXTradeStatisticsViewController.h
//  BitcoinApp
//
//  Created by Peter Hauke on 25.10.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SOXTradeStatisticsViewController : NSViewController

- (void)updateInfosForArrangedObjects:(NSArray *)arrangedObjects
                  withSelectedObjects:(NSArray *)selectedObjects
                    forCurrencyString:(NSString *)currencyString;


@end
