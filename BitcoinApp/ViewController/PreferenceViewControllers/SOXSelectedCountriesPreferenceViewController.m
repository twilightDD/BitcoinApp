//
//  SOXSelectedCountriesPreferenceViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 08.10.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXSelectedCountriesPreferenceViewController.h"

@interface SOXSelectedCountriesPreferenceViewController ()

@end

@implementation SOXSelectedCountriesPreferenceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

#pragma mark - MASPreferencesViewController
- (NSString *)toolbarItemLabel {
    return @"Selected countries";
}

- (NSImage *)toolbarItemImage {
    NSImage *image = [NSImage imageNamed:@"countries"];
    return image;
}
@end
