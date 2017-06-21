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

@property (strong, nonatomic) NSDecimalNumber *minAmountOrder;
@property (strong, nonatomic) NSDecimalNumber *maxAmountOrder;
@property (strong, nonatomic) NSDecimalNumber *maxPossibleBTCAmountToTrade;
@property (strong, nonatomic) NSDecimalNumber *amountToTrade;
@property (nonatomic) BitcoinDE_PaymentOption defaultPaymentOption;
@property (nonatomic) BitcoinDE_PaymentOption orderBookPaymentOption;
@property (nonatomic) BitcoinDE_PaymentOption executePaymentOption;

@property (strong, nonatomic) NSDecimalNumber *availableFidorAmount;
@property (strong, nonatomic) NSDecimalNumber *availableBitcoinAmount;

@property (strong, nonatomic) NSString *userInformationText;
@end

#pragma mark - Implementation
@implementation SOXExecuteTradeViewController
#pragma mark Init&Co.
- (void)viewWillAppear {
    [super viewWillAppear];
    
    self.mayExecuteTrade        = NO;
    self.defaultPaymentOption   = [SOXPreferenceCenter defaultPaymentOptionForExecuteTrade];
    self.orderBookPaymentOption = self.orderBookData.orderRequirements_paymentOption.unsignedIntegerValue;
    self.availableBitcoinAmount = [SOXMarket_BitcoinDE_Core sharedCore].availableBitcoinAmount;
    self.availableFidorAmount   = [SOXMarket_BitcoinDE_Core sharedCore].availableFidorAmount;
    // TODO: Debug availFidorAmount = 500
    //self.availableFidorAmount   = [NSDecimalNumber decimalNumberWithString:@"500"];

    [self setupTradeValues];
    [self setupUI];
    [self toggleUIElements];
}

#pragma mark - Private methods
- (void)setupTradeValues {
    if (!self.orderBookData) {
        return;
    }

    // check paymentOptions
    switch (self.orderBookPaymentOption) {
        case BitcoinDE_PaymentOptionExpressOnly:
            if (self.defaultPaymentOption == BitcoinDE_PaymentOptionExpressOnly
                || self.defaultPaymentOption == BitcoinDE_PaymentOptionExpressAndSepa) {
                self.executeTradeIsPossible = YES;
            }
            break;
        case BitcoinDE_PaymentOptionSEPAOnly:
            if (self.defaultPaymentOption == BitcoinDE_PaymentOptionSEPAOnly
                || self.defaultPaymentOption == BitcoinDE_PaymentOptionExpressAndSepa) {
                self.executeTradeIsPossible = YES;
            }
            break;
        case BitcoinDE_PaymentOptionExpressAndSepa:
            self.executeTradeIsPossible = YES;
            break;
        default:
            break;
    }
    if (!self.executeTradeIsPossible) {
        self.minAmountOrder = nil;
        self.maxAmountOrder = nil;
        self.maxPossibleBTCAmountToTrade = nil;
        return;
    }

    // MinAmount and MaxAmount
    self.minAmountOrder = self.orderBookData.orderInformation_minAmount;
    self.maxAmountOrder = self.orderBookData.orderInformation_maxAmount;

    // maxPossibleBTCAmountToTrade
    {
        {


            if (self.orderType == BitcoinDE_BuyOrderType) {
                /*
                 Express => maxAvaFidor
                 Sepa => default(SEPA mgl) ? order.maxAmount : geht nicht
                 Express/Sepa => default(SEPA mgl) ? order.maxAmount : maxAvaFidor
                 */
                // calculate, how much BTC we could buy with availableFidorAmount
                self.maxPossibleBTCAmountToTrade = [self.availableFidorAmount decimalNumberByDividingBy:self.orderBookData.orderInformation_price
                                                                                           withBehavior:[SOXFormatters btcNumberHandler]];

                if (self.orderBookPaymentOption == BitcoinDE_PaymentOptionExpressOnly) {
                    self.executePaymentOption = BitcoinDE_PaymentOptionExpressOnly;
                    self.userInformationText = @"Express only";
                    self.executeTradeIsPossible = YES;
                    if ([self.maxPossibleBTCAmountToTrade isLessThanOrEqualTo:self.maxAmountOrder]) {
                        self.maxAmountOrder = nil;
                    }
                    else {
                        self.maxPossibleBTCAmountToTrade = nil;
                    }
                }
                else if (self.orderBookPaymentOption == BitcoinDE_PaymentOptionSEPAOnly) {
                    self.executePaymentOption = BitcoinDE_PaymentOptionSEPAOnly;
                    if (self.defaultPaymentOption == BitcoinDE_PaymentOptionSEPAOnly
                        || self.defaultPaymentOption == BitcoinDE_PaymentOptionExpressAndSepa) {
                        self.userInformationText = @"SEPA only";
                        self.maxPossibleBTCAmountToTrade = nil;
                        self.executeTradeIsPossible = YES;
                    }
                    else {
                        self.userInformationText = @"SEPA not possible";
                        self.executePaymentOption = BitcoinDE_PaymentOptionUnknown;
                        self.executeTradeIsPossible = NO;
                    }
                }
                else if (self.orderBookPaymentOption == BitcoinDE_PaymentOptionExpressAndSepa) {
                    if ([self.maxPossibleBTCAmountToTrade isGreaterThanOrEqualTo:self.minAmountOrder]
                        && [self.maxAmountOrder isLessThanOrEqualTo:self.maxPossibleBTCAmountToTrade]) {
                        self.userInformationText = @"Express&SEPA - only Express";
                        self.executePaymentOption = BitcoinDE_PaymentOptionExpressOnly;
                        self.maxAmountOrder = nil;
                        self.executeTradeIsPossible = YES;
                    }
                    else if ([self.maxPossibleBTCAmountToTrade isGreaterThanOrEqualTo:self.minAmountOrder]) {
                        self.userInformationText = @"Express&SEPA";
                        self.executePaymentOption = BitcoinDE_PaymentOptionExpressAndSepa;
                        self.executeTradeIsPossible = YES;
                    }
                    else if ([self.maxPossibleBTCAmountToTrade isLessThan:self.minAmountOrder]) {
                        self.userInformationText = [NSString stringWithFormat:@"Express&SEPA - only SEPA - you don't have enough fidor reservation (%@)"
                                                    , [SOXFormatters currencyStringForNumber:self.availableFidorAmount
                                                                                roundingMode:NSNumberFormatterRoundDown]];
                        self.maxPossibleBTCAmountToTrade = nil;
                        self.executePaymentOption = BitcoinDE_PaymentOptionSEPAOnly;
                        self.executeTradeIsPossible = YES;
                    }
                    else {
                        self.userInformationText = @"Stranged";
                        self.executeTradeIsPossible = NO;
                    }

                }
                else {
                    self.userInformationText = @"VERY Stranged";
                    self.executeTradeIsPossible = NO;
                }
            }
            else if (self.orderType == BitcoinDE_SellOrderType) {
                /*
                 Express => maxAvaBTC
                 Sepa => default(SEPA mgl) ? order.maxAmount : geht nicht
                 Express/Sepa => default(SEPA mgl) ? order.maxAmount : maxAvaBTC
                 */

                self.maxPossibleBTCAmountToTrade = [SOXFormatters lesserDecimalNumberFrom:self.orderBookData.orderInformation_maxAmount
                                                                                 and:self.availableBitcoinAmount];

                if ([self.minAmountOrder isGreaterThan:self.maxPossibleBTCAmountToTrade]) {
                    self.userInformationText = [NSString stringWithFormat:@"Not enough bitcoins (%@)"
                                                , [SOXFormatters stringForBTCNumber:self.availableBitcoinAmount]];
                    self.executeTradeIsPossible = NO;
                }
                else if ([self.maxPossibleBTCAmountToTrade isLessThan:self.maxAmountOrder]) {
                    self.maxAmountOrder = nil;
                    self.userInformationText = [NSString stringWithFormat:@"You may sell all my bitcoins (%@)"
                                                , [SOXFormatters stringForBTCNumber:self.availableBitcoinAmount]];
                    self.executeTradeIsPossible = YES;
                }
                else {
                    self.maxPossibleBTCAmountToTrade = nil;
                    self.userInformationText = [NSString stringWithFormat:@"You may satisfy complete order (%@)"
                                                , [SOXFormatters stringForBTCNumber:self.maxAmountOrder]];
                    self.executeTradeIsPossible = YES;
                }

                if (self.orderBookPaymentOption == BitcoinDE_PaymentOptionExpressAndSepa
                    || self.orderBookPaymentOption == BitcoinDE_PaymentOptionExpressOnly) {
                    self.executePaymentOption = BitcoinDE_PaymentOptionExpressOnly;
                }
                else {
                    self.executePaymentOption = BitcoinDE_PaymentOptionSEPAOnly;
                }
            }
        }
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
    NSString *minimumBTCAmountButtonText;
    NSString *maximalFidorBTCAmountButtonText;
    NSString *maximalOrderBTCAmountButtonText;
    if (self.orderType == BitcoinDE_BuyOrderType) {
        titleText = @"Buy bitcoins";
        amountToTradeDescriptionText = @"Buy bitcoins";
        minimumBTCAmountButtonText = @"Min BTC";
        maximalFidorBTCAmountButtonText = @"Max BTC for reservation";
        maximalOrderBTCAmountButtonText = @"Max BTC from order";
    }
    else if (self.orderType == BitcoinDE_SellOrderType) {
        titleText = @"Sell bitcoins";
        amountToTradeDescriptionText = @"Sell bitcoins";
        minimumBTCAmountButtonText = @"Min BTC";
        maximalFidorBTCAmountButtonText = @"Max available BTC ";
        maximalOrderBTCAmountButtonText = @"Max BTC from order";
    }
    else {
        return;
    }

    self.titleTextField.stringValue = titleText;
    self.amountToTradeDescriptionTextField.stringValue = amountToTradeDescriptionText;
    self.minimumBTCAmountButton.title = minimumBTCAmountButtonText;
    self.maximalFidorBTCAmountButton.title = maximalFidorBTCAmountButtonText;
    self.maximalOrderBTCAmountButton.title = maximalOrderBTCAmountButtonText;


    self.volumeToTradeDescriptionTextField.stringValue = @"Volume";
    self.volumeToTradeTextField.stringValue            = [SOXFormatters currencyStringForNumber:[NSDecimalNumber decimalNumberWithString:@"0"]
                                                                                   roundingMode:NSNumberFormatterRoundUp];
    
    {// userInformationTextField not used at the moment
        self.userInformationTextField.hidden        = YES;
        self.userInformationTextField.stringValue   = @"";
    }

    [self setupExecuteTradeButton];
    self.cancelButton.title = @"Cancel";
    
    self.minMaxPossibleAmountTextField.stringValue = [NSString stringWithFormat:@"(min: %@, max: %@)",
                                                      [SOXFormatters stringForBTCNumber:self.orderBookData.orderInformation_minAmount],
                                                      [SOXFormatters stringForBTCNumber:self.maxPossibleBTCAmountToTrade]];
}

- (void)setupExecuteTradeButton {
    NSString *executeTradeButtonText;
    if (self.orderType == BitcoinDE_BuyOrderType) {
        if (self.executePaymentOption != BitcoinDE_PaymentOptionSEPAOnly) {
            executeTradeButtonText = @"Buy via Express";
        }
        else {
            executeTradeButtonText = @"Buy via SEPA";
        }
    }
    else if (self.orderType == BitcoinDE_SellOrderType) {
        if (self.executePaymentOption != BitcoinDE_PaymentOptionSEPAOnly) {
            executeTradeButtonText = @"Sell via Express";
        }
        else {
            executeTradeButtonText = @"Sell via SEPA";
        }
    }
    else {
        self.executeTradeButton.title = @"No orderType";
    }
    self.executeTradeButton.title = executeTradeButtonText;
}

- (void)toggleUIElements {
    self.amountToTradeDescriptionTextField.hidden   = !self.executeTradeIsPossible;
    self.amountToTradeTextField.hidden              = !self.executeTradeIsPossible;
    self.minMaxPossibleAmountTextField.hidden       = !self.executeTradeIsPossible;
    self.volumeToTradeDescriptionTextField.hidden   = !self.executeTradeIsPossible;
    self.volumeToTradeTextField.hidden              = !self.executeTradeIsPossible;
    self.executeTradeButton.hidden                  = !self.executeTradeIsPossible;


    self.minimumBTCAmountButton.hidden = self.minAmountOrder == nil;
    self.maximalOrderBTCAmountButton.hidden = self.maxAmountOrder == nil;
    self.maximalFidorBTCAmountButton.hidden = self.maxPossibleBTCAmountToTrade == nil;

    if (self.userInformationText) {
        self.userInformationTextField.stringValue = self.userInformationText;
        self.userInformationTextField.hidden = NO;
    }
    else {
        self.userInformationTextField.hidden = YES;
    }
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
            if ((self.maxPossibleBTCAmountToTrade && [self.amountToTrade isGreaterThan:self.maxPossibleBTCAmountToTrade])
                || (self.maxAmountOrder && [self.amountToTrade isGreaterThan:self.maxAmountOrder])) {
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
            if (self.maxPossibleBTCAmountToTrade && [self.amountToTrade isLessThanOrEqualTo:self.maxPossibleBTCAmountToTrade]) {
                self.executePaymentOption = BitcoinDE_PaymentOptionExpressOnly;
            }
            else if (self.maxAmountOrder && [self.amountToTrade isLessThanOrEqualTo:self.maxAmountOrder]){
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
        NSDecimalNumber *volume           = [self.amountToTrade decimalNumberByMultiplyingBy:self.orderBookData.orderInformation_price];
        NSString *informativeText         = [NSString stringWithFormat:@"You will %@ %@ bitcoins,\nworth %@ of real money.",
                                             [SOXMarket_BitcoinDE_DefTypes orderTypeStringForOrderType:self.orderType]
                                             , [SOXFormatters stringForBTCNumber:self.amountToTrade]
                                             , [SOXFormatters currencyStringForNumber:volume roundingMode:NSNumberFormatterRoundUp]
                                             ];
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
    self.amountToTrade = self.minAmountOrder;
}

- (IBAction)maximalFidorBTCAmountButtonAction:(NSButton *)sender {
    self.amountToTrade = self.maxPossibleBTCAmountToTrade;
}

- (IBAction)maximalOrderBTCAmountButtonAction:(NSButton *)sender {
    self.amountToTrade = self.maxAmountOrder;
    return;
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
- (void)setMaxAmountOrder:(NSDecimalNumber *)maxAmountOrder {
    _maxAmountOrder = maxAmountOrder;

}
- (void)setAmountToTrade:(NSDecimalNumber *)amountToTrade {
    _amountToTrade = amountToTrade;
    self.amountToTradeTextField.objectValue = _amountToTrade;
    [self validateInput];
}

- (void)setExecuteTradeIsPossible:(BOOL)executeTradeIsPossible {
    _executeTradeIsPossible = executeTradeIsPossible;
    if (!executeTradeIsPossible) {
        self.minAmountOrder = nil;
        self.maxAmountOrder = nil;
        self.maxPossibleBTCAmountToTrade = nil;
    }
}

- (void)setExecutePaymentOption:(BitcoinDE_PaymentOption)executePaymentOption {
    _executePaymentOption = executePaymentOption;
   
    [self setupExecuteTradeButton];
}

#pragma mark - SOXMarketCoreServerRequestProtocol
- (void)answerOfServerRequest:(NSDictionary *)answerOfServerRequest {
    if (![answerOfServerRequest valueForKey:ServerAnswerErrorKey]) {
        [[SOXMarket_BitcoinDE_Core sharedCore] startRequests];
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
- (BOOL)control:(NSControl *)control isValidObject:(id)obj {
    NSLog(@"isValidObject %@", obj);
    return YES;
}

- (void)controlTextDidChange:(NSNotification *)notification {
    NSTextField* valueField = notification.object;
    NSNumberFormatter* fieldFormatter = valueField.formatter;
    NSText* fieldEditor = valueField.currentEditor;
    
    id newValue = ( fieldEditor!=nil ? [fieldFormatter numberFromString:fieldEditor.string] : valueField.objectValue );
    NSLog(@"newValuenewValuenewValue: %@", newValue);
    _amountToTrade = newValue;
}

@end
