//
//  SOXOrdersViewController.h
//  BitcoinApp
//
//  Created by Peter Hauke on 18.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXSpinningWheelAbstractViewController.h"

typedef NS_ENUM (NSUInteger, OrdersType) {
    OrdersBuyType = 1, // "buy" liefert Verkaufsangebote
    OrdersSellType = 2 // "sell" liefert Kaufangebote
};

@interface SOXOrdersViewController : SOXSpinningWheelAbstractViewController

@property (nonatomic) OrdersType orderType;

@end
