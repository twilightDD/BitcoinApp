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
@property (weak) IBOutlet NSView *pageContainerView;
@property (weak) IBOutlet NSButton *pageBackwardButton;
@property (weak) IBOutlet NSButton *pageForwardButton;
@property (weak) IBOutlet NSTextField *pageIndicatorTextField;

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
@property (strong, nonatomic) NSDate *selectedStartDate;
@property (strong, nonatomic) NSDate *selectedEndDate;

@property (nonatomic) NSInteger currentPage;
@property (nonatomic) NSInteger lastPage;
@property (nonatomic) NSInteger nextPage;

@property (strong, nonatomic) NSMutableArray *myTrades;
@property (strong, nonatomic) NSMutableDictionary *myTradesPaged;

@end

#pragma mark - Implementation
@implementation SOXMyTradesViewController

#pragma mark Init&Co.
- (void)viewDidLoad {
    [super viewDidLoad];
   
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


    [self resetPagingValues];
    [self setupUI];

    [[NSNotificationCenter defaultCenter] postNotificationName:BitcoinDE_Notification_PresentBannerInformationForCurrency
                                                        object:@(BitcoinDE_CurrencyTypeBitcoin)];
}

#pragma mark - Private methods
- (void)setupUI {
    self.pageContainerView.hidden = NO;
    
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
    
    {
        [self.tableView setDoubleAction:@selector(tableViewDoubleAction:)];
    }
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
    [self resetPagingValues];
    [self loadNextPage];
}

#pragma mark - SOXMarketCoreServerRequestProtocol
- (void)answerOfServerRequest:(NSDictionary * _Nonnull)answerOfServerRequest {
    if ([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ShowMyTradesType)]) {
        NSDictionary *payloadDictionary = [answerOfServerRequest objectForKey:ServerAnswerPayloadKey];
        SOXPage_BitcoinDE_Data *pageData = [SOXPage_BitcoinDE_Data pageDataForPayloadDictionary:payloadDictionary];

        self.lastPage = pageData.pageLast;
        self.currentPage = pageData.pageCurrent;

        NSMutableArray *myTrades = [SOXMyTrades_BitcoinDE_Data myTradesDataArrayForMyTradeHistoryDictionary:payloadDictionary];
        [self.myTradesPaged setObject:myTrades
                               forKey:@(self.currentPage)];
        self.myTrades = [self allTrades];

        [self disableSpinningWheel];
    }
}

#pragma mark - Paging
- (void)resetPagingValues {
    self.myTradesPaged = [NSMutableDictionary dictionary];
    self.nextPage = 1;
    self.currentPage = 1;
    self.lastPage = 1;
    [self updatePagingUI];
}


- (void)loadNextPage {
    NSMutableArray *nextPageCache = [self.myTradesPaged objectForKey:@(self.nextPage)];
    if (nextPageCache) {
        self.myTrades = nextPageCache;
        self.currentPage = self.nextPage;
        return;
    }


    BitcoinDE_CurrencyType currencyType = [self.currencyTypeSelectionPopUpButton indexOfSelectedItem] + 1;
    BitcoinDE_MyTradeHistoryParameter_OrderType orderType = [self.tradingTypeSelectionPopUpButton indexOfSelectedItem] + 1;
    BitcoinDE_MyTradeHistoryParameter_TradeStateType tradeStateType = [self.stateTypeSelectionPopUpButton indexOfSelectedItem] + 1;

    NSDictionary *parameterDictionary = [SOXMyTrades_BitcoinDE_Data parameterForOrderType:orderType
                                                                               tradeState:tradeStateType
                                                                             currencyType:currencyType
                                                                                startDate:self.selectedStartDate
                                                                                  endDate:self.selectedEndDate
                                                                                     page:self.nextPage];
    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowMyTradesType
                                            withParameter:parameterDictionary
                                                respondTo:self];
}

- (IBAction)previousPageAction:(NSButton *)sender {
    self.nextPage = self.currentPage - 1;
    [self loadNextPage];
}

- (IBAction)nextPageAction:(NSButton *)sender {
    self.nextPage = self.currentPage + 1;
    [self loadNextPage];
}


- (void)setCurrentPage:(NSInteger)currentPage {
    _currentPage = currentPage;

    [self updatePagingUI];
}

- (void)updatePagingUI {
    self.pageForwardButton.enabled = self.currentPage < self.lastPage;
    self.pageBackwardButton.enabled = self.currentPage > 1;
    self.pageIndicatorTextField.stringValue = [NSString stringWithFormat:@"%ti/%ti"
                                               , self.currentPage
                                               , self.lastPage];
}

- (NSMutableArray *)allTrades {
    NSMutableArray *allTrades = [NSMutableArray array];
    NSArray *sortedTradePageKeys = [self.myTradesPaged.allKeys sortedArrayUsingSelector:@selector(compare:)];
    for (NSNumber *sortIndex in sortedTradePageKeys) {
        [allTrades addObjectsFromArray:[self.myTradesPaged objectForKey:sortIndex]];
    }


    return allTrades;
}

@end
