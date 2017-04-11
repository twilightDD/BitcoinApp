//
//  SOXCreateNewOrderViewController.h
//  BitcoinApp
//
//  Created by Peter Hauke on 10.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM (NSUInteger, CreateNewOrdersType) {
    CreateNewOrdersTypeOrdersBuyType  = 1, // "buy" liefert Verkaufsangebote
    CreateNewOrdersTypeOrdersSellType = 2 // "sell" liefert Kaufangebote
};

@interface SOXCreateNewOrderViewController : NSViewController

// TODO: doublette of type OrdersType (@see SOXOrdersViewController)
@property (nonatomic) CreateNewOrdersType orderType;



@end
