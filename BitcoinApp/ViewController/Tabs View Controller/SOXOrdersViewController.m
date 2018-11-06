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
#import "SOXFilterOptionsPreferenceViewController.h"

#import "SOXMarket_BitcoinDE_Core.h"
#import "SOXSocketIO_BitcoinDE_Core.h"
#import "SOXShowOrderbook_BitcoinDE_Data.h"

#import "SOXKeys_BitcoinDE.h"
#import "SOXErrorMessage_BitcoinDE.h"
#import "SOXPreferenceCenter.h"

#pragma mark - Interface
@interface SOXOrdersViewController () <SOXMarketCoreServerRequestProtocol, SOXMarketCoreErrorProtocol, SOXSocketIOCoreProtocol, SOXChangeOrderProtocol, NSTableViewDelegate, SOXSelectedCountriesViewControllerDelegate>

#pragma mark IBOutlets
@property (weak) IBOutlet NSTextField *titleTextField;

@property (weak) IBOutlet NSButton *otherFilterButton;
@property (weak) IBOutlet NSButton *addOrderButton;

@property (strong) IBOutlet NSArrayController *orderBookArrayController;

#pragma mark Properties
@property (strong, nonatomic) NSMutableArray *orderBook;
@property (strong, nonatomic) NSArray *sortDescriptorsForArrayController;
@property (strong, nonatomic) NSPredicate *orderBookPredicate;
@property (strong, nonatomic) NSPredicate *paymentOptionPredicate;
@property (strong, nonatomic) NSPredicate *seatOfBankPredicate;

@property (nonatomic) BOOL socketIODidDisconnectAppeared;
@property (nonatomic, copy) NSString *currencyTypeString;

@property (strong, nonatomic) id activeCountryCodesPreferencesDidChangeObserver;
@property (strong, nonatomic) id showNoSepaOrdersPreferencesDidChangeObserver;

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
    
    [self setupArrayController];
    
    [self setupObservers];
}

- (void)viewWillAppear {
    [super viewWillAppear];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BitcoinDE_Notification_PresentBannerInformationForCurrency
                                                        object:@(self.currencyType)];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.activeCountryCodesPreferencesDidChangeObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self.showNoSepaOrdersPreferencesDidChangeObserver];
}

#pragma mark - Action methods
- (IBAction)furtherFiltersAction:(NSButton *)sender {
    // Create view controller
    SOXFilterOptionsPreferenceViewController *viewController =
    [[SOXFilterOptionsPreferenceViewController alloc] initWithNibName:@"SOXFilterOptionsPreferenceViewController"
                                                                   bundle:nil];
    viewController.delegate = self;
    viewController.orderType = self.orderType;
    viewController.currencyType = self.currencyType;

    // Create popover
    NSPopover *furtherFilterPopover = [[NSPopover alloc] init];
    furtherFilterPopover.behavior = NSPopoverBehaviorTransient;
    furtherFilterPopover.animates = YES;
    furtherFilterPopover.contentViewController = viewController;

    // Convert point to main window coordinates
    NSRect entryRect = [sender convertRect:sender.bounds
                                    toView:[[NSApp mainWindow] contentView]];
    
    // Show popover
    [furtherFilterPopover showRelativeToRect:entryRect
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
        NSString *currencyString = [SOXMarket_BitcoinDE_DefTypes tradingPairShortStringUpperCaseForCurrencyType:self.currencyType];
        NSString *buySellString = [SOXMarket_BitcoinDE_DefTypes orderTypeStringForOrderType:self.orderType];
        self.addOrderButton.title = [NSString stringWithFormat:@"Create new %@ %@ order"
                                     , currencyString
                                     , buySellString];
        if (self.orderType == BitcoinDE_OrderTypeBuy) {
            self.titleTextField.stringValue                     = @"Buy";
        }
        else if (self.orderType == BitcoinDE_OrderTypeSell) {
            self.titleTextField.stringValue                     = @"Sell";
        }
    }
    
    self.otherFilterButton.title = @"Filters";
    
}

- (void)setupArrayController {
    NSArray *selectedCountriesFromPrefs = [SOXPreferenceCenter activeCountryCodesforOrderType:self.orderType
                                                                                 currencyType:self.currencyType];
    [self updateSelectedCountriesPredicateForCounties:selectedCountriesFromPrefs];

    NSControlStateValue controlStateValue = [SOXPreferenceCenter sepaPaymentOptionStateForOrderType:self.orderType
                                                                                       currencyType:self.currencyType];
    [self updatePaymentOptionPredicateForControlStateValue:controlStateValue];

    [self createSortDescriptorsForArrayController];
}

- (void)setupObservers {
    self.activeCountryCodesPreferencesDidChangeObserver =
    [[NSNotificationCenter defaultCenter] addObserverForName:ActiveCountryCodesPreferencesDidChangeNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      NSArray *activeCountryCodes = note.object;
                                                      [self updateSelectedCountriesPredicateForCounties:activeCountryCodes];
                                                  }];

    self.showNoSepaOrdersPreferencesDidChangeObserver =
    [[NSNotificationCenter defaultCenter] addObserverForName:ShowNoSepaOrdersPreferencesDidChangeNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      NSControlStateValue controlStateValue = [note.object integerValue];
                                                      [self updatePaymentOptionPredicateForControlStateValue:controlStateValue];
                                                  }];
}

- (void)requestServerData {
    [self enableSpinningWheel];
    
    BitcoinDE_ServerCommandType serverCommand = UnknownCommand;
    if (self.orderType == BitcoinDE_OrderTypeBuy ){
        serverCommand = BitcoinDE_ShowBuyOrderbookCommandType;
    }
    else if (self.orderType == BitcoinDE_OrderTypeSell) {
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
    if (self.orderType == BitcoinDE_OrderTypeBuy) {
        [SOXSocketIO_BitcoinDE_Core registerForOrderUpdatesForUpdateType:BitcoinDE_SocketUpdateType_BuyOrderChanges
                                                         forCurrencyType:self.currencyType
                                                                delegate:self];
        [SOXSocketIO_BitcoinDE_Core registerForOrderUpdatesForUpdateType:BitcoinDE_SocketUpdateType_RemoveOrderChanges
                                                         forCurrencyType:self.currencyType
                                                                delegate:self];
    }
    else if (self.orderType == BitcoinDE_OrderTypeSell) {
        [SOXSocketIO_BitcoinDE_Core registerForOrderUpdatesForUpdateType:BitcoinDE_SocketUpdateType_SellOrderChanges
                                                         forCurrencyType:self.currencyType
                                                                delegate:self];
        [SOXSocketIO_BitcoinDE_Core registerForOrderUpdatesForUpdateType:BitcoinDE_SocketUpdateType_RemoveOrderChanges
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
    if (self.orderType == BitcoinDE_OrderTypeBuy) {
        ascending = YES;
    }
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"orderInformation_price" ascending:ascending];
    NSArray *sortDesciptors = [NSArray arrayWithObjects:sort, nil];
    
    self.sortDescriptorsForArrayController = sortDesciptors;
}

#pragma mark | Array Controller Predicate Methods
- (void)updateOrderBookPredicate {
    NSMutableArray *subPredicates = [NSMutableArray array];
    if (self.paymentOptionPredicate) {
        [subPredicates addObject:self.paymentOptionPredicate];
    }
    
    if (self.seatOfBankPredicate) {
        [subPredicates addObject:self.seatOfBankPredicate];
    }
    
    if (subPredicates.count > 0) {
        self.orderBookPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
    }
    else {
        self.orderBookPredicate = nil;
    }
}

- (void)updatePaymentOptionPredicateForControlStateValue:(NSControlStateValue)controlStateValue {
    NSPredicate *paymentOptionPredicate = nil;
    if (controlStateValue == NSControlStateValueOn) {
        paymentOptionPredicate = [NSPredicate predicateWithFormat:
                                  @"orderRequirements_paymentOption == %@"
                                  " OR orderRequirements_paymentOption == %@"
                                  , @(BitcoinDE_PaymentOptionExpressOnly)
                                  , @(BitcoinDE_PaymentOptionExpressAndSepa)];
    }
    
    self.paymentOptionPredicate = paymentOptionPredicate;
}

- (void)updateSelectedCountriesPredicateForCounties:(NSArray *)selectedCountryCodes {
    NSPredicate *selectedCountriesPredicate = [NSPredicate predicateWithFormat:
                                               @"tradingPartnerInformation_seatOfBank IN %@"
                                               , selectedCountryCodes];
    self.seatOfBankPredicate = selectedCountriesPredicate;
}

#pragma mark - Manual Setters
- (void)setPaymentOptionPredicate:(NSPredicate *)paymentOptionPredicate {
    _paymentOptionPredicate = paymentOptionPredicate;
    [self updateOrderBookPredicate];
}

-(void)setSeatOfBankPredicate:(NSPredicate *)seatOfBankPredicate {
    _seatOfBankPredicate = seatOfBankPredicate;
    [self updateOrderBookPredicate];
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

#pragma mark - SOXFilterOrderViewControllerDelegate
- (void)filterSelectionChangedForKey:(NSString *)key withObject:(id)object {
    if (key == FilterOrderViewSelectedCountriesKey) {
        NSParameterAssert([object isKindOfClass:[NSArray class]]);
        [self updateSelectedCountriesPredicateForCounties:object];
    }
    else if (key == FilterOrderViewNoSepaKey) {
        NSParameterAssert([object isKindOfClass:[NSNumber class]]);
        NSControlStateValue controlStateValue = [(NSNumber *)object integerValue];
        [self updatePaymentOptionPredicateForControlStateValue:controlStateValue];
    }
    else {
        NSAssert(NO, @"Unknown key %@", key);
    }
}

@end
