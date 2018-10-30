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

@property (strong) IBOutlet NSButton *createDemoDataButton;
@property (strong) IBOutlet NSButton *importButton;

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

    [self setupUI];
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

- (IBAction)importButtonAction:(NSButton *)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.title = @"Load Key and Secrets";
    openPanel.allowedFileTypes = @[@"txt"];

    [openPanel beginWithCompletionHandler:^(NSModalResponse result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSURL *selectedURL = openPanel.URL;
            [self importFileWithURL:selectedURL];
        }
    }];
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
- (void)setupUI {
    self.importButton.title = @"Import";
}

- (void)importFileWithURL:(NSURL *)url {
    NSError *error = nil;

    NSString *loadedKeysAndSecrets = [NSString stringWithContentsOfFile:url.path
                                                               encoding:NSUTF8StringEncoding
                                                                  error:&error];
    if (error) {
        NSLog(@"Import keys and secret file - loading error %@", error.localizedDescription);
        NSAlert *alert = [NSAlert alertWithError:error];
        [alert runModal];
    }
    else {
        [self importKeysAndSecrets:loadedKeysAndSecrets];
    }
}

- (void)importKeysAndSecrets:(NSString *)keysAndSecrets {
    NSArray <NSString *> *lines = [keysAndSecrets componentsSeparatedByString:@"\n"];

    __block paringErrorOccured = NO;
    __block NSMutableArray *importedKeysAndSecrets = [NSMutableArray array];
    __block NSString *errorText = @"";
    [lines enumerateObjectsUsingBlock:^(NSString * _Nonnull line, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray <NSString *> *lineComponents = [line componentsSeparatedByString:@":"];
        if (lineComponents.count == 2) {
            NSString *key = [lineComponents objectAtIndex:0];
            BOOL validateKey = [SOXPreferencesCore validateKey:key];
            NSString *secret = [lineComponents objectAtIndex:1];
            BOOL validateSecret = [SOXPreferencesCore validateSecret:secret];


            if (validateKey
                && validateSecret) {
                NSMutableDictionary *newKeyAndSecretDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                            key, APIUserKey,
                                                            secret, APISecretKey,
                                                            nil];

                [importedKeysAndSecrets addObject:newKeyAndSecretDict];
            }
            else {
                paringErrorOccured = YES;
                if (validateKey == NO) {
                    NSString *lineErrorText = [NSString stringWithFormat:@"Line %tu: Error in key\n",idx+1];
                    errorText = [errorText stringByAppendingString:lineErrorText];
                }
                if (validateSecret == NO) {
                    NSString *lineErrorText = [NSString stringWithFormat:@"Line %tu: Error in secret\n",idx+1];
                    errorText = [errorText stringByAppendingString:lineErrorText];
                }
            }
        }
        else {
            paringErrorOccured = YES;
            NSString *lineErrorText = [NSString stringWithFormat:@"Line %tu: Format error\n",idx+1];
            errorText = [errorText stringByAppendingString:lineErrorText];
        }
    }];

    BOOL saveToKeychainSuccess = NO;
    if (paringErrorOccured == NO
        && importedKeysAndSecrets.count > 0) {
        [self.keysAndSecrets addObjectsFromArray:importedKeysAndSecrets];
        [self.keysAndSecretsArrayController rearrangeObjects];
        saveToKeychainSuccess = [SOXPreferencesCore saveKeysAndSecrets:self.keysAndSecrets];
    }

    NSAlert *alertPanel = [[NSAlert alloc] init];
    if (paringErrorOccured == NO) {
        alertPanel.messageText = @"Import successful";
        alertPanel.informativeText = [NSString stringWithFormat:@"%tu key secret pairs imported."
                                      , importedKeysAndSecrets.count];
    }
    else {
        alertPanel.messageText = @"Import went wrong. No key secret pairs imported.";
        alertPanel.informativeText = errorText;
    }
    [alertPanel runModal];
}

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

    return validationResult;
}

#pragma mark - MASPreferencesViewController
- (NSString *)toolbarItemLabel {
    return @"Keys and Secrets";
}

- (NSImage *)toolbarItemImage {
    NSImage *image = [NSImage imageNamed:NSImageNameUserAccounts];
    return image;
}

@end
