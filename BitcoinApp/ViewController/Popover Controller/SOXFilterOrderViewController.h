//
//  SOXFilterOrderViewController.h
//  BitcoinApp
//
//  Created by Peter Hauke on 26.09.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SOXMarket_BitcoinDE_DefTypes.h"


static const NSString *SOXFilterOrderViewControllerSegueKey = @"SOXFilterOrderViewControllerSegue";

static NSString *FilterOrderViewSelectedCountriesKey = @"selectedCountries";

@protocol SOXFilterOrderViewControllerDelegate

- (void)filterSelectionChangedForKey:(NSString *)key withObject:(id)object;

@end

@interface SOXFilterOrderViewController : NSViewController

@property (nonatomic) BitcoinDE_OrderType orderType;
@property (nonatomic) BitcoinDE_CurrencyType currencyType;
@property (weak, nonatomic) id <SOXFilterOrderViewControllerDelegate> delegate;

@end
