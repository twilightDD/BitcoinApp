//
//  SOXOrdersViewController.h
//  BitcoinApp
//
//  Created by Peter Hauke on 18.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXAbstractViewController.h"
#import "SOXMarket_BitcoinDE_DefTypes.h"

@interface SOXOrdersViewController : SOXAbstractViewController

@property (nonatomic) BitcoinDE_OrderType orderType;

@end
