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

#pragma mark - Interface
@interface SOXCreateNewOrderViewController () <SOXMarketCoreServerRequestProtocol>

#pragma mark IBOutlets

@property (weak) IBOutlet NSTextField *titleTextField;

@property (weak) IBOutlet NSTextField *amountDescriptionTextField;
@property (weak) IBOutlet NSTextField *amountTextField;
@property (weak) IBOutlet NSTextField *availableAmountTextField;

@property (weak) IBOutlet NSTextField *minAmountDescriptionTextField;
@property (weak) IBOutlet NSTextField *minAmountTextField;
@property (weak) IBOutlet NSTextField *minAmountHintTextField;

@property (weak) IBOutlet NSTextField *priceDescriptionTextField;
@property (weak) IBOutlet NSTextField *priceTextField;
@property (weak) IBOutlet NSTextField *volumeTextField;


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

@property (weak) IBOutlet NSButton *cancelButton;
@property (weak) IBOutlet NSButton *createOrderButton;


#pragma mark Properties
@property (nonatomic) BitcoinDE_TrustLevel trustLevel;

@property (nonatomic) NSDecimalNumber *amount;
@property (nonatomic) NSDecimalNumber *minAmount;
@property (nonatomic) NSDecimalNumber *price;
@property (nonatomic) NSDecimalNumber *minimalPossibleAmount;
@property (nonatomic) NSDecimalNumber *minimalPossiblePrice;

@property (nonatomic, getter = isInputValid) BOOL validInput;

@end

#pragma mark - Implementation
@implementation SOXCreateNewOrderViewController

#pragma mark Init&Co.
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

-(void)viewWillAppear {
    [super viewWillAppear];
    if (self.orderType != BitcoinDE_BuyOrderType
        && self.orderType != BitcoinDE_SellOrderType) {
        return;
    }

    [self setupUI];
    self.validInput = NO;

    // checkboxes in NSBox
    {
        self.trustLevel = self.orderBookDataToReplace ?
        [SOXMarket_BitcoinDE_DefTypes trustLevelForTrustLevelString:self.orderBookDataToReplace.orderRequirements_minTrustLevel] :
        [SOXPreferenceCenter defaultTrustLevelNewOrder];

        self.onlyKYCButton.state = self.orderBookDataToReplace ?
        self.orderBookDataToReplace.orderRequirements_onlyKYCFull :
        [SOXPreferenceCenter defaultKYCOnly];
        self.reNewOrderButton.state = self.orderBookDataToReplace ?
        self.orderBookDataToReplace.orderInformation_newOrderForRemainingAmount :
        [SOXPreferenceCenter new_order_for_remaining_amount];
    }
    // Default values (for bindings)
    {
        self.amount = self.orderBookDataToReplace ?
            [NSDecimalNumber decimalNumberWithDecimal:self.orderBookDataToReplace.orderInformation_maxAmount.decimalValue] :
            [NSDecimalNumber decimalNumberWithString:@"0.05"];
        self.minAmount = self.orderBookDataToReplace ?
            [NSDecimalNumber decimalNumberWithDecimal:self.orderBookDataToReplace.orderInformation_minAmount.decimalValue] :
            [NSDecimalNumber decimalNumberWithString:@"0.05"];
        self.minimalPossibleAmount = [NSDecimalNumber decimalNumberWithString:@"0.00001"];
        
        self.minimalPossiblePrice = [SOXMarket_BitcoinDE_Core rateWeightedHalfForCurrencyType:self.currencyType];
        // condition #1
        {
            // setting numberFormatter minimum value
            NSNumberFormatter *priceFormatter = self.priceTextField.formatter;
            // Stupid hack, but needed: subtract 0.001!
            priceFormatter.minimum            = [self.minimalPossiblePrice decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithString:@"0.001"]];
        
            // inform user
            self.volumeTextField.stringValue = [NSString stringWithFormat:@"Min. price: %@\n(50%% weighted rate)",
                                                [SOXFormatters currencyStringForNumber:self.minimalPossiblePrice
                                                                          roundingMode:NSNumberFormatterRoundUp]];
        }

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

    [self validateInputs];
}

#pragma mark - Public methods

#pragma mark - Private methods
- (void)setupTexts {
    NSString *titleTextFieldText = @"Error";
    NSString *amountDescriptionTextFieldText = @"Error";
    NSString *availableAmountTextFieldText = @"Error";
    BOOL availableAmountTextFieldHiddenStatus = NO;
    NSString *createOrderButtonText = @"Error";

    NSString *cancelButtonText = @"Cancel";

    if (self.orderType == BitcoinDE_BuyOrderType) {
        availableAmountTextFieldHiddenStatus = YES;
        amountDescriptionTextFieldText = @"Amount to buy";

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
        titleTextFieldText = @"Create new sell order";
        amountDescriptionTextFieldText = @"Amount to sell";
        availableAmountTextFieldText = [NSString stringWithFormat:@"Available: %@"
                                        , [SOXMarket_BitcoinDE_Core availableAmountForCurrencyType:self.currencyType]];
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
    self.availableAmountTextField.stringValue       = availableAmountTextFieldText;
    self.availableAmountTextField.hidden            = availableAmountTextFieldHiddenStatus;
    self.cancelButton.title = cancelButtonText;
    self.createOrderButton.title = createOrderButtonText;
}

- (void)setupUI {
    [self setupTexts];

    // ------------------
    
    self.minAmountDescriptionTextField.stringValue  = @"Minimal amount";
    self.minAmountHintTextField.stringValue         = @"";
    
    self.priceDescriptionTextField.stringValue      = @"Price per BTC";
    self.volumeTextField.stringValue                = @"";
    
    self.optionBox.title                            = @"Options";
    self.onlyKYCButton.title                        = @"Allow only fully identified Users";
    self.reNewOrderButton.title                     = @"Automatic residual purchase request";
    
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

    // ------------------
    NSDate *endDate = nil;
    if (self.orderBookDataToReplace) {
        endDate = self.orderBookDataToReplace.orderInformation_endDateTime;
    }
    else {
        self.endDateDescriptionTextField.stringValue = @"Order should end";
        NSDate *dateIn5Days = [NSDate dateWithTimeIntervalSinceNow:5 * 24 * 60 * 60];
        endDate = [SOXFormatters dateQuarterBeforeMidnightForDate:dateIn5Days];
    }
    self.endDatePicker.dateValue = endDate;

    // ------------------
    // Hint on buy: paymentOption depend on default via preferences on webside
    if (self.orderType == BitcoinDE_BuyOrderType) {
        self.paymentOptionHintTextField.stringValue = @"For type = \"buy\", it depends on you settings in \"Express Trade Settings\"";
    }
    else if (self.orderType == BitcoinDE_SellOrderType) {
        self.paymentOptionHintTextField.hidden = YES;
    }

}

- (void)validateInputs {
    if (!self.minAmount && self.amount) {
        self.minAmount = [self.amount decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"2"]];
    }
    else if (!self.minAmount && !self.amount) {
        self.minAmount = [NSDecimalNumber decimalNumberWithString:@"0"];
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
        || [self.price isLessThan:self.minimalPossiblePrice]) {
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

    DDLogInfo(@"Parameters:\n%@", parameters);

    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_CreateOrderType
                                            withParameter:parameters
                                                respondTo:self];
}

#pragma mark - Action methods
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
    DDLogInfo(@"selected Trust Level: %tu", self.trustLevel);
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
    DDLogInfo(@"NewValue: %@ (class: %@)", newValue, [newValue class]);

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
