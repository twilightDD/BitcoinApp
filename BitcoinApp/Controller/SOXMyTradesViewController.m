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
// - order type
@property (weak) IBOutlet NSTextField *orderTypeTextField;
@property (weak) IBOutlet NSButton *orderTypeBuyRadioButton;
@property (weak) IBOutlet NSButton *orderTypeSellRadioButton;
// - trade state
@property (weak) IBOutlet NSTextField *tradeStateTextField;
@property (weak) IBOutlet NSButton *tradeStateSuccessfulRadioButton;
@property (weak) IBOutlet NSButton *tradeStatePendingRadioButton;
@property (weak) IBOutlet NSButton *tradeStateCancelledRadioButton;
// - start date
@property (weak) IBOutlet NSTextField *startDateTextField;
@property (weak) IBOutlet NSDatePicker *startDateDatePicker;
// - end date
@property (weak) IBOutlet NSTextField *endDateTextField;
@property (weak) IBOutlet NSDatePicker *endDateDatePicker;

// Array controller
@property (strong) IBOutlet NSArrayController *myTradesArrayController;

#pragma mark Properties
@property (nonatomic) NSInteger selectedOrderType;
@property (nonatomic) NSInteger selectedTradeStateType;
@property (strong, nonatomic) NSDate *selectedStartDate;
@property (strong, nonatomic) NSDate *selectedEndDate;
@property (nonatomic) NSInteger selectedPage;

@property (strong, nonatomic) NSMutableArray *myTrades;

@end

#pragma mark - Implementation
@implementation SOXMyTradesViewController

#pragma mark Init&Co.
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)viewWillAppear {
    [super viewWillAppear];
    
    self.selectedOrderType      = BitcoinDE_MyTradeHistoryParameter_BuyOrderType;
    self.selectedTradeStateType = BitcoinDE_MyTradeHistoryParameter_SuccessfulTradeStateType;
   
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
    self.selectedPage = 1;
    
    [self setupUI];
}

#pragma mark - Private methods
- (void)setupUI {
    self.pageContainerView.hidden = YES;
    
    self.fetchDataButton.title = @"Fetch data";
    
    { // Radio buttons
        self.orderTypeTextField.stringValue     = @"Order type";
        self.orderTypeBuyRadioButton.title      = @"Buy";
        self.orderTypeBuyRadioButton.state      = NSOnState;
        self.orderTypeSellRadioButton.title     = @"Sell";
        
        self.tradeStateTextField.stringValue        = @"Trade state";
        self.tradeStateSuccessfulRadioButton.title  = @"Successful";
        self.tradeStateSuccessfulRadioButton.state  = NSOnState;
        self.tradeStatePendingRadioButton.title     = @"Pending";
        self.tradeStateCancelledRadioButton.title   = @"Cancelled";
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
- (IBAction)orderTypeButtonAction:(NSButton *)sender {
    NSLog(@"tag: %ti", sender.tag);
    self.selectedOrderType = sender.tag;
}

- (IBAction)tradeStateButtonAction:(NSButton *)sender {
    NSLog(@"tag: %ti", sender.tag);
    self.selectedTradeStateType = sender.tag;
}
- (IBAction)startDatePickerAction:(NSDatePicker *)sender {
    NSLog(@"startDatePickerAction %@", sender.dateValue);
    
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
    NSLog(@"final StartDate: %@", self.selectedStartDate);
}

- (IBAction)endDatePickerAction:(NSDatePicker *)sender {
    NSLog(@"endDatePickerAction %@", sender.dateValue);
    
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
    NSLog(@"final EndDate: %@", self.selectedEndDate);
}

- (IBAction)fetchDataButtonAction:(NSButton *)sender {
    [self enableSpinningWheel];
    NSDictionary *parameterDictionary = [SOXMyTrades_BitcoinDE_Data parameterForOrderType:self.selectedOrderType
                                                                               tradeState:self.selectedTradeStateType
                                                                                startDate:self.selectedStartDate
                                                                                  endDate:self.selectedEndDate
                                                                                     page:self.selectedPage];
    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowMyTradesType
                                            withParameter:parameterDictionary
                                                respondTo:self];
}

#pragma mark - SOXMarketCoreServerRequestProtocol
- (void)answerOfServerRequest:(NSDictionary * _Nonnull)answerOfServerRequest {
    if ([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ShowMyTradesType)]) {
        NSDictionary *payloadDictionary = [answerOfServerRequest objectForKey:ServerAnswerPayloadKey];
        NSMutableArray *myTrades = [SOXMyTrades_BitcoinDE_Data myTradesDataArrayForMyTradeHistoryDictionary:payloadDictionary];
        self.myTrades = myTrades;
        
        [self disableSpinningWheel];
    }
}

@end
