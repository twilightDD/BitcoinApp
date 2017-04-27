//
//  SOXExecuteTradeViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 17.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXExecuteTradeViewController.h"

#import "SOXMarket_BitcoinDE_Core.h"
#import "SOXShowOrderbook_BitcoinDE_Data.h"
#import "SOXTradeJob_BitcoinDE_Data.h"

#import "SOXKeys_BitcoinDE.h"
#import "SOXPreferenceCenter.h"

NSString const * _Nonnull ExecuteTradeViewControllerIdentifierKey = @"ExecuteTradeViewControllerIdentifier";

#pragma mark - Interface
@interface SOXExecuteTradeViewController () <SOXMarketCoreServerRequestProtocol, NSControlTextEditingDelegate>

#pragma mark IBOutlets
@property (weak) IBOutlet NSTextField *titleTextField;
// Order information stack view
@property (weak) IBOutlet NSTextField *priceDescriptionTextField;
@property (weak) IBOutlet NSTextField *priceTextField;
@property (weak) IBOutlet NSTextField *minBTCDescriptionTextField;
@property (weak) IBOutlet NSTextField *minBTCTextField;
@property (weak) IBOutlet NSTextField *maxBTCDescriptionTextField;
@property (weak) IBOutlet NSTextField *maxBTCTextField;
@property (weak) IBOutlet NSTextField *minVolumeDescriptionTextField;
@property (weak) IBOutlet NSTextField *minVolumeTextField;
@property (weak) IBOutlet NSTextField *maxVolumeDescriptionTextField;
@property (weak) IBOutlet NSTextField *maxVolumeTextField;
@property (weak) IBOutlet NSTextField *orderIDTextDescriptionField;
@property (weak) IBOutlet NSTextField *orderIDTextField;

// trading partner stack view
@property (weak) IBOutlet NSTextField *tradingPartnerInformationDescriptionTextField;
@property (weak) IBOutlet NSTextField *userNameDescriptionTextField;
@property (weak) IBOutlet NSTextField *userNameTextField;
@property (weak) IBOutlet NSTextField *isKYCDescriptionTextField;
@property (weak) IBOutlet NSTextField *isKYCTextField;
@property (weak) IBOutlet NSTextField *trustLevelDescriptionTextField;
@property (weak) IBOutlet NSTextField *trustLevelTextField;
@property (weak) IBOutlet NSTextField *tradesDescriptionTextField;
@property (weak) IBOutlet NSTextField *tradesTextField;
@property (weak) IBOutlet NSTextField *ratingDescriptionTextField;
@property (weak) IBOutlet NSTextField *ratingTextField;

// Amount section
@property (weak) IBOutlet NSTextField *amountToTradeDescriptionTextField;
@property (weak) IBOutlet NSTextField *amountToTradeTextField;
@property (weak) IBOutlet NSTextField *minMaxPossibleAmountTextField;
@property (weak) IBOutlet NSButton *autoMinAmountToTradeButton;
@property (weak) IBOutlet NSButton *autoMaxAmountToTradeButton;
@property (weak) IBOutlet NSTextField *volumeToTradeDescriptionTextField;
@property (weak) IBOutlet NSTextField *volumeToTradeTextField;

@property (weak) IBOutlet NSTextField *userInformationTextField;
// Buttons
@property (weak) IBOutlet NSButton *executeTradeButton;
@property (weak) IBOutlet NSButton *cancelButton;

#pragma mark Properties
@property (nonatomic) BOOL mayExecuteTrade;
@property (nonatomic) BOOL executeTradeIsPossible;
@property (strong, nonatomic) NSString *minimalAmountToTrade;
@property (strong, nonatomic) NSString *maximalAmountToTrade;
@property (strong, nonatomic) NSNumber *amountToTrade;
@property (nonatomic) BitcoinDE_PaymentOption defaultPaymentOption;
@property (nonatomic) BitcoinDE_PaymentOption orderBookPaymentOption;
@property (nonatomic) BitcoinDE_PaymentOption executePaymentOption;
@end

#pragma mark - Implementation
@implementation SOXExecuteTradeViewController
#pragma mark Init&Co.
- (void)viewWillAppear {
    [super viewWillAppear];
    
    self.mayExecuteTrade        = NO;
    self.defaultPaymentOption   = [SOXPreferenceCenter defaultPaymentOptionForExecuteTrade];
    self.orderBookPaymentOption = self.orderBookData.orderRequirements_paymentOption.unsignedIntegerValue;
    
    [self setupMinMaxAmountToTrade];
    [self setupUI];
}

#pragma mark - Private methods
- (void)setupMinMaxAmountToTrade {
    // MinAmount (we need it for userInformation in case of self.executeTradeIsPossible stays NO
    double minAmount            = self.orderBookData.orderInformation_minAmount.doubleValue;
    self.minimalAmountToTrade   = [NSString stringWithFormat:@"%.8g", minAmount];
    
    self.executeTradeIsPossible = NO;
    
    if (!self.orderBookData) {
        return;
    }
    
    // MaxAmount
    double maxAmount  = 0;
    {
        SOXMarket_BitcoinDE_Core *core = [SOXMarket_BitcoinDE_Core sharedCore];
        
        if (self.orderType == BitcoinDE_BuyOrderType) {
            NSNumber *maxAmountOrderBookData = self.orderBookData.orderInformation_maxAmount;
            NSNumber *maxAmountAvailableEuro = @([SOXMarket_BitcoinDE_Core sharedCore].availableEuroAmount.doubleValue /
                                                self.orderBookData.orderInformation_price.doubleValue);
            
            if ([maxAmountOrderBookData isLessThan:maxAmountAvailableEuro]) {
                maxAmount = maxAmountOrderBookData.doubleValue;
            }
            else {
                maxAmount = maxAmountAvailableEuro.doubleValue;
            }
        }
        else if (self.orderType == BitcoinDE_SellOrderType) {
            NSNumber *maxAmountOrderBookData    = self.orderBookData.orderInformation_maxAmount;
            NSNumber *maxAmountAvailableBitcoin = core.availableBitcoinAmount;
            if ([maxAmountOrderBookData isLessThan:maxAmountAvailableBitcoin]) {
                maxAmount = maxAmountOrderBookData.doubleValue;
            }
            else {
                maxAmount = maxAmountAvailableBitcoin.doubleValue;
            }
        }
        
        // maxMount may have up to 8 digits after "."
        maxAmount = floor(maxAmount * 100000000) / 100000000;
    }
    
    if ([SOXPreferenceCenter defaultPaymentOptionForExecuteTrade] == BitcoinDE_PaymentOptionExpressOnly) {
        // if minAmount < maxMount we can buy/sell
        if (minAmount <= maxAmount) {
            self.maximalAmountToTrade = [NSString stringWithFormat:@"%.8g", maxAmount];
            self.executeTradeIsPossible = YES;
        }
    }
    else {
        self.maximalAmountToTrade = [NSString stringWithFormat:@"%.8g", maxAmount];
        self.executeTradeIsPossible = YES;
        if (minAmount <= maxAmount) {
            self.executePaymentOption = BitcoinDE_PaymentOptionExpressAndSepa;
        }
        else {
            self.executePaymentOption = BitcoinDE_PaymentOptionSEPAOnly;
        }
    }
    
    
    // set boundaries of input field number formatter
    NSNumberFormatter* fieldFormatter = self.amountToTradeTextField.formatter;
    fieldFormatter.minimum = @(self.minimalAmountToTrade.doubleValue);
    // if order is Express only, set
    if (self.orderBookPaymentOption == BitcoinDE_PaymentOptionExpressOnly) {
        fieldFormatter.maximum = @(self.maximalAmountToTrade.doubleValue);
    }
}

- (void)setupUI {
    // orderBookData
    {
        self.tradingPartnerInformationDescriptionTextField.stringValue = @"Trading partner";
        self.priceDescriptionTextField.stringValue      = @"Price per BTC";
        self.minBTCDescriptionTextField.stringValue     = @"Minimum BTC";
        self.maxBTCDescriptionTextField.stringValue     = @"Maximum BTC";
        self.minVolumeDescriptionTextField.stringValue  = @"Minimum Volume";
        self.maxVolumeDescriptionTextField.stringValue  = @"Maximum Volume";
        self.orderIDTextDescriptionField.stringValue    = @"Order ID";
        
        self.priceTextField.doubleValue     = self.orderBookData.orderInformation_price.doubleValue ? : -1;
        self.minBTCTextField.doubleValue    = self.orderBookData.orderInformation_minAmount.doubleValue ? : -1;
        self.maxBTCTextField.doubleValue    = self.orderBookData.orderInformation_maxAmount.doubleValue ? : -1;
        self.minVolumeTextField.doubleValue = self.orderBookData.orderInformation_minVolume.doubleValue ? : -1;
        self.maxVolumeTextField.doubleValue = self.orderBookData.orderInformation_maxVolume.doubleValue ? : -1;
        self.orderIDTextField.stringValue   = self.orderBookData.orderInformation_orderID ? : @" - ";

    }
    
    // Trading partner information
    {
        self.userNameDescriptionTextField.stringValue   = @"User name";
        self.isKYCDescriptionTextField.stringValue      = @"User is known";
        self.trustLevelDescriptionTextField.stringValue = @"Trust level";
        self.tradesDescriptionTextField.stringValue     = @"Trades";
        self.ratingDescriptionTextField.stringValue     = @"Positiv ratings [%]";
        
        self.userNameTextField.stringValue      = self.orderBookData.tradingPartnerInformation_username ? : @" ? ";
        self.isKYCTextField.stringValue         = self.orderBookData.tradingPartnerInformation_isKYCFull ? @"Yes" : @"NO";
        self.trustLevelTextField.stringValue    = self.orderBookData.tradingPartnerInformation_trustLevel ? : @" ? ";
        self.tradesTextField.stringValue        = self.orderBookData.tradingPartnerInformation_amountTrades.stringValue ? : @" ? ";
        self.ratingTextField.stringValue        = self.orderBookData.tradingPartnerInformation_rating.stringValue ? : @" ? ";
    }
    
    // title and buttons
    NSString *titleText;
    NSString *amountToTradeDescriptionText;
    NSString *userInformationText;
    
    if (self.orderType == BitcoinDE_BuyOrderType) {
        titleText = @"Buy bitcoins";
        amountToTradeDescriptionText = @"Buy bitcoins";
        userInformationText = [NSString stringWithFormat:@"You have not enough fidor amount to buy at least %@ BTC", self.minimalAmountToTrade];
    }
    else if (self.orderType == BitcoinDE_SellOrderType) {
        titleText = @"Sell bitcoins";
        amountToTradeDescriptionText = @"Sell bitcoins";
        userInformationText = [NSString stringWithFormat:@"You have not enough BTC to sell at least %@ BTC", self.minimalAmountToTrade];
    }

    self.titleTextField.stringValue = titleText;
    self.amountToTradeDescriptionTextField.stringValue = amountToTradeDescriptionText;
    
    self.autoMinAmountToTradeButton.title = @"Minimal BTC";//self.minimalAmountToTrade.stringValue;
    self.autoMaxAmountToTradeButton.title = @"Maximal BTC";//self.maximalAmountToTrade.stringValue;
    
    self.volumeToTradeDescriptionTextField.stringValue = @"Volume";
    self.volumeToTradeTextField.doubleValue            = 0;
    
    self.userInformationTextField.stringValue = userInformationText;
    
    [self setupExecuteTradeButton];
    self.cancelButton.title = @"Cancel";
    
    self.minMaxPossibleAmountTextField.stringValue = [NSString stringWithFormat:@"(min: %@, max: %@)",
                                                      self.minimalAmountToTrade, self.maximalAmountToTrade];
}

- (void)setupExecuteTradeButton {
    if (self.orderType == BitcoinDE_BuyOrderType) {
        NSString *executeTradeButtonText;
        if (self.executePaymentOption != BitcoinDE_PaymentOptionSEPAOnly) {
            executeTradeButtonText = @"Execute buy";
        }
        else {
            executeTradeButtonText = @"Execute SEPA buy";
        }
        self.executeTradeButton.title = executeTradeButtonText;
    }
    else if (self.orderType == BitcoinDE_SellOrderType) {
        self.executeTradeButton.title = @"Execute sell";
    }
    else {
        self.executeTradeButton.title = @"No orderType";
    }
}

- (void)toggleUIElements {
    self.userInformationTextField.hidden = self.executeTradeIsPossible;
    
    self.amountToTradeDescriptionTextField.hidden   = !self.executeTradeIsPossible;
    self.amountToTradeTextField.hidden              = !self.executeTradeIsPossible;
    self.minMaxPossibleAmountTextField.hidden       = !self.executeTradeIsPossible;
    self.autoMinAmountToTradeButton.hidden          = !self.executeTradeIsPossible;
    self.autoMaxAmountToTradeButton.hidden          = !self.executeTradeIsPossible;
    self.volumeToTradeDescriptionTextField.hidden   = !self.executeTradeIsPossible;
    self.volumeToTradeTextField.hidden              = !self.executeTradeIsPossible;
    self.executeTradeButton.hidden                  = !self.executeTradeIsPossible;
}

- (BOOL)validateAmountInput:(NSNumber *)inputValue {
    BOOL validationResult = NO;
    
    // Validate minAmount
    if (inputValue.doubleValue >= self.minimalAmountToTrade.doubleValue) {
        validationResult = YES;
    }
    
    // Validate maxAmount and paymentOption
    if (validationResult) {
        // Express only
        if (self.defaultPaymentOption == BitcoinDE_PaymentOptionExpressOnly) {
            if (inputValue.doubleValue > self.maximalAmountToTrade.doubleValue) {
                validationResult = NO;
            }
            else {
                self.executePaymentOption = BitcoinDE_PaymentOptionExpressOnly;
            }
        }
        
        // SEPA only
        if (self.orderBookPaymentOption == BitcoinDE_PaymentOptionSEPAOnly
            && self.defaultPaymentOption != BitcoinDE_PaymentOptionExpressOnly) {
            if (inputValue.doubleValue <= self.orderBookData.orderInformation_maxAmount.doubleValue) {
                self.executePaymentOption = BitcoinDE_PaymentOptionSEPAOnly;
            }
            else {
                validationResult = NO;
            }
            
        }
        
        // Express or Sepa
        if (self.orderBookPaymentOption == BitcoinDE_PaymentOptionExpressAndSepa
            && self.defaultPaymentOption == BitcoinDE_PaymentOptionExpressAndSepa) {
            if (inputValue.doubleValue <= self.maximalAmountToTrade.doubleValue) {
                self.executePaymentOption = BitcoinDE_PaymentOptionExpressOnly;
            }
            else if (inputValue.doubleValue <= self.orderBookData.orderInformation_maxAmount.doubleValue){
                self.executePaymentOption = BitcoinDE_PaymentOptionSEPAOnly;
            }
            else {
                validationResult = NO;
            }
        }
    }

    if (validationResult) {
        double volume = inputValue.doubleValue * self.orderBookData.orderInformation_price.doubleValue;
        self.volumeToTradeTextField.doubleValue = volume;
        self.mayExecuteTrade = YES;
    }
    else {
        self.executePaymentOption = BitcoinDE_PaymentOptionUnknown;
        self.volumeToTradeTextField.stringValue = @"Non valid input";
        _amountToTrade = @(0);
        self.mayExecuteTrade = NO;
    }
    
    return validationResult;
}

- (void)executeTrade {
    NSDictionary *parameterDictionary;
    parameterDictionary = [SOXTradeJob_BitcoinDE_Data parameterForOrderID:self.orderBookData.orderInformation_orderID
                                                                orderType:self.orderType
                                                            bitcoinAmount:self.amountToTrade];
    
    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ExecuteTrade
                                            withParameter:parameterDictionary
                                                respondTo:nil];
    [self dismissController:self];

}

#pragma mark - Action methods
- (IBAction)executeTradeAction:(NSButton *)sender {
    if ([SOXPreferenceCenter secureExecuteTrade]) {
        
        // create strings
        NSString *executeTradeButtonTitle = self.executeTradeButton.title;
        NSString *cancelButtonTitle       = @"Cancel";
        NSString *messageText             = @"Attention attention ihr Menschen!";
        NSString *informativeText         = [NSString stringWithFormat:@"You will %@ %@ bitcoins (worth %0.2f of real money).",
                                             [SOXMarket_BitcoinDE_DefTypes orderTypeStringForOrderType:self.orderType]
                                             , self.amountToTrade
                                             , self.amountToTrade.doubleValue * self.orderBookData.orderInformation_price.doubleValue];
        // create alert
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:executeTradeButtonTitle];
        [alert addButtonWithTitle:cancelButtonTitle];
        [alert setMessageText:messageText];
        [alert setInformativeText:informativeText];
        [alert setAlertStyle:NSWarningAlertStyle];
        
        // present alert
        weakify(self)
        [alert beginSheetModalForWindow:self.view.window
                      completionHandler:^(NSModalResponse returnCode) {
                          strongify(self)
                          if (returnCode == NSModalResponseOK) { // Execute trade
                              [self executeTrade];
                          }
                      }];
    }
    else {
        // TODO: Enable [self executeTrade]; on secureExecuteTrade = NO;
//        [self executeTrade];
    }
}

- (IBAction)cancelAction:(NSButton *)sender {
    [self dismissViewController:self];
}

- (IBAction)autoMinAmountToTradeAction:(NSButton *)sender {
    self.amountToTrade = @(self.minimalAmountToTrade.doubleValue);
}

- (IBAction)autoMaxAmountToTradeAction:(NSButton *)sender {
    self.amountToTrade = @(self.maximalAmountToTrade.doubleValue);
}

#pragma mark - Manual Setters
- (void)setAmountToTrade:(NSNumber *)amountToTrade {
    _amountToTrade = amountToTrade;
    [self validateAmountInput:amountToTrade];
}

- (void)setExecuteTradeIsPossible:(BOOL)executeTradeIsPossible {
    _executeTradeIsPossible = executeTradeIsPossible;
    [self toggleUIElements];
}

- (void)setExecutePaymentOption:(BitcoinDE_PaymentOption)executePaymentOption {
    _executePaymentOption = executePaymentOption;
    if (executePaymentOption == BitcoinDE_PaymentOptionSEPAOnly) {
        self.userInformationTextField.hidden      = NO;
        self.userInformationTextField.stringValue = @"Attention: SEPA trade";
    }
    else {
        self.userInformationTextField.hidden = YES;
    }
    
    [self setupExecuteTradeButton];
}

#pragma mark - SOXMarketCoreServerRequestProtocol
- (void)answerOfServerRequest:(NSDictionary *)answerOfServerRequest {
    NSLog(@"answerOfServerRequest: \n%@", answerOfServerRequest);
}

#pragma mark - NSControlTextEditingDelegate
- (void)controlTextDidChange:(NSNotification *)notification {
    NSTextField* valueField = notification.object;
    NSNumberFormatter* fieldFormatter = valueField.formatter;
    NSText* fieldEditor = valueField.currentEditor;
    
    id newValue = ( fieldEditor!=nil ? [fieldFormatter numberFromString:fieldEditor.string] : valueField.objectValue );
    self.amountToTrade = newValue;
}

@end
