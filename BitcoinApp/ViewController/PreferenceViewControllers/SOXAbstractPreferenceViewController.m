//
//  SOXAbstractPreferenceViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 08.10.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXAbstractPreferenceViewController.h"

@interface SOXAbstractPreferenceViewController ()

@end

@implementation SOXAbstractPreferenceViewController

#pragma mark - MASPreferencesViewController
- (NSString *)viewIdentifier {
    return NSStringFromClass([self class]);
}

- (NSString *)toolbarItemLabel {
    NSAssert(NO, @"Set toolbarItemLabel in concrete subclass");
    return @"ERROR";
}

@end
