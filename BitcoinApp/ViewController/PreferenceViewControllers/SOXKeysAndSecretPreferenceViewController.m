//
//  SOXKeysAndSecretPreferenceViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 08.10.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXKeysAndSecretPreferenceViewController.h"

#import "SOXKeysAndSecretPreferenceHelpViewController.h"

#import "SOXPreferencesCore.h"

#import "MacAppDelegate.h"
#import "SOXLogWindowController.h"

#import "SOXConstants.h"

@interface SOXKeysAndSecretPreferenceViewController ()

#pragma mark | Outlets
@property (strong) IBOutlet NSTextField *headLineTextField;

@property (strong) IBOutlet NSTableView *tableView;
@property (strong) IBOutlet NSButton *addKeySecretPairButton;
@property (strong) IBOutlet NSButton *removeKeySecretPairButton;

@property (strong) IBOutlet NSButton *saveButton;
@property (strong) IBOutlet NSButton *dismissButton;

@property (strong) IBOutlet NSButton *importButton;
@property (strong) IBOutlet NSButton *helpButton;

@property (strong) IBOutlet NSArrayController *keysAndSecretsArrayController;

#pragma mark | properties
@property (strong, nonatomic) NSMutableArray<NSMutableDictionary *> *keysAndSecrets;

@property (strong, nonatomic) SOXLogWindowController *errorWindowController;

@property (nonatomic) BOOL keysAndSecretsChanged;
@end

@implementation SOXKeysAndSecretPreferenceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.errorWindowController = [(MacAppDelegate *)[[NSApplication sharedApplication] delegate] errorWindowController];

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
    self.keysAndSecrets = [[SOXPreferencesCore keysAndSecrets] mutableCopy];
    [self.keysAndSecretsArrayController rearrangeObjects];

    self.keysAndSecretsChanged = NO;
}

- (void)saveToKeychain {
    NSArray<NSDictionary *> *validationResults = [self validateKeysAndSecretsInput];
    NSError *error                             = nil;
    if (validationResults.count == 0) {
        [SOXPreferencesCore saveKeysAndSecrets:self.keysAndSecrets
                                         error:error];
        if (error) {
            NSAlert *saveErrorAlert = [NSAlert alertWithError:error];
            [saveErrorAlert runModal];
        }
        else {
            self.keysAndSecretsChanged = NO;
        }
    }
    else {
        NSAlert *validationErrorAlert    = [[NSAlert alloc] init];
        validationErrorAlert.messageText = @"Validation error";
        NSString *informationText        = @"Fix errors in:\n";
        for (NSDictionary *dictionary in validationResults) {
            NSNumber *row = [dictionary objectForKey:@"row"];
            if ([dictionary.allKeys containsObject:APIUserKey]) {
                NSString *text  = [NSString stringWithFormat:@"Row %@ (User Key)\n", row];
                informationText = [informationText stringByAppendingString:text];
            }
            if ([dictionary.allKeys containsObject:APISecretKey]) {
                NSString *text  = [NSString stringWithFormat:@"Row %@ (Secret)\n", row];
                informationText = [informationText stringByAppendingString:text];
            }
        }
        validationErrorAlert.informativeText = informationText;
        [validationErrorAlert runModal];
    }
}

#pragma mark - Action methods
- (IBAction)addKeySecretPairButtonAction:(NSButton *)sender {
    if (self.keysAndSecrets.count < 10) {
        NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                [NSString stringWithFormat:@"enter key"], APIUserKey, [NSString stringWithFormat:@"enter secret"], APISecretKey, nil];
        [self.keysAndSecrets addObject:newDict];
        [self.keysAndSecretsArrayController rearrangeObjects];

        [self.tableView editColumn:0
                               row:self.keysAndSecrets.count - 1
                         withEvent:nil
                            select:YES];

        self.keysAndSecretsChanged = YES;
    }
}

- (IBAction)removeKeySecretPairButtonAction:(NSButton *)sender {
    NSIndexSet *selectedRowIndexes = self.tableView.selectedRowIndexes;
    [self.keysAndSecrets removeObjectsAtIndexes:selectedRowIndexes];
    [self.keysAndSecretsArrayController rearrangeObjects];

    [self.tableView deselectAll:nil];

    self.keysAndSecretsChanged = YES;
}


- (IBAction)saveButtonAction:(NSButton *)sender {
    [self saveToKeychain];
}

- (IBAction)dismissButtonAction:(NSButtonCell *)sender {
    [self loadFromKeychain];
}


- (IBAction)importButtonAction:(NSButton *)sender {
    NSOpenPanel *openPanel     = [NSOpenPanel openPanel];
    openPanel.title            = @"Load Key and Secrets";
    openPanel.allowedFileTypes = @[@"txt"];

    weakify(self);
    [openPanel beginWithCompletionHandler:^(NSModalResponse result) {
        if (result == NSFileHandlingPanelOKButton) {
            strongify(self);
            NSURL *selectedURL = openPanel.URL;
            [self importFileWithURL:selectedURL];
            self.keysAndSecretsChanged = YES;
        }
    }];
}
- (IBAction)helpButtonAction:(NSButton *)sender {

    NSPopover *popover = [[NSPopover alloc] init];
    [popover setBehavior:NSPopoverBehaviorTransient];
    [popover setAnimates:YES];
    [popover setContentViewController:[SOXKeysAndSecretPreferenceHelpViewController new]];
    [popover setContentSize:NSMakeSize(400, 250)];

    // Convert point to main window coordinates
    NSRect entryRect = [sender convertRect:sender.bounds
                                    toView:[[NSApp mainWindow] contentView]];

    // Show popover
    [popover showRelativeToRect:entryRect
                         ofView:[[NSApp mainWindow] contentView]
                  preferredEdge:NSMinYEdge];
}

#pragma mark - Private methods
- (void)setupUI {
    self.headLineTextField.stringValue = @"Keys and Secrets";

    self.saveButton.title    = @"Save to Keychain";
    self.dismissButton.title = @"Reset";

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
    NSArray<NSString *> *lines = [keysAndSecrets componentsSeparatedByString:@"\n"];

    __block BOOL paringErrorOccured                = NO;
    __block NSMutableArray *importedKeysAndSecrets = [NSMutableArray array];
    __block NSString *errorText                    = @"";
    [lines enumerateObjectsUsingBlock:^(NSString *_Nonnull line, NSUInteger idx, BOOL *_Nonnull stop) {
        NSArray<NSString *> *lineComponents = [line componentsSeparatedByString:@":"];
        if (lineComponents.count == 2) {
            NSString *key       = [lineComponents objectAtIndex:0];
            BOOL validateKey    = [SOXPreferencesCore validateKey:key];
            NSString *secret    = [lineComponents objectAtIndex:1];
            BOOL validateSecret = [SOXPreferencesCore validateSecret:secret];


            if (validateKey && validateSecret) {
                NSMutableDictionary *newKeyAndSecretDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                                    key, APIUserKey,
                                                                                    secret, APISecretKey,
                                                                                    nil];

                [importedKeysAndSecrets addObject:newKeyAndSecretDict];
            }
            else {
                paringErrorOccured = YES;
                if (validateKey == NO) {
                    NSString *lineErrorText = [NSString stringWithFormat:@"Line %tu: Error in key\n", idx + 1];
                    errorText               = [errorText stringByAppendingString:lineErrorText];
                }
                if (validateSecret == NO) {
                    NSString *lineErrorText = [NSString stringWithFormat:@"Line %tu: Error in secret\n", idx + 1];
                    errorText               = [errorText stringByAppendingString:lineErrorText];
                }
            }
        }
        else {
            paringErrorOccured      = YES;
            NSString *lineErrorText = [NSString stringWithFormat:@"Line %tu: Format error\n", idx + 1];
            errorText               = [errorText stringByAppendingString:lineErrorText];
        }
    }];

    if (paringErrorOccured == NO && importedKeysAndSecrets.count > 0) {
        [self.keysAndSecrets addObjectsFromArray:importedKeysAndSecrets];
        [self.keysAndSecretsArrayController rearrangeObjects];
    }

    NSAlert *alertPanel = [[NSAlert alloc] init];
    if (paringErrorOccured == NO) {
        alertPanel.messageText     = @"Import successful";
        alertPanel.informativeText = [NSString stringWithFormat:@"%tu key secret pairs imported.", importedKeysAndSecrets.count];
    }
    else {
        alertPanel.messageText     = @"Import went wrong. No key secret pairs imported.";
        alertPanel.informativeText = errorText;
    }
    [alertPanel runModal];
}

- (NSArray<NSDictionary *> *)validateKeysAndSecretsInput {
    __block NSMutableArray *invalidInputs = [NSMutableArray array];

    [self.keysAndSecrets enumerateObjectsUsingBlock:^(NSMutableDictionary *_Nonnull dictionary,
                                                      NSUInteger rowCount,
                                                      BOOL *_Nonnull stop) {
        NSString *key    = [dictionary objectForKey:APIUserKey];
        BOOL validateKey = [SOXPreferencesCore validateKey:key];

        NSString *secret    = [dictionary objectForKey:APISecretKey];
        BOOL validateSecret = [SOXPreferencesCore validateSecret:secret];

        if (validateKey == NO || validateSecret == NO) {
            NSMutableDictionary *invalidColumn = [NSMutableDictionary dictionary];
            [invalidColumn setObject:@(rowCount)
                              forKey:@"row"];

            if (validateKey == NO) {
                [invalidColumn setObject:[NSNull null]
                                  forKey:APIUserKey];
            }
            if (validateSecret == NO) {
                [invalidColumn setObject:[NSNull null]
                                  forKey:APISecretKey];
            }

            [invalidInputs addObject:[invalidColumn copy]];
        }
    }];

    return [invalidInputs copy];
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
