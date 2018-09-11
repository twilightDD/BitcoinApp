//
//  SOXShowMyOrdersViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 27.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXMyActiveOrdersViewController.h"
#import "SOXAbstractViewController_Private.h"

#import "SOXMyOrderDetailsViewController.h"
#import "SOXCreateNewOrderViewController.h"

#import "SOXMarket_BitcoinDE_Core.h"
#import "SOXMyOrderBook_BitcoinDE_Data.h"
#import "SOXMyTrades_BitcoinDE_Data.h"
#import "SOXTradeJob_BitcoinDE_Data.h"
#import "SOXMarket_BitcoinDE_DefTypes.h"
#import "SOXKeys_BitcoinDE.h"

#import "SOXFormatters.h"

NSString *const PresentMyTradesSegueKey = @"PresentMyTradesSegue";
NSString *const PresentMyAccountSegueKey = @"PresentMyAccountSegue";

#pragma mark - Interface
@interface SOXMyActiveOrdersViewController () <SOXChangeOrderProtocol, SOXMarketCoreServerRequestProtocol, NSTableViewDelegate>

#pragma mark IBOutlets
@property (weak) IBOutlet NSPopUpButton *orderStateTypeSelectionPopUpButton;

@property (weak) IBOutlet NSButton *changeButton;
@property (weak) IBOutlet NSButton *removeButton;

#pragma mark Properties
@property (nonatomic) BitcoinDE_OrderStateType selectedOrderStateType;

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
- (void)setupUI {
    [super setupUI];

    { // buttons
        // orderStateType selection
        [self.orderStateTypeSelectionPopUpButton removeAllItems];
        for (BitcoinDE_OrderStateType idx = BitcoinDE_OrderStateTypeUnknown - 1
             ; idx > BitcoinDE_OrderStateType_EndOfType
             ; idx--) {
            [self.orderStateTypeSelectionPopUpButton addItemWithTitle:[SOXMarket_BitcoinDE_DefTypes orderStateTypeStringForOrderstateType:idx]];
        }
    }

    {
        self.changeButton.title = @"Change order";
        self.removeButton.title = @"Remove order";
    }
    
    {
        [self.tableView setDoubleAction:@selector(tableViewDoubleAction:)];
    }
}

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
        self.changeButton.enabled = NO;
        self.removeButton.enabled = NO;
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

#pragma mark - Table view methods
- (void)tableViewDoubleAction:(NSTableView *)tableView {
    NSArray <SOXMyOrderBook_BitcoinDE_Data *> *selectedObjects = [self.arrayController selectedObjects];
    SOXMyOrderBook_BitcoinDE_Data *selectedMyOrder = selectedObjects.firstObject;
    
    NSStoryboard *storyBoard = [NSStoryboard storyboardWithName:@"MacMain" bundle:nil];
    SOXMyOrderDetailsViewController *viewC = [storyBoard instantiateControllerWithIdentifier:@"MyOrderDetailsViewControllerIdentifier"];
    viewC.myOrder = selectedMyOrder;
    [self presentViewControllerAsSheet:viewC];
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
        [self.arrayControllerDatas addObjectsFromArray:myOrderBookDatas];
        [self.arrayController rearrangeObjects];

        // Page information
        [self updatePagingButtons:payloadDictionary];
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
}

#pragma mark - User information
- (void)informUserAboutDeletion:(NSInteger)countofDeletedObjects {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"Deletion successfull";
    alert.informativeText = [NSString stringWithFormat:@"%ti orders deleted.", countofDeletedObjects];
    alert.alertStyle = NSAlertStyleInformational;
    [alert runModal];
}

#pragma mark - Action methods
- (IBAction)orderStateTypePopUpButtonAction:(NSPopUpButton *)sender {
    BitcoinDE_OrderStateType orderStateType = sender.indexOfSelectedItem * -1;

    if (orderStateType != self.selectedOrderStateType) {
        self.selectedOrderStateType = orderStateType;
        [self resetTradeDatas];
    }
}

- (IBAction)changeButtonAction:(NSButton *)sender {
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

- (IBAction)removeButtonAction:(NSButton *)sender {
    NSArray <SOXMyOrderBook_BitcoinDE_Data *> *selectedDatas = self.arrayController.selectedObjects;
    if (selectedDatas.count > 0) {
        self.changeButton.enabled = NO;
        self.removeButton.enabled = NO;
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

#pragma mark - SOXChangeOrderProtocol
- (void)orderWasChanged:(NSString *)oldOrderID newOrderID:(NSString *)newOrderID {
    [[SOXMarket_BitcoinDE_Core sharedCore] startAccountInfoUpdate];
    [self resetTradeDatas];
    [self loadNextPage];
}

@end
