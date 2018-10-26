//
//  SOXPagingAbstractViewController_Private.h
//  BitcoinApp
//
//  Created by Peter Hauke on 26.10.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//
#import "SOXPagingAbstractViewController.h"

#import "SOXPagingViewController.h"

@interface SOXPagingAbstractViewController ()

@property (strong) IBOutlet NSArrayController *arrayController;

@property (weak) NSPopUpButton *currencyTypeSelectionPopUpButton;
@property (weak) NSPopUpButton *orderTypeSelectionPopUpButton;
@property (weak) NSPopUpButton *tradeStateTypeSelectionPopUpButton;

@property (strong, nonatomic) NSDate *selectedStartDate;
@property (strong, nonatomic) NSDate *selectedEndDate;


@property (strong, nonatomic) SOXPagingViewController *pagingViewController;
@property (nonatomic) BitcoinDE_OrderType selectedOrderType;
@property (nonatomic) BitcoinDE_CurrencyType selectedCurrencyType;

@property (strong, nonatomic) NSMutableArray *arrayControllerDatas;

@property (nonatomic) NSInteger currentPage;

- (void)setupUI;
- (void)startExport;
- (void)addToPasteBoard:(NSString *)pasteboardString;

- (void)updatePagingButtons:(NSDictionary *)payloadDictionary;
- (void)resetPagingButtons;
- (void)resetTradeDatas; // TODO: Rename
@end
