//
//  SOXKeysAndSecretPreferenceHelpViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 05.11.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXKeysAndSecretPreferenceHelpViewController.h"

#import "NSTextField+URL.h"

@interface SOXKeysAndSecretPreferenceHelpViewController ()
@property (strong) IBOutlet NSTextField *informativeTextField;
@property (strong) IBOutlet NSTextField *bottomTextField;

@end

@implementation SOXKeysAndSecretPreferenceHelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.

    self.informativeTextField.stringValue = @"Hier kommt ein Hilfetext in Fließtext rein";
    [self.bottomTextField setHyperlinkFormattingFromString:@"Apply for Keys and Secrets."
                                             withURLString:@"https://www.bitcoin.de/de/userprofile/tapi"];
}

@end
