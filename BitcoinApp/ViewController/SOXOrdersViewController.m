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
#import "SOXFilterOrderViewController.h"

#import "SOXMarket_BitcoinDE_Core.h"
#import "SOXSocketIO_BitcoinDE_Core.h"
#import "SOXShowOrderbook_BitcoinDE_Data.h"

#import "SOXKeys_BitcoinDE.h"
#import "SOXErrorMessage_BitcoinDE.h"
#import "SOXPreferenceCenter.h"

#pragma mark - Interface
@interface SOXOrdersViewController () <SOXMarketCoreServerRequestProtocol, SOXMarketCoreErrorProtocol, SOXSocketIOCoreProtocol, SOXChangeOrderProtocol, NSTableViewDelegate, NSPopoverDelegate>

#pragma mark IBOutlets
@property (weak) IBOutlet NSTextField *titleTextField;

@property (weak) IBOutlet NSButton *otherFilterButton;
@property (strong) IBOutlet NSButton *noSEPAPaymentOptionFilterButton;


@property (weak) IBOutlet NSButton *addOrderButton;

@property (strong) IBOutlet NSArrayController *orderBookArrayController;

#pragma mark Properties
@property (strong, nonatomic) NSMutableArray *orderBook;
@property (strong, nonatomic) NSArray *sortDescriptorsForArrayController;
@property (strong, nonatomic) NSPredicate *orderBookPredicate;
@property (strong, nonatomic) NSPredicate *seatOfBankPredicate;

@property (nonatomic) BOOL socketIODidDisconnectAppeared;
@property (nonatomic, copy) NSString *currencyTypeString;

@property (nonatomic, strong) NSPopover *furtherFilterPopover;
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
   // [self requestServerData];
#endif

//    self.orderBookArrayController.sortDescriptors = [self sortDescriptorsForArrayController];
//    self.orderBookArrayController.filterPredicate = self.orderBookPredicate;
    self.orderBookArrayController.clearsFilterPredicateOnInsertion = NO;

    [SOXMarket_BitcoinDE_Core registerForErrorMessages:self];

    [self.tableView setDoubleAction:@selector(tableViewDoubleAction:)];

    [self setupUI];

    [self updateOrderBookPredicate];
    [self createSortDescriptorsForArrayController];
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

    [SOXPreferenceCenter setSepaPaymentFilterOption:sender.state
                                       forOrderType:self.orderType
                                       currencyType:self.currencyType];
}

- (IBAction)furtherFiltersAction:(NSButton *)sender {
    // Create view controller
    NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"MacMain"
                                                         bundle:nil];
    SOXFilterOrderViewController *viewController = [storyboard instantiateControllerWithIdentifier:@"SOXFilterOrderViewControllerIdentifier"];

    // Create popover
    self.furtherFilterPopover = [[NSPopover alloc] init];
   // [self.furtherFilterPopover setContentSize:NSMakeSize(200.0, 200.0)];
    [self.furtherFilterPopover setBehavior:NSPopoverBehaviorTransient];
    [self.furtherFilterPopover setAnimates:YES];
    [self.furtherFilterPopover setContentViewController:viewController];
    self.furtherFilterPopover.delegate = self;

    // Convert point to main window coordinates
    NSRect entryRect = [sender convertRect:sender.bounds
                                    toView:[[NSApp mainWindow] contentView]];

    // Show popover
    [self.furtherFilterPopover showRelativeToRect:entryRect
                                           ofView:[[NSApp mainWindow] contentView]
                                    preferredEdge:NSMinYEdge];
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

#pragma mark | Array Controller Descriptors
- (void)createSortDescriptorsForArrayController {
    BOOL ascending = NO;
    if (self.orderType == BitcoinDE_BuyOrderType) {
        ascending = YES;
    }

    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"orderInformation_price" ascending:ascending];
    NSArray *sortDesciptors = [NSArray arrayWithObjects:sort, nil];

    self.sortDescriptorsForArrayController = sortDesciptors;
}

#pragma mark | Array Controller Predicate Methods
- (void)updateOrderBookPredicate {
    if (self.paymentOptionPredicate) {
        self.orderBookPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[[self paymentOptionPredicate]
                                                                                       ]];
    }

    if (self.seatOfBankPredicate) {
        self.orderBookPredicate = self.seatOfBankPredicate;
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

    [self.orderBookArrayController rearrangeObjects];
}

- (void)addedOrder:(SOXShowOrderbookData *)addOrderData {
    if (![addOrderData.orderInformation_tradingPair isEqualToString:self.currencyTypeString]) {
        DDLogInfo(@"addedOrder in %@ - tradingPair is %@ - we don't support it right now"
              , [SOXMarket_BitcoinDE_DefTypes orderTypeStringForOrderType:self.orderType]
              , addOrderData.orderInformation_tradingPair);
        return;
    }

    NSLog(@"addedOrder: %@", addOrderData.orderRequirements_paymentOption);

    [self.orderBook addObject:addOrderData];
    [self.orderBookArrayController rearrangeObjects];
}

- (void)removedOrderWithOrderID:(NSDictionary *)payloadDictionary {
    NSString *orderID = [payloadDictionary objectForKey:BitcoinDE_WebSocket_RemoveOrder_OrderID];
    NSMutableArray *foundOrders = [NSMutableArray array];
    
    // check for orderbookData with correct orderID
    for (SOXShowOrderbookData *orderbookData in self.orderBook) {
        if ([orderbookData.orderInformation_orderID isEqualToString:orderID]) {
            [foundOrders addObject:orderbookData];
        }
    }
    
    // remove orderbookData from arrayController
    for (id foundOrder in foundOrders) {
        [self.orderBook removeObject:foundOrder];
    }

    [self.orderBookArrayController rearrangeObjects];
}

-(void)updateOrderWithSocketOrderObjectID:(NSString *)orderObjectID withValues:(NSDictionary *)changesDictionary {
    for (SOXShowOrderbook_BitcoinDE_Data *orderbookData in self.orderBook) {
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

#pragma mark - NSPopoverDelegate
- (void)popoverDidClose:(NSNotification *)notification {

    if (notification.object == self.furtherFilterPopover) {
        SOXFilterOrderViewController *filterOrderViewController = (SOXFilterOrderViewController *)self.furtherFilterPopover.contentViewController;
        NSArray *selectedCountryCodes = filterOrderViewController.selectedCountryCodes;
        if (selectedCountryCodes.count > 0
            && !self.seatOfBankPredicate) {
            NSPredicate *seatOfBankPredicate = [NSPredicate predicateWithFormat:
                                                @"tradingPartnerInformation_seatOfBank IN %@"
                                                , selectedCountryCodes];
            self.seatOfBankPredicate = seatOfBankPredicate;

        }
        else {
            self.seatOfBankPredicate = nil;
        }
        [self updateOrderBookPredicate];
    }

}
@end
