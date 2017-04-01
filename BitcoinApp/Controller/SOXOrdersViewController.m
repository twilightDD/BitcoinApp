//
//  SOXOrdersViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 18.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXOrdersViewController.h"

#import "SOXMarket_BitcoinDE_Core.h"
#import "SOXSocketIO_BitcoinDE_Core.h"
#import "SOXShowOrderbook_BitcoinDE_Data.h"

#import "SOXKeys_BitcoinDE.h"
#import "SOXErrorMessage_BitcoinDE.h"

#pragma mark - Interface
@interface SOXOrdersViewController () <SOXMarketCoreServerRequestProtocol, SOXMarketCoreErrorProtocol, SOXSocketIOCoreProtocol, NSTableViewDelegate>

#pragma mark IBOutlets
@property (weak) IBOutlet NSTextField *titleTextField;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTextField *filterPriceDescriptionTextField;
@property (weak) IBOutlet NSTextField *filterPriceValueTextField;
@property (weak) IBOutlet NSButton *otherFilterButton;
@property (strong) IBOutlet NSArrayController *orderBookArrayController;

@property (weak) IBOutlet NSView *spinningBackgroundView;
@property (weak) IBOutlet NSProgressIndicator *circularProgressIndicator;

#pragma mark Properties
@property (strong, nonatomic) NSMutableArray *orderBook;

@end

#pragma mark - Implementation
@implementation SOXOrdersViewController

#pragma mark Init&Co.
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear {
    [super viewWillAppear];
    
    [SOXMarket_BitcoinDE_Core registerForErrorMessages:self];
    
    [self setupUI];
    [self requestServerData];
    
    [self.tableView setDoubleAction:@selector(tableViewDoubleAction:)];
    
    [SOXSocketIO_BitcoinDE_Core registerForAllOrderUpdatesWithDelegate:self];
}

-(void)viewDidAppear {
    [super viewDidAppear];

    self.spinningBackgroundView.hidden = NO;
    [self.circularProgressIndicator startAnimation:nil];
}

- (IBAction)reloadAction:(NSButton *)sender {
    NSLog(@"Manually reload Data");
   // [self requestServerData];
}

#pragma mark - Private methods
- (void)setupUI {
    {
        NSString *titleText = nil;
        if (self.orderType == OrdersBuyType) {
            titleText = @"Buy";
        }
        else {
            titleText = @"Sell";
        }
        self.titleTextField.stringValue = titleText;
    }
    
    self.filterPriceDescriptionTextField.stringValue = @"Minimum price";
    self.otherFilterButton.title = @"More filters";
    
    self.spinningBackgroundView.layer.backgroundColor = [NSColor colorWithCalibratedRed:0
                                                                                  green:0
                                                                                   blue:0
                                                                                  alpha:0.1].CGColor;
}

- (void)requestServerData {
    if (self.orderType == OrdersBuyType) {
        [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowBuyOrderbookCommandType // "buy" liefert Verkaufsangebote
                                                    respondTo:self];
    }
    else if (self.orderType == OrdersSellType) {
        [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowSellOrderbookCommandType //"sell" liefert Kaufangebote
                                                    respondTo:self];
    }
    else {
        NSLog(@"SOXOrdersViewController - (void)viewWillAppear : self.orderType has wrong type");
    }
}

- (void)registerForWebSocketUpdates {
    if (self.orderType == OrdersBuyType) {
        [SOXSocketIO_BitcoinDE_Core registerForOrderUpdatesForUpdateType:BitcoinDE_UpdateType_BuyOrderChanges
                                                                delegate:self];
        [SOXSocketIO_BitcoinDE_Core registerForOrderUpdatesForUpdateType:BitcoinDE_UpdateType_RemoveOrderChanges
                                                                delegate:self];
    }
    else if (self.orderType == OrdersSellType) {
        [SOXSocketIO_BitcoinDE_Core registerForOrderUpdatesForUpdateType:BitcoinDE_UpdateType_SellOrderChanges
                                                                delegate:self];
        [SOXSocketIO_BitcoinDE_Core registerForOrderUpdatesForUpdateType:BitcoinDE_UpdateType_RemoveOrderChanges
                                                                delegate:self];
    }
    else {
        NSLog(@"SOXOrdersViewController - (void)viewWillAppear : self.orderType has wrong type");
    }
}

#pragma mark - Table view handling
- (void)tableViewDoubleAction:(NSTableView *)tableView {
    NSInteger clickedRow = tableView.clickedRow;
    NSUInteger selectionIndex = self.orderBookArrayController.selectionIndex;
    NSArray *selectedObjects = self.orderBookArrayController.selectedObjects;
    
    NSLog(@"\nclickedRow %ti\nselectionIndex %tu\nselectedObjects\n%@",clickedRow, selectionIndex, selectedObjects );
    
   // SOXShowOrderbook_BitcoinDE_Data *selectedOrderBookData = selectedObjects.firstObject;
    
    NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"MacMain" bundle:nil];
    NSViewController *viewC = [storyboard instantiateControllerWithIdentifier:@"OrderDetailsViewControllerIdentifier"];
    [self presentViewControllerAsSheet:viewC];
}

#pragma mark - SOXMarketCoreServerRequestProtocol
- (void)answerOfServerRequest:(NSDictionary *)answerOfServerRequest {
    if ([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ShowBuyOrderbookCommandType)]
        || [[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ShowSellOrderbookCommandType)]) {
        NSDictionary *payloadDictionary = [answerOfServerRequest objectForKey:ServerAnswerPayloadKey];
        NSMutableArray *orderBook = [SOXShowOrderbook_BitcoinDE_Data orderbookDataArrayForShowOrderbookDictionary:payloadDictionary];
        self.orderBook = orderBook;

        [self.circularProgressIndicator stopAnimation:nil];
        self.spinningBackgroundView.hidden = YES;
    }
    
    [self registerForWebSocketUpdates]; // after basic dataset, so self.orderBook != nil;
}

#pragma mark - SOXSocketIOCoreProtocol
- (void)addedOrder:(SOXShowOrderbookData *)addOrderData {
    [self.orderBookArrayController addObject:addOrderData];
    [self.orderBookArrayController rearrangeObjects];
}

- (void)removedOrderWithOrderID:(NSString *)orderID {
    
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
