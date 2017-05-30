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

#import "SOXAccountInfoData.h"
#import "SOXRatesData.h"

#import "SOXFormatters.h"

#pragma mark - Interface
@interface SOXBannerViewController () <SOXMarketCoreServerRequestProtocol, SOXCreditUpdateProtocol>

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

#pragma mark | creditData
@property (weak) IBOutlet NSTextField *creditHeadlineTextField;
@property (weak) IBOutlet NSTextField *creditTextCurrentCreditsDescriptionField;
@property (weak) IBOutlet NSTextField *creditTextCurrentCreditsField;
@property (weak) IBOutlet NSTextField *creditTextMaxCreditsDescriptonField;
@property (weak) IBOutlet NSTextField *creditTextMaxCreditsField;
@property (weak) IBOutlet NSStackView *creditValuesStackView;

#pragma mark - Properties
// Values to calculate wealth
@property (strong, nonatomic) NSDecimalNumber *btcBalanceTotalAmount;

// Notifications
@property (strong, nonatomic) id requestShowAccountInfoNotification;
@property (strong, nonatomic) id requestShowRatesNotification;

@end

#pragma mark - Implementation
@implementation SOXBannerViewController

#pragma mark Init&Co.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerOberservers];
    [self setupUI];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.requestShowAccountInfoNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:self.requestShowRatesNotification];
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
        
        self.fidorReservationTotalAmountDescriptionTextField.stringValue = @"Total amount";
        self.fidorReservationAvailableAmountDescriptionTextField.stringValue = @"Available amount";
        self.fidorReservationValidUntilDescriptionTextField.stringValue = @"Valid unitl";
        
        self.fidorReservationTotalAmountTextField.stringValue = @"...";
        self.fidorReservationAvailableAmountTextField.stringValue = @"...";
        self.fidorReservationValidUntilTextField.stringValue = @"...";
        
    }
    
    // Rates stack
    {
        self.ratesHeadlineTextField.stringValue = @"Weighted Bitcoin Rates";
        
        self.ratesRateWeightedDescriptionTextField.stringValue = @"Current";
        self.ratesRateWeighted3hDescriptionTextField.stringValue = @"Last 3 hours";
        self.ratesRateWeighted12hDescriptionTextField.stringValue = @"Last 12 hours";
        
        self.ratesRateWeightedTextField.stringValue = @"...";
        self.ratesRateWeighted3hTextField.stringValue = @"...";
        self.ratesRateWeighted12hTextField.stringValue = @"...";
    }
    
    // Credit stack
    {
        self.creditHeadlineTextField.stringValue = @"Wealth information";
        
        self.creditTextCurrentCreditsDescriptionField.stringValue = @"";
        self.creditTextMaxCreditsDescriptonField.stringValue = @"Current worth";
        
        self.creditTextCurrentCreditsField.stringValue = @"";
        self.creditTextMaxCreditsField.stringValue = @"...";
    
    }
}

- (void)updateUIForBankReservationWithAccountInfoData:(SOXAccountInfoData *)accountInfoData {
    if (accountInfoData.bankReservation_exists) {
        self.fidorReservationValuesAndDescriptionStackView.hidden = NO;
        
        { // Total amount
            self.fidorReservationTotalAmountDescriptionTextField.stringValue = @"Total amount";
            self.fidorReservationTotalAmountTextField.doubleValue = accountInfoData.bankReservation_totalAmount.doubleValue;
        }
        { // Available amount
            self.fidorReservationAvailableAmountTextField.doubleValue = accountInfoData.bankReservation_availableAmount.doubleValue;
        }
        { // Valid until
            NSString *validUntilString = [SOXFormatters stringDateTimeStringForRFC3339DateTimeString:accountInfoData.bankReservation_validUntil];
            self.fidorReservationValidUntilTextField.stringValue = validUntilString;
        }
    }
    else {
        self.fidorReservationValuesAndDescriptionStackView.hidden = YES;
        
        // DEBUG Fidor Reservation for testing
//        self.fidorReservationValuesAndDescriptionStackView.hidden = NO;
//        [SOXMarket_BitcoinDE_Core sharedCore].availableFidorAmount = [NSDecimalNumber decimalNumberWithString:@"300"];
//        self.fidorReservationAvailableAmountTextField.stringValue = @"Debug: 300€";
    }
}

#pragma mark - SOXMarketCoreServerRequestProtocol
- (void)answerOfServerRequest:(NSDictionary *)answerOfServerRequest {

    if ([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ShowAccountInfoCommandType)]) {
        SOXAccountInfoData *accountInfoData = [answerOfServerRequest objectForKey:ServerAnswerPayloadKey];
        
        //  btc_balance
        {
            self.btcBalanceTotalAmountTextField.doubleValue = accountInfoData.btcBalance_totalAmount.doubleValue;
            self.btcBalanceAvailableAmountTextField.doubleValue = accountInfoData.btcBalance_availableAmount.doubleValue;
            self.btcBalanceReservedAmountTextField.doubleValue = accountInfoData.btcBalance_reservedAmount.doubleValue;
            
            [SOXMarket_BitcoinDE_Core sharedCore].availableBitcoinAmount = accountInfoData.btcBalance_availableAmount;
            self.btcBalanceTotalAmount = accountInfoData.btcBalance_totalAmount;
        }
        
        // fidor_reservation
        {
            
            [SOXMarket_BitcoinDE_Core sharedCore].availableFidorAmount = accountInfoData.bankReservation_availableAmount;
            [self updateUIForBankReservationWithAccountInfoData:accountInfoData];
        }
    }
    else if ([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ShowRatesCommandType)]) {
        SOXRatesData *ratesData = [answerOfServerRequest objectForKey:ServerAnswerPayloadKey];
        //  rates
        {
            self.ratesRateWeightedTextField.doubleValue = ratesData.rate_weighted.doubleValue;
            self.ratesRateWeighted3hTextField.doubleValue = ratesData.rate_weighted_3h.doubleValue;
            self.ratesRateWeighted12hTextField.doubleValue = ratesData.rate_weighted_12h.doubleValue;
            
            // set values on SOXMarket_BitcoinDE_Core
            {
                [SOXMarket_BitcoinDE_Core sharedCore].rate_weighted = ratesData.rate_weighted;
            
                
                NSDecimalNumber *rate_weighted_half         = [ratesData.rate_weighted decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"2"]];
                NSDecimalNumber *rate_weighted_half_rounded = [SOXFormatters currencyNumberForNumber:rate_weighted_half
                                                                                        roundingMode:NSNumberFormatterRoundUp];
                [SOXMarket_BitcoinDE_Core sharedCore].rate_weighted_half = rate_weighted_half_rounded;
            }
            
           // [self startRatesReloadTimer];
        }
    }
    
    if (self.btcBalanceTotalAmount && [SOXMarket_BitcoinDE_Core sharedCore].rate_weighted ) {
        NSDecimalNumber *wealth = [self.btcBalanceTotalAmount decimalNumberByMultiplyingBy:[SOXMarket_BitcoinDE_Core sharedCore].rate_weighted ];
        self.creditTextMaxCreditsField.stringValue = [SOXFormatters currencyStringForNumber:wealth
                                                                               roundingMode:NSNumberFormatterRoundUp];
    }
    
}

- (void)startRatesReloadTimer {
    NSLog(@"***** NEW RATE: %@", [SOXMarket_BitcoinDE_Core sharedCore].rate_weighted);
    
    NSTimer *ratesReloadTimer  = [NSTimer scheduledTimerWithTimeInterval:600
                                                                     target:self
                                                                   selector:@selector(requestServerData)
                                                                   userInfo:nil
                                                                    repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:ratesReloadTimer forMode:NSDefaultRunLoopMode];
}


#pragma mark - SOXCreditUpdateProtocol
- (void)creditValuesUpdated:(NSDictionary * _Nonnull)creditDicts {
    NSNumber *currentCredit = [creditDicts objectForKey:CreditUpdate_CurrentCreditsKey];
    NSNumber *maxCredits = [creditDicts objectForKey:CreditUpdate_MaximalCreditsKey];
    
    self.creditTextCurrentCreditsField.stringValue = currentCredit.stringValue;
    self.creditTextMaxCreditsField.stringValue = maxCredits.stringValue;
}

@end
