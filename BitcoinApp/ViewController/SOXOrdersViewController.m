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
@interface SOXOrdersViewController () <SOXMarketCoreServerRequestProtocol, SOXMarketCoreErrorProtocol, SOXSocketIOCoreProtocol, SOXChangeOrderProtocol, NSTableViewDelegate>

#pragma mark IBOutlets
@property (weak) IBOutlet NSTextField *titleTextField;

@property (weak) IBOutlet NSButton *otherFilterButton;
@property (strong) IBOutlet NSButton *noSEPAPaymentOptionFilterButton;


@property (weak) IBOutlet NSButton *addOrderButton;

@property (strong) IBOutlet NSArrayController *orderBookArrayController;

#pragma mark Properties
@property (strong, nonatomic) NSMutableArray *orderBook;
@property (strong, nonatomic) NSPredicate *orderBookPredicate;

@property (nonatomic) BOOL socketIODidDisconnectAppeared;
@property (nonatomic, copy) NSString *currencyTypeString;
@end

#pragma mark - Implementation
@implementation SOXOrdersViewController

#pragma mark Init&Co.
- (void)viewDidLoad {
    [super viewDidLoad];
    self.currencyTypeString = [SOXMarket_BitcoinDE_DefTypes tradingPairStringForCurrencyType:self.currencyType];

#if PETER
    // PETER = APP for AppStore
    // Automatic Trade version should not load orderBooks automatically.
    [self requestServerData];
#endif

    self.orderBookArrayController.clearsFilterPredicateOnInsertion = NO;

    [SOXMarket_BitcoinDE_Core registerForErrorMessages:self];

    [self.tableView setDoubleAction:@selector(tableViewDoubleAction:)];

    [self setupUI];

    [self updateOrderBookPredicate];
}

- (void)viewWillAppear {
    [super viewWillAppear];


    [[NSNotificationCenter defaultCenter] postNotificationName:BitcoinDE_Notification_PresentBannerInformationForCurrency
                                                        object:@(self.currencyType)];
}

#pragma mark - Action methods
#pragma mark | Payment Options
- (IBAction)noSEPAPaymentOptionFilterButtonAction:(NSButton *)sender {
    [self updateOrderBookPredicate];
}

#pragma mark |
- (IBAction)reloadAction:(NSButton *)sender {
   [self requestServerData];
}

- (IBAction)addOrderAction:(NSButton *)sender {
    DDLogInfo(@"addOrderAction");
    
    NSStoryboard *storyBoard = [NSStoryboard storyboardWithName:@"MacMain" bundle:nil];
    SOXCreateNewOrderViewController *viewC = [storyBoard instantiateControllerWithIdentifier:@"CreateNewOrderIdentifier"];
    viewC.orderType = self.orderType;
    viewC.currencyType = self.currencyType;
    viewC.delegate = self;
    
    [self presentViewControllerAsSheet:viewC];
}

#pragma mark - Private methods
- (void)setupUI {
    {
        if (self.orderType == BitcoinDE_BuyOrderType) {
            self.titleTextField.stringValue                     = @"Buy";
            self.addOrderButton.title                           = @"I'd like to buy";
        }
        else if (self.orderType == BitcoinDE_SellOrderType) {
            self.titleTextField.stringValue                     = @"Sell";
            self.addOrderButton.title                           = @"I'd like to sell";
        }
    }
    
    self.otherFilterButton.title = @"Filters";
    self.noSEPAPaymentOptionFilterButton.title = @"No SEPA";
    NSControlStateValue noSEPAButtonControlState = [SOXPreferenceCenter sepaPaymentOptionStateForOrderType:self.orderType
                                                                                              currencyType:self.currencyType];
    self.noSEPAPaymentOptionFilterButton.state = noSEPAButtonControlState;
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
                                                                          currencyType:self.currencyType
                                                              onlyExpressPaymentOption:NO];
    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:serverCommand
                                            withParameter:parameters
                                                respondTo:self];
}

- (void)registerForWebSocketUpdates {
    if (self.orderType == BitcoinDE_BuyOrderType) {
        [SOXSocketIO_BitcoinDE_Core registerForOrderUpdatesForUpdateType:BitcoinDE_UpdateType_BuyOrderChanges
                                                         forCurrencyType:self.currencyType
                                                                delegate:self];
        [SOXSocketIO_BitcoinDE_Core registerForOrderUpdatesForUpdateType:BitcoinDE_UpdateType_RemoveOrderChanges
                                                         forCurrencyType:self.currencyType
                                                                delegate:self];
    }
    else if (self.orderType == BitcoinDE_SellOrderType) {
        [SOXSocketIO_BitcoinDE_Core registerForOrderUpdatesForUpdateType:BitcoinDE_UpdateType_SellOrderChanges
                                                         forCurrencyType:self.currencyType
                                                                delegate:self];
        [SOXSocketIO_BitcoinDE_Core registerForOrderUpdatesForUpdateType:BitcoinDE_UpdateType_RemoveOrderChanges
                                                         forCurrencyType:self.currencyType
                                                                delegate:self];
    }
    else {
        DDLogInfo(@"SOXOrdersViewController - (void)viewWillAppear : self.orderType has wrong type");
    }
}

#pragma mark - Array Controller Descriptors
- (NSArray *)sortDescriptorsForArrayController {
    BOOL ascending = NO;
    if (self.orderType == BitcoinDE_BuyOrderType) {
        ascending = YES;
    }
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"orderInformation_price" ascending:ascending];
    NSArray *sortDesciptors = [NSArray arrayWithObjects:sort, nil];
    
    return sortDesciptors;
}

#pragma mark - Array Controller Predicate Methods
- (void)updateOrderBookPredicate {
    if (self.paymentOptionPredicate) {
        self.orderBookPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[[self paymentOptionPredicate]
                                                                                       ]];
    }
    else {
        self.orderBookPredicate = nil;
    }
}

- (NSPredicate *)paymentOptionPredicate {
    if (self.noSEPAPaymentOptionFilterButton.state == NSControlStateValueOn) {
        NSPredicate *paymentOptionPredicate;
        paymentOptionPredicate = [NSPredicate predicateWithFormat:
                                  @"orderRequirements_paymentOption == %@"
                                  " OR orderRequirements_paymentOption == %@"
                                  , @(BitcoinDE_PaymentOptionExpressOnly)
                                  , @(BitcoinDE_PaymentOptionExpressAndSepa)];

        return paymentOptionPredicate;
    }

    return nil;
}

#pragma mark - Table view handling
- (void)tableViewDoubleAction:(NSTableView *)tableView {
    NSInteger clickedRow = tableView.clickedRow;
    NSUInteger selectionIndex = self.orderBookArrayController.selectionIndex;
    NSArray *selectedObjects = self.orderBookArrayController.selectedObjects;
    
    DDLogInfo(@"\nclickedRow %ti\nselectionIndex %tu\nselectedObjects\n%@",clickedRow, selectionIndex, selectedObjects );
    
    SOXShowOrderbook_BitcoinDE_Data *selectedOrderBookData = selectedObjects.firstObject;
    if (!selectedOrderBookData) {
        return;
    }

    NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"MacMain" bundle:nil];
    SOXExecuteTradeViewController *viewC = [storyboard instantiateControllerWithIdentifier:@"ExecuteTradeViewControllerIdentifier"];
    viewC.orderType = self.orderType;
    viewC.currencyType = self.currencyType;
    viewC.orderBookData = selectedOrderBookData;
    [self presentViewControllerAsSheet:viewC];
}

#pragma mark - SOXMarketCoreServerRequestProtocol
- (void)answerOfServerRequest:(NSDictionary *)answerOfServerRequest {
    NSArray *errorArray = [answerOfServerRequest objectForKey:ServerAnswerErrorKey];
    if (errorArray) {
        DDLogInfo(@"SOXAutomaticTrading_BitcoinDE_Core - answerOfServerRequest with error:\n%@", errorArray);
    }

    if ([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ShowBuyOrderbookCommandType)]
        || [[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ShowSellOrderbookCommandType)]) {

        // Request server data again on nonce error
        if (errorArray) {
            NSNumber *errorCode = [errorArray.firstObject objectForKey:@"code"];
            if ([errorCode isEqualToNumber:@4]) {
                DDLogInfo(@"ErrorCode 4 - requestServerData %tu",
                          self.orderType);
                [self requestServerData];
                return;
            }
        }

        NSDictionary *payloadDictionary = [answerOfServerRequest objectForKey:ServerAnswerPayloadKey];
        NSMutableArray *orderBook = [SOXShowOrderbook_BitcoinDE_Data orderbookDataArrayForShowOrderbookDictionary:payloadDictionary];
        self.orderBook = orderBook;

        [self disableSpinningWheel];
        self.orderBookArrayController.sortDescriptors = [self sortDescriptorsForArrayController];
        self.orderBookArrayController.filterPredicate = self.orderBookPredicate;
#if PETER
        // PETER = APP for AppStore
        // Automatic Trade version should not load orderBooks automatically.
        [self registerForWebSocketUpdates]; // after basic dataset, so self.orderBook != nil;
#endif
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
    self.orderBookArrayController.sortDescriptors = [self sortDescriptorsForArrayController];
    self.orderBookArrayController.filterPredicate = self.orderBookPredicate;
    [self.orderBookArrayController rearrangeObjects];
}

- (void)addedOrder:(SOXShowOrderbookData *)addOrderData {
    if (![addOrderData.orderInformation_tradingPair isEqualToString:self.currencyTypeString]) {
        DDLogInfo(@"addedOrder in %@ - tradingPair is %@ - we don't support it right now"
              , [SOXMarket_BitcoinDE_DefTypes orderTypeStringForOrderType:self.orderType]
              , addOrderData.orderInformation_tradingPair);
        return;
    }

    [self.orderBookArrayController addObject:addOrderData];
    self.orderBookArrayController.sortDescriptors = [self sortDescriptorsForArrayController];
    self.orderBookArrayController.filterPredicate = self.orderBookPredicate;
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

    self.orderBookArrayController.sortDescriptors = [self sortDescriptorsForArrayController];
    self.orderBookArrayController.filterPredicate = self.orderBookPredicate;
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

#pragma mark - SOXChangeOrderProtocol
- (void)orderWasChanged:(NSString *)oldOrderID newOrderID:(NSString *)newOrderID {
    // TODO: orderbook views will be empty - but why?!?!?!
    [[SOXMarket_BitcoinDE_Core sharedCore] startAccountInfoUpdate];
}

@end
