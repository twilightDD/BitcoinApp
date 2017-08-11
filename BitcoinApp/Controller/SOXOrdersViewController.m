//
//  SOXOrdersViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 18.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXOrdersViewController.h"
#import "SOXAbstractViewController_Private.h"

#import "SOXCreateNewOrderViewController.h"
#import "SOXExecuteTradeViewController.h"

#import "SOXMarket_BitcoinDE_Core.h"
#import "SOXSocketIO_BitcoinDE_Core.h"
#import "SOXShowOrderbook_BitcoinDE_Data.h"

#import "SOXKeys_BitcoinDE.h"
#import "SOXErrorMessage_BitcoinDE.h"
#import "SOXPreferenceCenter.h"

#pragma mark - Interface
@interface SOXOrdersViewController () <SOXMarketCoreServerRequestProtocol, SOXMarketCoreErrorProtocol, SOXSocketIOCoreProtocol, NSTableViewDelegate>

#pragma mark IBOutlets
@property (weak) IBOutlet NSTextField *titleTextField;
@property (weak) IBOutlet NSTableView *tableView;

@property (weak) IBOutlet NSButton *otherFilterButton;

@property (weak) IBOutlet NSButton *addOrderButton;

@property (strong) IBOutlet NSArrayController *orderBookArrayController;

#pragma mark Properties
@property (strong, nonatomic) NSMutableArray *orderBook;
@property (nonatomic) BOOL socketIODidDisconnectAppeared;

@end

#pragma mark - Implementation
@implementation SOXOrdersViewController

#pragma mark Init&Co.
- (void)viewDidLoad {
    [super viewDidLoad];
     [self requestServerData];
}

- (void)viewWillAppear {
    [super viewWillAppear];
    
    [SOXMarket_BitcoinDE_Core registerForErrorMessages:self];
    
    [self setupUI];
   
    
    [self.tableView setDoubleAction:@selector(tableViewDoubleAction:)];
}

#pragma mark - Action methods
- (IBAction)reloadAction:(NSButton *)sender {
   [self requestServerData];
}

- (IBAction)addOrderAction:(NSButton *)sender {
    NSLog(@"addOrderAction");
    
    NSStoryboard *storyBoard = [NSStoryboard storyboardWithName:@"MacMain" bundle:nil];
    SOXCreateNewOrderViewController *viewC = [storyBoard instantiateControllerWithIdentifier:@"CreateNewOrderIdentifier"];
    viewC.orderType = self.orderType;
    
    [self presentViewControllerAsSheet:viewC];
}

#pragma mark - Private methods
- (void)setupUI {
    {
        if (self.orderType == BitcoinDE_BuyOrderType) {
            self.titleTextField.stringValue                     = @"Buy";
            self.addOrderButton.title                           = @"Add Buy Order";
        }
        else if (self.orderType == BitcoinDE_SellOrderType) {
            self.titleTextField.stringValue                     = @"Sell";
            self.addOrderButton.title                           = @"Add Sell Order";
        }
    }
    
    self.otherFilterButton.title = @"Filters";
}

- (void)requestServerData {
    [self enableSpinningWheel];
    
    BitcoinDE_ServerCommandType serverCommand = UnknownCommand;
    if (self.orderType == BitcoinDE_BuyOrderType ){
        serverCommand = BitcoinDE_ShowBuyOrderbookCommandType;
    }
    else if (self.orderType == BitcoinDE_SellOrderType) {
        serverCommand = BitcoinDE_ShowSellOrderbookCommandType;
    }
    
    NSDictionary *parameters = [SOXShowOrderbook_BitcoinDE_Data parametersForOrderType:self.orderType
                                                              onlyExpressPaymentOption:NO];
    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:serverCommand
                                            withParameter:parameters
                                                respondTo:self];
}

- (void)registerForWebSocketUpdates {
    if (self.orderType == BitcoinDE_BuyOrderType) {
        [SOXSocketIO_BitcoinDE_Core registerForOrderUpdatesForUpdateType:BitcoinDE_UpdateType_BuyOrderChanges
                                                                delegate:self];
        [SOXSocketIO_BitcoinDE_Core registerForOrderUpdatesForUpdateType:BitcoinDE_UpdateType_RemoveOrderChanges
                                                                delegate:self];
    }
    else if (self.orderType == BitcoinDE_SellOrderType) {
        [SOXSocketIO_BitcoinDE_Core registerForOrderUpdatesForUpdateType:BitcoinDE_UpdateType_SellOrderChanges
                                                                delegate:self];
        [SOXSocketIO_BitcoinDE_Core registerForOrderUpdatesForUpdateType:BitcoinDE_UpdateType_RemoveOrderChanges
                                                                delegate:self];
    }
    else {
        NSLog(@"SOXOrdersViewController - (void)viewWillAppear : self.orderType has wrong type");
    }
}

- (NSArray *)sortDescriptorsForArrayController {
    BOOL ascending = NO;
    if (self.orderType == BitcoinDE_BuyOrderType) {
        ascending = YES;
    }
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"orderInformation_price" ascending:ascending];
    NSArray *sortDesciptors = [NSArray arrayWithObjects:sort, nil];
    
    return sortDesciptors;
}

#pragma mark - Table view handling
- (void)tableViewDoubleAction:(NSTableView *)tableView {
    NSInteger clickedRow = tableView.clickedRow;
    NSUInteger selectionIndex = self.orderBookArrayController.selectionIndex;
    NSArray *selectedObjects = self.orderBookArrayController.selectedObjects;
    
    NSLog(@"\nclickedRow %ti\nselectionIndex %tu\nselectedObjects\n%@",clickedRow, selectionIndex, selectedObjects );
    
    SOXShowOrderbook_BitcoinDE_Data *selectedOrderBookData = selectedObjects.firstObject;
    if (!selectedOrderBookData) {
        return;
    }
    NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"MacMain" bundle:nil];
    SOXExecuteTradeViewController *viewC = [storyboard instantiateControllerWithIdentifier:@"ExecuteTradeViewControllerIdentifier"];
    viewC.orderType = self.orderType;
    viewC.orderBookData = selectedOrderBookData;
    [self presentViewControllerAsSheet:viewC];
}

#pragma mark - SOXMarketCoreServerRequestProtocol
- (void)answerOfServerRequest:(NSDictionary *)answerOfServerRequest {
    if ([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ShowBuyOrderbookCommandType)]
        || [[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ShowSellOrderbookCommandType)]) {
        NSDictionary *payloadDictionary = [answerOfServerRequest objectForKey:ServerAnswerPayloadKey];
        NSMutableArray *orderBook = [SOXShowOrderbook_BitcoinDE_Data orderbookDataArrayForShowOrderbookDictionary:payloadDictionary];
        self.orderBook = orderBook;

        [self disableSpinningWheel];
        self.orderBookArrayController.sortDescriptors = [self sortDescriptorsForArrayController];
        [self registerForWebSocketUpdates]; // after basic dataset, so self.orderBook != nil;
    }
}

#pragma mark - SOXSocketIOCoreProtocol
- (void)socketIODidConnect:(NSString *)socketStatus {
    if (self.socketIODidDisconnectAppeared) {
        self.socketIODidDisconnectAppeared = NO;
        [self requestServerData];
    }
}

- (void)socketIODidDisconnect:(NSString *)socketStatus {
    self.socketIODidDisconnectAppeared = YES;

    // Flush orderBooks
    [self.orderBook removeAllObjects];
    [self.orderBookArrayController rearrangeObjects];
}

- (void)addedOrder:(SOXShowOrderbookData *)addOrderData {
    if (![addOrderData.orderInformation_tradingPair isEqualToString:BitcoinDE_BitcoinOriginal]) {
        NSLog(@"addedOrder in %@ - tradingPair is %@ - we don't support it right now"
              , [SOXMarket_BitcoinDE_DefTypes orderTypeStringForOrderType:self.orderType]
              , addOrderData.orderInformation_tradingPair);
        return;
    }

    [self.orderBookArrayController addObject:addOrderData];
    [self.orderBookArrayController rearrangeObjects];
}

- (void)removedOrderWithOrderID:(NSDictionary *)payloadDictionary {
    NSString *orderID = [payloadDictionary objectForKey:BitcoinDE_WebSocket_RemoveOrder_OrderID];
    NSArray *arrangedObjects = self.orderBookArrayController.arrangedObjects;
    NSMutableArray *foundOrders = [NSMutableArray array];
    
    // check for orderbookData with correct orderID
    for (SOXShowOrderbookData *orderbookData in arrangedObjects) {
        if ([orderbookData.orderInformation_orderID isEqualToString:orderID]) {
            [foundOrders addObject:orderbookData];
        }
    }
    
    // remove orderbookData from arrayController
    for (id foundOrder in foundOrders) {
        [self.orderBookArrayController removeObject:foundOrder];
    }
}
-(void)updateOrderWithSocketOrderObjectID:(NSString *)orderObjectID withValues:(NSDictionary *)changesDictionary {
    NSArray *arrangedObjects = self.orderBookArrayController.arrangedObjects;
    
    for (SOXShowOrderbook_BitcoinDE_Data *orderbookData in arrangedObjects) {
        if ([orderbookData.orderInformation_socketOrderObjectID isEqualToString:orderObjectID]) {
            // ist data object mit orderObjectID vorhanden? Ja: updaten!
            [orderbookData updateOrderbookDataWith:changesDictionary];
        }
    }
}

#pragma mark - SOXMarketCoreErrorProtocol
- (void)presentErrorMessage:(SOXErrorMessage_BitcoinDE *)errorMessage {
    if (errorMessage && errorMessage.hasError) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = errorMessage.serverRequestTitle;
        alert.informativeText = errorMessage.errorMessage;
        alert.alertStyle = NSAlertStyleCritical;
        [alert runModal];
    }
}

@end
