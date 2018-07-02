//
//  SOXMainPreferencesWindowController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 27.06.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXMainPreferencesWindowController.h"

#import "SAMKeychain.h"

@interface Doof : NSObject

@property (strong, nonatomic) NSString *apiKey;
@property (strong, nonatomic) NSString *apiSecret;

@end

@implementation Doof

@end


@interface SOXMainPreferencesWindowController ()

@property (strong, nonatomic) NSMutableArray <NSMutableDictionary*> *keysAndSecrets;
@property (strong) IBOutlet NSArrayController *keysAndSecretsArrayController;

@property (strong) IBOutlet NSTableView *tableView;
@property (strong) IBOutlet NSButton *addKeySecretPairButton;
@property (strong) IBOutlet NSButton *removeKeySecretPairButton;

@property (strong) IBOutlet NSButton *saveButton;
@property (strong) IBOutlet NSButton *dismissButton;



@end

@implementation SOXMainPreferencesWindowController

#pragma mark Init&Co.
- (void)windowDidLoad {
    [super windowDidLoad];

    self.keysAndSecrets = [[NSMutableArray array] init];
    NSString *keyKey = @"key";
    NSString *secretKey = @"secret";
    for (NSUInteger a = 0; a<8; a++) {
        NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"key %tu", a], keyKey
                                        , [NSString stringWithFormat:@"secret %tu", a], secretKey
                                        , nil];

        [self.keysAndSecrets addObject:newDict];
    }

    [self.keysAndSecretsArrayController rearrangeObjects];
}

#pragma mark - Action methods
- (IBAction)addKeySecretPairButtonAction:(NSButton *)sender {
    if (self.keysAndSecrets.count < 10) {
        NSString *keyKey = @"key";
        NSString *secretKey = @"secret";
        NSUInteger count = self.keysAndSecrets.count;
        NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"key %tu", count], keyKey
                                        , [NSString stringWithFormat:@"secret %tu", count], secretKey
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
    NSError *error = nil;

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.keysAndSecrets
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    [SAMKeychain setPasswordData:jsonData
                      forService:@"BitcoinService"
                         account:@"BitcounAccount"];
}

- (IBAction)dismissButtonAction:(NSButtonCell *)sender {
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

}

@end
