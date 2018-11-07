//
//  SOXGeneralSettingsPreferenceViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 07.11.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXGeneralSettingsPreferenceViewController.h"

@interface SOXGeneralSettingsPreferenceViewController ()

@end

@implementation SOXGeneralSettingsPreferenceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

#pragma mark - MASPreferencesViewController
- (NSString *)toolbarItemLabel {
    return @"General settings";
}

- (NSImage *)toolbarItemImage {
    NSImage *image = [NSImage imageNamed:NSImageNamePreferencesGeneral];
    return image;
}
@end
