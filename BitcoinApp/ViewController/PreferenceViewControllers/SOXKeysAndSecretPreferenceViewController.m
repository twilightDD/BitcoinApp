//
//  SOXKeysAndSecretPreferenceViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 08.10.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXKeysAndSecretPreferenceViewController.h"

#import "SOXPreferencesCore.h"

#import "MacAppDelegate.h"
#import "SOXLogWindowController.h"

#import "SOXConstants.h"

@interface SOXKeysAndSecretPreferenceViewController ()

#pragma mark | Outlets
@property (strong) IBOutlet NSArrayController *keysAndSecretsArrayController;

@property (strong) IBOutlet NSTableView *tableView;
@property (strong) IBOutlet NSButton *addKeySecretPairButton;
@property (strong) IBOutlet NSButton *removeKeySecretPairButton;

@property (strong) IBOutlet NSButton *saveButton;
@property (strong) IBOutlet NSButton *dismissButton;

#pragma mark | properties
@property (strong, nonatomic) NSMutableArray <NSMutableDictionary*> *keysAndSecrets;
@property (strong, nonatomic) SOXLogWindowController *errorWindowController;


@end

@implementation SOXKeysAndSecretPreferenceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.errorWindowController = [(MacAppDelegate*)[[NSApplication sharedApplication] delegate] errorWindowController];

    for (NSTableColumn *column in self.tableView.tableColumns) {
        NSFont *font = [NSFont systemFontOfSize:[NSFont systemFontSize]];

        if ([NSFont respondsToSelector:@selector(monospacedDigitSystemFontOfSize:weight:)]) {
            font = [NSFont monospacedDigitSystemFontOfSize:[NSFont systemFontSize]
                                                    weight:NSFontWeightRegular];
        }

        [column.dataCell setFont:font];
    }
}

- (void)viewWillAppear {
    [super viewWillAppear];
    [self loadFromKeychain];
}

#pragma mark - Keychain methods
- (void)loadFromKeychain {
    // ask PreferenceCore
    self.keysAndSecrets = [SOXPreferencesCore keysAndSecrets];

    [self.keysAndSecretsArrayController rearrangeObjects];
}

- (void)saveToKeychain {
    BOOL success = [SOXPreferencesCore saveKeysAndSecrets:self.keysAndSecrets];
    if (success == NO) {

    }
}

#pragma mark - Action methods
- (IBAction)addKeySecretPairButtonAction:(NSButton *)sender {
    if (self.keysAndSecrets.count < 10) {
        NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"enter key"], APIUserKey
                                        , [NSString stringWithFormat:@"enter secret"], APISecretKey
                                        , nil];
        [self.keysAndSecrets addObject:newDict];
        [self.keysAndSecretsArrayController rearrangeObjects];

        [self.tableView editColumn:0
                               row:self.keysAndSecrets.count-1
                         withEvent:nil
                            select:YES];
    }
}

- (IBAction)removeKeySecretPairButtonAction:(NSButton *)sender {
    NSIndexSet *selectedRowIndexes = self.tableView.selectedRowIndexes;
    [self.keysAndSecrets removeObjectsAtIndexes:selectedRowIndexes];
    [self.keysAndSecretsArrayController rearrangeObjects];

    [self.tableView deselectAll:nil];
}

- (IBAction)saveButtonAction:(NSButton *)sender {
    BOOL validationResult = [self validateKeysAndSecretsInput];
    if (validationResult) {
        [self saveToKeychain];
        [self.errorWindowController showMessage:@" Saved to keychain"];
    }
    else {
        // TODO: Fehlermeldung bringen
        [self.errorWindowController showMessage:@" ->>>>>>> NO save to keychain"];
    }
}

- (IBAction)dismissButtonAction:(NSButtonCell *)sender {
    [self loadFromKeychain];
}

- (IBAction)createDemoDataButtonAction:(NSButton *)sender {
    self.keysAndSecrets = [[NSMutableArray array] init];
    for (NSUInteger a = 0; a<8; a++) {
        NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"key %tu", a], APIUserKey
                                        , [NSString stringWithFormat:@"secret %tu", a], APISecretKey
                                        , nil];

        [self.keysAndSecrets addObject:newDict];
    }

    [self.keysAndSecretsArrayController rearrangeObjects];
}

#pragma mark - Private methods
- (BOOL)validateKeysAndSecretsInput {
    __block BOOL validationResult = YES;

    __block NSMutableArray *invalidInputs = [NSMutableArray array];

    [self.keysAndSecrets enumerateObjectsUsingBlock:^(NSMutableDictionary * _Nonnull dictionary,
                                                      NSUInteger rowCount,
                                                      BOOL * _Nonnull stop) {
        NSString *key = [dictionary objectForKey:APIUserKey];
        BOOL validateKey = [SOXPreferencesCore validateKey:key];

        NSString *secret = [dictionary objectForKey:APISecretKey];
        BOOL validateSecret = [SOXPreferencesCore validateSecret:secret];

        validationResult = validationResult && validateKey && validateSecret;

        NSMutableDictionary *invalidColumns = [NSMutableDictionary dictionary];
        if (validateKey == NO) {
            [invalidColumns setObject:@(rowCount)
                               forKey:@"row"];
            [invalidColumns setObject:[NSNull null]
                               forKey:APIUserKey];
        }
        if (validateSecret == NO) {
            [invalidColumns setObject:@(rowCount)
                               forKey:@"row"];
            [invalidColumns setObject:[NSNull null]
                               forKey:APISecretKey];
        }
        if (invalidColumns.allKeys.count > 0) {
            [invalidInputs addObject:invalidColumns];
        }
    }];

    //    if (invalidInputs.count > 0) {
    //        [invalidInputs enumerateObjectsUsingBlock:^(NSMutableDictionary * _Nonnull dict,
    //                                                    NSUInteger idx,
    //                                                    BOOL * _Nonnull stop) {
    //            NSNumber *row = [dict objectForKey:@"row"];
    //            id errorInKey = [dict objectForKey:APIUserKey];
    //            id errorInSecret = [dict objectForKey:APISecretKey];
    //
    //
    //
    //
    //        }];
    //    }


    return validationResult;
}

#pragma mark - MASPreferencesViewController
- (NSString *)toolbarItemLabel {
    return @"Keys and Secrets";
}

- (BOOL)hasResizableWidth {
    return YES;
}

- (BOOL)hasResizableHeight {
    return YES;
}


@end
