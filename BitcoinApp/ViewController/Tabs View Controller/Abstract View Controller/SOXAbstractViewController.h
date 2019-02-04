//
//  SOXAbstractViewController.h
//  BitcoinApp
//
//  Created by Peter Hauke on 05.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SOXMarket_BitcoinDE_Core.h"

@interface SOXAbstractViewController : NSViewController

@property (weak) IBOutlet NSTableView *tableView;

- (void)enableSpinningWheel;
- (void)disableSpinningWheel;
- (void)presentNoDataView;
- (void)hideNoDataView;

@end
