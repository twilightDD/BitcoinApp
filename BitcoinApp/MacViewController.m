//
//  ViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 12.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "MacViewController.h"

#import "SOXMarket_BitcoinDE_Core.h"
#import "SOXSocketIO_BitcoinDE_Core.h"

#import "SOXOrdersViewController.h"

static NSString *BannerContainerViewSegueKey          = @"BannerContainerViewSegue";
static NSString *ShowMyOrdersContainerSegueKey        = @"ShowMyOrdersContainerSegue";
static NSString *OrdersViewControllerBuySegueKey      = @"OrdersViewControllerBuySegue";     // TabView.0
static NSString *OrdersViewControllerSellSegueKey     = @"OrdersViewControllerSellSegue";    // TabView.0
static NSString *AccountLedgerViewControllerSegueKey  = @"AccountLedgerViewControllerSegue"; // TabView.1
static NSString *MyTradeHistoryViewControllerSegueKey = @"MyTradeHistoryViewControllerSegue";// TabView.2

#pragma mark - Interface
@interface MacViewController () <SOXSocketIOCoreProtocol, SOXCreditUpdateProtocol, SOXStatusBarUpdateProtocol>
#pragma mark | IBOutlets
@property (weak) IBOutlet NSTabView *bottomTabView;

@property (weak) IBOutlet NSTextField *leftStatusTextField;
@property (weak) IBOutlet NSTextField *rightStatusTextField;

@end

#pragma mark - Implementation
@implementation MacViewController

#pragma mark Init&Co.
- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
    [[SOXMarket_BitcoinDE_Core sharedCore] startRequests];
    
}

- (void)viewWillAppear {
    [super viewWillAppear];
    [SOXMarket_BitcoinDE_Core registerForCreditUpdates:self];
    [SOXMarket_BitcoinDE_Core registerForStatusBarUpdates:self];
}
#pragma mark - Private methods
- (void)setupUI {
    // Configure TabView
    {
        NSTabViewItem *item0 = [self.bottomTabView tabViewItemAtIndex:0];
        item0.label = @"Buy and Sell";
        NSTabViewItem *item1 = [self.bottomTabView tabViewItemAtIndex:1];
        item1.label = @"My Active Orders";
        NSTabViewItem *item2 = [self.bottomTabView tabViewItemAtIndex:2];
        item2.label = @"Account ledger";
        NSTabViewItem *item3 = [self.bottomTabView tabViewItemAtIndex:3];
        item3.label = @"My Trade History";
        NSTabViewItem *item4 = [self.bottomTabView tabViewItemAtIndex:4];
        item4.label = @"Public Trade History";
        NSTabViewItem *item5 = [self.bottomTabView tabViewItemAtIndex:5];
        item5.label = @"Chart";
        NSTabViewItem *item6 = [self.bottomTabView tabViewItemAtIndex:6];
        item6.label = @"Reporting";
        NSTabViewItem *item7 = [self.bottomTabView tabViewItemAtIndex:7];
        item7.label = @"Rich mode";
        // debug
        //[self.bottomTabView removeTabViewItem:item6];
        
    }
}

#pragma mark - Segue handling
- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:OrdersViewControllerBuySegueKey]) {
        SOXOrdersViewController *viewC = segue.destinationController;
        viewC.orderType = BitcoinDE_BuyOrderType;
    }
    else if ([segue.identifier isEqualToString:OrdersViewControllerSellSegueKey]) {
        SOXOrdersViewController *viewC = segue.destinationController;
        viewC.orderType = BitcoinDE_SellOrderType;
    }
}
#pragma mark - Action methods
- (IBAction)startRequests:(NSButton *)sender {
    [[SOXMarket_BitcoinDE_Core sharedCore] startRequests];
}

#pragma mark - SOXCreditUpdateProtocol
- (void)creditValuesUpdated:(NSDictionary * _Nonnull)creditDicts {
    NSNumber *currentCredit = [creditDicts objectForKey:CreditUpdate_CurrentCreditsKey];
    NSNumber *maxCredits = [creditDicts objectForKey:CreditUpdate_MaximalCreditsKey];
    
    NSString *creditString = [NSString stringWithFormat:@"API Credits: %@/%@", currentCredit, maxCredits];
    self.rightStatusTextField.stringValue = creditString;
}

#pragma mark - SOXStatusBarUpdateProtocol
- (void)statusBarUpdated:(NSString *)statusBarText {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.leftStatusTextField.stringValue = statusBarText;
    });
}

@end
