//
//  SOXShowMyOrdersViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 27.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXShowMyOrdersViewController.h"

#import "SOXMyOrderDetailsViewController.h"

#import "SOXMarket_BitcoinDE_Core.h"
#import "SOXMyOrderBook_BitcoinDE_Data.h"

NSString *const PresentMyTradesSegueKey = @"PresentMyTradesSegue";
NSString *const PresentMyAccountSegueKey = @"PresentMyAccountSegue";

#pragma mark - Interface
@interface SOXShowMyOrdersViewController () <SOXMarketCoreServerRequestProtocol, NSTableViewDelegate>

#pragma mark IBOutlets
@property (weak) IBOutlet NSTextField *titleTextField;

@property (weak) IBOutlet NSTableView *tableView;

@property (weak) IBOutlet NSButton *reloadButton;
@property (weak) IBOutlet NSButton *removeButton;

@property (weak) IBOutlet NSView *spinningBackgroundView;
@property (weak) IBOutlet NSProgressIndicator *circularProgressIndicator;

@property (strong) IBOutlet NSArrayController *myOrderArrayController;

#pragma mark Properties
@property (strong, nonatomic) NSMutableArray *myOrderBook;

@end

#pragma mark - Implementation
@implementation SOXShowMyOrdersViewController
#pragma mark Init&Co.
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear {
    [super viewWillAppear];
    
    [self setupUI];
    [self requestServerData];
}

#pragma mark - Private methods
- (void)setupUI {
    self.titleTextField.stringValue = @"My active orders";
    
    {
        self.reloadButton.title = @"Reload";
        self.removeButton.title = @"Remove order";
        self.removeButton.enabled = NO;
    }
    
    {
        [self.tableView setDoubleAction:@selector(tableViewDoubleAction:)];
    }
    
    {
        self.spinningBackgroundView.hidden = NO;
        [self.circularProgressIndicator startAnimation:nil];
        self.spinningBackgroundView.layer.backgroundColor = [NSColor colorWithCalibratedRed:0
                                                                                      green:0
                                                                                       blue:0
                                                                                      alpha:0.1].CGColor;
    }
}

- (void)requestServerData {
    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowMyOrdersCommandType
                                                respondTo:self];
}

#pragma mark - Table view methods
- (void)tableViewDoubleAction:(NSTableView *)tableView {
    NSArray <SOXMyOrderBook_BitcoinDE_Data *> *selectedObjects = [self.myOrderArrayController selectedObjects];
    SOXMyOrderBook_BitcoinDE_Data *selectedMyOrder = selectedObjects.firstObject;
    
    NSStoryboard *storyBoard = [NSStoryboard storyboardWithName:@"MacMain" bundle:nil];
    SOXMyOrderDetailsViewController *viewC = [storyBoard instantiateControllerWithIdentifier:@"MyOrderDetailsViewControllerIdentifier"];
    viewC.myOrder = selectedMyOrder;
    [self presentViewControllerAsSheet:viewC];
}

#pragma mark - SOXMarketCoreServerRequestProtocol
- (void)answerOfServerRequest:(NSDictionary * _Nonnull)answerOfServerRequest {
    
    if ([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ShowMyOrdersCommandType)]) {
        NSDictionary *payloadDictionary = [answerOfServerRequest objectForKey:ServerAnswerPayloadKey];
        NSMutableArray *myOrderBook = [SOXMyOrderBook_BitcoinDE_Data myOrderbookDataArrayForMyOrderbookDictionary:payloadDictionary];
        self.myOrderBook = myOrderBook;
        
        [self.circularProgressIndicator stopAnimation:nil];
        self.spinningBackgroundView.hidden = YES;
    }
}

#pragma mark - Action methods
- (IBAction)removeButtonAction:(NSButton *)sender {
    
}

- (IBAction)reloadButtonAction:(NSButton *)sender {

}

@end
