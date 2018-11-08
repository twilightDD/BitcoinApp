//
//  SOXBannerViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 20.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXBannerViewController.h"

#import "SOXMarket_BitcoinDE_Core.h"
#import "SOXKeys_BitcoinDE.h"

#import "SOXAccountInfo_BitcoinDE_Data.h"
#import "SOXRates_BitcoinDE_Data.h"

#import "SOXFormatters.h"

#pragma mark - Interface
@interface SOXBannerViewController () <SOXMarketCoreServerRequestProtocol>

#pragma mark IBOutlets
#pragma mark | accountInfoData (BTCBalance)
@property (weak) IBOutlet NSStackView *btcBalanceValuesAndDescriptionStackView;
@property (weak) IBOutlet NSTextField *btcBalanceHeadlineTextField;
@property (weak) IBOutlet NSTextField *btcBalanceTotalAmountDescriptionTextField;
@property (weak) IBOutlet NSTextField *btcBalanceTotalAmountTextField;
@property (weak) IBOutlet NSTextField *btcBalanceAvailableAmountDescriptionTextField;
@property (weak) IBOutlet NSTextField *btcBalanceAvailableAmountTextField;
@property (weak) IBOutlet NSTextField *btcBalanceReservedAmountDescriptionTextField;
@property (weak) IBOutlet NSTextField *btcBalanceReservedAmountTextField;

#pragma mark | accountInfoData (Bank Reservation)
@property (weak) IBOutlet NSStackView *fidorReservationValuesAndDescriptionStackView;
@property (weak) IBOutlet NSTextField *fidorReservationHeadlineTextField;
@property (weak) IBOutlet NSTextField *fidorReservationTotalAmountDescriptionTextField;
@property (weak) IBOutlet NSTextField *fidorReservationTotalAmountTextField;
@property (weak) IBOutlet NSTextField *fidorReservationAvailableAmountDescriptionTextField;
@property (weak) IBOutlet NSTextField *fidorReservationAvailableAmountTextField;
@property (weak) IBOutlet NSTextField *fidorReservationValidUntilDescriptionTextField;
@property (weak) IBOutlet NSTextField *fidorReservationValidUntilTextField;

#pragma mark | ratesData
@property (weak) IBOutlet NSStackView *ratesValuesAndDescriptionStackView;
@property (weak) IBOutlet NSTextField *ratesHeadlineTextField;
@property (weak) IBOutlet NSTextField *ratesRateWeightedDescriptionTextField;
@property (weak) IBOutlet NSTextField *ratesRateWeightedTextField;
@property (weak) IBOutlet NSTextField *ratesRateWeighted3hDescriptionTextField;
@property (weak) IBOutlet NSTextField *ratesRateWeighted3hTextField;
@property (weak) IBOutlet NSTextField *ratesRateWeighted12hDescriptionTextField;
@property (weak) IBOutlet NSTextField *ratesRateWeighted12hTextField;

#pragma mark | Coin value data
@property (weak) IBOutlet NSStackView *coinValueValuesAndDescriptionStackView;
@property (weak) IBOutlet NSTextField *coinValueHeadlineTextField;
@property (weak) IBOutlet NSTextField *coinValueDescriptionTextField;
@property (weak) IBOutlet NSTextField *coinValueTextField;
@property (weak) IBOutlet NSTextField *emptyDescriptionTextField; // layout errors
@property (weak) IBOutlet NSTextField *emptyTextField;// layout errors
@property (weak) IBOutlet NSTextField *emptyDescription2TextField; // layout errors
@property (weak) IBOutlet NSTextField *empty2TextField;// layout errors

#pragma mark | Others
@property (weak) IBOutlet NSButton *updateBannerButton;
@property (nonatomic) NSInteger countOfAllRates;

#pragma mark - Properties
// Values to calculate wealth
@property (strong, nonatomic) NSDecimalNumber *btcBalanceTotalAmount;
@property (nonatomic) BitcoinDE_CurrencyType currencyType;

// Notifications
@property (strong, nonatomic) id requestShowAccountInfoNotification;
@property (strong, nonatomic) id requestShowRatesNotification;
@property (strong, nonatomic) id presentBannerInformationForCurrencyNotification;
@property (strong, nonatomic) id apiKeysAndSecretsDidChangeObserver;

@end

#pragma mark - Implementation
@implementation SOXBannerViewController

#pragma mark Init&Co.
- (void)viewDidLoad {
    [super viewDidLoad];
    self.currencyType = BitcoinDE_CurrencyTypeBitcoin;

    [self registerOberservers];
    [self setupUI];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.requestShowAccountInfoNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:self.requestShowRatesNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:self.presentBannerInformationForCurrencyNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:self.apiKeysAndSecretsDidChangeObserver];
}

#pragma mark - Private methods
- (void)registerOberservers {
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    
    weakify(self)
    self.requestShowAccountInfoNotification =
    [[NSNotificationCenter defaultCenter] addObserverForName:BitcoinDE_Notification_RequestShowAccountInfo
                                                      object:nil
                                                       queue:mainQueue
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      strongify(self)
                                                      [self answerOfServerRequest:note.object];
                                                  }
     ];
    
    self.requestShowRatesNotification =
    [[NSNotificationCenter defaultCenter] addObserverForName:BitcoinDE_Notification_RequestShowRates
                                                      object:nil
                                                       queue:mainQueue
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      strongify(self)
                                                      [self answerOfServerRequest:note.object];
                                                  }
     ];

    self.presentBannerInformationForCurrencyNotification =
    [[NSNotificationCenter defaultCenter] addObserverForName:BitcoinDE_Notification_PresentBannerInformationForCurrency
                                                      object:nil
                                                       queue:mainQueue
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      strongify(self)
                                                      [self presentBannerForCurrencyType:note];
                                                  }
     ];

    self.apiKeysAndSecretsDidChangeObserver =
    [[NSNotificationCenter defaultCenter] addObserverForName:SOXAPIKeysAndSecretsDidChangeNotification
                                                      object:nil
                                                       queue:mainQueue
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      [[SOXMarket_BitcoinDE_Core sharedCore] startAccountInfoUpdate];
                                                      [[SOXMarket_BitcoinDE_Core sharedCore] startAllRatesUpdate];
                                                  }];
}

- (void)setupUI {
    // monoSpaceFonts
    NSFont *monospacedFont = [NSFont systemFontOfSize:15];

    if ([NSFont respondsToSelector:@selector(monospacedDigitSystemFontOfSize:weight:)]) {
        monospacedFont = [NSFont monospacedDigitSystemFontOfSize:15
                                                          weight:NSFontWeightRegular];
    }


    // BTC stack
    {
        self.btcBalanceHeadlineTextField.stringValue = @"My Bitcoins";
        
        self.btcBalanceTotalAmountDescriptionTextField.stringValue = @"Total";
        self.btcBalanceAvailableAmountDescriptionTextField.stringValue = @"Available";
        self.btcBalanceReservedAmountDescriptionTextField.stringValue = @"Reserved";
        
        self.btcBalanceTotalAmountTextField.stringValue = @"...";
        self.btcBalanceTotalAmountTextField.font = monospacedFont;
        self.btcBalanceAvailableAmountTextField.stringValue = @"...";
        self.btcBalanceAvailableAmountTextField.font = monospacedFont;
        self.btcBalanceReservedAmountTextField.stringValue = @"...";
        self.btcBalanceReservedAmountTextField.font = monospacedFont;
    }
    
    // Bank stack
    {
        self.fidorReservationHeadlineTextField.stringValue = @"Fidor Bank reservation";
        
        self.fidorReservationTotalAmountDescriptionTextField.stringValue = @"Max Euro";
        self.fidorReservationAvailableAmountDescriptionTextField.stringValue = @"Open orders";
        self.fidorReservationValidUntilDescriptionTextField.stringValue = @"Valid unitl";
        
        self.fidorReservationTotalAmountTextField.stringValue = @"...";
        self.fidorReservationAvailableAmountTextField.stringValue = @"...";
        self.fidorReservationValidUntilTextField.stringValue = @"...";
        
    }
    
    // Rates stack
    {
        self.ratesHeadlineTextField.stringValue = @"Weighted Coin Rates";
        
        self.ratesRateWeightedDescriptionTextField.stringValue = @"Current";
        self.ratesRateWeighted3hDescriptionTextField.stringValue = @"Last 3 hours";
        self.ratesRateWeighted12hDescriptionTextField.stringValue = @"Last 12 hours";
        
        self.ratesRateWeightedTextField.stringValue = @"...";
        self.ratesRateWeighted3hTextField.stringValue = @"...";
        self.ratesRateWeighted12hTextField.stringValue = @"...";
    }
    
    // Credit stack
    {
        self.coinValueHeadlineTextField.stringValue = @"Coin value";
        
        self.coinValueDescriptionTextField.stringValue = @"Value";
        self.coinValueTextField.stringValue = @"...";
        
        self.emptyDescriptionTextField.stringValue = @"";
        self.emptyTextField.stringValue = @"";
        self.emptyDescription2TextField.stringValue = @"";
        self.empty2TextField.stringValue = @"";
    }
}

- (void)updateUIForCoinAmounts {
    NSString *btcBalanceHeadlineText;
    if (self.currencyType == BitcoinDE_CurrencyTypeUnknown) {
        self.btcBalanceValuesAndDescriptionStackView.hidden = YES;
        btcBalanceHeadlineText = @"Coin amount";
    }
    else {
        self.btcBalanceValuesAndDescriptionStackView.hidden = NO;
        NSString *currencyTypeString = [SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:self.currencyType];
        btcBalanceHeadlineText = [NSString stringWithFormat:@"%@ amounts", currencyTypeString];
    }

    self.btcBalanceHeadlineTextField.stringValue = btcBalanceHeadlineText;


    SOXAccountInfo_BitcoinDE_Data *accountInfoData = (SOXAccountInfo_BitcoinDE_Data *)[SOXMarket_BitcoinDE_Core sharedCore].accountInfoData;
    NSDecimalNumber *btcBalanceTotalAmount         = [accountInfoData totalAmountForCurrencyType:self.currencyType];
    NSDecimalNumber *btcBalanceAvailableAmountText = [accountInfoData availableAmountForCurrencyType:self.currencyType];
    NSDecimalNumber *btcBalanceReservedAmountText  = [accountInfoData reservedAmountForCurrencyType:self.currencyType];

    NSString *currencyTypeShortString = [SOXMarket_BitcoinDE_DefTypes tradingPairShortStringUpperCaseForCurrencyType:self.currencyType];
    self.btcBalanceTotalAmountTextField.stringValue     = [NSString stringWithFormat:@"%@ %@"
                                                           , [[SOXFormatters bitcoinNumberWithoutCurrencySymbolFormatter] stringFromNumber:btcBalanceTotalAmount]
                                                           , currencyTypeShortString];
    self.btcBalanceAvailableAmountTextField.stringValue = [NSString stringWithFormat:@"%@ %@"
                                                           , [[SOXFormatters bitcoinNumberWithoutCurrencySymbolFormatter] stringFromNumber:btcBalanceAvailableAmountText]
                                                           , currencyTypeShortString];
    self.btcBalanceReservedAmountTextField.stringValue  = [NSString stringWithFormat:@"%@ %@"
                                                           , [[SOXFormatters bitcoinNumberWithoutCurrencySymbolFormatter] stringFromNumber:btcBalanceReservedAmountText]
                                                           , currencyTypeShortString];
}

- (void)updateUIForAllocations {
    // Header
    NSString *fidorReservationHeadlineText;
    if (self.currencyType == BitcoinDE_CurrencyTypeUnknown) {
        fidorReservationHeadlineText = @"Sum of Reservations";
    }
    else {
        NSString *currencyTypeString = [SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:self.currencyType];
        fidorReservationHeadlineText = [NSString stringWithFormat:@"Reservation for %@"
                                        , currencyTypeString];
    }
    self.fidorReservationHeadlineTextField.stringValue = fidorReservationHeadlineText;

    // Reservation figures and date
    SOXAccountInfo_BitcoinDE_Data *accountInfoData = (SOXAccountInfo_BitcoinDE_Data *)[SOXMarket_BitcoinDE_Core sharedCore].accountInfoData;
    self.fidorReservationValuesAndDescriptionStackView.hidden = !accountInfoData.bankReservation_exists;
    if (accountInfoData.bankReservation_exists) {
        // Show sum of reservations
        NSDecimalNumber *overallTotalReservationAmount = [NSDecimalNumber zero];
        NSDecimalNumber *overallAvailableReservationAmount = [NSDecimalNumber zero];
        for (BitcoinDE_CurrencyType currencyType = BitcoinDE_CurrencyTypeUnknown + 1;
             currencyType < BitcoinDE_CurrencyType_EndOfType;
             currencyType++) {
            overallTotalReservationAmount = [overallTotalReservationAmount decimalNumberByAdding:
                                             [accountInfoData allocationMaxEurVolumeForCurrencyType:currencyType]];
            overallAvailableReservationAmount = [overallAvailableReservationAmount decimalNumberByAdding:
                                                 [accountInfoData allocationEurVolumeOpenOrdersForCurrencyType:currencyType]];
        }

        if (self.currencyType == BitcoinDE_CurrencyTypeUnknown) {
            NSString *overallTotalReservationAmountString = [NSString stringWithFormat:@"%@ € (%@%%)"
                                                             , overallTotalReservationAmount
                                                             , @100];
            self.fidorReservationTotalAmountTextField.stringValue = overallTotalReservationAmountString;
            self.fidorReservationTotalAmountTextField.toolTip = [NSString stringWithFormat:@"100%% of total reservation"];

            self.fidorReservationAvailableAmountTextField.doubleValue = overallAvailableReservationAmount.doubleValue;
        }
        else {
            NSString *totalReservationAmountString = [NSString stringWithFormat:@"%@ € (%@%%)"
                                                      , [accountInfoData allocationMaxEurVolumeForCurrencyType:self.currencyType]
                                                      , [accountInfoData allocationPercentForCurrencyType:self.currencyType]];
            self.fidorReservationTotalAmountTextField.stringValue = totalReservationAmountString;
            self.fidorReservationTotalAmountTextField.toolTip = [NSString stringWithFormat:@"%@%% of total reservation of %@ €"
                                                                 , [accountInfoData allocationPercentForCurrencyType:self.currencyType]
                                                                 , overallTotalReservationAmount];

            self.fidorReservationAvailableAmountTextField.doubleValue = [accountInfoData allocationEurVolumeOpenOrdersForCurrencyType:self.currencyType].doubleValue;
        }

        // Reservation end date
        NSString *validUntilString = [SOXFormatters stringDateTimeStringForRFC3339DateTimeString:accountInfoData.bankReservation_validUntil];
        self.fidorReservationValidUntilTextField.stringValue = validUntilString;
        NSString *reservedAtString = [SOXFormatters stringDateTimeStringForRFC3339DateTimeString:accountInfoData.bankReservation_reservedAt];
        self.fidorReservationValidUntilTextField.toolTip = [NSString stringWithFormat:@"Reserved at %@"
                                                            , reservedAtString];
    }
}

- (void)updateUIForRates {
    NSString *currencyTypeString = [SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:self.currencyType];

    // Header
    NSString *ratesHeadlineText;
    if (self.currencyType == BitcoinDE_CurrencyTypeUnknown) {
        ratesHeadlineText = @"Weighted rates";
        self.ratesValuesAndDescriptionStackView.hidden = YES;
    }
    else {
        ratesHeadlineText = [NSString stringWithFormat:@"Weighted %@ rates"
                             , currencyTypeString];
        self.ratesValuesAndDescriptionStackView.hidden = NO;

        // Rate figures
        SOXRates_BitcoinDE_Data *ratesData = (SOXRates_BitcoinDE_Data *)[SOXMarket_BitcoinDE_Core sharedCore].ratesData;
        self.ratesRateWeightedTextField.objectValue     = [ratesData rateWeightedForCurrencyType:self.currencyType];
        self.ratesRateWeighted3hTextField.objectValue   = [ratesData rateWeighted3hForCurrencyType:self.currencyType];
        self.ratesRateWeighted12hTextField.objectValue  = [ratesData rateWeighted12hForCurrencyType:self.currencyType];

    }
    self.ratesHeadlineTextField.stringValue = ratesHeadlineText;

    // We know the rates so we can show the Volume of my coins
    [self updateVolumeOfCoins];
}

- (void)updateVolumeOfCoins {
    NSString *currencyTypeString = [SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:self.currencyType];

    NSString *coinValueHeadlineText;
    NSDecimalNumber *totalVolume = [NSDecimalNumber zero];
    if (self.currencyType == BitcoinDE_CurrencyTypeUnknown) {
        coinValueHeadlineText = @"Sum of Values";

        for (BitcoinDE_CurrencyType currencyType = BitcoinDE_CurrencyTypeUnknown + 1;
             currencyType < BitcoinDE_CurrencyType_EndOfType;
             currencyType++) {
            NSDecimalNumber *totalCoinAmount = [SOXMarket_BitcoinDE_Core totalAmountForCurrencyType:currencyType];
            NSDecimalNumber *rateWeighted = [SOXMarket_BitcoinDE_Core rateWeightedForCurrencyType:currencyType];
            if (totalCoinAmount
                && [totalCoinAmount isNotEqualTo:[NSDecimalNumber notANumber]]
                && rateWeighted
                && [rateWeighted isNotEqualTo:[NSDecimalNumber notANumber]]) {

                NSDecimalNumber *coinValue = [totalCoinAmount decimalNumberByMultiplyingBy:rateWeighted ];
                totalVolume = [totalVolume decimalNumberByAdding:coinValue];
            }
        }
        self.coinValueTextField.stringValue = [SOXFormatters currencyStringForNumber:totalVolume
                                                                        roundingMode:NSNumberFormatterRoundUp];
    }
    else {
        coinValueHeadlineText = [NSString stringWithFormat:@"%@ Value"
                             , currencyTypeString];
        // Volume figures
        NSDecimalNumber *totalCoinAmount = [SOXMarket_BitcoinDE_Core totalAmountForCurrencyType:self.currencyType];
        NSDecimalNumber *rateWeighted = [SOXMarket_BitcoinDE_Core rateWeightedForCurrencyType:self.currencyType];
        if (totalCoinAmount
            && [totalCoinAmount isNotEqualTo:[NSDecimalNumber notANumber]]
            && rateWeighted
            && [rateWeighted isNotEqualTo:[NSDecimalNumber notANumber]]) {

            totalVolume = [totalCoinAmount decimalNumberByMultiplyingBy:rateWeighted ];

        }
    }

    self.coinValueHeadlineTextField.stringValue = coinValueHeadlineText;
    self.coinValueTextField.stringValue = [SOXFormatters currencyStringForNumber:totalVolume
                                                                    roundingMode:NSNumberFormatterRoundUp];

}

#pragma mark - Action methods
- (IBAction)updateBannerButtonAction:(NSButton *)sender {
    self.updateBannerButton.enabled = NO;
    [[SOXMarket_BitcoinDE_Core sharedCore] startAccountInfoUpdate];
    self.countOfAllRates = [[SOXMarket_BitcoinDE_Core sharedCore] startAllRatesUpdate];
}

#pragma mark - Notification methods
- (void)presentBannerForCurrencyType:(NSNotification *)notification {
    NSNumber *currencyTypeNumber = notification.object;
    self.currencyType = currencyTypeNumber.unsignedIntegerValue;

    [self updateUIForCoinAmounts];
    [self updateUIForAllocations];
    [self updateUIForRates];
}

#pragma mark - SOXMarketCoreServerRequestProtocol
- (void)answerOfServerRequest:(NSDictionary *)answerOfServerRequest {

    if ([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ShowAccountInfoCommandType)]) {
        [self updateUIForCoinAmounts];
        [self updateUIForAllocations];
    }
    else if ([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ShowRatesCommandType)]) {
        [self updateUIForRates];

        // Enable updateBannerButton after all rates updates are complete
        self.countOfAllRates--;
        if (self.countOfAllRates < 1) {
            self.updateBannerButton.enabled = YES;
            // [self startRatesReloadTimer];
        }
    }
}

#pragma mark - Reload Timer
- (void)startRatesReloadTimer {
//    DDLogInfo(@"***** NEW RATE: %@", [SOXMarket_BitcoinDE_Core sharedCore].rate_weighted);
//    
//    NSTimer *ratesReloadTimer  = [NSTimer scheduledTimerWithTimeInterval:600
//                                                                     target:self
//                                                                   selector:@selector(requestServerData)
//                                                                   userInfo:nil
//                                                                    repeats:NO];
//    [[NSRunLoop mainRunLoop] addTimer:ratesReloadTimer forMode:NSDefaultRunLoopMode];
}


@end
