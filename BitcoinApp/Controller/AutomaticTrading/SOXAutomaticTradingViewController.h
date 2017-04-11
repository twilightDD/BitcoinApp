//
//  SOXAutomaticTradingViewController.h
//  BitcoinApp
//
//  Created by Peter Hauke on 11.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SOXSocketIO_BitcoinDE_Core.h"

@interface SOXAutomaticTradingViewController : NSViewController

@property (nonatomic) BitcoinDE_OrderType orderType;

@end
