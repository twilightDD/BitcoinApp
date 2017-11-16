//
//  SOXCreateNewOrderViewController.h
//  BitcoinApp
//
//  Created by Peter Hauke on 10.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SOXMarket_BitcoinDE_DefTypes.h"

@class SOXMyOrderBook_BitcoinDE_Data;

@protocol SOXChangeOrderProtocol

- (void)orderWasChanged:(NSString *)oldOrderID newOrderID:(NSString *)newOrderID;

@end


@interface SOXCreateNewOrderViewController : NSViewController

@property (weak, nonatomic) id <SOXChangeOrderProtocol> delegate;

// TODO: doublette of type OrdersType (@see SOXOrdersViewController)
@property (nonatomic) BitcoinDE_OrderType orderType;
@property (nonatomic) BitcoinDE_CurrencyType currencyType;
@property (weak, nonatomic) SOXMyOrderBook_BitcoinDE_Data *orderBookDataToReplace;

@end
