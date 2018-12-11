//
//  SOXStatisticsSummaryViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 11.12.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXStatisticsSummaryViewController.h"

#pragma mark - Interface
@interface SOXStatisticsSummaryViewController ()

#pragma mark | IBOutlets

#pragma mark 1. Stack: Currencies
@property (strong) IBOutlet NSStackView *currencyColumnStackView;
@property (strong) IBOutlet NSTextField *empty1CurrencyTextField;
@property (strong) IBOutlet NSTextField *empty2TextField;
@property (strong) IBOutlet NSTextField *btcCurrencyTextField;
@property (strong) IBOutlet NSTextField *bchCurrencyTextField;
@property (strong) IBOutlet NSTextField *bsvCurrencyTextField;
@property (strong) IBOutlet NSTextField *btgCurrencyTextField;
@property (strong) IBOutlet NSTextField *ethCurrencyTextField;
@property (strong) IBOutlet NSTextField *sumCurrencyTextField;

#pragma mark 2. Stack: Buy
@property (strong) IBOutlet NSStackView *buyColumnStackView;
@property (strong) IBOutlet NSTextField *header1BuyTradesTextField;
@property (strong) IBOutlet NSTextField *header1BuySalesBuyTextField;
@property (strong) IBOutlet NSTextField *header1BuyCoinsBuyTextField;
@property (strong) IBOutlet NSTextField *header2BuyTradesTextField;
@property (strong) IBOutlet NSTextField *header2BuySalesBuyTextField;
@property (strong) IBOutlet NSTextField *header2BuyCoinsBuyTextField;
@property (strong) IBOutlet NSTextField *btcBuyBuyTradesTextField;
@property (strong) IBOutlet NSTextField *btcBuyBuySalesTextField;
@property (strong) IBOutlet NSTextField *btcBuyBuyCoinsTextField;
@property (strong) IBOutlet NSTextField *bchBuyBuyTradesTextField;
@property (strong) IBOutlet NSTextField *bchBuyBuySalesTextField;
@property (strong) IBOutlet NSTextField *bchBuyBuyCoinsTextField;
@property (strong) IBOutlet NSTextField *bsvBuyBuyTradesTextField;
@property (strong) IBOutlet NSTextField *bsvBuyBuySalesTextField;
@property (strong) IBOutlet NSTextField *bsvBuyBuyCoinsTextField;
@property (strong) IBOutlet NSTextField *btgBuyBuyTradesTextField;
@property (strong) IBOutlet NSTextField *btgBuyBuySalesTextField;
@property (strong) IBOutlet NSTextField *btgBuyBuyCoinsTextField;
@property (strong) IBOutlet NSTextField *ethBuyBuyTradesTextField;
@property (strong) IBOutlet NSTextField *ethBuyBuySalesTextField;
@property (strong) IBOutlet NSTextField *ethBuyBuyCoinsTextField;
@property (strong) IBOutlet NSTextField *sumBuyBuyTradesTextField;
@property (strong) IBOutlet NSTextField *sumBuyBuySalesTextField;
@property (strong) IBOutlet NSTextField *sumBuyBuyCoinsTextField;

#pragma mark 3. Stack: Sell
@property (strong) IBOutlet NSTextField *header1SellTradesTextField;
@property (strong) IBOutlet NSTextField *header1SellSalesBuyTextField;
@property (strong) IBOutlet NSTextField *header1SellCoinsBuyTextField;
@property (strong) IBOutlet NSTextField *header2SellTradesTextField;
@property (strong) IBOutlet NSTextField *header2SellSalesBuyTextField;
@property (strong) IBOutlet NSTextField *header2SellCoinsBuyTextField;
@property (strong) IBOutlet NSTextField *btcBuySellTradesTextField;
@property (strong) IBOutlet NSTextField *btcBuySellSalesTextField;
@property (strong) IBOutlet NSTextField *btcBuySellCoinsTextField;
@property (strong) IBOutlet NSTextField *bchBuySellTradesTextField;
@property (strong) IBOutlet NSTextField *bchBuySellSalesTextField;
@property (strong) IBOutlet NSTextField *bchBuySellCoinsTextField;
@property (strong) IBOutlet NSTextField *bsvBuySellTradesTextField;
@property (strong) IBOutlet NSTextField *bsvBuySellSalesTextField;
@property (strong) IBOutlet NSTextField *bsvBuySellCoinsTextField;
@property (strong) IBOutlet NSTextField *btgBuySellTradesTextField;
@property (strong) IBOutlet NSTextField *btgBuySellSalesTextField;
@property (strong) IBOutlet NSTextField *btgBuySellCoinsTextField;
@property (strong) IBOutlet NSTextField *ethBuySellTradesTextField;
@property (strong) IBOutlet NSTextField *ethBuySellSalesTextField;
@property (strong) IBOutlet NSTextField *ethBuySellCoinsTextField;
@property (strong) IBOutlet NSTextField *sumBuySellTradesTextField;
@property (strong) IBOutlet NSTextField *sumBuySellSalesTextField;
@property (strong) IBOutlet NSTextField *sumBuySellCoinsTextField;

#pragma mark 4. Stack: Kickback
@property (strong) IBOutlet NSTextField *header1KickbackEventsTextField;
@property (strong) IBOutlet NSTextField *header1KickbackCoinsBuyTextField;
@property (strong) IBOutlet NSTextField *header2KickbackEventsTextField;
@property (strong) IBOutlet NSTextField *header2KickbackCoinsBuyTextField;
@property (strong) IBOutlet NSTextField *btcBuyKickbackEventsTextField;
@property (strong) IBOutlet NSTextField *btcBuyKickbackCoinsTextField;
@property (strong) IBOutlet NSTextField *bchBuyKickbackEventsTextField;
@property (strong) IBOutlet NSTextField *bchBuyKickbackCoinsTextField;
@property (strong) IBOutlet NSTextField *bsvBuyKickbackEventsTextField;
@property (strong) IBOutlet NSTextField *bsvBuyKickbackCoinsTextField;
@property (strong) IBOutlet NSTextField *btgBuyKickbackEventsTextField;
@property (strong) IBOutlet NSTextField *btgBuyKickbackCoinsTextField;
@property (strong) IBOutlet NSTextField *ethBuyKickbackEventsTextField;
@property (strong) IBOutlet NSTextField *ethBuyKickbackCoinsTextField;
@property (strong) IBOutlet NSTextField *sumBuyKickbackEventsTextField;
@property (strong) IBOutlet NSTextField *sumBuyKickbackCoinsTextField;

#pragma mark 5. Stack: Fees
@property (strong) IBOutlet NSTextField *header1FeeBitcoinDETextField;
@property (strong) IBOutlet NSTextField *header1FeeFidorBuyTextField;
@property (strong) IBOutlet NSTextField *header1FeeCoinerBuyTextField;
@property (strong) IBOutlet NSTextField *header2FeeBitcoinDETextField;
@property (strong) IBOutlet NSTextField *header2FeeFidorBuyTextField;
@property (strong) IBOutlet NSTextField *header2FeeCoinerBuyTextField;
@property (strong) IBOutlet NSTextField *btcBuyFeeBitcoinDETextField;
@property (strong) IBOutlet NSTextField *btcBuyFeeFidorTextField;
@property (strong) IBOutlet NSTextField *btcBuyFeeCoinerTextField;
@property (strong) IBOutlet NSTextField *bchBuyFeeBitcoinDETextField;
@property (strong) IBOutlet NSTextField *bchBuyFeeFidorTextField;
@property (strong) IBOutlet NSTextField *bchBuyFeeCoinerTextField;
@property (strong) IBOutlet NSTextField *bsvBuyFeeBitcoinDETextField;
@property (strong) IBOutlet NSTextField *bsvBuyFeeFidorTextField;
@property (strong) IBOutlet NSTextField *bsvBuyFeeCoinerTextField;
@property (strong) IBOutlet NSTextField *btgBuyFeeBitcoinDETextField;
@property (strong) IBOutlet NSTextField *btgBuyFeeFidorTextField;
@property (strong) IBOutlet NSTextField *btgBuyFeeCoinerTextField;
@property (strong) IBOutlet NSTextField *ethBuyFeeBitcoinDETextField;
@property (strong) IBOutlet NSTextField *ethBuyFeeFidorTextField;
@property (strong) IBOutlet NSTextField *ethBuyFeeCoinerTextField;
@property (strong) IBOutlet NSTextField *sumBuyFeeBitcoinDETextField;
@property (strong) IBOutlet NSTextField *sumBuyFeeFidorTextField;
@property (strong) IBOutlet NSTextField *sumBuyFeeCoinerTextField;

#pragma mark 6. Stack: WinLose
@property (strong) IBOutlet NSTextField *header1WinLostRawTextField;
@property (strong) IBOutlet NSTextField *header1WinLostAfterFeeBuyTextField;
@property (strong) IBOutlet NSTextField *header2WinLostRawTextField;
@property (strong) IBOutlet NSTextField *header2WinLostAfterFeeBuyTextField;
@property (strong) IBOutlet NSTextField *btcBuyWinLostRawTextField;
@property (strong) IBOutlet NSTextField *btcBuyWinLostAfterFeeTextField;
@property (strong) IBOutlet NSTextField *bchBuyWinLostRawTextField;
@property (strong) IBOutlet NSTextField *bchBuyWinLostAfterFeeTextField;
@property (strong) IBOutlet NSTextField *bsvBuyWinLostRawTextField;
@property (strong) IBOutlet NSTextField *bsvBuyWinLostAfterFeeTextField;
@property (strong) IBOutlet NSTextField *btgBuyWinLostRawTextField;
@property (strong) IBOutlet NSTextField *btgBuyWinLostAfterFeeTextField;
@property (strong) IBOutlet NSTextField *ethBuyWinLostRawTextField;
@property (strong) IBOutlet NSTextField *ethBuyWinLostAfterFeeTextField;
@property (strong) IBOutlet NSTextField *sumBuyWinLostRawTextField;
@property (strong) IBOutlet NSTextField *sumBuyWinLostAfterFeeTextField;

#pragma mark | Properties
@end

#pragma mark - Implementation
@implementation SOXStatisticsSummaryViewController

#pragma mark Init & Co.
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

@end
