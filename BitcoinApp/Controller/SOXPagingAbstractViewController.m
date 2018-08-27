//
//  SOXPagingAbstractViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 27.08.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXPagingAbstractViewController.h"

#import "SOXPage_BitcoinDE_Data.h"

#import "SOXKeys_BitcoinDE.h"

@implementation SOXPagingAbstractViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.shouldLoadAllTradeDatas = NO;
    self.selectedCurrencyType = BitcoinDE_CurrencyTypeBitcoin;

    [self setupUI];
}

- (void)setupUI {
    [self resetPagingButtons];

    // currency selection
    [self.currencyTypeSelectionPopUpButton removeAllItems];
    for (BitcoinDE_CurrencyType idx = BitcoinDE_CurrencyTypeUnknown + 1
         ; idx < BitcoinDE_CurrencyType_EndOfType
         ; idx++) {
        [self.currencyTypeSelectionPopUpButton addItemWithTitle:[SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:idx]];
    }
}

- (void)resetPagingButtons {
    self.fetchDataButton.title = @"Fetch data";
    self.loadMoreTradeDatasButton.hidden = YES;
    self.loadAllTradeDatasButton.hidden = YES;
}

- (void)resetTradeDatas {
    // reset tableView
    self.arrayControllerDatas = [NSMutableArray array];
    [self.arrayController rearrangeObjects];

    // reset paging
    self.currentPage = 0;
    [self resetPagingButtons];
}

#pragma mark - Paging
- (void)loadNextPage {
    [self enableSpinningWheel];
    
    self.loadMoreTradeDatasButton.enabled = NO;
    self.loadAllTradeDatasButton.enabled = NO;
    self.currentPage = self.currentPage + 1;

    // loading in concrete subClass
}

- (void)updatePagingButtons:(NSDictionary *)payloadDictionary {
    SOXPage_BitcoinDE_Data *pageData = [SOXPage_BitcoinDE_Data pageDataForPayloadDictionary:payloadDictionary];
    self.currentPage = pageData.pageCurrent;

    BOOL enableLoadMoreTradDatasButton = self.currentPage != pageData.pageLast;

    // enable load more buttons, if needed
    if (enableLoadMoreTradDatasButton) {
        self.loadMoreTradeDatasButton.hidden = NO;
        self.loadMoreTradeDatasButton.enabled = enableLoadMoreTradDatasButton;
        self.loadAllTradeDatasButton.hidden = NO;
        self.loadAllTradeDatasButton.enabled = enableLoadMoreTradDatasButton;


        self.loadAllTradeDatasButton.title = [NSString stringWithFormat:@"Load all (%ti pages left)"
                                              , pageData.pageLast - pageData.pageCurrent];
    }
    else {
        self.loadMoreTradeDatasButton.hidden = YES;
        self.loadAllTradeDatasButton.hidden = YES;
    }

    // automatically load further pages, if possible
    if (self.shouldLoadAllTradeDatas == YES
        && enableLoadMoreTradDatasButton == YES) {
        [self loadNextPage];
    }
    else {
        self.shouldLoadAllTradeDatas = NO;
        self.fetchDataButton.title = @"Fetch data";
        self.fetchDataButton.enabled = YES;
        [self disableSpinningWheel];
    }
}

#pragma mark - Settings
- (IBAction)currencyTypPopUpButtonAction:(NSPopUpButton *)sender {
    BitcoinDE_CurrencyType newCurrencyType = sender.indexOfSelectedItem + 1;

    if (newCurrencyType != self.selectedCurrencyType) {
        self.selectedCurrencyType = newCurrencyType;
        [self resetTradeDatas];

        [[NSNotificationCenter defaultCenter] postNotificationName:BitcoinDE_Notification_PresentBannerInformationForCurrency
                                                            object:@(newCurrencyType)];
    }
}

#pragma mark - Fetch and load buttons
- (IBAction)loadAllTradeDatasAction:(NSButton *)sender {
    self.shouldLoadAllTradeDatas = YES;
    self.fetchDataButton.title = @"Cancel";

    [self loadNextPage];
}

- (IBAction)loadMoreTradeDatasAction:(NSButton *)sender {
    self.fetchDataButton.enabled = NO;

    [self loadNextPage];
}

- (IBAction)fetchDataButtonAction:(NSButton *)sender {
    self.fetchDataButton.enabled = NO;
    if (self.shouldLoadAllTradeDatas == YES) {
        self.shouldLoadAllTradeDatas = NO;
    }
    else {
        // reset all fetched datas
        self.arrayControllerDatas = [NSMutableArray array];
        self.currentPage = 0;

        [self loadNextPage];
    }
}

@end
