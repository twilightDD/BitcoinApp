//
//  ViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 12.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "MacViewController.h"

#import "SOXOrdersViewController.h"
#import "SOXAutomaticTradingViewController.h"

#import "SOXPreferenceCenter.h"

static NSString *BannerContainerViewSegueKey         = @"BannerContainerViewSegue";
static NSString *ShowMyOrdersContainerSegueKey       = @"ShowMyOrdersContainerSegue";
static NSString *OrdersViewControllerBuyBTCSegueKey  = @"OrdersViewControllerBuyBTCSegue";    // TabView.0
static NSString *OrdersViewControllerSellBTCSegueKey = @"OrdersViewControllerSellBTCSegue";   // TabView.0
static NSString *OrdersViewControllerBuyBCHSegueKey  = @"OrdersViewControllerBuyBCHSegue";    // TabView.1
static NSString *OrdersViewControllerSellBCHSegueKey = @"OrdersViewControllerSellBCHSegue";   // TabView.1
static NSString *OrdersViewControllerBuyBSVSegueKey  = @"OrdersViewControllerBuyBSVSegue";    // TabView.2
static NSString *OrdersViewControllerSellBSVSegueKey = @"OrdersViewControllerSellBSVSegue";   // TabView.2
static NSString *OrdersViewControllerBuyBTGSegueKey  = @"OrdersViewControllerBuyBTGSegue";    // TabView.3
static NSString *OrdersViewControllerSellBTGSegueKey = @"OrdersViewControllerSellBTGSegue";   // TabView.3
static NSString *OrdersViewControllerBuyETHSegueKey  = @"OrdersViewControllerBuyETHSegue";    // TabView.4
static NSString *OrdersViewControllerSellETHSegueKey = @"OrdersViewControllerSellETHSegue";   // TabView.4
static NSString *OrdersViewControllerBuyLTCSegueKey  = @"OrdersViewControllerBuyLTCSegue";    // TabView.5
static NSString *OrdersViewControllerSellLTCSegueKey = @"OrdersViewControllerSellLTCSegue";   // TabView.5
static NSString *OrdersViewControllerBuyXRPSegueKey  = @"OrdersViewControllerBuyXRPSegue";    // TabView.6
static NSString *OrdersViewControllerSellXRPSegueKey = @"OrdersViewControllerSellXRPSegue";   // TabView.6


static NSString *AccountLedgerViewControllerSegueKey  = @"AccountLedgerViewControllerSegue";
static NSString *MyTradeHistoryViewControllerSegueKey = @"MyTradeHistoryViewControllerSegue";
static NSString *AutomaticTradeBTCSegueKey            = @"EmbedAutoTraderForBTC";
static NSString *AutomaticTradeBCHSegueKey            = @"EmbedAutoTraderForBCH";
static NSString *AutomaticTradeBTGSegueKey            = @"EmbedAutoTraderForBTG";
static NSString *AutomaticTradeETHSegueKey            = @"EmbedAutoTraderForETH";
static NSString *AutomaticTradeBSVSegueKey            = @"EmbedAutoTraderForBSV";
static NSString *AutomaticTradeLTCSegueKey            = @"EmbedAutoTraderForLTC";
static NSString *AutomaticTradeXRPSegueKey            = @"EmbedAutoTraderForXRP";


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
    for (BitcoinDE_CurrencyType currencyType = BitcoinDE_CurrencyTypeUnknown + 1; currencyType < BitcoinDE_CurrencyType_EndOfType; currencyType++) {
        if ([SOXPreferenceCenter automaticallyLoadBannerForCurrencyType:currencyType]) {
            [[SOXMarket_BitcoinDE_Core sharedCore] startRatesUpdateForCurrencyType:currencyType];
        }
    }
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
        item0.label          = [SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:BitcoinDE_CurrencyTypeBitcoin];
        NSTabViewItem *item1 = [self.bottomTabView tabViewItemAtIndex:1];
        item1.label          = [SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:BitcoinDE_CurrencyTypeBitcoinCash];
        NSTabViewItem *item2 = [self.bottomTabView tabViewItemAtIndex:2];
        item2.label          = [SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:BitcoinDE_CurrencyTypeBitcoinCashSV];
        NSTabViewItem *item3 = [self.bottomTabView tabViewItemAtIndex:3];
        item3.label          = [SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:BitcoinDE_CurrencyTypeBitcoinGold];
        NSTabViewItem *item4 = [self.bottomTabView tabViewItemAtIndex:4];
        item4.label          = [SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:BitcoinDE_CurrencyTypeEthereum];
        NSTabViewItem *item5 = [self.bottomTabView tabViewItemAtIndex:5];
        item5.label          = [SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:BitcoinDE_CurrencyTypeLitecoin];
        NSTabViewItem *item6 = [self.bottomTabView tabViewItemAtIndex:6];
        item6.label          = [SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:BitcoinDE_CurrencyTypeRipple];
        NSTabViewItem *item7 = [self.bottomTabView tabViewItemAtIndex:7];
        item7.label          = @"My Orders";
        NSTabViewItem *item8 = [self.bottomTabView tabViewItemAtIndex:8];
        item8.label          = @"My Account Ledger";
        NSTabViewItem *item9 = [self.bottomTabView tabViewItemAtIndex:9];
        item9.label          = @"My Trade History";


#if PETER
        NSTabViewItem *item14 = [self.bottomTabView tabViewItemAtIndex:14];   // auto trader: eth
        [self.bottomTabView removeTabViewItem:item13];
        NSTabViewItem *item13 = [self.bottomTabView tabViewItemAtIndex:13];   // auto trader: gold
        [self.bottomTabView removeTabViewItem:item12];
        NSTabViewItem *item12 = [self.bottomTabView tabViewItemAtIndex:12];   // auto trader: sv
        [self.bottomTabView removeTabViewItem:item11];
        NSTabViewItem *item11 = [self.bottomTabView tabViewItemAtIndex:11];   // auto trader: cash
        [self.bottomTabView removeTabViewItem:item10];
        NSTabViewItem *item10 = [self.bottomTabView tabViewItemAtIndex:10];   // auto trader: bitcoin
        [self.bottomTabView removeTabViewItem:item9];
#endif
    }
}

#pragma mark - Segue handling
- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender {
    //BTC
    if ([segue.identifier isEqualToString:OrdersViewControllerBuyBTCSegueKey]) {
        SOXOrdersViewController *viewC = segue.destinationController;
        viewC.orderType                = BitcoinDE_OrderTypeBuy;
        viewC.currencyType             = BitcoinDE_CurrencyTypeBitcoin;
    }
    else if ([segue.identifier isEqualToString:OrdersViewControllerSellBTCSegueKey]) {
        SOXOrdersViewController *viewC = segue.destinationController;
        viewC.orderType                = BitcoinDE_OrderTypeSell;
        viewC.currencyType             = BitcoinDE_CurrencyTypeBitcoin;
    }
    //BCH
    else if ([segue.identifier isEqualToString:OrdersViewControllerBuyBCHSegueKey]) {
        SOXOrdersViewController *viewC = segue.destinationController;
        viewC.orderType                = BitcoinDE_OrderTypeBuy;
        viewC.currencyType             = BitcoinDE_CurrencyTypeBitcoinCash;
    }
    else if ([segue.identifier isEqualToString:OrdersViewControllerSellBCHSegueKey]) {
        SOXOrdersViewController *viewC = segue.destinationController;
        viewC.orderType                = BitcoinDE_OrderTypeSell;
        viewC.currencyType             = BitcoinDE_CurrencyTypeBitcoinCash;
    }
    //BSV
    else if ([segue.identifier isEqualToString:OrdersViewControllerBuyBSVSegueKey]) {
        SOXOrdersViewController *viewC = segue.destinationController;
        viewC.orderType                = BitcoinDE_OrderTypeBuy;
        viewC.currencyType             = BitcoinDE_CurrencyTypeBitcoinCashSV;
    }
    else if ([segue.identifier isEqualToString:OrdersViewControllerSellBSVSegueKey]) {
        SOXOrdersViewController *viewC = segue.destinationController;
        viewC.orderType                = BitcoinDE_OrderTypeSell;
        viewC.currencyType             = BitcoinDE_CurrencyTypeBitcoinCashSV;
    }
    //BTG
    else if ([segue.identifier isEqualToString:OrdersViewControllerBuyBTGSegueKey]) {
        SOXOrdersViewController *viewC = segue.destinationController;
        viewC.orderType                = BitcoinDE_OrderTypeBuy;
        viewC.currencyType             = BitcoinDE_CurrencyTypeBitcoinGold;
    }
    else if ([segue.identifier isEqualToString:OrdersViewControllerSellBTGSegueKey]) {
        SOXOrdersViewController *viewC = segue.destinationController;
        viewC.orderType                = BitcoinDE_OrderTypeSell;
        viewC.currencyType             = BitcoinDE_CurrencyTypeBitcoinGold;
    }
    //ETH
    else if ([segue.identifier isEqualToString:OrdersViewControllerBuyETHSegueKey]) {
        SOXOrdersViewController *viewC = segue.destinationController;
        viewC.orderType                = BitcoinDE_OrderTypeBuy;
        viewC.currencyType             = BitcoinDE_CurrencyTypeEthereum;
    }
    else if ([segue.identifier isEqualToString:OrdersViewControllerSellETHSegueKey]) {
        SOXOrdersViewController *viewC = segue.destinationController;
        viewC.orderType                = BitcoinDE_OrderTypeSell;
        viewC.currencyType             = BitcoinDE_CurrencyTypeEthereum;
    }
    //LTC
    else if ([segue.identifier isEqualToString:OrdersViewControllerBuyLTCSegueKey]) {
        SOXOrdersViewController *viewC = segue.destinationController;
        viewC.orderType                = BitcoinDE_OrderTypeBuy;
        viewC.currencyType             = BitcoinDE_CurrencyTypeLitecoin;
    }
    else if ([segue.identifier isEqualToString:OrdersViewControllerSellLTCSegueKey]) {
        SOXOrdersViewController *viewC = segue.destinationController;
        viewC.orderType                = BitcoinDE_OrderTypeSell;
        viewC.currencyType             = BitcoinDE_CurrencyTypeLitecoin;
    }
    //XRP
    else if ([segue.identifier isEqualToString:OrdersViewControllerBuyXRPSegueKey]) {
        SOXOrdersViewController *viewC = segue.destinationController;
        viewC.orderType                = BitcoinDE_OrderTypeBuy;
        viewC.currencyType             = BitcoinDE_CurrencyTypeRipple;
    }
    else if ([segue.identifier isEqualToString:OrdersViewControllerSellXRPSegueKey]) {
        SOXOrdersViewController *viewC = segue.destinationController;
        viewC.orderType                = BitcoinDE_OrderTypeSell;
        viewC.currencyType             = BitcoinDE_CurrencyTypeRipple;
    }
    
    
    
    // Automatic BTC
    else if ([segue.identifier isEqualToString:AutomaticTradeBTCSegueKey]) {
        SOXAutomaticTradingViewController *viewC = segue.destinationController;
        viewC.currencyType                       = BitcoinDE_CurrencyTypeBitcoin;
    }
    // Automatic BCH
    else if ([segue.identifier isEqualToString:AutomaticTradeBCHSegueKey]) {
        SOXAutomaticTradingViewController *viewC = segue.destinationController;
        viewC.currencyType                       = BitcoinDE_CurrencyTypeBitcoinCash;
    }
    // Automatic BTG
    else if ([segue.identifier isEqualToString:AutomaticTradeBTGSegueKey]) {
        SOXAutomaticTradingViewController *viewC = segue.destinationController;
        viewC.currencyType                       = BitcoinDE_CurrencyTypeBitcoinGold;
    }
    // Automatic ETH
    else if ([segue.identifier isEqualToString:AutomaticTradeETHSegueKey]) {
        SOXAutomaticTradingViewController *viewC = segue.destinationController;
        viewC.currencyType                       = BitcoinDE_CurrencyTypeEthereum;
    }
    // Automatic BSV
    else if ([segue.identifier isEqualToString:AutomaticTradeBSVSegueKey]) {
        SOXAutomaticTradingViewController *viewC = segue.destinationController;
        viewC.currencyType                       = BitcoinDE_CurrencyTypeBitcoinCashSV;
    }
    // Automatic LTC
    else if ([segue.identifier isEqualToString:AutomaticTradeLTCSegueKey]) {
        SOXAutomaticTradingViewController *viewC = segue.destinationController;
        viewC.currencyType                       = BitcoinDE_CurrencyTypeLitecoin;
    }
    // Automatic XRP
    else if ([segue.identifier isEqualToString:AutomaticTradeXRPSegueKey]) {
        SOXAutomaticTradingViewController *viewC = segue.destinationController;
        viewC.currencyType                       = BitcoinDE_CurrencyTypeRipple;
    }
}

#pragma mark - SOXCreditUpdateProtocol
- (void)creditValuesUpdated:(NSDictionary *_Nonnull)creditDicts {
    NSNumber *currentCredit = [creditDicts objectForKey:CreditUpdate_CurrentCreditsKey];
    NSNumber *maxCredits    = [creditDicts objectForKey:CreditUpdate_MaximalCreditsKey];

    NSString *creditString                = [NSString stringWithFormat:@"API Credits: %@/%@", currentCredit, maxCredits];
    self.rightStatusTextField.stringValue = creditString;
}

#pragma mark - SOXStatusBarUpdateProtocol
- (void)statusBarUpdated:(NSString *)statusBarText {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.leftStatusTextField.stringValue = statusBarText;
    });
}

@end
