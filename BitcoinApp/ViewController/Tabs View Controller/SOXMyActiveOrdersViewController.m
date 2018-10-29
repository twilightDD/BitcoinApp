//
//  SOXShowMyOrdersViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 27.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXMyActiveOrdersViewController.h"
#import "SOXAbstractViewController_Private.h"
#import "SOXPagingAbstractViewController_Private.h"
#import "SOXStatisticsAbstractViewController_Private.h"

#import "SOXMyOrderDetailsViewController.h"
#import "SOXCreateNewOrderViewController.h"

#import "SOXMarket_BitcoinDE_Core.h"
#import "SOXMyOrderBook_BitcoinDE_Data.h"
#import "SOXMyTrades_BitcoinDE_Data.h"
#import "SOXTradeJob_BitcoinDE_Data.h"
#import "SOXMarket_BitcoinDE_DefTypes.h"
#import "SOXKeys_BitcoinDE.h"

#import "SOXFormatters.h"

//NSString *const PresentMyTradesSegueKey = @"PresentMyTradesSegue";
//NSString *const PresentMyAccountSegueKey = @"PresentMyAccountSegue";

#pragma mark - Interface
@interface SOXMyActiveOrdersViewController () <SOXChangeOrderProtocol, SOXMarketCoreServerRequestProtocol, NSTableViewDelegate>

#pragma mark IBOutlets

#pragma mark Properties
@property (weak) NSButton *changeOrderButton;
@property (weak) NSButton *removeOrderButton;

@property (nonatomic) NSInteger countOfMyOrderBook_BitcoinDE_DatasToDelete;
@property (nonatomic) NSInteger countOfDeletedMyOrderBook_BitcoinDE_Datas;

@end

#pragma mark - Implementation
@implementation SOXMyActiveOrdersViewController
#pragma mark Init&Co.
- (void)viewDidLoad {
    [super viewDidLoad];

    self.selectedOrderStateType = BitcoinDE_OrderStateTypePending;
}

#pragma mark - Private methods
- (void)loadNextPage {
    [super loadNextPage];

    NSDictionary *parameters = [SOXMyOrderBook_BitcoinDE_Data parameterForOrderType:self.selectedOrderType
                                                                       currencyType:self.selectedCurrencyType
                                                                         orderState:self.selectedOrderStateType
                                                                          startDate:self.selectedStartDate
                                                                            endDate:self.selectedEndDate
                                                                               page:self.currentPage];
//    if (self.selectedTradingPairString.length > 0) {
//        parameters = [NSDictionary dictionaryWithObject:self.selectedTradingPairString
//                                                 forKey:@"trading_pair"];
//    }
    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowMyOrdersCommandType
                                            withParameter:parameters
                                                respondTo:self];
}

- (void)removeOrderBookDatas:(NSArray <SOXMyOrderBook_BitcoinDE_Data *> *)ordersToRemove {
    if (ordersToRemove.count == 1) {
        self.changeOrderButton.enabled = NO;
        self.removeOrderButton.enabled = NO;
        [self enableSpinningWheel];

        self.countOfMyOrderBook_BitcoinDE_DatasToDelete = ordersToRemove.count;

        // get parameterDictionaries for data to delete
        NSArray *myOrderBookParametersToDelete = [SOXMyOrderBook_BitcoinDE_Data parametersForDeletingMyOrderBookDatas:ordersToRemove];
        for (NSDictionary *myOrderBookParameter in myOrderBookParametersToDelete) {
            [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_RemoveOrderType
                                                    withParameter:myOrderBookParameter
                                                        respondTo:self];
        }
    }
}

- (void)informUserAboutDeletion:(NSInteger)countofDeletedObjects {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"Deletion successfull";
    alert.informativeText = [NSString stringWithFormat:@"%ti orders deleted.", countofDeletedObjects];
    alert.alertStyle = NSAlertStyleInformational;
    [alert runModal];
}

#pragma mark | Table view methods
- (void)tableViewDoubleAction:(NSTableView *)tableView {
    NSArray <SOXMyOrderBook_BitcoinDE_Data *> *selectedObjects = [self.arrayController selectedObjects];
    SOXMyOrderBook_BitcoinDE_Data *selectedMyOrder = selectedObjects.firstObject;
    
    NSStoryboard *storyBoard = [NSStoryboard storyboardWithName:@"MacMain" bundle:nil];
    SOXMyOrderDetailsViewController *viewC = [storyBoard instantiateControllerWithIdentifier:@"MyOrderDetailsViewControllerIdentifier"];
    viewC.myOrder = selectedMyOrder;
    [self presentViewControllerAsSheet:viewC];
}

- (void)updateChangeAndRemoveOrderButtons {
    self.changeOrderButton.enabled = NO;
    self.removeOrderButton.enabled = NO;

    NSInteger numberOfSelectedRows = [self.tableView numberOfSelectedRows];
    if (numberOfSelectedRows == 1) {
        self.changeOrderButton.enabled = numberOfSelectedRows;
    }
    if (numberOfSelectedRows > 0) {
        self.removeOrderButton.enabled = numberOfSelectedRows;
    }
}

#pragma mark - SOXMarketCoreServerRequestProtocol
- (void)answerOfServerRequest:(NSDictionary * _Nonnull)answerOfServerRequest {
    [self disableSpinningWheel];

    if ([answerOfServerRequest valueForKey:ServerAnswerErrorKey]) {
#warning  enable fetch button
        return;
    }
    
    if ([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ShowMyOrdersCommandType)]) {
        NSDictionary *payloadDictionary = [answerOfServerRequest objectForKey:ServerAnswerPayloadKey];
        NSMutableArray *myOrderBookDatas = [SOXMyOrderBook_BitcoinDE_Data myOrderbookDataArrayForMyOrderbookDictionary:payloadDictionary];
        [self updateControllerDatasWithDataObjects:myOrderBookDatas
                              andPayloadDictionary:payloadDictionary];
    }
    else if ([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_RemoveOrderType)]){
        NSDictionary *errors = [answerOfServerRequest objectForKey:ServerAnswerErrorKey];
        if (errors.count == 0) {
            self.countOfDeletedMyOrderBook_BitcoinDE_Datas++;
            if (self.countOfMyOrderBook_BitcoinDE_DatasToDelete == self.countOfDeletedMyOrderBook_BitcoinDE_Datas) {

                // Start tableView update
                [self resetTradeDatas];
                [self loadNextPage];
                // inform user
                [self informUserAboutDeletion:self.countOfDeletedMyOrderBook_BitcoinDE_Datas];


                // reset counters
                self.countOfMyOrderBook_BitcoinDE_DatasToDelete = 0;
                self.countOfDeletedMyOrderBook_BitcoinDE_Datas  = 0;

                [[SOXMarket_BitcoinDE_Core sharedCore] startAccountInfoUpdate];
            }
        }
    }

    [self updateTradeStatistics];
}

#pragma mark - NSTableViewDelegate
- (void)tableViewSelectionIsChanging:(NSNotification *)notification {
    [super tableViewSelectionIsChanging:notification];

    // responds to mouse events only
    if (self.tableView == notification.object) {
        [self updateChangeAndRemoveOrderButtons];
    }
}
- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    [super tableViewSelectionDidChange:notification];
    
    if (notification.object == self.tableView) {
        [self updateChangeAndRemoveOrderButtons];
    }
}

#pragma mark - SOXChangeOrderProtocol
- (void)orderWasChanged:(NSString *)oldOrderID newOrderID:(NSString *)newOrderID {
    [[SOXMarket_BitcoinDE_Core sharedCore] startAccountInfoUpdate];
    [self resetTradeDatas];
    [self loadNextPage];
}

#pragma mark - SOXPagingViewControllerProtocol
- (void)pagingViewControllerDidLoad {
    { // popUp buttons
        // currency selection
        self.currencyTypeSelectionPopUpButton = self.pagingViewController.firstSelectionPopUpButton;
        [self.currencyTypeSelectionPopUpButton removeAllItems];
        for (BitcoinDE_CurrencyType idx = BitcoinDE_CurrencyTypeUnknown
             ; idx < BitcoinDE_CurrencyType_EndOfType
             ; idx++) {
            [self.currencyTypeSelectionPopUpButton addItemWithTitle:[SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:idx]];
        }

        // orderType selection
        self.orderTypeSelectionPopUpButton = self.pagingViewController.secondSelectionPopUpButton;
        [self.orderTypeSelectionPopUpButton removeAllItems];
        for (BitcoinDE_OrderType idx = BitcoinDE_UnknownOrderType
             ; idx < BitcoinDE_OrderType_EndOfType
             ; idx++) {
            [self.orderTypeSelectionPopUpButton addItemWithTitle:[SOXMarket_BitcoinDE_DefTypes titleForOrderType:idx]];
        }

        // orderStateType selection
        self.orderStateTypeSelectionPopUpButton = self.pagingViewController.thirdSelectionPopUpButton;
        [self.orderStateTypeSelectionPopUpButton removeAllItems];
        for (BitcoinDE_OrderStateType idx = BitcoinDE_OrderStateTypeUnknown - 1
             ; idx > BitcoinDE_OrderStateType_EndOfType
             ; idx--) {
            [self.orderStateTypeSelectionPopUpButton addItemWithTitle:[SOXMarket_BitcoinDE_DefTypes orderStateTypeStringForOrderstateType:idx]];
        }
    }

    {
        self.changeOrderButton = self.pagingViewController.changeOrderButton;
        self.changeOrderButton.hidden = NO;
        self.changeOrderButton.enabled = NO;
        self.changeOrderButton.title = @"Change";

        self.removeOrderButton = self.pagingViewController.removeOrderButton;
        self.removeOrderButton.hidden = NO;
        self.removeOrderButton.enabled = NO;
        self.removeOrderButton.title = @"Remove";
    }

    {
        [self.tableView setDoubleAction:@selector(tableViewDoubleAction:)];
    }
}

- (void)popupButtonAction:(NSPopUpButton *)sender {
    // currency selection
    if (sender == self.currencyTypeSelectionPopUpButton) {
        BitcoinDE_CurrencyType newCurrencyType = sender.indexOfSelectedItem;
        if (newCurrencyType != self.selectedCurrencyType) {
            self.selectedCurrencyType = newCurrencyType;
            [self resetTradeDatas];
        }
    }
    // orderType selection
    else if (sender == self.orderTypeSelectionPopUpButton) {
        BitcoinDE_OrderType newOrderType = sender.indexOfSelectedItem;
        if (newOrderType != self.selectedOrderType) {
            self.selectedOrderType = newOrderType;
            [self resetTradeDatas];
        }
    }
    // orderStateType
    else if (sender == self.orderStateTypeSelectionPopUpButton) {
        BitcoinDE_OrderStateType newOrderStateType = sender.indexOfSelectedItem * -1;

        if (newOrderStateType != self.selectedOrderStateType) {
            self.selectedOrderStateType = newOrderStateType;
            [self resetTradeDatas];
            BOOL hideChangeAndRemoveButtons = newOrderStateType != BitcoinDE_OrderStateTypePending;
            self.changeOrderButton.hidden = hideChangeAndRemoveButtons;
            self.removeOrderButton.hidden = hideChangeAndRemoveButtons;
        }
    }
}


- (void)changeOrderButtonPressed {
    NSArray <SOXMyOrderBook_BitcoinDE_Data *> *selectedDatas = self.arrayController.selectedObjects;

    if (selectedDatas.count == 1) {
        SOXMyOrderBook_BitcoinDE_Data *orderBookDataToReplace = selectedDatas.firstObject;

        BitcoinDE_OrderType orderType = [SOXMarket_BitcoinDE_DefTypes orderTypeForOrderTypeString:orderBookDataToReplace.orderInformation_type];
        BitcoinDE_CurrencyType currencyType = [SOXMarket_BitcoinDE_DefTypes currencyTypeForTradingPairString:orderBookDataToReplace.orderInformation_tradingPair];
        NSStoryboard *storyBoard = [NSStoryboard storyboardWithName:@"MacMain" bundle:nil];
        SOXCreateNewOrderViewController *viewC = [storyBoard instantiateControllerWithIdentifier:@"CreateNewOrderIdentifier"];
        viewC.orderType = orderType;
        viewC.currencyType = currencyType;
        viewC.orderBookDataToReplace = orderBookDataToReplace;
        viewC.delegate = self;

        [self presentViewControllerAsSheet:viewC];
    }
}

- (void)removeOrderButtonPressed {
    NSArray <SOXMyOrderBook_BitcoinDE_Data *> *selectedDatas = self.arrayController.selectedObjects;
    if (selectedDatas.count > 0) {
        self.changeOrderButton.enabled = NO;
        self.removeOrderButton.enabled = NO;
        [self enableSpinningWheel];

        self.countOfMyOrderBook_BitcoinDE_DatasToDelete = selectedDatas.count;

        // get parameterDictionaries for data to delete
        NSArray *myOrderBookParametersToDelete = [SOXMyOrderBook_BitcoinDE_Data parametersForDeletingMyOrderBookDatas:selectedDatas];
        for (NSDictionary *myOrderBookParameter in myOrderBookParametersToDelete) {
            [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_RemoveOrderType
                                                    withParameter:myOrderBookParameter
                                                        respondTo:self];
        }
    }
}

#pragma mark - SOXExportDataProtocol
- (NSString *)suggestedExportFileName {
    return @"ActiveOrders";
}

@end
