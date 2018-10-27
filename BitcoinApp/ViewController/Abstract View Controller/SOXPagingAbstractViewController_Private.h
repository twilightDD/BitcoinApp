//
//  SOXPagingAbstractViewController_Private.h
//  BitcoinApp
//
//  Created by Peter Hauke on 26.10.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//
#import "SOXPagingAbstractViewController.h"

#import "SOXAccountLedger_BitcoinDE_Data.h"

@class SOXPagingViewController;

@interface SOXPagingAbstractViewController ()

@property (strong) IBOutlet NSArrayController *arrayController;

@property (strong, nonatomic) SOXPagingViewController *pagingViewController;
@property (weak) NSPopUpButton *accountLedgerOrderTypePopUpButton;
@property (weak) NSPopUpButton *currencyTypeSelectionPopUpButton;
@property (weak) NSPopUpButton *orderStateTypeSelectionPopUpButton;
@property (weak) NSPopUpButton *orderTypeSelectionPopUpButton;
@property (weak) NSPopUpButton *tradeStateTypeSelectionPopUpButton;

@property (nonatomic) BitcoinDE_AccountLedgerParameter_OrderType selectedAccountLedgerOrderType;
@property (nonatomic) BitcoinDE_CurrencyType selectedCurrencyType;
@property (nonatomic) BitcoinDE_OrderType selectedOrderType;
@property (nonatomic) BitcoinDE_OrderStateType selectedOrderStateType;
@property (strong, nonatomic, readonly) NSDate *selectedStartDate;
@property (strong, nonatomic, readonly) NSDate *selectedEndDate;

@property (strong, nonatomic) NSMutableArray *arrayControllerDatas;

@property (nonatomic) NSInteger currentPage;

- (void)setupUI;
- (void)startExport;
- (void)addToPasteBoard:(NSString *)pasteboardString;

- (void)updatePagingButtons:(NSDictionary *)payloadDictionary;
- (void)resetPagingButtons;
- (void)resetTradeDatas; // TODO: Rename
@end
