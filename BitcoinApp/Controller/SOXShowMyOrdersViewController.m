//
//  SOXShowMyOrdersViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 27.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXShowMyOrdersViewController.h"

#import "SOXMarket_BitcoinDE_Core.h"
#import "SOXMyOrderBook_BitcoinDE_Data.h"

#pragma mark - Interface
@interface SOXShowMyOrdersViewController () <SOXMarketCoreServerRequestProtocol, NSTableViewDelegate>

#pragma mark IBOutlets
@property (weak) IBOutlet NSTextField *titleTextField;
@property (weak) IBOutlet NSButton *reloadButton;
@property (weak) IBOutlet NSButton *addButton;
@property (weak) IBOutlet NSButton *removeButton;
@property (weak) IBOutlet NSTableView *tableView;

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
    
    [self.tableView setDoubleAction:@selector(tableViewDoubleAction:)];

    self.spinningBackgroundView.hidden = NO;
    [self.circularProgressIndicator startAnimation:nil];
}

#pragma mark - Private methods
- (void)setupUI {
    self.titleTextField.stringValue = @"My active orders";
    
    {
        self.reloadButton.title = @"Reload";
        self.addButton.title = @"Add new order";
        self.removeButton.title = @"Remove order";
        self.removeButton.enabled = NO;
    }
    
    self.spinningBackgroundView.layer.backgroundColor = [NSColor colorWithCalibratedRed:0
                                                                                  green:0
                                                                                   blue:0
                                                                                  alpha:0.1].CGColor;
}

- (void)requestServerData {
    
    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowMyOrdersCommandType
                                                respondTo:self];
    
}
#pragma mark - Table view methods
- (void)tableViewDoubleAction:(NSTableView *)tableView {

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
    
    SOXMyOrderBookData *data = self.myOrderBook.firstObject;
    NSLog(@"data:\n%@", data);
}

#pragma mark - Action methods
- (IBAction)reloadButtonAction:(NSButton *)sender {

}

- (IBAction)addButtonAction:(NSButton *)sender {

}

- (IBAction)removeButtonAction:(NSButton *)sender {

}

@end
