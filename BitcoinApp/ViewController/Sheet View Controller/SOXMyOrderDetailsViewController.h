//
//  SOXMyOrderDetailsViewController.h
//  BitcoinApp
//
//  Created by Peter Hauke on 28.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SOXMyOrderBook_BitcoinDE_Data;

@interface SOXMyOrderDetailsViewController : NSViewController

@property (weak, nonatomic) SOXMyOrderBook_BitcoinDE_Data *myOrder;

@end
