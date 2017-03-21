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

#pragma mark - Interface
@interface SOXBannerViewController () <SOXMarketCoreServerRequestProtocol>

#pragma mark IBOutlets
// accountInfoData
@property (weak) IBOutlet NSTextField *btcBalanceHeadlineTextField;
@property (weak) IBOutlet NSTextField *btcBalanceTotalAmountDescriptionTextField;
@property (weak) IBOutlet NSTextField *btcBalanceTotalAmountTextField;
@property (weak) IBOutlet NSTextField *btcBalanceAvailableAmountDescriptionTextField;
@property (weak) IBOutlet NSTextField *btcBalanceAvailableAmountTextField;
@property (weak) IBOutlet NSTextField *btcBalanceReservedAmountDescriptionTextField;
@property (weak) IBOutlet NSTextField *btcBalanceReservedAmountTextField;

@property (weak) IBOutlet NSTextField *fidorReservationHeadlineTextField;
@property (weak) IBOutlet NSTextField *fidorReservationTotalAmountDescriptionTextField;
@property (weak) IBOutlet NSTextField *fidorReservationTotalAmountTextField;
@property (weak) IBOutlet NSTextField *fidorReservationAvailableAmountDescriptionTextField;
@property (weak) IBOutlet NSTextField *fidorReservationAvailableAmountTextField;
@property (weak) IBOutlet NSTextField *fidorReservationReservedAtDescriptionTextField;
@property (weak) IBOutlet NSTextField *fidorReservationReservedAtTextField;
@property (weak) IBOutlet NSTextField *fidorReservationValidUntilDescriptionTextField;
@property (weak) IBOutlet NSTextField *fidorReservationValidUntilTextField;

// ratesData
@property (weak) IBOutlet NSTextField *ratesHeadlineTextField;
@property (weak) IBOutlet NSTextField *ratesRateWeightedDescriptionTextField;
@property (weak) IBOutlet NSTextField *ratesRateWeightedTextField;
@property (weak) IBOutlet NSTextField *ratesRateWeighted3hDescriptionTextField;
@property (weak) IBOutlet NSTextField *ratesRateWeighted3hTextField;
@property (weak) IBOutlet NSTextField *ratesRateWeighted12hDescriptionTextField;
@property (weak) IBOutlet NSTextField *ratesRateWeighted12hTextField;

#pragma mark Properties


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
    
    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowRatesCommandType
                                                respondTo:self];
    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowAccountInfoCommandType
                                                respondTo:self];
    
    
    
}

- (void)setupUI {
    // BTC stack
    {
        self.btcBalanceHeadlineTextField.stringValue = @"My Bitcoins";
        
        self.btcBalanceTotalAmountDescriptionTextField.stringValue = @"Total smount";
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
}

- (void)updateBankReservationUI:(BOOL)bankReservation_exists {
    if (bankReservation_exists) {
        self.fidorReservationTotalAmountDescriptionTextField.stringValue = @"Total amount";
        self.fidorReservationTotalAmountDescriptionTextField.alignment = NSTextAlignmentLeft;
    }
    else {
        self.fidorReservationTotalAmountDescriptionTextField.stringValue = @"No reservation";
        self.fidorReservationTotalAmountDescriptionTextField.alignment = NSTextAlignmentCenter;
    }
    
    self.fidorReservationAvailableAmountDescriptionTextField.hidden = !bankReservation_exists;
    self.fidorReservationReservedAtDescriptionTextField.hidden = !bankReservation_exists;
    self.fidorReservationValidUntilDescriptionTextField.hidden = !bankReservation_exists;
    
    self.fidorReservationTotalAmountTextField.hidden = !bankReservation_exists;
    self.fidorReservationAvailableAmountTextField.hidden = !bankReservation_exists;
    self.fidorReservationReservedAtTextField.hidden = !bankReservation_exists;
    self.fidorReservationValidUntilTextField.hidden = !bankReservation_exists;

    
}

#pragma mark - SOXMarketCoreServerRequestProtocol
- (void)answerOfServerRequest:(NSDictionary *)answerOfServerRequest {

    if ([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ShowAccountInfoCommandType)]) {
        SOXAccountInfoData *accountInfoData = [answerOfServerRequest objectForKey:ServerAnswerPayloadKey];
        { //  btc_balance
            self.btcBalanceTotalAmountTextField.doubleValue = accountInfoData.btcBalance_totalAmount.doubleValue;
            self.btcBalanceAvailableAmountTextField.doubleValue = accountInfoData.btcBalance_totalAmount.doubleValue;
            self.btcBalanceReservedAmountTextField.doubleValue = accountInfoData.btcBalance_reservedAmount.doubleValue;
        }
        { // fidor_reservation
            
                [self updateBankReservationUI:accountInfoData.bankReservation_exists];
//                self.fidorReservationTotalAmountTextField.doubleValue = accountInfoData.bankReservation_totalAmount.doubleValue;
//                self.fidorReservationAvailableAmountTextField.doubleValue = accountInfoData.bankReservation_availableAmount.doubleValue;
//                self.fidorReservationReservedAtTextField.doubleValue = accountInfoData.bankReservation_reservedAt.doubleValue;
//                self.fidorReservationValidUntilTextField.doubleValue = accountInfoData.bankReservation_validUntil.doubleValue;
            
        }
    }
    else if ([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ShowRatesCommandType)]) {
        SOXRatesData *ratesData = [answerOfServerRequest objectForKey:ServerAnswerPayloadKey];
        { //  rates
            self.ratesRateWeightedTextField.doubleValue = ratesData.rate_weighted.doubleValue;
            self.ratesRateWeighted3hTextField.doubleValue = ratesData.rate_weighted_3h.doubleValue;
            self.ratesRateWeighted12hTextField.doubleValue = ratesData.rate_weighted_12h.doubleValue;
        }

    }
}


@end
