//
//  SOXCreateNewOrderViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 10.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXCreateNewOrderViewController.h"

#import "SOXMarket_BitcoinDE_Core.h"
#import "SOXMyOrderBook_BitcoinDE_Data.h"

#import "SOXPreferenceCenter.h"

#import "SOXKeys_BitcoinDE.h"

#import "SOXFormatters.h"

#import "NSAttributedString+URL.h"
#import "NSTextField+URL.h"

#pragma mark - Interface
@interface SOXCreateNewOrderViewController () <SOXMarketCoreServerRequestProtocol>

#pragma mark IBOutlets

@property (weak) IBOutlet NSTextField *titleTextField;

#pragma mark | Input fields
@property (weak) IBOutlet NSTextField *amountDescriptionTextField;
@property (weak) IBOutlet NSTextField *amountTextField;
@property (strong) IBOutlet NSButton *maxAmountButton;

@property (weak) IBOutlet NSTextField *minAmountDescriptionTextField;
@property (weak) IBOutlet NSTextField *minAmountTextField;

@property (weak) IBOutlet NSTextField *priceDescriptionTextField;
@property (weak) IBOutlet NSTextField *priceTextField;
@property (weak) IBOutlet NSTextField *priceLimitInformationTextField;

#pragma mark | Box
@property (weak) IBOutlet NSBox *optionBox;
@property (weak) IBOutlet NSButton *onlyKYCButton;
@property (weak) IBOutlet NSButton *reNewOrderButton;
@property (weak) IBOutlet NSTextField *trustLevelDescpriptionTextField;
@property (weak) IBOutlet NSButton *bronceTrustLevelButton;
@property (weak) IBOutlet NSButton *silverTrustLevelButton;
@property (weak) IBOutlet NSButton *goldTrustLevelButton;

@property (weak) IBOutlet NSTextField *endDateDescriptionTextField;
@property (weak) IBOutlet NSDatePicker *endDatePicker;

@property (weak) IBOutlet NSTextField *paymentOptionHintTextField;

#pragma mark | Base line
@property (weak) IBOutlet NSButton *cancelButton;
@property (weak) IBOutlet NSTextField *volumeInformationLine;
@property (weak) IBOutlet NSButton *createOrderButton;


#pragma mark Properties
@property (nonatomic) BitcoinDE_TrustLevel trustLevel;

@property (nonatomic) NSDecimalNumber *amount;
@property (nonatomic) NSDecimalNumber *minAmount;
@property (nonatomic) NSDecimalNumber *price;
@property (nonatomic) NSDecimalNumber *minimalPossibleAmount;
@property (nonatomic) NSDecimalNumber *priceLimit;

@property (nonatomic, getter = isInputValid) BOOL validInput;

@end

#pragma mark - Implementation
@implementation SOXCreateNewOrderViewController

#pragma mark Init&Co.
-(void)viewWillAppear {
    [super viewWillAppear];

    // better save than sorry
    if (self.orderType != BitcoinDE_BuyOrderType
        && self.orderType != BitcoinDE_SellOrderType) {
        return;
    }

    [self setupValues];
    [self setupUI];
    [self validateInputs];
}

#pragma mark - Setup methods
#pragma mark | Values
- (void)setupValues {
    [self setupAmountValue];
    [self setupMinAmountValue];
    [self setupPriceLimitValue];
    [self setupPriceValue];
    [self setupTrustLevelValue];
}

- (void)setupAmountValue {
    self.amount = self.orderBookDataToReplace ?
    [NSDecimalNumber decimalNumberWithDecimal:self.orderBookDataToReplace.orderInformation_maxAmount.decimalValue] :
    [NSDecimalNumber decimalNumberWithString:@"0.05"];
}

- (void)setupMinAmountValue {
    self.minAmount = self.orderBookDataToReplace ?
    [NSDecimalNumber decimalNumberWithDecimal:self.orderBookDataToReplace.orderInformation_minAmount.decimalValue] :
    [NSDecimalNumber decimalNumberWithString:@"0.05"];
    self.minimalPossibleAmount = [NSDecimalNumber decimalNumberWithString:@"0.00001"];
}


- (void)setupPriceLimitValue {
    switch (self.orderType) {
        case BitcoinDE_BuyOrderType:
            self.priceLimit = [SOXMarket_BitcoinDE_Core rateWeightedHalfForCurrencyType:self.currencyType];
            break;
        case BitcoinDE_SellOrderType:
            self.priceLimit = [SOXMarket_BitcoinDE_Core rateWeightedDoubleForCurrencyType:self.currencyType];
            break;
        default:
            break;
    }
}

- (void)setupPriceValue {
    if (!self.orderBookDataToReplace) {
        /* Bedingungen:
         #1 Please correct the purchase price per bitcoin.
         The price shall not be less than 50% of the current market rate.
         #2 The value of the amount of bitcoin may not be lower than than €60.00
         */
        if (self.orderType == BitcoinDE_BuyOrderType){
            self.price = [SOXMarket_BitcoinDE_Core rateWeightedHalfForCurrencyType:self.currencyType];
        }
        else if (self.orderType == BitcoinDE_SellOrderType) {
            self.price = [SOXMarket_BitcoinDE_Core rateWeightedForCurrencyType:self.currencyType];
        }
    }
    else {
        self.price = [NSDecimalNumber decimalNumberWithDecimal:self.orderBookDataToReplace.orderInformation_price.decimalValue];
    }
}

- (void)setupTrustLevelValue {
    self.trustLevel = self.orderBookDataToReplace ?
    [SOXMarket_BitcoinDE_DefTypes trustLevelForTrustLevelString:self.orderBookDataToReplace.orderRequirements_minTrustLevel] :
    [SOXPreferenceCenter defaultTrustLevelNewOrder];
}

#pragma mark | UI
- (void)setupUI {
    [self setupUITexts];
    [self setupUIBox];
}

- (void)setupUITexts {
    NSString *titleTextFieldText = @"Error";
    NSString *amountDescriptionTextFieldText = @"Error";
    NSString *createOrderButtonText = @"Error";
    NSString *maxAmountButtonTitle = @"Error";
    BOOL maxAmountButtonHidden = NO;
    NSString *cancelButtonText = @"Cancel";

    NSString *shortCurrencyString = [SOXMarket_BitcoinDE_DefTypes tradingPairShortStringUpperCaseForCurrencyType:self.currencyType];
    if (self.orderType == BitcoinDE_BuyOrderType) {
        amountDescriptionTextFieldText = @"Amount to buy";
        maxAmountButtonHidden = YES;
        if (self.orderBookDataToReplace == nil) {
            titleTextFieldText = @"Create new buy order";
            createOrderButtonText = @"Create new buy order";
        }
        else {
            titleTextFieldText = @"Change buy order";
            createOrderButtonText = @"Change buy order";
        }
    }
    else if (self.orderType == BitcoinDE_SellOrderType) {
        amountDescriptionTextFieldText = @"Amount to sell";
        maxAmountButtonTitle = [NSString stringWithFormat:@"Max %@"
                                , shortCurrencyString];
        if (self.orderBookDataToReplace == nil) {
            titleTextFieldText = @"Create new sell order";
            createOrderButtonText = @"Create new sell order";
        }
        else {
            titleTextFieldText = @"Change sell order";
            createOrderButtonText = @"Change sell order";
        }
    }

    self.titleTextField.stringValue                 = titleTextFieldText;
    self.amountDescriptionTextField.stringValue     = amountDescriptionTextFieldText;
    self.maxAmountButton.title = maxAmountButtonTitle;
    self.maxAmountButton.hidden = maxAmountButtonHidden;

    self.minAmountDescriptionTextField.stringValue  = @"Minimal amount";
    self.priceDescriptionTextField.stringValue      = @"Price per BTC";

    self.createOrderButton.title = createOrderButtonText;
    self.cancelButton.title = cancelButtonText;

    // priceLimitInformationTextField
    {
        NSString *volumeTextFieldText = @"Error";
        switch (self.orderType) {
            case BitcoinDE_BuyOrderType:
                volumeTextFieldText = [NSString stringWithFormat:@"Min. price: %@\n(50%% weighted rate)"
                                       , [SOXFormatters currencyStringForNumber:self.priceLimit
                                                                   roundingMode:NSNumberFormatterRoundUp]];
                break;
            case BitcoinDE_SellOrderType:
                volumeTextFieldText = [NSString stringWithFormat:@"Max. price: %@\n(200%% weighted rate)"
                                       , [SOXFormatters currencyStringForNumber:self.priceLimit
                                                                   roundingMode:NSNumberFormatterRoundDown]];
                break;
            default:
                break;
        }
        self.priceLimitInformationTextField.stringValue = volumeTextFieldText;
    }
}

- (void)setupUIBox {
    // Strings
    self.optionBox.title                            = @"Options";

    [self setupUIBoxCheckboxes];
    [self setupUIBoxDatePicker];
    [self setupUIBoxPaymentOptionHint];
}

- (void)setupUIBoxCheckboxes {
    { // OnlyKYC
        self.onlyKYCButton.title = @"Allow only fully identified Users";
        self.onlyKYCButton.state = self.orderBookDataToReplace ?
        self.orderBookDataToReplace.orderRequirements_onlyKYCFull :
        [SOXPreferenceCenter defaultKYCOnly];
    }

    { // ReNew
        self.reNewOrderButton.title = @"Automatic residual purchase request";
        self.reNewOrderButton.state = self.orderBookDataToReplace ?
        self.orderBookDataToReplace.orderInformation_newOrderForRemainingAmount :
        [SOXPreferenceCenter new_order_for_remaining_amount];
    }

    { // TrustLevel
        self.trustLevelDescpriptionTextField.stringValue = @"Minimal Trust Level";
        self.bronceTrustLevelButton.title               = [SOXMarket_BitcoinDE_DefTypes trustLevelStringForTrustLevel:BitcoinDE_TrustLevelBronze];
        self.bronceTrustLevelButton.tag                 = BitcoinDE_TrustLevelBronze;

        self.silverTrustLevelButton.title               = [SOXMarket_BitcoinDE_DefTypes trustLevelStringForTrustLevel:BitcoinDE_TrustLevelSilver];
        self.silverTrustLevelButton.tag                 = BitcoinDE_TrustLevelSilver;

        self.goldTrustLevelButton.title                 = [SOXMarket_BitcoinDE_DefTypes trustLevelStringForTrustLevel:BitcoinDE_TrustLevelGold];
        self.goldTrustLevelButton.tag                   = BitcoinDE_TrustLevelGold;

        if (self.bronceTrustLevelButton.tag == self.trustLevel) {
            self.bronceTrustLevelButton.state = 1;
        }
        else if (self.silverTrustLevelButton.tag == self.trustLevel) {
            self.silverTrustLevelButton.state = 1;
        }
        else if (self.goldTrustLevelButton.tag == self.trustLevel) {
            self.goldTrustLevelButton.state = 1;
        }
    }
}

- (void)setupUIBoxDatePicker {
    self.endDateDescriptionTextField.stringValue = @"Order should end";

    NSDate *endDate = nil;
    if (self.orderBookDataToReplace) {
        endDate = self.orderBookDataToReplace.orderInformation_endDateTime;
    }
    else {
        NSDate *dateIn5Days = [NSDate dateWithTimeIntervalSinceNow:5 * 24 * 60 * 60];
        endDate = [SOXFormatters dateQuarterBeforeMidnightForDate:dateIn5Days];
    }
    self.endDatePicker.dateValue = endDate;
}

- (void)setupUIBoxPaymentOptionHint {
    // Hint on buy: paymentOption depend on default via preferences on webside
    if (self.orderType == BitcoinDE_BuyOrderType) {
        self.paymentOptionHintTextField.allowsEditingTextAttributes = YES;
        self.paymentOptionHintTextField.selectable = YES;
        [self.paymentOptionHintTextField setHyperlinkFormattingFromString:@"Express Trade Settings"
                                                            withURLString:@"https://www.bitcoin.de/de/express-trade/settings"];
    }
    else if (self.orderType == BitcoinDE_SellOrderType) {
        self.paymentOptionHintTextField.stringValue = @"Sell orders are alway Express Orders";
    }
}


#pragma mark - Private methods
- (void)validateInputs {
    if ([[self volumeNonNil] isLessThan:[SOXPreferenceCenter minimalVolume]]
        || [[self minVolumeNonNil] isLessThan:[SOXPreferenceCenter minimalVolume]]) {
        self.validInput = NO;
        return;
    }
    
    if ([self.amount isLessThan:self.minimalPossibleAmount]) {
        self.validInput = NO;
        return;
    }
    if ([self.amount isLessThan:self.minAmount]) {
        self.validInput = NO;
        return;
    }

    if (!self.price
        || [self.price isLessThan:[NSDecimalNumber zero]]
        || (self.orderType == BitcoinDE_BuyOrderType && [self.price isLessThan:self.priceLimit])
        || (self.orderType == BitcoinDE_SellOrderType && [self.price isGreaterThan:self.priceLimit])
        ) {
        self.validInput = NO;
        return;
    }

    NSDate *endDate = self.endDatePicker.dateValue;
    if ([endDate isLessThanOrEqualTo:[NSDate date]]) {
        self.validInput = NO;
        return;
    }

    self.validInput = YES;
}

- (void)updateVolumeInformationLine {
    NSDecimalNumber *priceAsDecimalNumber = [self priceNonNil];
    NSDecimalNumber *volume = [self volumeNonNil];
    NSDecimalNumber *minVolume = [self minVolumeNonNil];

    BOOL priceIsZero = [priceAsDecimalNumber isEqualToNumber:[NSDecimalNumber zero]];
    BOOL priceToLess = [priceAsDecimalNumber isLessThan:self.priceLimit];
    BOOL priceToHigh = [priceAsDecimalNumber isGreaterThan:self.priceLimit];
    BOOL minAmountToLess = [minVolume isLessThan:[SOXPreferenceCenter minimalVolume]];
    BOOL amountToLess = [volume isLessThan:[SOXPreferenceCenter minimalVolume]];

    NSString *volumeInformation;
    if (priceIsZero) {
        volumeInformation = @"Confucius says:\nNo Price - No Profit";
    }
    else if (self.orderType == BitcoinDE_BuyOrderType
             && priceToLess) {
        volumeInformation = [NSString stringWithFormat:@"Price beneath minimal price (%@)"
                             , [SOXFormatters currencyStringForNumber:self.priceLimit
                                                         roundingMode:NSNumberFormatterRoundHalfUp]];
    }
    else if (self.orderType == BitcoinDE_SellOrderType
             && priceToHigh) {
        volumeInformation = [NSString stringWithFormat:@"Price above maximal price (%@)"
                             , [SOXFormatters currencyStringForNumber:self.priceLimit
                                                         roundingMode:NSNumberFormatterRoundHalfUp]];
    }
    else if (amountToLess) {
        NSDecimalNumber *amountNeeded = [[SOXPreferenceCenter minimalVolume] decimalNumberByDividingBy:priceAsDecimalNumber
                                                                                          withBehavior:[SOXFormatters btcNumberHandler]];
        volumeInformation = [NSString stringWithFormat:@"Amount to less (min: %@)\nVolume must be grater than %@"
                             , [SOXFormatters stringForBTCNumber:amountNeeded]
                             , [SOXFormatters currencyStringForNumber:[SOXPreferenceCenter minimalVolume]
                                                         roundingMode:NSNumberFormatterRoundHalfUp]];
    }
    else if (minAmountToLess) {
        NSDecimalNumber *minAmountNeeded = [[SOXPreferenceCenter minimalVolume] decimalNumberByDividingBy:priceAsDecimalNumber
                                                                                             withBehavior:[SOXFormatters btcNumberHandler]];
        volumeInformation = [NSString stringWithFormat:@"Minimum amount to less (min: %@)\nVolume must be grater than %@"
                             , [SOXFormatters stringForBTCNumber:minAmountNeeded]
                             , [SOXFormatters currencyStringForNumber:[SOXPreferenceCenter minimalVolume]
                                                         roundingMode:NSNumberFormatterRoundHalfUp]];
    }
    else {
        volumeInformation = [NSString stringWithFormat:@"%@ %@ %@ for %@ equals %@"
                             , [SOXMarket_BitcoinDE_DefTypes orderTypeStringForOrderType:self.orderType]
                             , [SOXFormatters stringForBTCNumber:self.amount]
                             , [SOXMarket_BitcoinDE_DefTypes tradingPairShortStringUpperCaseForCurrencyType:self.currencyType]
                             , [SOXFormatters currencyStringForNumber:priceAsDecimalNumber roundingMode:NSNumberFormatterRoundHalfUp]
                             , [SOXFormatters currencyStringForNumber:volume roundingMode:NSNumberFormatterRoundHalfUp]];
    }

    self.volumeInformationLine.stringValue = volumeInformation;
}

- (void)removeOldOrder {
    NSDictionary *myOrderBookParameter = [SOXMyOrderBook_BitcoinDE_Data parameterForDeletingOrderWithOrderBookData:self.orderBookDataToReplace];
    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_RemoveOrderType
                                            withParameter:myOrderBookParameter
                                                respondTo:self];
}

- (void)createNewOrder {
    NSDictionary *parameters = [SOXMyOrderBook_BitcoinDE_Data parameterForNewOrderWithOrderType:self.orderType
                                                                                   currencyType:self.currencyType
                                                                                     max_amount:@(self.amountTextField.doubleValue)
                                                                                     min_amount:@(self.minAmountTextField.doubleValue)
                                                                                          price:@(self.priceTextField.doubleValue)
                                                                                   end_datetime:self.endDatePicker.dateValue
                                                                 new_order_for_remaining_amount:self.reNewOrderButton.state
                                                                                min_trust_level:self.trustLevel
                                                                                  only_kyc_full:self.reNewOrderButton.state
                                                                                 payment_option:[SOXPreferenceCenter defaultPaymentOptionForCreateOrder]
                                                                                   seat_of_bank:[SOXPreferenceCenter defaultCountryCodes]];

    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_CreateOrderType
                                            withParameter:parameters
                                                respondTo:self];
}

#pragma mark - Special getter methods (nonnull)
- (NSDecimalNumber *)priceNonNil {
    NSDecimalNumber *priceNonNil = [NSDecimalNumber decimalNumberWithDecimal:self.price.decimalValue] ? : [NSDecimalNumber zero];
    return priceNonNil;
}

- (NSDecimalNumber *)volumeNonNil {
    NSDecimalNumber *amount = self.amount ? : [NSDecimalNumber zero];
    NSDecimalNumber *volume = [[self priceNonNil] decimalNumberByMultiplyingBy:amount
                                                                  withBehavior:[SOXFormatters currencyNumberHandler]];
    return volume;
}

- (NSDecimalNumber *)minVolumeNonNil {
    NSDecimalNumber *minAmount = self.minAmount ? : [NSDecimalNumber zero];
    NSDecimalNumber *minVolume = [[self priceNonNil] decimalNumberByMultiplyingBy:minAmount
                                                                     withBehavior:[SOXFormatters currencyNumberHandler]];
    return minVolume;
}

#pragma mark - Manual setters
- (void)setValidInput:(BOOL)validInput {
    _validInput = validInput;
    [self updateVolumeInformationLine];
}

#pragma mark - Action methods
- (IBAction)maxAmountButtonAction:(NSButton *)sender {
    /* set new amount to:
     - create: availAmount
     - change: availAmount +self.orderBookDataToReplace.amount
     */
    NSDecimalNumber *newAmount = [[SOXMarket_BitcoinDE_Core availableAmountForCurrencyType:self.currencyType] copy];
    if (self.orderBookDataToReplace) {
        NSDecimalNumber *maxAmountOfOrderToReplace = [NSDecimalNumber decimalNumberWithDecimal:[self.orderBookDataToReplace.orderInformation_maxAmount decimalValue]];
        newAmount = [newAmount decimalNumberByAdding:maxAmountOfOrderToReplace];
    }
    self.amount = newAmount;
    [self validateInputs];
}

- (IBAction)createOrderAction:(NSButton *)sender {
    if (self.isInputValid) {
        // create strings
        NSString *createOrderButtonTitle = self.createOrderButton.title;
        NSString *cancelButtonTitle       = @"Cancel";
        NSString *messageText             = @"Warning";
        NSString *informativeText = @"ERROR";
        if (self.orderBookDataToReplace) {
            informativeText = @"Do you really want to change the order?";
        }
        else {
            informativeText = @"Do you really want to create a new order?";
        }
        // create alert
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:createOrderButtonTitle];
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
                              if (self.orderBookDataToReplace) {
                                  [self removeOldOrder];
                              }
                              else {
                                  [self createNewOrder];
                              }
                          }
                      }];
    }
    else {
        // inform user
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Non valid input";
        alert.informativeText = [NSString stringWithFormat:@"Some information are missing"];
        alert.alertStyle = NSAlertStyleInformational;
        [alert runModal];
    }
}

- (IBAction)cancelAction:(NSButton *)sender {
    [self dismissViewController:self];
}

- (IBAction)trustLevelAction:(NSButton *)sender {
    self.trustLevel = sender.tag;
}

#pragma mark - SOXMarketCoreServerRequestProtocol
-(void)answerOfServerRequest:(NSDictionary *)answerOfServerRequest {
    // on Error: do nothing (error message will be displayed by bitcoinCore)
    if ([answerOfServerRequest objectForKey:ServerAnswerErrorKey]) {
        self.orderBookDataToReplace = nil; // in case our order was sold/bought
        return;
    }
    
    if ([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_CreateOrderType)]) {
        NSDictionary *payloadDictionary = [answerOfServerRequest objectForKey:ServerAnswerPayloadKey];
        NSString *newOrderID = [payloadDictionary objectForKey:BitcoinDE_ShowOrderbook_OrderID];
        
         // inform user
        {
            NSString *messageText,*informativeText;
            NSAlertStyle alertStyle;
            if (newOrderID) {
                messageText     = @"Successfully created";
                informativeText = [NSString stringWithFormat:@"Order created with orderID %@", newOrderID];
                alertStyle      = NSAlertStyleInformational;
            }
            else {
                messageText     = @"No order created";
                informativeText = @"There is no orderID";
                alertStyle      = NSAlertStyleWarning;
            }

            if (self.delegate) {
                [self.delegate orderWasChanged:nil newOrderID:newOrderID];
            }

            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText     = messageText;
            alert.informativeText = informativeText;
            alert.alertStyle      = alertStyle;
            [alert runModal];

            [self dismissViewController:self];
        }
    }
    else if ([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_RemoveOrderType)]) {
        self.orderBookDataToReplace = nil;
        [self createNewOrder];
    }
}

#pragma mark - NSControlTextEditingDelegate
- (void)controlTextDidChange:(NSNotification *)notification {
    NSTextField* textField           = notification.object;
    NSNumberFormatter* textFieldFormatter = textField.formatter;
    NSText* textFieldEditor               = textField.currentEditor;
    
    id newValue = ( textFieldEditor != nil ? [textFieldFormatter numberFromString:textFieldEditor.string] : textField.objectValue );

    if (textField == self.amountTextField) {
        _amount = newValue;
    }
    else if (textField == self.minAmountTextField) {
        _minAmount = newValue;
    }
    else if (textField == self.priceTextField) {
        _price = newValue;
    }

    [self validateInputs];
}

@end
