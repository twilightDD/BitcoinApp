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

#import "SOXFormatters.h"

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
@property (weak) IBOutlet NSTextField *volumeToTradeDescriptionTextField;
@property (weak) IBOutlet NSTextField *volumeToTradeTextField;

// Auto btc amount stack view
@property (weak) IBOutlet NSButton *minimumBTCAmountButton;
@property (weak) IBOutlet NSButton *maximalFidorBTCAmountButton;
@property (weak) IBOutlet NSButton *maximalOrderBTCAmountButton;

@property (weak) IBOutlet NSTextField *userInformationTextField;
// Buttons
@property (weak) IBOutlet NSButton *executeTradeButton;
@property (weak) IBOutlet NSButton *cancelButton;

#pragma mark Properties
@property (nonatomic) BOOL mayExecuteTrade;
@property (nonatomic) BOOL executeTradeIsPossible;
@property (strong, nonatomic) NSDecimalNumber *maxPossibleBTCAmountToTrade;
@property (strong, nonatomic) NSDecimalNumber *amountToTrade;
@property (nonatomic) BitcoinDE_PaymentOption defaultPaymentOption;
@property (nonatomic) BitcoinDE_PaymentOption orderBookPaymentOption;
@property (nonatomic) BitcoinDE_PaymentOption executePaymentOption;

@property (strong, nonatomic) NSDecimalNumber *availableFidorAmount;

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
    if (!self.orderBookData) {
        return;
    }
    
    self.executeTradeIsPossible = NO;
    
    // MaxAmount
    NSDecimalNumber *maxPossibleBTCAmountToTrade  = 0;
    {
        SOXMarket_BitcoinDE_Core *core = [SOXMarket_BitcoinDE_Core sharedCore];
        
        if (self.orderType == BitcoinDE_BuyOrderType) {
            NSDecimalNumber *maxAmountOrderBookData = self.orderBookData.orderInformation_maxAmount;
            NSDecimalNumber *maxAmountAvailableEuro = [[SOXMarket_BitcoinDE_Core sharedCore].availableFidorAmount decimalNumberByDividingBy:
                                                self.orderBookData.orderInformation_price
                                                                                                                               withBehavior:[SOXFormatters btcNumberHandler]];
            
            if ([maxAmountOrderBookData isLessThan:maxAmountAvailableEuro]) {
                maxPossibleBTCAmountToTrade = maxAmountOrderBookData;
            }
            else {
                maxPossibleBTCAmountToTrade = maxAmountAvailableEuro;
            }
        }
        else if (self.orderType == BitcoinDE_SellOrderType) {
            if ([self.orderBookData.orderInformation_maxAmount isLessThan:core.availableBitcoinAmount]) {
                maxPossibleBTCAmountToTrade = self.orderBookData.orderInformation_maxAmount;
            }
            else {
                maxPossibleBTCAmountToTrade = core.availableBitcoinAmount;
            }
        }
    }
    
    
    
    
    
    if ([SOXPreferenceCenter defaultPaymentOptionForExecuteTrade] == BitcoinDE_PaymentOptionExpressOnly) {
        // if minAmount < maxMount we can buy/sell
        if ([self.orderBookData.orderInformation_minAmount isLessThanOrEqualTo:maxPossibleBTCAmountToTrade]) {
            self.userNameTextField.hidden = YES;
            self.maxPossibleBTCAmountToTrade = maxPossibleBTCAmountToTrade;
            self.executeTradeIsPossible = YES;
        }
        else {
            self.userNameTextField.hidden      = NO;
            self.userNameTextField.stringValue = @"Express only - you don't have enough fidor reservation";
            self.executeTradeIsPossible        = NO;
        }
    }
    else { // Sepa OR Express&Sepa
        self.maxPossibleBTCAmountToTrade = maxPossibleBTCAmountToTrade;
        self.executeTradeIsPossible = YES;
        if ([self.orderBookData.orderInformation_minAmount isLessThanOrEqualTo:maxPossibleBTCAmountToTrade]) {
            self.executePaymentOption = BitcoinDE_PaymentOptionExpressAndSepa;
        }
        else {
            self.executePaymentOption = BitcoinDE_PaymentOptionSEPAOnly;
            
        }
    }
    
    
    // set boundaries of input field number formatter
    NSNumberFormatter* fieldFormatter = self.amountToTradeTextField.formatter;
    fieldFormatter.minimum = self.orderBookData.orderInformation_minAmount;
    fieldFormatter.maximum = [SOXFormatters greaterDecimalNumberFrom:self.maxPossibleBTCAmountToTrade
                                                                 and:self.orderBookData.orderInformation_maxAmount];
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
    
    if (self.orderType == BitcoinDE_BuyOrderType) {
        titleText = @"Buy bitcoins";
        amountToTradeDescriptionText = @"Buy bitcoins";
    }
    else if (self.orderType == BitcoinDE_SellOrderType) {
        titleText = @"Sell bitcoins";
        amountToTradeDescriptionText = @"Sell bitcoins";
    }

    self.titleTextField.stringValue = titleText;
    self.amountToTradeDescriptionTextField.stringValue = amountToTradeDescriptionText;
    
    self.volumeToTradeDescriptionTextField.stringValue = @"Volume";
    self.volumeToTradeTextField.stringValue            = [SOXFormatters currencyStringForNumber:[NSDecimalNumber decimalNumberWithString:@"0"]
                                                                                   roundingMode:NSNumberFormatterRoundUp];
    
    {// userInformationTextField not used at the moment
        self.userInformationTextField.hidden        = YES;
        self.userInformationTextField.stringValue   = @"";
    }
    
    // Auto btc amount stack view
    {
        self.minimumBTCAmountButton.title = @"Min";
        
        if (self.orderType == BitcoinDE_BuyOrderType) {
            if (self.orderBookData.orderRequirements_paymentOption.unsignedIntegerValue == BitcoinDE_PaymentOptionSEPAOnly
                || [self.orderBookData.orderInformation_minVolume isGreaterThanOrEqualTo:[SOXMarket_BitcoinDE_Core sharedCore].availableFidorAmount]) {
                
                self.maximalFidorBTCAmountButton.hidden = YES;
            }
            else {
                self.maximalFidorBTCAmountButton.hidden = NO;
                self.maximalFidorBTCAmountButton.title = @"Max Fidor";
            }
            
            if (self.orderBookData.orderRequirements_paymentOption.unsignedIntegerValue == BitcoinDE_PaymentOptionExpressOnly
                && [self.orderBookData.orderInformation_minVolume isGreaterThanOrEqualTo:[SOXMarket_BitcoinDE_Core sharedCore].availableFidorAmount]) {
                self.userInformationTextField.hidden        = NO;
                self.userInformationTextField.stringValue = @"Express only, but not enough Fidor reservation";
                self.minimumBTCAmountButton.hidden = YES;
                self.maximalFidorBTCAmountButton.hidden = YES;
                self.maximalOrderBTCAmountButton.hidden = YES;
                self.amountToTradeTextField.enabled = NO;
            }
            
            self.maximalOrderBTCAmountButton.title = @"Max from order";
        }
        else if (self.orderType == BitcoinDE_SellOrderType) {
            self.maximalFidorBTCAmountButton.hidden = YES;
            self.maximalOrderBTCAmountButton.title = @"Max possible";
        }
    }
    
    [self setupExecuteTradeButton];
    self.cancelButton.title = @"Cancel";
    
    self.minMaxPossibleAmountTextField.stringValue = [NSString stringWithFormat:@"(min: %@, max: %@)",
                                                      self.orderBookData.orderInformation_minAmount, self.maxPossibleBTCAmountToTrade];
}

- (void)setupExecuteTradeButton {
    if (self.orderType == BitcoinDE_BuyOrderType) {
        NSString *executeTradeButtonText;
        if (self.executePaymentOption != BitcoinDE_PaymentOptionSEPAOnly) {
            executeTradeButtonText = @"Buy via Express";
        }
        else {
            executeTradeButtonText = @"Buy via SEPA";
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
    self.amountToTradeDescriptionTextField.hidden   = !self.executeTradeIsPossible;
    self.amountToTradeTextField.hidden              = !self.executeTradeIsPossible;
    self.minMaxPossibleAmountTextField.hidden       = !self.executeTradeIsPossible;
    self.volumeToTradeDescriptionTextField.hidden   = !self.executeTradeIsPossible;
    self.volumeToTradeTextField.hidden              = !self.executeTradeIsPossible;
    self.executeTradeButton.hidden                  = !self.executeTradeIsPossible;
}

- (BOOL)validateInput {
    BOOL validationResult = NO;
    
    // Validate minAmount
    if ([self.amountToTrade isGreaterThanOrEqualTo:self.orderBookData.orderInformation_minAmount]) {
        validationResult = YES;
    }
    
    // Validate maxAmount and paymentOption
    if (validationResult) {
        // Express only
        if (self.defaultPaymentOption == BitcoinDE_PaymentOptionExpressOnly) {
            if ([self.amountToTrade isGreaterThan:self.maxPossibleBTCAmountToTrade]) {
                validationResult = NO;
            }
            else {
                self.executePaymentOption = BitcoinDE_PaymentOptionExpressOnly;
            }
        }
        
        // SEPA only
        if (self.orderBookPaymentOption == BitcoinDE_PaymentOptionSEPAOnly
            && self.defaultPaymentOption != BitcoinDE_PaymentOptionExpressOnly) {
            if ([self.amountToTrade isLessThanOrEqualTo:self.orderBookData.orderInformation_maxAmount]) {
                self.executePaymentOption = BitcoinDE_PaymentOptionSEPAOnly;
            }
            else {
                validationResult = NO;
            }
            
        }
        
        // Express or Sepa
        if (self.orderBookPaymentOption == BitcoinDE_PaymentOptionExpressAndSepa
            && self.defaultPaymentOption == BitcoinDE_PaymentOptionExpressAndSepa) {
            if ([self.amountToTrade isLessThanOrEqualTo:self.maxPossibleBTCAmountToTrade]) {
                self.executePaymentOption = BitcoinDE_PaymentOptionExpressOnly;
            }
            else if ([self.amountToTrade isLessThanOrEqualTo:self.orderBookData.orderInformation_maxAmount]){
                self.executePaymentOption = BitcoinDE_PaymentOptionSEPAOnly;
            }
            else {
                validationResult = NO;
            }
        }
    }

    if (validationResult) {
        NSDecimalNumber *volume = [self.amountToTrade decimalNumberByMultiplyingBy:self.orderBookData.orderInformation_price];
        self.volumeToTradeTextField.stringValue = [SOXFormatters currencyStringForNumber:volume
                                                                            roundingMode:NSNumberFormatterRoundUp];
        self.mayExecuteTrade = YES;
    }
    else {
        self.executePaymentOption = BitcoinDE_PaymentOptionUnknown;
        self.volumeToTradeTextField.stringValue = @"Non valid input";
        _amountToTrade = [NSDecimalNumber decimalNumberWithString:@"0"];
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
                                                respondTo:self];
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
                          if (returnCode == 1000) { // Execute trade
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

- (IBAction)minimumBTCAmountButtonAction:(NSButton *)sender {
    self.amountToTrade = self.orderBookData.orderInformation_minAmount;
}

- (IBAction)maximalFidorBTCAmountButtonAction:(NSButton *)sender {
    self.amountToTrade = self.maxPossibleBTCAmountToTrade;
}

- (IBAction)maximalOrderBTCAmountButtonAction:(NSButton *)sender {
    if (self.orderType == BitcoinDE_BuyOrderType) {
        self.amountToTrade = self.orderBookData.orderInformation_maxAmount;
    }
    else if (self.orderType == BitcoinDE_SellOrderType) {
        if ([[SOXMarket_BitcoinDE_Core sharedCore].availableBitcoinAmount isLessThan:self.orderBookData.orderInformation_maxAmount]) {
            self.amountToTrade = [SOXMarket_BitcoinDE_Core sharedCore].availableBitcoinAmount;
        }
        else {
            self.amountToTrade = self.orderBookData.orderInformation_maxAmount;
        }
    }
}


#pragma mark - Manual Setters
- (void)setAmountToTrade:(NSDecimalNumber *)amountToTrade {
    _amountToTrade = amountToTrade;
    [self validateInput];
}

- (void)setExecuteTradeIsPossible:(BOOL)executeTradeIsPossible {
    _executeTradeIsPossible = executeTradeIsPossible;
    [self toggleUIElements];
}

- (void)setExecutePaymentOption:(BitcoinDE_PaymentOption)executePaymentOption {
    _executePaymentOption = executePaymentOption;
   
    [self setupExecuteTradeButton];
}

#pragma mark - SOXMarketCoreServerRequestProtocol
- (void)answerOfServerRequest:(NSDictionary *)answerOfServerRequest {
    if (![answerOfServerRequest valueForKey:ServerAnswerErrorKey]) {
        // No error means success
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Okay"];
        [alert setMessageText:@"Success"];
        [alert setInformativeText:@"Trade executed."];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
    }
}

#pragma mark - NSControlTextEditingDelegate
- (void)controlTextDidChange:(NSNotification *)notification {
    NSTextField* valueField = notification.object;
    NSNumberFormatter* fieldFormatter = valueField.formatter;
    NSText* fieldEditor = valueField.currentEditor;
    
    id newValue = ( fieldEditor!=nil ? [fieldFormatter numberFromString:fieldEditor.string] : valueField.objectValue );
    NSLog(@"newValuenewValuenewValue: %@", newValue);
    _amountToTrade = newValue;
    
    
}

@end
