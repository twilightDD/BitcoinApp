//
//  SOXGeneralSettingsPreferenceViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 07.11.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXGeneralSettingsPreferenceViewController.h"

#import "SOXMarket_BitcoinDE_DefTypes.h"

#import "SOXPreferenceCenter.h"

#import "NSTextField+URL.h"

@interface SOXGeneralSettingsPreferenceViewController ()

#pragma mark | IBOutlet
// Header
@property (strong) IBOutlet NSTextField *headlineTextField;

// Create new order
@property (strong) IBOutlet NSBox *createNewOrderBox;
@property (strong) IBOutlet NSButton *onlyKYCButton;
@property (strong) IBOutlet NSButton *reNewOrderButton;
@property (strong) IBOutlet NSTextField *trustLevelDescpriptionTextField;
@property (strong) IBOutlet NSButton *bronceTrustLevelButton;
@property (strong) IBOutlet NSButton *silverTrustLevelButton;
@property (strong) IBOutlet NSButton *goldTrustLevelButton;
@property (strong) IBOutlet NSTextField *endDateTimeSpanDescriptionTextField;
@property (strong) IBOutlet NSTextField *endDateTimeSpanValueTextField;
@property (strong) IBOutlet NSStepper *endDateStepper;


@property (strong) IBOutlet NSTextField *paymentOptionHintTextField;

// Load orderbooks automatically
@property (strong) IBOutlet NSBox *loadOrderbooksAutomaticallyBox;
@property (strong) IBOutlet NSTextField *buyDescriptionTextField;
@property (strong) IBOutlet NSTextField *sellDescriptionTextField;

@property (strong) IBOutlet NSTextField *btcDescriptionTextField;
@property (strong) IBOutlet NSButton *btcBuyButton;
@property (strong) IBOutlet NSButton *btcSellButton;

@property (strong) IBOutlet NSTextField *bchDescriptionTextField;
@property (strong) IBOutlet NSButton *bchBuyButton;
@property (strong) IBOutlet NSButtonCell *bchSellButton;

@property (strong) IBOutlet NSTextField *btgDescriptionTextField;
@property (strong) IBOutlet NSButton *btgBuyButton;
@property (strong) IBOutlet NSButton *btgSellButton;

@property (strong) IBOutlet NSTextField *ethDescriptionTextField;
@property (strong) IBOutlet NSButton *ethBuyButton;
@property (strong) IBOutlet NSButton *ethSellButton;


#pragma mark | Properties
@property (strong) NSNumber *endDateTimespan;
@end

@implementation SOXGeneralSettingsPreferenceViewController

- (void)viewDidLoad {
    [super viewDidLoad];


}

- (void)viewWillAppear {
    [super viewWillAppear];

    self.endDateTimespan = [SOXPreferenceCenter defaultEndDateTimespan];
    [self setupUI];
}

#pragma mark - Private Methods
- (void)setupUI {
    // Headline
    self.headlineTextField.stringValue = @"General settings";

    [self setupCreateNewOrderBox];
    [self setupLoadOrderBooksAutomatically];

}
- (void)setupCreateNewOrderBox {
    self.createNewOrderBox.title = @"Create new order";

    { // OnlyKYC
        self.onlyKYCButton.title = @"Allow only fully identified Users";
        self.onlyKYCButton.state = [SOXPreferenceCenter defaultKYCOnly] ? NSControlStateValueOn : NSControlStateValueOff;
    }

    { // ReNew
        self.reNewOrderButton.title = @"Automatic residual purchase request";
        self.reNewOrderButton.state =  [SOXPreferenceCenter reNewOrderForRemainingAmount] ? NSControlStateValueOn : NSControlStateValueOff;
    }

    { // TrustLevel
        self.trustLevelDescpriptionTextField.stringValue = @"Minimal Trust Level";
        self.bronceTrustLevelButton.title               = [SOXMarket_BitcoinDE_DefTypes trustLevelStringForTrustLevel:BitcoinDE_TrustLevelBronze];
        self.bronceTrustLevelButton.tag                 = BitcoinDE_TrustLevelBronze;

        self.silverTrustLevelButton.title               = [SOXMarket_BitcoinDE_DefTypes trustLevelStringForTrustLevel:BitcoinDE_TrustLevelSilver];
        self.silverTrustLevelButton.tag                 = BitcoinDE_TrustLevelSilver;

        self.goldTrustLevelButton.title                 = [SOXMarket_BitcoinDE_DefTypes trustLevelStringForTrustLevel:BitcoinDE_TrustLevelGold];
        self.goldTrustLevelButton.tag                   = BitcoinDE_TrustLevelGold;

        BitcoinDE_TrustLevel trustLevel = [SOXPreferenceCenter defaultTrustLevelForNewOrder];
        if (self.bronceTrustLevelButton.tag == trustLevel) {
            self.bronceTrustLevelButton.state = 1;
        }
        else if (self.silverTrustLevelButton.tag == trustLevel) {
            self.silverTrustLevelButton.state = 1;
        }
        else if (self.goldTrustLevelButton.tag == trustLevel) {
            self.goldTrustLevelButton.state = 1;
        }
    }

    // End Date Time Span
    {
        self.endDateTimeSpanDescriptionTextField.stringValue = @"Order should end in days:";
    }
    [self setupUIBoxPaymentOptionHint];
}

- (void)setupUIBoxPaymentOptionHint {
    // Hint on buy: paymentOption depend on default via preferences on webside

    self.paymentOptionHintTextField.allowsEditingTextAttributes = YES;
    self.paymentOptionHintTextField.selectable = YES;
    [self.paymentOptionHintTextField setHyperlinkFormattingFromString:@"Express Trade Settings"
                                                        withURLString:@"https://www.bitcoin.de/de/express-trade/settings"];
}

- (void)setupLoadOrderBooksAutomatically {
    self.buyDescriptionTextField.stringValue = [SOXMarket_BitcoinDE_DefTypes naturalStringForOrderType:BitcoinDE_OrderTypeBuy];
    self.sellDescriptionTextField.stringValue = [SOXMarket_BitcoinDE_DefTypes naturalStringForOrderType:BitcoinDE_OrderTypeSell];

    // BTC
    self.btcDescriptionTextField.stringValue = [SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:BitcoinDE_CurrencyTypeBitcoin];
    self.btcBuyButton.state = [SOXPreferenceCenter controlStateForAutoLoadOrderbookForOrderType:BitcoinDE_OrderTypeBuy
                                                                                forCurrencyType:BitcoinDE_CurrencyTypeBitcoin];
    self.btcSellButton.state = [SOXPreferenceCenter controlStateForAutoLoadOrderbookForOrderType:BitcoinDE_OrderTypeSell
                                                                                 forCurrencyType:BitcoinDE_CurrencyTypeBitcoin];

    // BCH
    self.bchDescriptionTextField.stringValue = [SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:BitcoinDE_CurrencyTypeBitcoinCash];
    self.bchBuyButton.state =  [SOXPreferenceCenter controlStateForAutoLoadOrderbookForOrderType:BitcoinDE_OrderTypeBuy
                                                                                 forCurrencyType:BitcoinDE_CurrencyTypeBitcoinCash];
    self.bchSellButton.state = [SOXPreferenceCenter controlStateForAutoLoadOrderbookForOrderType:BitcoinDE_OrderTypeSell
                                                                                forCurrencyType:BitcoinDE_CurrencyTypeBitcoinCash];

    // BTG
    self.btgDescriptionTextField.stringValue = [SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:BitcoinDE_CurrencyTypeBitcoinGold];
    self.btgBuyButton.state = [SOXPreferenceCenter controlStateForAutoLoadOrderbookForOrderType:BitcoinDE_OrderTypeBuy
                                                                                forCurrencyType:BitcoinDE_CurrencyTypeBitcoinGold];
    self.btgSellButton.state = [SOXPreferenceCenter controlStateForAutoLoadOrderbookForOrderType:BitcoinDE_OrderTypeSell
                                                                                 forCurrencyType:BitcoinDE_CurrencyTypeBitcoinGold];

    // ETH
    self.ethDescriptionTextField.stringValue = [SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:BitcoinDE_CurrencyTypeEthereum];
    self.ethBuyButton.state = [SOXPreferenceCenter controlStateForAutoLoadOrderbookForOrderType:BitcoinDE_OrderTypeBuy
                                                                                forCurrencyType:BitcoinDE_CurrencyTypeEthereum];
    self.ethSellButton.state = [SOXPreferenceCenter controlStateForAutoLoadOrderbookForOrderType:BitcoinDE_OrderTypeSell
                                                                                 forCurrencyType:BitcoinDE_CurrencyTypeEthereum];
}

#pragma mark - Action Methods
#pragma mark | Create new order
- (IBAction)onlyKYCButtonAction:(NSButton *)sender {
    BOOL onlyKYC = sender.state;
    [SOXPreferenceCenter setDefaultKYCOnly:onlyKYC];
}

- (IBAction)reNewOrderButtonAction:(NSButton *)sender {
    BOOL reNewOrder = sender.state;
    [SOXPreferenceCenter setReNewOrderForRemainingAmount:reNewOrder];
}

- (IBAction)trustLevelAction:(NSButton *)sender {
    BitcoinDE_TrustLevel trustLevel = sender.tag;
    [SOXPreferenceCenter setDefaultTrustLevelNewOrder:trustLevel];
}

#pragma mark | Load Orderbooks automatically
- (IBAction)buyButtonActions:(NSButton *)sender {
    BOOL automaticallyLoadOrderbook = sender.state;
    BitcoinDE_CurrencyType currencyType = sender.tag;
    [SOXPreferenceCenter setAutomaticallyLoadOrderbook:automaticallyLoadOrderbook
                                          forOrderType:BitcoinDE_OrderTypeBuy
                                       forCurrencyType:currencyType];
}

- (IBAction)sellButtonActions:(NSButton *)sender {
    BOOL automaticallyLoadOrderbook = sender.state;
    BitcoinDE_CurrencyType currencyType = sender.tag;
    [SOXPreferenceCenter setAutomaticallyLoadOrderbook:automaticallyLoadOrderbook
                                          forOrderType:BitcoinDE_OrderTypeSell
                                       forCurrencyType:currencyType];
}

#pragma mark - Manual setter
- (void)setEndDateTimespan:(NSNumber *)endDateTimespan {
    _endDateTimespan = endDateTimespan;
    [SOXPreferenceCenter setDefaultEndDateTimespan:endDateTimespan];
}

#pragma mark - MASPreferencesViewController
- (NSString *)toolbarItemLabel {
    return @"General settings";
}

- (NSImage *)toolbarItemImage {
    NSImage *image = [NSImage imageNamed:NSImageNamePreferencesGeneral];
    return image;
}
@end
