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

#import "SOXKeys_BitcoinDE.h"
#import "SOXMarket_BitcoinDE_DefTypes.h"

#pragma mark - Interface
@interface SOXMyTradesViewController () <SOXMarketCoreServerRequestProtocol>

#pragma mark IBOutlets
@property (weak) IBOutlet NSTableView *tableView;


//// Page selector
//@property (strong) IBOutlet NSButton *loadMoreTradeDatasButton;
//@property (strong) IBOutlet NSButton *loadAllTradeDatasButton;


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
    [super setupUI];
    
    
    
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
}

- (void)resetTradeDatas {
    // reset tableView
    self.arrayControllerDatas = [NSMutableArray array];
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



#pragma mark - SOXMarketCoreServerRequestProtocol
- (void)answerOfServerRequest:(NSDictionary * _Nonnull)answerOfServerRequest {
    if ([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ShowMyTradesType)]) {
        NSDictionary *payloadDictionary = [answerOfServerRequest objectForKey:ServerAnswerPayloadKey];

        NSMutableArray *myTrades = [SOXMyTrades_BitcoinDE_Data myTradesDataArrayForMyTradeHistoryDictionary:payloadDictionary];
        [self.arrayControllerDatas addObjectsFromArray:myTrades];
        [self.myTradesArrayController rearrangeObjects];

        // Page information
        [self updatePagingButtons:payloadDictionary];
    }
}

- (void)loadNextPage {
    [super loadNextPage];

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
