//
//  SOXMyTradesViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 28.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXMyTradesViewController.h"
#import "SOXAbstractViewController_Private.h"

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


// Parameter
// - currency type
@property (weak) IBOutlet NSTextField *currencyTypeSelectionLabel;
@property (weak) IBOutlet NSPopUpButton *currencyTypeSelectionPopUpButton;

// - order type
@property (weak) IBOutlet NSTextField *tradingTypeSelectionLabel;
@property (weak) IBOutlet NSPopUpButton *tradingTypeSelectionPopUpButton;

// - trade state
@property (weak) IBOutlet NSTextField *stateTypeSelectionLabel;
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

@property (strong, nonatomic) NSMutableArray *myTrades;

@end

#pragma mark - Implementation
@implementation SOXMyTradesViewController

#pragma mark Init&Co.
- (void)viewDidLoad {
    [super viewDidLoad];

    // Defaults for types
    self.selectedCurrencyType = BitcoinDE_CurrencyTypeBitcoin;
    self.selectedOrderType = BitcoinDE_MyTradeHistoryParameter_AllOrderType;
    self.selectedTradeStateType = BitcoinDE_MyTradeHistoryParameter_SuccessfulTradeStateType;

    // StartDate
    {
        self.selectedStartDate      = [NSDate dateWithTimeInterval:-1*60*60*24*7 sinceDate:[NSDate date]];
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        //gather date components from date
        NSDateComponents *startDateComponents = [calendar components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear)
                                                            fromDate:self.selectedStartDate];
        
        
        //set date components
        startDateComponents.day   = startDateComponents.day;
        startDateComponents.month = startDateComponents.month;
        startDateComponents.year  = startDateComponents.year;
        
        startDateComponents.hour   = 0;
        startDateComponents.minute = 0;
        startDateComponents.second = 0;
        self.selectedStartDate = [calendar dateFromComponents:startDateComponents];
    }

    self.selectedEndDate        = [NSDate date];

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
        self.currencyTypeSelectionLabel.stringValue = @"Selection currency";
        [self.currencyTypeSelectionPopUpButton removeAllItems];
        for (BitcoinDE_CurrencyType idx = BitcoinDE_CurrencyTypeUnknown + 1
             ; idx < BitcoinDE_CurrencyType_EndOfType
             ; idx++) {
            [self.currencyTypeSelectionPopUpButton addItemWithTitle:[SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:idx]];
        }

        // tradingType selection
        self.tradingTypeSelectionLabel.stringValue = @"Select type";
        [self.tradingTypeSelectionPopUpButton removeAllItems];
        for (BitcoinDE_MyTradeHistoryParameter_OrderType idx = BitcoinDE_MyTradeHistoryParameter_UnknownOrderType + 1
             ; idx < BitcoinDE_MyTradeHistoryParameter_EndOfOrderType
             ; idx++) {
            [self.tradingTypeSelectionPopUpButton addItemWithTitle:[SOXMyTrades_BitcoinDE_Data titleForOrderType:idx]];
        }

        // state selection
        self.stateTypeSelectionLabel.stringValue = @"Select state";
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
    self.loadMoreTradeDatasButton.enabled = NO;
    
    {
        [self.tableView setDoubleAction:@selector(tableViewDoubleAction:)];
    }
}

- (void)resetTradeDatas {
    // reset tableView
    self.myTrades = [NSMutableArray array];
    [self.myTradesArrayController rearrangeObjects];

    // reset paging
    self.currentPage = 0;
    self.loadMoreTradeDatasButton.enabled = NO;
}

#pragma mark - Table view methods
- (void)tableViewDoubleAction:(NSTableView *)tableView {
//    NSArray <SOXMyOrderBook_BitcoinDE_Data *> *selectedObjects = [self.myOrderArrayController selectedObjects];
//    SOXMyOrderBook_BitcoinDE_Data *selectedMyOrder = selectedObjects.firstObject;
//    
//    NSStoryboard *storyBoard = [NSStoryboard storyboardWithName:@"MacMain" bundle:nil];
//    SOXMyOrderDetailsViewController *viewC = [storyBoard instantiateControllerWithIdentifier:@"MyOrderDetailsViewControllerIdentifier"];
//    viewC.myOrder = selectedMyOrder;
//    [self presentViewControllerAsSheet:viewC];
}

#pragma mark - Action methods

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
    DDLogInfo(@"startDatePickerAction %@", sender.dateValue);
    
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
    DDLogInfo(@"final StartDate: %@", self.selectedStartDate);
}

- (IBAction)endDatePickerAction:(NSDatePicker *)sender {
    DDLogInfo(@"endDatePickerAction %@", sender.dateValue);
    
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
    DDLogInfo(@"final EndDate: %@", self.selectedEndDate);
}

- (IBAction)fetchDataButtonAction:(NSButton *)sender {
    [self enableSpinningWheel];

    // reset all fetched datas
    self.loadMoreTradeDatasButton.enabled = NO;

    self.myTrades = [NSMutableArray array];
    self.currentPage = 0;

    [self loadNextPage];
}
- (IBAction)loadMoreTradeDatasAction:(NSButton *)sender {
    self.loadMoreTradeDatasButton.enabled = NO;
    [self loadNextPage];
}

#pragma mark - SOXMarketCoreServerRequestProtocol
- (void)answerOfServerRequest:(NSDictionary * _Nonnull)answerOfServerRequest {
    if ([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ShowMyTradesType)]) {
        NSDictionary *payloadDictionary = [answerOfServerRequest objectForKey:ServerAnswerPayloadKey];

        // Page information
        {
            SOXPage_BitcoinDE_Data *pageData = [SOXPage_BitcoinDE_Data pageDataForPayloadDictionary:payloadDictionary];
            self.currentPage = pageData.pageCurrent;

            BOOL enableLoadMoreTradDatasButton = self.currentPage != pageData.pageLast;
            self.loadMoreTradeDatasButton.enabled = enableLoadMoreTradDatasButton;

        }

        NSMutableArray *myTrades = [SOXMyTrades_BitcoinDE_Data myTradesDataArrayForMyTradeHistoryDictionary:payloadDictionary];
        [self.myTrades addObjectsFromArray:myTrades];
        [self.myTradesArrayController rearrangeObjects];
        [self disableSpinningWheel];
    }
}

#pragma mark - Paging
- (void)loadNextPage {
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
