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

@property (weak) IBOutlet NSStackView *fidorReservationDescriptionStackView;
@property (weak) IBOutlet NSStackView *fidorReservationValuesStackView;

#pragma mark | ratesData
@property (weak) IBOutlet NSTextField *ratesHeadlineTextField;
@property (weak) IBOutlet NSTextField *ratesRateWeightedDescriptionTextField;
@property (weak) IBOutlet NSTextField *ratesRateWeightedTextField;
@property (weak) IBOutlet NSTextField *ratesRateWeighted3hDescriptionTextField;
@property (weak) IBOutlet NSTextField *ratesRateWeighted3hTextField;
@property (weak) IBOutlet NSTextField *ratesRateWeighted12hDescriptionTextField;
@property (weak) IBOutlet NSTextField *ratesRateWeighted12hTextField;

#pragma mark | Coin value data
@property (weak) IBOutlet NSTextField *coinValueHeadlineTextField;
@property (weak) IBOutlet NSTextField *coinValueDescriptionTextField;
@property (weak) IBOutlet NSTextField *coinValueTextField;
@property (weak) IBOutlet NSTextField *emptyDescriptionTextField; // layout errors
@property (weak) IBOutlet NSTextField *emptyTextField;// layout errors

@property (weak) IBOutlet NSStackView *coinValueStackView;

#pragma mark - Properties
// Values to calculate wealth
@property (strong, nonatomic) NSDecimalNumber *btcBalanceTotalAmount;
@property (nonatomic) BitcoinDE_CurrencyType currencyType;

// Notifications
@property (strong, nonatomic) id requestShowAccountInfoNotification;
@property (strong, nonatomic) id requestShowRatesNotification;
@property (strong, nonatomic) id presentBannerInformationForCurrencyNotification;

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
}

#pragma mark - Private methods
- (void)registerOberservers {
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    
    weakify(self)
    self.requestShowAccountInfoNotification = [[NSNotificationCenter defaultCenter] addObserverForName:BitcoinDE_Notification_RequestShowAccountInfo
                                                                                                object:nil
                                                                                                 queue:mainQueue
                                                                                            usingBlock:^(NSNotification * _Nonnull note) {
                                                                                                strongify(self)
                                                                                                [self answerOfServerRequest:note.object];
                                                                                            }
                                               ];
    
    self.requestShowRatesNotification = [[NSNotificationCenter defaultCenter] addObserverForName:BitcoinDE_Notification_RequestShowRates
                                                                                          object:nil
                                                                                           queue:mainQueue
                                                                                      usingBlock:^(NSNotification * _Nonnull note) {
                                                                                          strongify(self)
                                                                                          [self answerOfServerRequest:note.object];
                                                                                      }
                                         ];

    self.presentBannerInformationForCurrencyNotification = [[NSNotificationCenter defaultCenter] addObserverForName:BitcoinDE_Notification_PresentBannerInformationForCurrency
                                                                                                object:nil
                                                                                                 queue:mainQueue
                                                                                            usingBlock:^(NSNotification * _Nonnull note) {
                                                                                                strongify(self)
                                                                                                [self presentBannerForCurrencyType:note];
                                                                                            }
                                                            ];
}

- (void)setupUI {
    // BTC stack
    {
        self.btcBalanceHeadlineTextField.stringValue = @"My Bitcoins";
        
        self.btcBalanceTotalAmountDescriptionTextField.stringValue = @"Total amount";
        self.btcBalanceAvailableAmountDescriptionTextField.stringValue = @"Available amount";
        self.btcBalanceReservedAmountDescriptionTextField.stringValue = @"Reserved amount";
        
        self.btcBalanceTotalAmountTextField.stringValue = @"...";
        self.btcBalanceAvailableAmountTextField.stringValue = @"...";
        self.btcBalanceReservedAmountTextField.stringValue = @"...";
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
        
        self.emptyDescriptionTextField.hidden = YES;
        self.emptyTextField.hidden = YES;
    
    }
}

- (void)updateUIForCoinAmounts {
    NSString *currencyTypeString = [SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:self.currencyType];
    self.btcBalanceHeadlineTextField.stringValue = [NSString stringWithFormat:@"My %@", currencyTypeString];
    
    NSString *currencyTypeShortString = [SOXMarket_BitcoinDE_DefTypes tradingPairShortStringForCurrencyType:self.currencyType];

    SOXAccountInfo_BitcoinDE_Data *accountInfoData = (SOXAccountInfo_BitcoinDE_Data *)[SOXMarket_BitcoinDE_Core sharedCore].accountInfoData;


    NSDecimalNumber *btcBalanceTotalAmount         = [accountInfoData totalAmountForCurrencyType:self.currencyType];
    NSDecimalNumber *btcBalanceAvailableAmountText = [accountInfoData availableAmountForCurrencyType:self.currencyType];
    NSDecimalNumber *btcBalanceReservedAmountText  = [accountInfoData reservedAmountForCurrencyType:self.currencyType];


    self.btcBalanceTotalAmountTextField.objectValue     = [NSString stringWithFormat:@"%@ %@"
                                                           , [[SOXFormatters bitcoinNumberWithoutCurrencySymbolFormatter] stringFromNumber:btcBalanceTotalAmount]
                                                           , currencyTypeShortString];
    self.btcBalanceAvailableAmountTextField.objectValue = [NSString stringWithFormat:@"%@ %@"
                                                           , [[SOXFormatters bitcoinNumberWithoutCurrencySymbolFormatter] stringFromNumber:btcBalanceAvailableAmountText]
                                                           , currencyTypeShortString];
    self.btcBalanceReservedAmountTextField.objectValue  = [NSString stringWithFormat:@"%@ %@"
                                                           , [[SOXFormatters bitcoinNumberWithoutCurrencySymbolFormatter] stringFromNumber:btcBalanceReservedAmountText]
                                                           , currencyTypeShortString];
}

- (void)updateUIForAllocations {
    SOXAccountInfo_BitcoinDE_Data *accountInfoData = (SOXAccountInfo_BitcoinDE_Data *)[SOXMarket_BitcoinDE_Core sharedCore].accountInfoData;
    if (accountInfoData.bankReservation_exists) {
        self.fidorReservationValuesAndDescriptionStackView.hidden = NO;

        self.fidorReservationTotalAmountTextField.doubleValue = [accountInfoData allocationMaxEurVolumeForCurrencyType:self.currencyType].doubleValue ;
        self.fidorReservationAvailableAmountTextField.doubleValue = [accountInfoData allocationEurVolumeOpenOrdersForCurrencyType:self.currencyType].doubleValue;
        NSString *validUntilString = [SOXFormatters stringDateTimeStringForRFC3339DateTimeString:accountInfoData.bankReservation_validUntil];
        self.fidorReservationValidUntilTextField.stringValue = validUntilString;
    }
    else {
        self.fidorReservationValuesAndDescriptionStackView.hidden = YES;
    }
}

- (void)updateUIForRates {
    SOXRates_BitcoinDE_Data *ratesData = (SOXRates_BitcoinDE_Data *)[SOXMarket_BitcoinDE_Core sharedCore].ratesData;
    self.ratesRateWeightedTextField.objectValue     = [ratesData rateWeightedForCurrencyType:self.currencyType];
    self.ratesRateWeighted3hTextField.objectValue   = [ratesData rateWeighted3hForCurrencyType:self.currencyType];
    self.ratesRateWeighted12hTextField.objectValue  = [ratesData rateWeighted12hForCurrencyType:self.currencyType];

    NSDecimalNumber *totalCoinAmount = [SOXMarket_BitcoinDE_Core totalAmountForCurrencyType:self.currencyType];
    NSDecimalNumber *rateWeighted = [SOXMarket_BitcoinDE_Core rateWeightedForCurrencyType:self.currencyType];
    if (totalCoinAmount
        && [totalCoinAmount isNotEqualTo:[NSDecimalNumber notANumber]]
        && rateWeighted
        && [rateWeighted isNotEqualTo:[NSDecimalNumber notANumber]]) {
        NSString *currencyTypeString = [SOXMarket_BitcoinDE_DefTypes tradingPairNaturalStringForCurrencyType:self.currencyType];
        self.coinValueHeadlineTextField.stringValue = [NSString stringWithFormat:@"Value of my %@", currencyTypeString];
        NSDecimalNumber *coinValue = [totalCoinAmount decimalNumberByMultiplyingBy:rateWeighted ];
        self.coinValueTextField.stringValue = [SOXFormatters currencyStringForNumber:coinValue
                                                                        roundingMode:NSNumberFormatterRoundUp];
    }
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
        // [self startRatesReloadTimer];
    }

    NSDecimalNumber *totalCoinAmount = [SOXMarket_BitcoinDE_Core totalAmountForCurrencyType:self.currencyType];
    NSDecimalNumber *rateWeighted = [SOXMarket_BitcoinDE_Core rateWeightedForCurrencyType:self.currencyType];
    if (totalCoinAmount
        && [totalCoinAmount isNotEqualTo:[NSDecimalNumber notANumber]]
        && rateWeighted
        && [rateWeighted isNotEqualTo:[NSDecimalNumber notANumber]]) {
        NSDecimalNumber *coinValue = [totalCoinAmount decimalNumberByMultiplyingBy:rateWeighted ];
        self.coinValueTextField.stringValue = [SOXFormatters currencyStringForNumber:coinValue
                                                                        roundingMode:NSNumberFormatterRoundUp];
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
