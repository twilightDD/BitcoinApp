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

@property (strong) IBOutlet NSTextField *startDateTextField;
@property (strong, readwrite) IBOutlet NSDatePicker *startDateDatePicker;
@property (strong) IBOutlet NSTextField *endDateTextField;
@property (strong, readwrite) IBOutlet NSDatePicker *endDateDatePicker;

@property (strong) IBOutlet NSButton *changeOrderButton;
@property (strong) IBOutlet NSButton *removeOrderButton;


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

@property (nonatomic) BOOL shouldLoadAllTradeDatas;

@end

#pragma mark - Implementation
@implementation SOXPagingViewController


#pragma mark - Init & Co.
- (void)viewDidLoad {
    [super viewDidLoad];

    self.selectedCurrencyType = BitcoinDE_CurrencyTypeUnknown;
    self.shouldLoadAllTradeDatas = NO;

    // dates
    self.selectedStartDate = [SOXFormatters dateForRFC3339DateTimeString:@"2000-01-01T02:00:00+02:00" ];
    if (self.selectedEndDate == nil) {
        self.selectedEndDate = [SOXFormatters dateNextDayQuarterBeforeMidnightForDate:[NSDate date]];
    }

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
- (void)loadingPagingButton {
    self.fetchDataButton.title = @"Cancel";
}

- (void)setAllPagingButtonsEnabled:(BOOL)enabled {
    self.loadAllTradeDatasButton.enabled = enabled;
    self.loadMoreTradeDatasButton.enabled = enabled;
    self.fetchDataButton.enabled = enabled;
}

- (void)updatePagingButtonsWithPageData:(SOXPage_BitcoinDE_Data *)pageData
                  whileLoadingMorePages:(BOOL)whileLoadingMorePages {

    BOOL enableLoadMoreTradDatasButton = self.delegate.currentPage != pageData.pageLast;

    if (whileLoadingMorePages) {
        self.loadAllTradeDatasButton.enabled = NO;
        self.loadMoreTradeDatasButton.enabled = NO;
    }
    else {
        self.loadAllTradeDatasButton.enabled = YES;
        self.loadMoreTradeDatasButton.enabled = YES;
        self.fetchDataButton.enabled = YES;
        self.fetchDataButton.title = @"Fetch data";
    }

    // enable load more buttons, if needed
    if (enableLoadMoreTradDatasButton) {
        self.loadAllTradeDatasButton.hidden = NO;
        if (pageData) {
            self.loadAllTradeDatasButton.title = [NSString stringWithFormat:@"Load all (%ti pages left)"
                                                  , pageData.pageLast - pageData.pageCurrent];
        }
        self.loadMoreTradeDatasButton.hidden = NO;
    }
    else {
        self.loadMoreTradeDatasButton.hidden = YES;
        self.loadAllTradeDatasButton.hidden = YES;
        self.fetchDataButton.title = @"Fetch data";
    }
}

- (void)setSeparateEndDate:(NSDate *)selectedEndDate {
    if (selectedEndDate) {
        self.selectedEndDate = selectedEndDate;
        self.endDateDatePicker.dateValue = selectedEndDate;
    }
}


#pragma mark - Action methods
#pragma mark Settings
- (IBAction)popUpButtonActions:(NSPopUpButton *)sender {
    [self.delegate popupButtonAction:sender];
}

- (IBAction)startDatePickerAction:(NSDatePicker *)sender {
    NSDate *newSelectedStartDate = sender.dateValue;

    if ([self.selectedStartDate isEqualToDate:newSelectedStartDate] == NO) {
        self.selectedStartDate = newSelectedStartDate;
        [self resetPagingButtons];
    }
}

- (IBAction)endDatePickerAction:(NSDatePicker *)sender {
    NSDate *newSelectedEndDate = sender.dateValue;

    if ([self.selectedEndDate isEqualToDate:newSelectedEndDate] == NO) {
        self.selectedEndDate = newSelectedEndDate;
        [self resetPagingButtons];
    }
}
#pragma mark Change/Remove order
- (IBAction)changeOrderButtonAction:(NSButton *)sender {
    if ([self.delegate respondsToSelector:@selector(changeOrderButtonPressed)]) {
        [self.delegate changeOrderButtonPressed];
    }
}

- (IBAction)removeOrderButtonAction:(NSButton *)sender {
    if ([self.delegate respondsToSelector:@selector(removeOrderButtonPressed)]) {
        [self.delegate removeOrderButtonPressed];
    }
}

#pragma mark Export
- (IBAction)exportButtonAction:(NSButton *)sender {
    if ([self.delegate respondsToSelector:@selector(exportButtonPressed)]) {
        [self.delegate exportButtonPressed];
    }
 }

#pragma mark Fetch and load buttons
- (IBAction)loadAllTradeDatasAction:(NSButton *)sender {
    [self setAllPagingButtonsEnabled:NO];
    self.fetchDataButton.enabled = YES;
    self.fetchDataButton.title = @"Cancel";
    [self.delegate loadAllTradeDatas];
}

- (IBAction)loadMoreTradeDatasAction:(NSButton *)sender {
    [self setAllPagingButtonsEnabled:NO];
    [self.delegate loadNextPage];
}

- (IBAction)fetchDataButtonAction:(NSButton *)sender {
    [self setAllPagingButtonsEnabled:NO];
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
