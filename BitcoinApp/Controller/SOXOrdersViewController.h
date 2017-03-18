//
//  SOXOrdersViewController.h
//  BitcoinApp
//
//  Created by Peter Hauke on 18.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM (NSUInteger, OrdersType) {
    OrdersBuyType = 1,
    OrdersSellType = 2
};

@interface SOXOrdersViewController : NSViewController

@property (nonatomic) OrdersType orderType;

@end
