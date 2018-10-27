//
//  SOXPagingViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 26.10.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXPagingViewController.h"
#import "SOXPagingAbstractViewController_Private.h"

#import "SOXFormatters.h"

#import "SOXKeys_BitcoinDE.h"

#import "SOXPage_BitcoinDE_Data.h"

#pragma mark - Interface
@interface SOXPagingViewController ()

#pragma mark | IBOutlets
@property (strong, readwrite) IBOutlet NSPopUpButton *firstSelectionPopUpButton;
@property (strong, readwrite) IBOutlet NSPopUpButton *secondSelectionPopUpButton;
@property (strong, readwrite) IBOutlet NSPopUpButton *thirdSelectionPopUpButton;

// - start date
@property (strong) IBOutlet NSTextField *startDateTextField;
@property (strong, readwrite) IBOutlet NSDatePicker *startDateDatePicker;
// - end date
@property (strong) IBOutlet NSTextField *endDateTextField;
@property (strong, readwrite) IBOutlet NSDatePicker *endDateDatePicker;

@property (strong) IBOutlet NSButton *exportButton;

@property (strong) IBOutlet NSButton *loadAllTradeDatasButton;
@property (strong) IBOutlet NSButton *loadMoreTradeDatasButton;
@property (strong) IBOutlet NSButton *fetchDataButton;

#pragma mark | Properties
@property (nonatomic, readwrite) BitcoinDE_CurrencyType selectedCurrencyType;
@property (nonatomic, readwrite) BitcoinDE_OrderType selectedOrderType;
@property (nonatomic, readwrite) BitcoinDE_AccountLedgerParameter_OrderType selectedAccountLedgerOrderType;
@property (strong, nonatomic, readwrite) NSDate *selectedStartDate;
@property (strong, nonatomic, readwrite) NSDate *selectedEndDate;


@end

#pragma mark - Implementation
@implementation SOXPagingViewController


#pragma mark - Init & Co.
- (void)viewDidLoad {
    [super viewDidLoad];

    self.selectedCurrencyType = BitcoinDE_CurrencyTypeUnknown;

    // dates
    self.selectedStartDate = [SOXFormatters dateForRFC3339DateTimeString:@"2000-01-01T02:00:00+02:00" ];
    self.selectedEndDate = [SOXFormatters dateNextDayQuarterBeforeMidnightForDate:[NSDate date]];

    [self setupUI];
}



#pragma mark - Public methods
- (void)setupUI {
    [self resetPagingButtons];

    { // date picker
        self.startDateTextField.stringValue = @"Start date";
        self.startDateDatePicker.dateValue  = self.selectedStartDate;
        self.startDateDatePicker.locale = [NSLocale autoupdatingCurrentLocale];

        self.endDateTextField.stringValue   = @"End date";
        self.endDateDatePicker.dateValue    = self.selectedEndDate;
        self.endDateDatePicker.locale = [NSLocale autoupdatingCurrentLocale];
    }
}

#pragma mark Paging
- (void)resetPagingButtons {
    self.fetchDataButton.hidden = NO;
    self.fetchDataButton.enabled = YES;
    self.fetchDataButton.title = @"Fetch data";
    self.loadMoreTradeDatasButton.hidden = YES;
    self.loadAllTradeDatasButton.hidden = YES;
}

- (void)resetTradeDatas {
//    self.currentPage = 0;
    [self resetPagingButtons];
}


- (void)updatePagingButtons:(NSDictionary *)payloadDictionary {
    SOXPage_BitcoinDE_Data *pageData = [SOXPage_BitcoinDE_Data pageDataForPayloadDictionary:payloadDictionary];

    BOOL enableLoadMoreTradDatasButton = self.delegate.currentPage != pageData.pageLast;

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

//    // automatically load further pages, if possible
//    if (self.shouldLoadAllTradeDatas == YES
//        && enableLoadMoreTradDatasButton == YES) {
//        [self loadNextPage];
//    }
//    else {
//        self.shouldLoadAllTradeDatas = NO;
//        self.fetchDataButton.title = @"Fetch data";
//        self.fetchDataButton.enabled = YES;
//        [self.delegate disableSpinningWheel];
//    }


}



#pragma mark - Action methods
#pragma mark Settings
- (IBAction)popUpButtonActions:(NSPopUpButton *)sender {
    [self.delegate popupButtonAction:sender];
}

- (IBAction)firstPopUpButtonAction:(NSPopUpButton *)sender {
//    [self.delegate popUpButtonAction:sender];
    BitcoinDE_CurrencyType newCurrencyType = sender.indexOfSelectedItem + 1;

    // < EndType => on MyActiveOrders and MyTradeHistory
    if (sender.itemArray.count < BitcoinDE_CurrencyType_EndOfType) {
        newCurrencyType = sender.indexOfSelectedItem + 1;
    }
    // == EndType => on MyAccountLedger
    else if (sender.itemArray.count == BitcoinDE_CurrencyType_EndOfType) {
        newCurrencyType = sender.indexOfSelectedItem;
    }
    else {
        NSAssert(NO, @"can't solve this.");
    }

    if (newCurrencyType != self.selectedCurrencyType) {
        self.selectedCurrencyType = newCurrencyType;
        [self resetTradeDatas];

        [[NSNotificationCenter defaultCenter] postNotificationName:BitcoinDE_Notification_PresentBannerInformationForCurrency
                                                            object:@(newCurrencyType)];
    }
}

- (IBAction)orderTypePopUpButtonAction:(NSPopUpButton *)sender {
    BitcoinDE_OrderType newOrderType = sender.indexOfSelectedItem;

    if (newOrderType != self.selectedOrderType) {
        self.selectedOrderType = newOrderType;
        [self resetTradeDatas];
    }
}

- (IBAction)startDatePickerAction:(NSDatePicker *)sender {
    NSDate *newSelectedStartDate = sender.dateValue;

    if ([self.selectedStartDate isEqualToDate:newSelectedStartDate] == NO) {
        self.selectedStartDate = newSelectedStartDate;
        [self resetTradeDatas];
    }
}

- (IBAction)endDatePickerAction:(NSDatePicker *)sender {
    NSDate *newSelectedEndDate = sender.dateValue;

    if ([self.selectedEndDate isEqualToDate:newSelectedEndDate] == NO) {
        self.selectedEndDate = newSelectedEndDate;
        [self resetTradeDatas];
    }
}

#pragma mark Export
- (IBAction)exportButtonAction:(NSButton *)sender {
    [self.delegate startExport];
 }

#pragma mark Fetch and load buttons
- (IBAction)loadAllTradeDatasAction:(NSButton *)sender {
    self.fetchDataButton.enabled = YES;
    self.fetchDataButton.title = @"Cancel";
    [self.delegate loadAllTradeDatas];
}

- (IBAction)loadMoreTradeDatasAction:(NSButton *)sender {
    self.fetchDataButton.enabled = NO;
    [self.delegate loadNextPage];
}

- (IBAction)fetchDataButtonAction:(NSButton *)sender {
    self.fetchDataButton.enabled = NO;
    [self.delegate fetchDatas];
}

#pragma - Pasteboard
- (void)addToPasteBoard:(NSString *)pasteboardString {
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];

    [pasteboard setString:pasteboardString
                  forType:NSPasteboardTypeString];
}


@end
