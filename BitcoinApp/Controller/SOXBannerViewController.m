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

#pragma mark - SOXMarketCoreServerRequestProtocol
- (void)answerOfServerRequest:(NSDictionary *)answerOfServerRequest {

    if ([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ShowAccountInfoCommandType)]) {
        SOXAccountInfoData *accountInfoData = [answerOfServerRequest objectForKey:ServerAnswerPayloadKey];
        { //  btc_balance
            self.btcBalanceTotalAmountTextField.stringValue = accountInfoData.btcBalance_totalAmount;
            self.btcBalanceAvailableAmountTextField.stringValue = accountInfoData.btcBalance_totalAmount;
            self.btcBalanceReservedAmountTextField.stringValue = accountInfoData.btcBalance_reservedAmount;
        }
        { // fidor_reservation
            
            
        }
    }
    else if ([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ShowRatesCommandType)]) {
        SOXRatesData *ratesData = [answerOfServerRequest objectForKey:ServerAnswerPayloadKey];
        { //  rates
            self.ratesRateWeightedTextField.stringValue = ratesData.rate_weighted;
            self.ratesRateWeighted3hTextField.stringValue = ratesData.rate_weighted_3h;
            self.ratesRateWeighted12hTextField.stringValue = ratesData.rate_weighted_12h;
        }

    }
}


@end
