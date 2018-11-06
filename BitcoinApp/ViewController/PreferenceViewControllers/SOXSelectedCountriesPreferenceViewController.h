//
//  SOXSelectedCountriesPreferenceViewController.h
//  BitcoinApp
//
//  Created by Peter Hauke on 08.10.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXAbstractPreferenceViewController.h"
#import "SOXMarket_BitcoinDE_DefTypes.h"

static NSString *FilterOrderViewSelectedCountriesKey = @"selectedCountries";
static NSString *FilterOrderViewNoSepaKey = @"noSepa";

@protocol SOXSelectedCountriesViewControllerDelegate

- (void)filterSelectionChangedForKey:(NSString *)key withObject:(id)object;

@end

@interface SOXSelectedCountriesPreferenceViewController : SOXAbstractPreferenceViewController

@property (nonatomic) BitcoinDE_OrderType orderType;
@property (nonatomic) BitcoinDE_CurrencyType currencyType;
@property (weak, nonatomic) id <SOXSelectedCountriesViewControllerDelegate> delegate;

// Kann weg
+ (NSArray <NSButton *> *)addCountryButtonsToView:(NSView *)view;
@end
