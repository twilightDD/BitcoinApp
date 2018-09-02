//
//  SOXPagingAbstractViewController.h
//  BitcoinApp
//
//  Created by Peter Hauke on 27.08.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXAbstractViewController.h"

#import "SOXMarket_BitcoinDE_DefTypes.h"

@interface SOXPagingAbstractViewController : SOXAbstractViewController

// Outlets
// - Parameter
@property (weak) IBOutlet NSPopUpButton *currencyTypeSelectionPopUpButton;
@property (weak) IBOutlet NSPopUpButton *tradingTypeSelectionPopUpButton;

@property (strong) IBOutlet NSButton *loadMoreTradeDatasButton;
@property (strong) IBOutlet NSButton *loadAllTradeDatasButton;
@property (weak)   IBOutlet NSButton *fetchDataButton;
@property (strong) IBOutlet NSArrayController *arrayController;

// - start date
@property (weak) IBOutlet NSTextField *startDateTextField;
@property (weak) IBOutlet NSDatePicker *startDateDatePicker;
// - end date
@property (weak) IBOutlet NSTextField *endDateTextField;
@property (weak) IBOutlet NSDatePicker *endDateDatePicker;

@property (strong, nonatomic) NSDate *selectedStartDate;
@property (strong, nonatomic) NSDate *selectedEndDate;


// Properties
#pragma mark Properties
@property (nonatomic) BitcoinDE_CurrencyType selectedCurrencyType;
@property (nonatomic) BitcoinDE_OrderType selectedOrderType;

@property (strong, nonatomic) NSMutableArray *arrayControllerDatas;
@property (nonatomic) NSInteger currentPage;
@property (nonatomic) BOOL shouldLoadAllTradeDatas;

- (void)setupUI;
- (void)resetTradeDatas;
- (void)loadNextPage;
- (void)updatePagingButtons:(NSDictionary *)payloadDictionary;

- (void)addToPasteBoard:(NSString *)pasteboardString;
@end
