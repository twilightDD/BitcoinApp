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

@end

@implementation SOXMainPreferencesWindowController

#pragma mark Init&Co.
- (void)windowDidLoad {
    [super windowDidLoad];

    self.keysAndSecrets = [[NSMutableArray array] init];
    for (NSUInteger a = 0; a<10; a++) {
        Doof *newDoof = [[Doof alloc] init];
        newDoof.apiKey = [NSString stringWithFormat:@"key %tu", a];
        newDoof.apiSecret = [NSString stringWithFormat:@"secret %tu", a];

        [self.keysAndSecrets addObject:newDoof];
    }

//    self.keysAndSecrets = [NSMutableArray arrayWithObjects:@"1",@"2",@"3", nil];

    [self.keysAndSecretsArrayController rearrangeObjects];
//



//    self.keysAndSecrets = [NSMutableArray arrayWithObjects:
//                           [NSDictionary dictionaryWithObject:@"secret1" forKey:@"key1"]
//                           , [NSDictionary dictionaryWithObject:@"secret2" forKey:@"key2"]
//                           , [NSDictionary dictionaryWithObject:@"secret3" forKey:@"key3"]
//                           , [NSDictionary dictionaryWithObject:@"secret4" forKey:@"key4"]
//                           , nil];

}

-(void)showWindow:(id)sender {
    [super showWindow:sender];
}

#pragma mark - Action methods
- (IBAction)addKeySecretPairButtonAction:(NSButton *)sender {
    if (self.keysAndSecrets.count < 10) {
        Doof *newDoof = [[Doof alloc] init];
        [self.keysAndSecrets addObject:newDoof];
        [self.keysAndSecretsArrayController rearrangeObjects];

    }

}
- (IBAction)removeKeySecretPairButtonAction:(NSButton *)sender {
    NSArray *selectedKeySecretPairs = self.keysAndSecretsArrayController.selectedObjects;
    [self.keysAndSecrets removeObjectsInArray:selectedKeySecretPairs];
    [self.keysAndSecretsArrayController rearrangeObjects];

}
@end
