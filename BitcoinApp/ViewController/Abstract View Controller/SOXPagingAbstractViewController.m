//
//  SOXPagingAbstractViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 27.08.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXPagingAbstractViewController.h"

#import "SOXFormatters.h"

#import "SOXKeys_BitcoinDE.h"

#import "SOXPage_BitcoinDE_Data.h"


@implementation SOXPagingAbstractViewController

#pragma mark - Init & Co.
- (void)viewDidLoad {
    [super viewDidLoad];

    self.shouldLoadAllTradeDatas = NO;
    self.selectedCurrencyType = BitcoinDE_CurrencyTypeUnknown;

    // dates
    self.selectedStartDate = [SOXFormatters dateForRFC3339DateTimeString:@"2000-01-01T02:00:00+02:00" ];
    self.selectedEndDate = [NSDate date];

    [self setupUI];
}

- (void)viewWillAppear {
    [super viewWillAppear];

    if (self.arrayControllerDatas.count == 0) {
        [self resetTradeDatas];
        [self loadNextPage];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:BitcoinDE_Notification_PresentBannerInformationForCurrency
                                                        object:@(self.selectedCurrencyType)];
}

#pragma mark - Public methods
- (void)setupUI {
    [self resetPagingButtons];

    // currency selection
    [self.currencyTypeSelectionPopUpButton removeAllItems];
    for (BitcoinDE_CurrencyType idx = BitcoinDE_CurrencyTypeUnknown
         ; idx < BitcoinDE_CurrencyType_EndOfType
         ; idx++) {
        [self.currencyTypeSelectionPopUpButton addItemWithTitle:[SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:idx]];
    }

    // tradingType selection
    [self.tradingTypeSelectionPopUpButton removeAllItems];
    [self.tradingTypeSelectionPopUpButton addItemWithTitle:@"All"];
    for (BitcoinDE_OrderType idx = BitcoinDE_UnknownOrderType + 1
         ; idx < BitcoinDE_OrderType_EndOfType
         ; idx++) {
        [self.tradingTypeSelectionPopUpButton addItemWithTitle:[SOXMarket_BitcoinDE_DefTypes orderTypeStringForOrderType:idx]];
    }

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

#pragma mark - Private methods
- (void)saveString:(NSString *)stringToSave {
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    savePanel.allowedFileTypes = @[@"csv"];

    [savePanel beginWithCompletionHandler:^(NSModalResponse result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSError *error = nil;
            NSURL *selectedURL = savePanel.URL;
            [stringToSave writeToURL:selectedURL
                          atomically:YES
                            encoding:NSUTF16StringEncoding
                               error:&error];
            if (error) {
                NSLog(@"%@", error.localizedDescription);
            }

        }
    }];
}

- (NSDate *)formatDate:(NSDate *)date {
    //gather current calendar
    NSCalendar *calendar = [NSCalendar currentCalendar];

    //gather date components from date
    NSDateComponents *inputDateComponents = [calendar components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear)
                                                        fromDate:date];

    NSDateComponents *selectedStartDateComponents = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond)
                                                                fromDate:[NSDate date]];
    //set date components
    selectedStartDateComponents.day   = inputDateComponents.day;
    selectedStartDateComponents.month = inputDateComponents.month;
    selectedStartDateComponents.year  = inputDateComponents.year;

    NSDate *formatDate = [calendar dateFromComponents:selectedStartDateComponents];

    return formatDate;
}

#pragma mark - Action methods
#pragma mark Settings
- (IBAction)currencyTypPopUpButtonAction:(NSPopUpButton *)sender {
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
    NSDate *newSelectedStartDate = [self formatDate:sender.dateValue];

    if ([self.selectedStartDate isEqualToDate:newSelectedStartDate] == NO) {
        self.selectedStartDate = newSelectedStartDate;
        [self resetTradeDatas];
    }
}

- (IBAction)endDatePickerAction:(NSDatePicker *)sender {
    NSDate *newSelectedEndDate = [self formatDate:sender.dateValue];

    if ([self.selectedEndDate isEqualToDate:newSelectedEndDate] == NO) {
        self.selectedEndDate = newSelectedEndDate;
        [self resetTradeDatas];
    }
}

#pragma mark Export
- (IBAction)exportButtonAction:(NSButton *)sender {
    // get columnTitles
    NSArray <NSString *> *columnTitles = [self.tableView.tableColumns valueForKey:@"identifier"];
    NSUInteger columnTitlesCount = columnTitles.count - 1;

    // get objects to export
    NSArray *arrayControllerObjects = self.arrayController.selectedObjects;
    if (arrayControllerObjects.count == 0) {
        arrayControllerObjects = self.arrayController.arrangedObjects;
    }
    NSUInteger dataObjectsCounts = arrayControllerObjects.count - 1;

    // first line in a csv are headers
    __block NSString *exportString = [columnTitles componentsJoinedByString:@";"];
    exportString = [exportString stringByAppendingString:@"\n"];

    // enum objects
    [arrayControllerObjects enumerateObjectsUsingBlock:^(id _Nonnull dataObj, NSUInteger dataIdx, BOOL * _Nonnull stop) {
        // enum columns
        [columnTitles enumerateObjectsUsingBlock:^(NSString * _Nonnull columnTitle, NSUInteger columnIdx, BOOL * _Nonnull stop) {
            if (columnTitle.length > 0) {
                // get value for columnTitle and convert it to string
                id valueForColumnTitle = [dataObj valueForKey:columnTitle];
                if (valueForColumnTitle) {
                    // convert to string, if needed
                    if ([valueForColumnTitle isKindOfClass:[NSNumber class]]) {
                        if ([columnTitle containsString:@"volume"]
                            || [columnTitle containsString:@"price"]
                            || [columnTitle containsString:@"Price"]
                            || [columnTitle containsString:@"Eur"]) {
                            valueForColumnTitle = [SOXFormatters currencyStringForNumber:valueForColumnTitle
                                                                            roundingMode:NSNumberFormatterRoundHalfEven];
                        }
                        else if ([columnTitle containsString:@"amount"]
                                 || [columnTitle containsString:@"BTC"]
                                 || [columnTitle containsString:@"Cash"]
                                 || [columnTitle containsString:@"Balance"]) {
                            valueForColumnTitle = [[SOXFormatters bitcoinNumberWithoutCurrencySymbolFormatter] stringFromNumber:valueForColumnTitle];
                        }
                        else {
                            valueForColumnTitle = [valueForColumnTitle stringValue];
                        }
                    }
                    else if ([valueForColumnTitle isKindOfClass:[NSDate class]]) {
                        valueForColumnTitle = [SOXFormatters shortDateShortTimeStringForDate:valueForColumnTitle];
                    }
                    exportString = [exportString stringByAppendingString:valueForColumnTitle];
                }

                // there is no separator after the last value
                if (columnIdx < columnTitlesCount) {
                    exportString = [exportString stringByAppendingString:@";"];
                }
            }
        }];

        // next line for next object
        if (dataIdx < dataObjectsCounts) {
            exportString = [exportString stringByAppendingString:@"\n"];
        }
    }];

    [self addToPasteBoard:exportString];

    [self saveString:exportString];
}

#pragma mark Fetch and load buttons
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

#pragma - Pasteboard
- (void)addToPasteBoard:(NSString *)pasteboardString {
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];

    [pasteboard setString:pasteboardString
                  forType:NSPasteboardTypeString];
}


@end
