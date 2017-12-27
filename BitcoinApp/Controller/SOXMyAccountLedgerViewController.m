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

#import "SOXKeys_BitcoinDE.h"
#import "SOXMarket_BitcoinDE_DefTypes.h"

#pragma mark - Interface
@interface SOXMyAccountLedgerViewController () <SOXMarketCoreServerRequestProtocol>
#pragma mark IBOutlets
@property (weak) IBOutlet NSTableView *tableView;

@property (weak) IBOutlet NSView *pageContainerView;
@property (weak) IBOutlet NSButton *pageBackwardButton;
@property (weak) IBOutlet NSButton *pageForwardButton;
@property (weak) IBOutlet NSTextField *pageIndicatorTextField;

@property (weak) IBOutlet NSTextField *currencyTypeSelectionLabel;
@property (weak) IBOutlet NSPopUpButton *currencyTypeSelectionPopUpButton;

@property (weak) IBOutlet NSTextField *typeLabel;
@property (weak) IBOutlet NSPopUpButton *typePopUpButton;

@property (weak) IBOutlet NSButton *reloadButton;


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
    //[self requestServerData];

    [[NSNotificationCenter defaultCenter] postNotificationName:BitcoinDE_Notification_PresentBannerInformationForCurrency
                                                        object:@(BitcoinDE_CurrencyTypeBitcoin)];
}

#pragma mark - Private methods
- (void)setupUI {    
    self.pageContainerView.hidden = YES;

    // CurrencyType Selection
    self.currencyTypeSelectionLabel.stringValue = @"Select Currency";
    [self.currencyTypeSelectionPopUpButton removeAllItems];
    for (BitcoinDE_CurrencyType idx = BitcoinDE_CurrencyTypeUnknown + 1
         ; idx < BitcoinDE_CurrencyType_EndOfType
         ; idx++) {
        [self.currencyTypeSelectionPopUpButton addItemWithTitle:[SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:idx]];
    }

    // Type Selection
    self.typeLabel.stringValue = @"Select Type";
    [self.typePopUpButton removeAllItems];
    for (BitcoinDE_AccountLedgerParameter_OrderType idx = BitcoinDE_AccountLedgerParameter_UnknownOrderType + 1
         ; idx < BitcoinDE_AccountLedgerParameter_EndOfType
         ; idx++) {
        [self.typePopUpButton addItemWithTitle:[SOXAccountLedger_BitcoinDE_Data titleForAccountLedgerOrderType:idx]];
    }

    self.reloadButton.title = @"Reload";
}

#pragma mark - Action methods
- (IBAction)reloadButtonAction:(NSButton *)sender {
    [self requestServerData];
}

#pragma mark - Network stuff

- (void)requestServerData {
    [self enableSpinningWheel];
    BitcoinDE_CurrencyType currencyTypeIndex = [self.currencyTypeSelectionPopUpButton indexOfSelectedItem] + 1;
    BitcoinDE_AccountLedgerParameter_OrderType orderTypeIndex =  [self.typePopUpButton indexOfSelectedItem] + 1 ;

    NSDictionary *parameter = [SOXAccountLedger_BitcoinDE_Data parameterForOrderType:orderTypeIndex
                                                                     forCurrencyType:currencyTypeIndex
                                                                           startDate:[NSDate dateWithTimeIntervalSinceNow:-10320000]
                                                                             endDate:[NSDate dateWithTimeIntervalSinceNow:-4320000]
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
