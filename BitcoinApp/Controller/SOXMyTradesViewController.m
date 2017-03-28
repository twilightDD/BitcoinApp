//
//  SOXMyTradesViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 28.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXMyTradesViewController.h"

#import "SOXMarket_BitcoinDE_Core.h"

#pragma mark - Interface
@interface SOXMyTradesViewController () <SOXMarketCoreServerRequestProtocol>

#pragma mark IBOutlets
@property (weak) IBOutlet NSTextField *titleTextField;
@property (weak) IBOutlet NSTableView *tableView;

@property (weak) IBOutlet NSView *pageContainerView;

@property (weak) IBOutlet NSButton *pageBackwardButton;
@property (weak) IBOutlet NSButton *pageForwardButton;
@property (weak) IBOutlet NSTextField *pageIndicatorTextField;

@property (strong) IBOutlet NSArrayController *myTradesArrayController;

#pragma mark Properties

@end

#pragma mark - Implementation
@implementation SOXMyTradesViewController

#pragma mark Init&Co.
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)viewWillAppear {
    [super viewWillAppear];
    
    [self setupUI];
    [self requestServerData];
}

#pragma mark - Private methods
- (void)setupUI {
    self.titleTextField.stringValue = @"My trading history";
    
    self.pageContainerView.hidden = YES;
}


- (void)requestServerData {
    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowAccountLedger
                                                respondTo:self];
    
}

#pragma mark - SOXMarketCoreServerRequestProtocol
- (void)answerOfServerRequest:(NSDictionary * _Nonnull)answerOfServerRequest {
    NSLog(@"BitcoinDE_ShowAccountLedger\n%@",answerOfServerRequest);
}

@end
