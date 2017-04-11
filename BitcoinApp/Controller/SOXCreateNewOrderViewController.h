//
//  SOXCreateNewOrderViewController.h
//  BitcoinApp
//
//  Created by Peter Hauke on 10.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SOXMarket_BitcoinDE_DefTypes.h"

@interface SOXCreateNewOrderViewController : NSViewController

// TODO: doublette of type OrdersType (@see SOXOrdersViewController)
@property (nonatomic) BitcoinDE_OrderType orderType;

@end
