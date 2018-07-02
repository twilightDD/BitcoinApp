//
//  SOXMainPreferencesWindowController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 27.06.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXMainPreferencesWindowController.h"


@interface Doof : NSObject

@property (strong, nonatomic) NSString *apiKey;
@property (strong, nonatomic) NSString *apiSecret;

@end

@implementation Doof

- (IBAction)addKeySecretPairButton:(NSButton *)sender {
}
@end


@interface SOXMainPreferencesWindowController ()

@property (strong, nonatomic) NSMutableArray *keysAndSecrets;
@property (strong) IBOutlet NSArrayController *keysAndSecretsArrayController;
@property (strong) IBOutlet NSButton *addKeySecretPairButton;

@property (strong) IBOutlet NSButton *removeKeySecretPairButton;
@property (strong) IBOutlet NSTableView *tableView;

@end

@implementation SOXMainPreferencesWindowController

#pragma mark Init&Co.
- (void)windowDidLoad {
    [super windowDidLoad];

    self.keysAndSecrets = [[NSMutableArray array] init];
    for (NSUInteger a = 0; a<8; a++) {
        Doof *newDoof = [[Doof alloc] init];
        newDoof.apiKey = [NSString stringWithFormat:@"key %tu", a];
        newDoof.apiSecret = [NSString stringWithFormat:@"secret %tu", a];

        [self.keysAndSecrets addObject:newDoof];
    }

    [self.keysAndSecretsArrayController rearrangeObjects];
}

#pragma mark - Action methods
- (IBAction)addKeySecretPairButtonAction:(NSButton *)sender {
    if (self.keysAndSecrets.count < 10) {
        Doof *newDoof = [[Doof alloc] init];
        [self.keysAndSecrets addObject:newDoof];
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

@end
