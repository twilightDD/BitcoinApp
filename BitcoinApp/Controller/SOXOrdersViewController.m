//
//  SOXOrdersViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 18.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXOrdersViewController.h"

#import "SOXMarket_BitcoinDE_Core.h"
#import "SOXShowOrderbook_BitcoinDE_Data.h"

#pragma mark - Interface
@interface SOXOrdersViewController () <SOXMarketCoreServerRequestProtocol, NSTableViewDelegate>

#pragma mark IBOutlets
@property (weak) IBOutlet NSTextField *titleTextField;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTextField *filterPriceDescriptionTextField;
@property (weak) IBOutlet NSTextField *filterPriceValueTextField;
@property (weak) IBOutlet NSButton *otherFilterButton;
@property (strong) IBOutlet NSArrayController *orderBookArrayController;

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
    
    [self setupUI];
    [self requestServerData];
    
    [self.tableView setDoubleAction:@selector(tableViewDoubleAction:)];
}

- (IBAction)reloadAction:(NSButton *)sender {
    NSLog(@"Manually reload Data");
    [self requestServerData];
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

- (void)tableViewDoubleAction:(NSTableView *)tableView {
    NSInteger clickedRow = tableView.clickedRow;
    NSUInteger selectionIndex = self.orderBookArrayController.selectionIndex;
    NSArray *selectedObjects = self.orderBookArrayController.selectedObjects;
    
    NSLog(@"\nclickedRow %ti\nselectionIndex %tu\nselectedObjects\n%@",clickedRow, selectionIndex, selectedObjects );
    
    SOXShowOrderbook_BitcoinDE_Data *selectedOrderBookData = selectedObjects.firstObject;
    
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

//        else {
//            [self willChangeValueForKey:@"orderBook"];
//            [self.orderBook addObjectsFromArray:orderBook];
//            [self didChangeValueForKey:@"orderBook"];
//        }
        
    }
    
    SOXShowOrderbookData *data = self.orderBook.firstObject;
    NSLog(@"data:\n%@", data);
    
}
#pragma mark - NSTableViewDelegate


@end
