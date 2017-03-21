//
//  SOXBannerViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 20.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXBannerViewController.h"

#import "SOXMarket_BitcoinDE_Core.h"

#import "SOXAccountInfo_BitcoinDE_Data.h"
#pragma mark - Interface
@interface SOXBannerViewController () <SOXMarketCoreServerRequestProtocol>
#pragma mark IBOutlets
@property (weak) IBOutlet NSTextField *btcBalanceHeadlineTextField;
@property (weak) IBOutlet NSTextField *btcBalanceTotalAmountDescriptionTextField;
@property (weak) IBOutlet NSTextField *btcBalanceTotalAmountTextField;
@property (weak) IBOutlet NSTextField *btcBalanceAvailableAmountDescriptionTextField;
@property (weak) IBOutlet NSTextField *btcBalanceAvailableAmountTextField;
@property (weak) IBOutlet NSTextField *btcBalanceReservedAmountTextField;
@property (weak) IBOutlet NSTextField *btcBalanceReservedAmountDescriptionTextField;

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
    self.btcBalanceHeadlineTextField.stringValue = @"Bitcoins";
    self.btcBalanceTotalAmountDescriptionTextField.stringValue = @"Total smount";
    self.btcBalanceAvailableAmountDescriptionTextField.stringValue = @"Available amount";
    self.btcBalanceReservedAmountDescriptionTextField.stringValue = @"Reserved amount";
    
    
    self.btcBalanceTotalAmountTextField.stringValue = @"...";
    self.btcBalanceAvailableAmountTextField.stringValue = @"...";
    self.btcBalanceReservedAmountTextField.stringValue = @"...";
    
}

#pragma mark - SOXMarketCoreServerRequestProtocol
- (void)answerOfServerRequest:(NSDictionary *)answerOfServerRequest {

    if ([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ShowAccountInfoCommandType)]) {
        SOXAccountInfo_BitcoinDE_Data *bannerData = [answerOfServerRequest objectForKey:ServerAnswerPayloadKey];
        { //  btc_balance
            self.btcBalanceTotalAmountTextField.stringValue = bannerData.btcBalance_totalAmount;
            self.btcBalanceAvailableAmountTextField.stringValue = bannerData.btcBalance_totalAmount;
            self.btcBalanceReservedAmountTextField.stringValue = bannerData.btcBalance_reservedAmount;
        }
        { // fidor_reservation
            
            
        }
    }
    else if ([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ShowRatesCommandType)]) {
        NSLog(@"BitcoinDE_ShowRatesCommandType\n%@",answerOfServerRequest);
    }
}


@end
