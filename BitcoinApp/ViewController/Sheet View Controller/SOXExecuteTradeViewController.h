//
//  SOXExecuteTradeViewController.h
//  BitcoinApp
//
//  Created by Peter Hauke on 17.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SOXMarket_BitcoinDE_DefTypes.h"

@class SOXShowOrderbook_BitcoinDE_Data;

FOUNDATION_EXPORT NSString const *_Nonnull ExecuteTradeViewControllerIdentifierKey;

@interface SOXExecuteTradeViewController : NSViewController

@property (nonatomic) BitcoinDE_OrderType orderType;
@property (nonatomic) BitcoinDE_CurrencyType currencyType;
@property (strong) SOXShowOrderbook_BitcoinDE_Data *_Nullable orderBookData;

@end
