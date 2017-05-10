//
//  SOXMyAccountLedgerViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 28.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXMyAccountLedgerViewController.h"
#import "SOXAbstractViewController_Private.h"

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

#pragma mark - Private methods
- (void)setupUI {
    self.titleTextField.stringValue = @"My trading history";
    
    self.pageContainerView.hidden = YES;
}


- (void)requestServerData {
    [self enableSpinningWheel];
    
    NSDictionary *parameter = [SOXAccountLedger_BitcoinDE_Data parameterForOrderType:BitcoinDE_AccountLedgerParameter_AllOrderType
                                                                           startDate:[NSDate dateWithTimeIntervalSinceNow:-4320000]
                                                                             endDate:nil
                                                                                page:1];
    
    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowAccountLedgerType
                                            withParameter:parameter
                                                respondTo:self];
}

#pragma mark - SOXMarketCoreServerRequestProtocol
- (void)answerOfServerRequest:(NSDictionary * _Nonnull)answerOfServerRequest {
    if ([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ShowAccountLedgerType)]) {
        NSDictionary *payloadDictionary = [answerOfServerRequest objectForKey:ServerAnswerPayloadKey];
        NSMutableArray *accountLedger = [SOXAccountLedger_BitcoinDE_Data accountLedgerDataArrayForAccountLedgerDictionary:payloadDictionary];
        self.accountLedger = accountLedger;
        
        [self disableSpinningWheel];
    }
}

@end
