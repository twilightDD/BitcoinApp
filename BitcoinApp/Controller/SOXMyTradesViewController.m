//
//  SOXMyTradesViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 28.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXMyTradesViewController.h"
#import "SOXAbstractViewController_Private.h"

#import "SOXMyOrderDetailsViewController.h"

#import "SOXFormatters.h"

#import "SOXMarket_BitcoinDE_Core.h"
#import "SOXMyTrades_BitcoinDE_Data.h"
#import "SOXPage_BitcoinDE_Data.h"

#import "SOXKeys_BitcoinDE.h"
#import "SOXMarket_BitcoinDE_DefTypes.h"

#pragma mark - Interface
@interface SOXMyTradesViewController () <SOXMarketCoreServerRequestProtocol>

#pragma mark IBOutlets
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSButton *fetchDataButton;

// Page selector
@property (strong) IBOutlet NSButton *loadMoreTradeDatasButton;
@property (strong) IBOutlet NSButton *loadAllTradeDatasButton;


// Parameter
// - types
@property (weak) IBOutlet NSPopUpButton *currencyTypeSelectionPopUpButton;
@property (weak) IBOutlet NSPopUpButton *tradingTypeSelectionPopUpButton;
@property (weak) IBOutlet NSPopUpButton *stateTypeSelectionPopUpButton;

// - start date
@property (weak) IBOutlet NSTextField *startDateTextField;
@property (weak) IBOutlet NSDatePicker *startDateDatePicker;
// - end date
@property (weak) IBOutlet NSTextField *endDateTextField;
@property (weak) IBOutlet NSDatePicker *endDateDatePicker;

// Array controller
@property (strong) IBOutlet NSArrayController *myTradesArrayController;

#pragma mark Properties
@property (nonatomic) BitcoinDE_CurrencyType selectedCurrencyType;
@property (nonatomic) BitcoinDE_MyTradeHistoryParameter_OrderType selectedOrderType;
@property (nonatomic) BitcoinDE_MyTradeHistoryParameter_TradeStateType selectedTradeStateType;

@property (strong, nonatomic) NSDate *selectedStartDate;
@property (strong, nonatomic) NSDate *selectedEndDate;

@property (nonatomic) NSInteger currentPage;
@property (nonatomic) BOOL shouldLoadAllTradeDatas;

@property (strong, nonatomic) NSMutableArray *myTrades;

@end

#pragma mark - Implementation
@implementation SOXMyTradesViewController

#pragma mark Init&Co.
- (void)viewDidLoad {
    [super viewDidLoad];

    self.shouldLoadAllTradeDatas = NO;

    // Defaults for types
    self.selectedCurrencyType = BitcoinDE_CurrencyTypeBitcoin;
    self.selectedOrderType = BitcoinDE_MyTradeHistoryParameter_AllOrderType;
    self.selectedTradeStateType = BitcoinDE_MyTradeHistoryParameter_SuccessfulTradeStateType;

    // dates
    self.selectedStartDate = [SOXFormatters dateTimeStringForRFC3339DateTimeString:@"2000-01-01T02:00:00+02:00" ];
    self.selectedEndDate = [NSDate date];

    [self setupUI];
}

- (void)viewWillAppear {
    [super viewWillAppear];

    [[NSNotificationCenter defaultCenter] postNotificationName:BitcoinDE_Notification_PresentBannerInformationForCurrency
                                                        object:@(self.selectedCurrencyType)];
}

#pragma mark - Private methods
- (void)setupUI {
    self.fetchDataButton.title = @"Fetch data";
    
    { // Radio buttons
        // currency selection
        [self.currencyTypeSelectionPopUpButton removeAllItems];
        for (BitcoinDE_CurrencyType idx = BitcoinDE_CurrencyTypeUnknown + 1
             ; idx < BitcoinDE_CurrencyType_EndOfType
             ; idx++) {
            [self.currencyTypeSelectionPopUpButton addItemWithTitle:[SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:idx]];
        }

        // tradingType selection
        [self.tradingTypeSelectionPopUpButton removeAllItems];
        for (BitcoinDE_MyTradeHistoryParameter_OrderType idx = BitcoinDE_MyTradeHistoryParameter_UnknownOrderType + 1
             ; idx < BitcoinDE_MyTradeHistoryParameter_EndOfOrderType
             ; idx++) {
            [self.tradingTypeSelectionPopUpButton addItemWithTitle:[SOXMyTrades_BitcoinDE_Data titleForOrderType:idx]];
        }

        // state selection
        [self.stateTypeSelectionPopUpButton removeAllItems];
        for (BitcoinDE_MyTradeHistoryParameter_TradeStateType idx = BitcoinDE_MyTradeHistoryParameter_UnknownTradeStateType + 1
             ; idx < BitcoinDE_MyTradeHistoryParameter_EndOfTradeStateType
             ; idx++) {
            [self.stateTypeSelectionPopUpButton addItemWithTitle:[SOXMyTrades_BitcoinDE_Data titleForTradeStateType:idx]];
        }
    }
    
    { // date picker
        self.startDateTextField.stringValue = @"Start date";
        self.startDateDatePicker.dateValue  = self.selectedStartDate;
        self.startDateDatePicker.locale = [NSLocale autoupdatingCurrentLocale];
        
        
        self.endDateTextField.stringValue   = @"End date";
        self.endDateDatePicker.dateValue    = self.selectedEndDate;
        self.endDateDatePicker.locale = [NSLocale autoupdatingCurrentLocale];
    }

    // Load more trades (paging)
    self.loadMoreTradeDatasButton.hidden = YES;
    self.loadAllTradeDatasButton.hidden = YES;
}

- (void)resetTradeDatas {
    // reset tableView
    self.myTrades = [NSMutableArray array];
    [self.myTradesArrayController rearrangeObjects];

    // reset paging
    self.currentPage = 0;
    self.loadMoreTradeDatasButton.enabled = NO;
}

#pragma mark - Action methods
#pragma mark | Settings
- (IBAction)currencyTypPopUpButtonAction:(NSPopUpButton *)sender {
    BitcoinDE_CurrencyType newCurrencyType = sender.indexOfSelectedItem + 1;

    if (newCurrencyType != self.selectedCurrencyType) {
        self.selectedCurrencyType = newCurrencyType;
        [self resetTradeDatas];

        [[NSNotificationCenter defaultCenter] postNotificationName:BitcoinDE_Notification_PresentBannerInformationForCurrency
                                                            object:@(newCurrencyType)];
    }
}

- (IBAction)orderTypePopUpButtonAction:(NSPopUpButton *)sender {
    BitcoinDE_MyTradeHistoryParameter_OrderType newOrderType = sender.indexOfSelectedItem + 1;

    if (newOrderType != self.selectedOrderType) {
        self.selectedOrderType = newOrderType;
        [self resetTradeDatas];
    }
}

- (IBAction)statePopUpButtonAction:(NSPopUpButton *)sender {
    BitcoinDE_MyTradeHistoryParameter_TradeStateType newTradeState = sender.indexOfSelectedItem + 1;
    if (newTradeState != self.selectedTradeStateType) {
        self.selectedTradeStateType = newTradeState;
        [self resetTradeDatas];
    }
}

- (IBAction)startDatePickerAction:(NSDatePicker *)sender {
    //gather current calendar
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    //gather date components from date
    NSDateComponents *inputDateComponents = [calendar components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear)
                                                        fromDate:sender.dateValue];
    
    NSDateComponents *selectedStartDateComponents = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond)
                                                                fromDate:self.selectedStartDate];
    //set date components
    selectedStartDateComponents.day   = inputDateComponents.day;
    selectedStartDateComponents.month = inputDateComponents.month;
    selectedStartDateComponents.year  = inputDateComponents.year;

    self.selectedStartDate = [calendar dateFromComponents:selectedStartDateComponents];
}

- (IBAction)endDatePickerAction:(NSDatePicker *)sender {
    //gather current calendar
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    //gather date components from date
    NSDateComponents *inputDateComponents = [calendar components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear)
                                                        fromDate:sender.dateValue];
    
    NSDateComponents *selectedEndDateComponents = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond)
                                                              fromDate:[NSDate date]];
    //set date components
    selectedEndDateComponents.day   = inputDateComponents.day;
    selectedEndDateComponents.month = inputDateComponents.month;
    selectedEndDateComponents.year  = inputDateComponents.year;
    
    selectedEndDateComponents.hour   = 23;
    selectedEndDateComponents.minute = 59;
    selectedEndDateComponents.second = 59;
    
    self.selectedEndDate = [calendar dateFromComponents:selectedEndDateComponents];
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
        [self enableSpinningWheel];

        // reset all fetched datas
        self.myTrades = [NSMutableArray array];
        self.currentPage = 0;

        [self loadNextPage];
    }
}

#pragma mark - SOXMarketCoreServerRequestProtocol
- (void)answerOfServerRequest:(NSDictionary * _Nonnull)answerOfServerRequest {
    if ([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ShowMyTradesType)]) {
        NSDictionary *payloadDictionary = [answerOfServerRequest objectForKey:ServerAnswerPayloadKey];

        NSMutableArray *myTrades = [SOXMyTrades_BitcoinDE_Data myTradesDataArrayForMyTradeHistoryDictionary:payloadDictionary];
        [self.myTrades addObjectsFromArray:myTrades];
        [self.myTradesArrayController rearrangeObjects];

        // Page information
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
}

#pragma mark - Paging
- (void)loadNextPage {
    self.loadMoreTradeDatasButton.enabled = NO;
    self.loadAllTradeDatasButton.enabled = NO;

    self.currentPage = self.currentPage + 1;
    NSDictionary *parameterDictionary = [SOXMyTrades_BitcoinDE_Data parameterForOrderType:self.selectedOrderType
                                                                               tradeState:self.selectedTradeStateType
                                                                             currencyType:self.selectedCurrencyType
                                                                                startDate:self.selectedStartDate
                                                                                  endDate:self.selectedEndDate
                                                                                     page:self.currentPage];
    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowMyTradesType
                                            withParameter:parameterDictionary
                                                respondTo:self];
}

@end
