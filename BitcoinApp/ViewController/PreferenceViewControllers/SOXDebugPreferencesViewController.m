//
//  SOXDebugPreferencesViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 08.10.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXDebugPreferencesViewController.h"
#import "SOXPreferenceCenter.h"

@interface SOXDebugPreferencesViewController ()

@end

@implementation SOXDebugPreferencesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}
- (IBAction)resetUserDefaultsAction:(NSButton *)sender {
    [SOXPreferenceCenter resetAllSettings];
}

#pragma mark - MASPreferencesViewController
- (NSString *)toolbarItemLabel {
    return @"Debug";
}
@end
