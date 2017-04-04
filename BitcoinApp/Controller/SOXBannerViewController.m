//
//  SOXBannerViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 20.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXBannerViewController.h"

#import "SOXMarket_BitcoinDE_Core.h"

#import "SOXAccountInfoData.h"
#import "SOXRatesData.h"

#import "SOXDateFormatter.h"

#import "NSTextField+URL.h"

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
@property (weak) IBOutlet NSTextField *fidorReservationReservedAtDescriptionTextField;
@property (weak) IBOutlet NSTextField *fidorReservationReservedAtTextField;
@property (weak) IBOutlet NSTextField *fidorReservationValidUntilDescriptionTextField;
@property (weak) IBOutlet NSTextField *fidorReservationValidUntilTextField;

@property (weak) IBOutlet NSStackView *fidorReservationDescriptionStackView;
@property (weak) IBOutlet NSStackView *fidorReservationValuesStackView;

@property (weak) IBOutlet NSStackView *fidorReservationURLStackView;
@property (weak) IBOutlet NSTextField *fidorReservationLeftURLTextField;
@property (weak) IBOutlet NSTextField *fidorReservationRightURLTextField;

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

@end

#pragma mark - Implementation
@implementation SOXBannerViewController

#pragma mark Init&Co.
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear {
    [super viewWillAppear];
    
    [self setupUI];
    [self requestServerData];
}

#pragma mark - Private methods
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
        self.fidorReservationReservedAtDescriptionTextField.stringValue = @"Reserved at";
        self.fidorReservationValidUntilDescriptionTextField.stringValue = @"Valid unitl";
        
        self.fidorReservationTotalAmountTextField.stringValue = @"...";
        self.fidorReservationAvailableAmountTextField.stringValue = @"...";
        self.fidorReservationReservedAtTextField.stringValue = @"...";
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
        self.creditHeadlineTextField.stringValue = @"Credit information";
        
        self.creditTextCurrentCreditsDescriptionField.stringValue = @"Current credits";
        self.creditTextMaxCreditsDescriptonField.stringValue = @"Est. max credits";
        
        self.creditTextCurrentCreditsField.stringValue = @"...";
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
        { // Reserved At
            NSString *reservedATString = [SOXDateFormatter stringDateTimeStringForRFC3339DateTimeString:accountInfoData.bankReservation_reservedAt];
            self.fidorReservationReservedAtTextField.stringValue = reservedATString;
        }
        { // Valid until
            NSString *validUntilString = [SOXDateFormatter stringDateTimeStringForRFC3339DateTimeString:accountInfoData.bankReservation_validUntil];
            self.fidorReservationValidUntilTextField.stringValue = validUntilString;
        }
        { // clickable URLs
            [self.fidorReservationLeftURLTextField setHyperlinkFormattingFromString:@"Cancel reservation"
                                                                      withURLString:@"https://www.bitcoin.de/de/end_reservation"];
            [self.fidorReservationRightURLTextField setHyperlinkFormattingFromString:@"Renew reservation"
                                                                       withURLString:@"https://www.bitcoin.de/de/create_reservation"];
        }
    }
    else {
        self.fidorReservationValuesAndDescriptionStackView.hidden = YES;

        { // Description
            [self.fidorReservationLeftURLTextField resetHyperlinkFormatting];
            self.fidorReservationLeftURLTextField.stringValue = @"No Reservation";
        }
        { // clickable URL
            [self.fidorReservationRightURLTextField setHyperlinkFormattingFromString:@"Go to reservation"
                                                                       withURLString:@"https://www.bitcoin.de/de/reservation"];
        }
    }
}


- (void)requestServerData {
    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowAccountInfoCommandType
                                                respondTo:self];
    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowRatesCommandType
                                                respondTo:self];
    
    [SOXMarket_BitcoinDE_Core registerForCreditUpdates:self];
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
        }
        
        // fidor_reservation
        {
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
        }
    }
}
#pragma mark - SOXCreditUpdateProtocol
- (void)creditValuesUpdated:(NSDictionary * _Nonnull)creditDicts {
    NSNumber *currentCredit = [creditDicts objectForKey:CreditUpdate_CurrentCreditsKey];
    NSNumber *maxCredits = [creditDicts objectForKey:CreditUpdate_MaximalCreditsKey];
    
    self.creditTextCurrentCreditsField.stringValue = currentCredit.stringValue;
    self.creditTextMaxCreditsField.stringValue = maxCredits.stringValue;
}

@end
