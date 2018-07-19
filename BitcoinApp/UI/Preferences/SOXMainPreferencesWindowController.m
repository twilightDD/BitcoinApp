//
//  SOXMainPreferencesWindowController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 27.06.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXMainPreferencesWindowController.h"

#import "SAMKeychain.h"

#import "SOXConstants.h"

#pragma mark - Interface
@interface SOXMainPreferencesWindowController ()

@property (strong, nonatomic) NSMutableArray <NSMutableDictionary*> *keysAndSecrets;
@property (strong) IBOutlet NSArrayController *keysAndSecretsArrayController;

@property (strong) IBOutlet NSTableView *tableView;
@property (strong) IBOutlet NSButton *addKeySecretPairButton;
@property (strong) IBOutlet NSButton *removeKeySecretPairButton;

@property (strong) IBOutlet NSButton *saveButton;
@property (strong) IBOutlet NSButton *dismissButton;

@end

#pragma mark - Implementation
@implementation SOXMainPreferencesWindowController

#pragma mark Init&Co.
- (void)windowDidLoad {
    [super windowDidLoad];
}

- (void)showWindow:(id)sender {
    [super showWindow:sender];
    // Load keychain
    [self loadFromKeychain];
}

#pragma mark - Keychain methods
- (void)loadFromKeychain {
    NSError *error = nil;

    NSData *data = [SAMKeychain passwordDataForService:@"BitcoinService"
                                               account:@"BitcounAccount"];
    if (data) {
        NSMutableArray *array = [NSJSONSerialization JSONObjectWithData:data
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&error];
        self.keysAndSecrets = [array mutableCopy];
        [self.keysAndSecretsArrayController rearrangeObjects];
    }
    else {
        self.keysAndSecrets = [NSMutableArray array];
    }
}

- (void)saveToKeychain {
    NSError *error = nil;

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.keysAndSecrets
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    [SAMKeychain setPasswordData:jsonData
                      forService:@"BitcoinService"
                         account:@"BitcounAccount"];
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
    [self saveToKeychain];
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

@end
