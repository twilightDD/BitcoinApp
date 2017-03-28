//
//  SOXMyAccountLedgerViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 28.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXMyAccountLedgerViewController.h"

#import "SOXMarket_BitcoinDE_Core.h"
#import "SOXAccountLedger_BitcoinDE_Data.h"

#pragma mark - Interface
@interface SOXMyAccountLedgerViewController () <SOXMarketCoreServerRequestProtocol>
#pragma mark IBOutlets

@property (weak) IBOutlet NSTextField *titleTextField;
@property (weak) IBOutlet NSTableView *tableView;

@property (weak) IBOutlet NSView *pageContainerView;
@property (weak) IBOutlet NSButton *pageBackwardButton;
@property (weak) IBOutlet NSButton *pageForwardButton;
@property (weak) IBOutlet NSTextField *pageIndicatorTextField;

@property (weak) IBOutlet NSView *spinningBackgroundView;
@property (weak) IBOutlet NSProgressIndicator *circularProgressIndicator;

@property (strong) IBOutlet NSArrayController *accountLedgerArrayController;

#pragma mark Properties
@property (strong, nonatomic) NSMutableArray *accountLedger;
@end

#pragma mark - Implementation
@implementation SOXMyAccountLedgerViewController

#pragma mark Init&Co.
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)viewWillAppear {
    [super viewWillAppear];
    
    [self setupUI];
    [self requestServerData];
}

-(void)viewDidAppear {
    [super viewDidAppear];
    
    self.spinningBackgroundView.hidden = NO;
    [self.circularProgressIndicator startAnimation:nil];
}

#pragma mark - Private methods
- (void)setupUI {
    self.titleTextField.stringValue = @"My trading history";
    
    self.pageContainerView.hidden = YES;
    
    self.spinningBackgroundView.layer.backgroundColor = [NSColor colorWithCalibratedRed:0
                                                                                  green:0
                                                                                   blue:0
                                                                                  alpha:0.1].CGColor;
}


- (void)requestServerData {
    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowAccountLedger
                                                respondTo:self];
    
}
#pragma mark - SOXMarketCoreServerRequestProtocol
- (void)answerOfServerRequest:(NSDictionary * _Nonnull)answerOfServerRequest {
    if ([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ShowAccountLedger)]) {
        NSDictionary *payloadDictionary = [answerOfServerRequest objectForKey:ServerAnswerPayloadKey];
        NSMutableArray *accountLedger = [SOXAccountLedger_BitcoinDE_Data accountLedgerDataArrayForAccountLedgerDictionary:payloadDictionary];
        self.accountLedger = accountLedger;
        
        [self.circularProgressIndicator stopAnimation:nil];
        self.spinningBackgroundView.hidden = YES;

        
    }
    
    SOXAccountLedger_BitcoinDE_Data *data = self.accountLedger.firstObject;
    NSLog(@"data:\n%@", data);
}


@end
