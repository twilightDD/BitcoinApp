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

@property (weak) IBOutlet NSPopUpButton *typePopUpButton;

#pragma mark Properties
@property (nonatomic) BitcoinDE_AccountLedgerParameter_OrderType selectedOrderType;

@end

#pragma mark - Implementation
@implementation SOXMyAccountLedgerViewController

#pragma mark Init&Co.
- (void)viewDidLoad {
    [super viewDidLoad];

    self.selectedOrderType = BitcoinDE_AccountLedgerParameter_AllOrderType;
}

- (void)viewWillAppear {
    [super viewWillAppear];
    

    //[self requestServerData];

    [[NSNotificationCenter defaultCenter] postNotificationName:BitcoinDE_Notification_PresentBannerInformationForCurrency
                                                        object:@(BitcoinDE_CurrencyTypeBitcoin)];
}

#pragma mark - Private methods
- (void)setupUI {    
    [super setupUI];

    // Type Selection
    [self.typePopUpButton removeAllItems];
    for (BitcoinDE_AccountLedgerParameter_OrderType idx = BitcoinDE_AccountLedgerParameter_UnknownOrderType + 1
         ; idx < BitcoinDE_AccountLedgerParameter_EndOfType
         ; idx++) {
        [self.typePopUpButton addItemWithTitle:[SOXAccountLedger_BitcoinDE_Data titleForAccountLedgerOrderType:idx]];
    }
}

#pragma mark - Action methods

- (IBAction)typePopUpButtonAction:(NSPopUpButton *)sender {
    BitcoinDE_AccountLedgerParameter_OrderType newOrderType = sender.indexOfSelectedItem + 1;

    if (newOrderType != self.selectedOrderType) {
        self.selectedOrderType = newOrderType;
        [self resetTradeDatas];
    }
}

#pragma mark - Next Page Data
- (void)loadNextPage {
    [super loadNextPage];

    NSDictionary *parameter = [SOXAccountLedger_BitcoinDE_Data parameterForOrderType:self.selectedOrderType
                                                                     forCurrencyType:self.selectedCurrencyType
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
        NSMutableArray *accountLedgerDatas = [SOXAccountLedger_BitcoinDE_Data accountLedgerDataArrayForAccountLedgerDictionary:payloadDictionary];

        [self.arrayControllerDatas addObjectsFromArray:accountLedgerDatas];
        [self.arrayController rearrangeObjects];

        [self disableSpinningWheel];

        [self updatePagingButtons:payloadDictionary];
    }
}

@end
