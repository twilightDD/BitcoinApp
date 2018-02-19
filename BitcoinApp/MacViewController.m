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

#import "SOXMarket_BitcoinDE_DefTypes.h"

#import "SOXOrdersViewController.h"
#import "SOXAutomaticTradingViewController.h"

static NSString *BannerContainerViewSegueKey          = @"BannerContainerViewSegue";
static NSString *ShowMyOrdersContainerSegueKey        = @"ShowMyOrdersContainerSegue";
static NSString *OrdersViewControllerBuyBTCSegueKey      = @"OrdersViewControllerBuyBTCSegue";      // TabView.0
static NSString *OrdersViewControllerSellBTCSegueKey     = @"OrdersViewControllerSellBTCSegue";     // TabView.0
static NSString *OrdersViewControllerBuyBCHSegueKey      = @"OrdersViewControllerBuyBCHSegue";      // TabView.1
static NSString *OrdersViewControllerSellBCHSegueKey     = @"OrdersViewControllerSellBCHSegue";     // TabView.1
static NSString *OrdersViewControllerBuyBTGSegueKey      = @"OrdersViewControllerBuyBTGSegue";      // TabView.2
static NSString *OrdersViewControllerSellBTGSegueKey     = @"OrdersViewControllerSellBTGSegue";     // TabView.2
static NSString *OrdersViewControllerBuyETHSegueKey      = @"OrdersViewControllerBuyETHSegue";      // TabView.3
static NSString *OrdersViewControllerSellETHSegueKey     = @"OrdersViewControllerSellETHSegue";     // TabView.3

static NSString *AccountLedgerViewControllerSegueKey  = @"AccountLedgerViewControllerSegue";
static NSString *MyTradeHistoryViewControllerSegueKey = @"MyTradeHistoryViewControllerSegue";
static NSString *AutomaticTradeBTCSegueKey = @"EmbedAutoTraderForBTC";
static NSString *AutomaticTradeBCHSegueKey = @"EmbedAutoTraderForBCH";
static NSString *AutomaticTradeBTGSegueKey = @"EmbedAutoTraderForBTG";
static NSString *AutomaticTradeETHSegueKey = @"EmbedAutoTraderForETH";


#pragma mark - Interface
@interface MacViewController () <SOXCreditUpdateProtocol, SOXStatusBarUpdateProtocol>
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
    [[SOXMarket_BitcoinDE_Core sharedCore] startAccountInfoUpdate];
    [[SOXMarket_BitcoinDE_Core sharedCore] startAllRatesUpdate];
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
        item0.label = [SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:BitcoinDE_CurrencyTypeBitcoin];
        NSTabViewItem *item1 = [self.bottomTabView tabViewItemAtIndex:1];
        item1.label = [SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:BitcoinDE_CurrencyTypeBitcoinCash];
        NSTabViewItem *item2 = [self.bottomTabView tabViewItemAtIndex:2];
        item2.label = [SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:BitcoinDE_CurrencyTypeBitcoinGold];
        NSTabViewItem *item3 = [self.bottomTabView tabViewItemAtIndex:3];
        item3.label = [SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:BitcoinDE_CurrencyTypeEthereum];
        NSTabViewItem *item4 = [self.bottomTabView tabViewItemAtIndex:4];
        item4.label = @"My Active Orders";
        NSTabViewItem *item5 = [self.bottomTabView tabViewItemAtIndex:5];
        item5.label = @"Account ledger";
        NSTabViewItem *item6 = [self.bottomTabView tabViewItemAtIndex:6];
        item6.label = @"My Trade History";


        // debug
        //[self.bottomTabView removeTabViewItem:item6];
        
    }
}

#pragma mark - Segue handling
- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:OrdersViewControllerBuyBTCSegueKey]) {
        SOXOrdersViewController *viewC = segue.destinationController;
        viewC.orderType = BitcoinDE_BuyOrderType;
        viewC.currencyType = BitcoinDE_CurrencyTypeBitcoin;
    }
    else if ([segue.identifier isEqualToString:OrdersViewControllerSellBTCSegueKey]) {
        SOXOrdersViewController *viewC = segue.destinationController;
        viewC.orderType = BitcoinDE_SellOrderType;
        viewC.currencyType = BitcoinDE_CurrencyTypeBitcoin;
    }
    else if ([segue.identifier isEqualToString:OrdersViewControllerBuyBCHSegueKey]) {
        SOXOrdersViewController *viewC = segue.destinationController;
        viewC.orderType = BitcoinDE_BuyOrderType;
        viewC.currencyType = BitcoinDE_CurrencyTypeBitcoinCash;
    }
    else if ([segue.identifier isEqualToString:OrdersViewControllerSellBCHSegueKey]) {
        SOXOrdersViewController *viewC = segue.destinationController;
        viewC.orderType = BitcoinDE_SellOrderType;
        viewC.currencyType = BitcoinDE_CurrencyTypeBitcoinCash;
    }
    else if ([segue.identifier isEqualToString:OrdersViewControllerBuyBTGSegueKey]) {
        SOXOrdersViewController *viewC = segue.destinationController;
        viewC.orderType = BitcoinDE_BuyOrderType;
        viewC.currencyType = BitcoinDE_CurrencyTypeBitcoinGold;
    }
    else if ([segue.identifier isEqualToString:OrdersViewControllerSellBTGSegueKey]) {
        SOXOrdersViewController *viewC = segue.destinationController;
        viewC.orderType = BitcoinDE_SellOrderType;
        viewC.currencyType = BitcoinDE_CurrencyTypeBitcoinGold;
    }
    else if ([segue.identifier isEqualToString:OrdersViewControllerBuyETHSegueKey]) {
        SOXOrdersViewController *viewC = segue.destinationController;
        viewC.orderType = BitcoinDE_BuyOrderType;
        viewC.currencyType = BitcoinDE_CurrencyTypeEthereum;
    }
    else if ([segue.identifier isEqualToString:OrdersViewControllerSellETHSegueKey]) {
        SOXOrdersViewController *viewC = segue.destinationController;
        viewC.orderType = BitcoinDE_SellOrderType;
        viewC.currencyType = BitcoinDE_CurrencyTypeEthereum;
    }
    else if ([segue.identifier isEqualToString:AutomaticTradeBTCSegueKey]) {
        SOXAutomaticTradingViewController *viewC = segue.destinationController;
        viewC.currencyType = BitcoinDE_CurrencyTypeBitcoin;
    }
    else if ([segue.identifier isEqualToString:AutomaticTradeBCHSegueKey]) {
        SOXAutomaticTradingViewController *viewC = segue.destinationController;
        viewC.currencyType = BitcoinDE_CurrencyTypeBitcoinCash;
    }
    else if ([segue.identifier isEqualToString:AutomaticTradeBTGSegueKey]) {
        SOXAutomaticTradingViewController *viewC = segue.destinationController;
        viewC.currencyType = BitcoinDE_CurrencyTypeBitcoinGold;
    }
    else if ([segue.identifier isEqualToString:AutomaticTradeETHSegueKey]) {
        SOXAutomaticTradingViewController *viewC = segue.destinationController;
        viewC.currencyType = BitcoinDE_CurrencyTypeEthereum;
    }
}

#pragma mark - Action methods
- (IBAction)startRequests:(NSButton *)sender {
    [[SOXMarket_BitcoinDE_Core sharedCore] startAccountInfoUpdate];
    [[SOXMarket_BitcoinDE_Core sharedCore] startAllRatesUpdate];
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
