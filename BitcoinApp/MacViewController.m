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
@interface MacViewController () <SOXSocketIOCoreProtocol>
@property (weak) IBOutlet NSTabView *bottomTabView;

@property (strong, nonatomic) NSDictionary *serverAnswerDictionary;

@end

#pragma mark - Implementation
@implementation MacViewController

#pragma mark Init&Co.
- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
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
        item4.label = @"Rich mode";
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

@end
