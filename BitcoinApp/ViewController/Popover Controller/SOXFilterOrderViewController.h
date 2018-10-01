//
//  SOXFilterOrderViewController.h
//  BitcoinApp
//
//  Created by Peter Hauke on 26.09.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import <Cocoa/Cocoa.h>

static const NSString *SOXFilterOrderViewControllerSegueKey = @"SOXFilterOrderViewControllerSegue";

@interface SOXFilterOrderViewController : NSViewController

- (NSArray <NSString *> *)selectedCountryCodes;

@end
