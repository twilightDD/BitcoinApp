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
@property (weak) IBOutlet NSTextField *avaibleAmountTetField;

@property (weak) IBOutlet NSTextField *minAmountDescriptionTextField;
@property (weak) IBOutlet NSTextField *minAmountTextField;
@property (weak) IBOutlet NSTextField *minAmountHintTextField;

@property (weak) IBOutlet NSTextField *priceDescriptionTextField;
@property (weak) IBOutlet NSTextField *priceTextField;
@property (weak) IBOutlet NSTextField *volumeTextField;


@property (weak) IBOutlet NSBox *optionBox;
@property (weak) IBOutlet NSButton *onlyKYCButton;
@property (weak) IBOutlet NSButton *reNewOrderButton;
@property (weak) IBOutlet NSButton *bronceTrustLevelButton;
@property (weak) IBOutlet NSButton *silverTrustLevelButton;
@property (weak) IBOutlet NSButton *goldTrustLevelButton;

@property (weak) IBOutlet NSTextField *endDateDescriptionTextField;
@property (weak) IBOutlet NSDatePicker *endDatePicker;

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
    
    self.trustLevel = [SOXPreferenceCenter defaultTrustLevelNewOrder];
    self.validInput = NO;
    [self setupUI];
    
    // Default values (for bindings)
    {
        self.amount = @0.05;
        self.minAmount = @0.05;
        self.minimalPossibleAmount = @0.05;
        
        /* Bedingungen:
         #1 Please correct the purchase price per bitcoin.
            The price shall not be less than 50% of the current market rate.
         #2 The value of the amount of bitcoin may not be lower than than €60.00
         */
        if (self.orderType == BitcoinDE_BuyOrderType
            || self.orderType == BitcoinDE_SellOrderType) {
            
            self.price                = [[SOXMarket_BitcoinDE_Core sharedCore] rate_weighted_half];
            self.minimalPossiblePrice = [[SOXMarket_BitcoinDE_Core sharedCore] rate_weighted_half];

            // setting numberFormatter minimum value
            NSNumberFormatter *priceFormatter = self.priceTextField.formatter;
            // Stipid hack, but needed: subtract 0.001!
            priceFormatter.minimum            = [self.minimalPossiblePrice decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithString:@"0.001"]];
            
            // inform user
            self.volumeTextField.stringValue = [NSString stringWithFormat:@"Min. price: %@\n(50%% weighted rate)",self.minimalPossiblePrice];
        }
        else {
            self.price = @0;
        }
        [self validateInputs];
    }
}

#pragma mark - Public methods

#pragma mark - Private methods
- (void)setupUI {
    
    if (self.orderType == BitcoinDE_BuyOrderType) {
        self.titleTextField.stringValue                 = @"Create new buy order";
        self.amountDescriptionTextField.stringValue     = @"Amount to buy";
        self.avaibleAmountTetField.hidden               = YES;
    }
    else if (self.orderType == BitcoinDE_SellOrderType) {
        self.titleTextField.stringValue                 = @"Create new sell order";
        self.amountDescriptionTextField.stringValue     = @"Amount to sell";
        // input textFields uses bindings
        self.avaibleAmountTetField.stringValue          = [NSString stringWithFormat:@"Avaible: %@", [SOXMarket_BitcoinDE_Core sharedCore].availableBitcoinAmount];
    }
    else {
        self.titleTextField.stringValue                 = @"ERROR - no type given!";
    }
    
    
    
    self.minAmountDescriptionTextField.stringValue  = @"Minimal amount";
    self.minAmountHintTextField.stringValue         = @"";
    
    self.priceDescriptionTextField.stringValue      = @"Price per BTC";
    self.volumeTextField.stringValue                = @"";
    
    self.optionBox.title                            = @"Options";
    self.onlyKYCButton.title                        = @"Trade with KYC only";
    self.reNewOrderButton.title                     = @"New Order for residue";
    
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
    
    
    self.endDateDescriptionTextField.stringValue = @"Order should end";
    self.endDatePicker.dateValue = [NSDate dateWithTimeIntervalSinceNow:5 * 24 * 60 * 60];
   
    self.cancelButton.title = @"Cancel";
    if (self.orderType == BitcoinDE_BuyOrderType) {
        self.createOrderButton.title = @"Create new buy order";
    }
    else if (self.orderType == BitcoinDE_SellOrderType) {
        self.createOrderButton.title = @"Create new sell order";
    }
    else {
        self.createOrderButton.title = @"ERROR";
        self.createOrderButton.enabled = NO;
    }
}

- (void)validateInputs {
    if (!self.minAmount && self.amount) {
        self.minAmount = [SOXFormatters divideNumber:self.amount by:2] ;
    }
    else if (!self.minAmount && !self.amount) {
        self.minAmount = @0;
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


#pragma mark - Action methods
- (IBAction)createOrderAction:(NSButton *)sender {
    if (self.isInputValid) {
        NSDictionary *parameters = [SOXMyOrderBook_BitcoinDE_Data parameterForNewOrderWithOrderType:self.orderType
                                                                                         max_amount:@(self.amountTextField.doubleValue)
                                                                                         min_amount:@(self.minAmountTextField.doubleValue)
                                                                                              price:@(self.priceTextField.doubleValue)
                                                                                       end_datetime:self.endDatePicker.dateValue
                                                                     new_order_for_remaining_amount:self.reNewOrderButton.state
                                                                                    min_trust_level:self.trustLevel
                                                                                      only_kyc_full:self.reNewOrderButton.state
                                                                                     payment_option:[SOXPreferenceCenter defaultPaymentOptionForCreateOrder]
                                                                                       seat_of_bank:[SOXPreferenceCenter defaultTradingCountries]];
        
        NSLog(@"Parameters:\n%@", parameters);
        
        [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_CreateOrderType
                                                withParameter:parameters
                                                    respondTo:self];
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
    NSLog(@"selected Trust Level: %tu", self.trustLevel);
}

#pragma mark - SOXMarketCoreServerRequestProtocol
-(void)answerOfServerRequest:(NSDictionary *)answerOfServerRequest {
    // on Error: do nothing (error message will be displayed by bitcoinCore)
    if ([answerOfServerRequest objectForKey:ServerAnswerErrorKey]) {
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
                messageText     = @"Success";
                informativeText = [NSString stringWithFormat:@"Order created with orderID %@", newOrderID];
                alertStyle      = NSAlertStyleInformational;
            }
            else {
                messageText     = @"No order created";
                informativeText = @"There is no orderID";
                alertStyle      = NSAlertStyleWarning;
            }
            
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText     = messageText;
            alert.informativeText = informativeText;
            alert.alertStyle      = alertStyle;
            [alert runModal];
            [self dismissViewController:self];
        }
    }
}

#pragma mark - NSControlTextEditingDelegate
- (void)controlTextDidChange:(NSNotification *)notification {
    NSTextField* textField           = notification.object;
    NSNumberFormatter* textFieldFormatter = textField.formatter;
    NSText* textFieldEditor               = textField.currentEditor;
    
    id newValue = ( textFieldEditor != nil ? [textFieldFormatter numberFromString:textFieldEditor.string] : textField.objectValue );
    NSLog(@"NewValue: %@ (class: %@)", newValue, [newValue class]);

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
