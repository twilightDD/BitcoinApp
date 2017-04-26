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
@property (nonatomic) BitcoinDE_MinimalTrustLevel trustLevel;
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
    
    self.trustLevel = [SOXPreferenceCenter defaultMinTrustLevel];
    [self setupUI];
}

#pragma mark - Public methods

#pragma mark - Private methods
- (void)setupUI {
    
    if (self.orderType == BitcoinDE_BuyOrderType) {
        self.titleTextField.stringValue                 = @"Create new buy order";
        self.amountDescriptionTextField.stringValue     = @"Amount to buy";
    }
    else if (self.orderType == BitcoinDE_SellOrderType) {
        self.titleTextField.stringValue                 = @"Create new sell order";
        self.amountDescriptionTextField.stringValue     = @"Amount to sell";
    }
    else {
        self.titleTextField.stringValue                 = @"ERROR - no type given!";
    }
    
    
    self.amountTextField.doubleValue                = 0;
    self.avaibleAmountTetField.stringValue          = [NSString stringWithFormat:@"Avaible: %@", [SOXMarket_BitcoinDE_Core sharedCore].availableBitcoinAmount];
    
    self.minAmountDescriptionTextField.stringValue  = @"Minimal amount";
    self.minAmountTextField.stringValue             = @"";
    self.minAmountHintTextField.stringValue         = @"";
    
    self.priceDescriptionTextField.stringValue      = @"Price per BTC";
    self.priceTextField.stringValue                 = @"";
    self.volumeTextField.stringValue                = @"";
    
    self.optionBox.title = @"Options";
    self.onlyKYCButton.title = @"Trade with KYC only";
    self.reNewOrderButton.title = @"New Order for residue";
    
    self.bronceTrustLevelButton.title = @"Bronce";
    self.silverTrustLevelButton.title = @"Silver";
    self.goldTrustLevelButton.title = @"Gold & Platin";
    self.goldTrustLevelButton.state = 1;
    
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

- (BOOL)validateInput {
    if (self.amountTextField.stringValue.length == 0) {
        return  NO;
    }
    if (self.minAmountTextField.stringValue.length == 0) {
        return  NO;
    }
    if (self.priceTextField.stringValue.length == 0) {
        return  NO;
    }
    
    NSDate *endDate = self.endDatePicker.dateValue;
    if ([endDate isLessThanOrEqualTo:[NSDate date]]) {
        return NO;
    }
    return YES;
}


#pragma mark - Action methods
- (IBAction)createOrderAction:(NSButton *)sender {
    // gather information and create data object and send data object to Bitcoin core
    
    // Input validation
    BOOL validInput = [self validateInput];
    
    if (validInput) {
        NSDictionary *parameters = [SOXMyOrderBook_BitcoinDE_Data parameterForNewOrderWithOrderType:self.orderType
                                                                                         max_amount:@(self.amountTextField.doubleValue)
                                                                                              price:@(self.priceTextField.doubleValue)
                                                                                         min_amount:@(self.minAmountTextField.doubleValue)
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
}

- (IBAction)cancelAction:(NSButton *)sender {
    [self dismissViewController:self];
}

- (IBAction)trustLevelAction:(NSButton *)sender {
}

#pragma mark - SOXMarketCoreServerRequestProtocol
-(void)answerOfServerRequest:(NSDictionary *)answerOfServerRequest {
    if ([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_CreateOrderType)]) {
        NSDictionary *payloadDictionary = [answerOfServerRequest objectForKey:ServerAnswerPayloadKey];
        NSString *newOrderID = [payloadDictionary objectForKey:BitcoinDE_ShowOrderbook_OrderID];
        
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Succsess";
        alert.informativeText = [NSString stringWithFormat:@"Order created with orderID %@", newOrderID];
        alert.alertStyle = NSAlertStyleInformational;
        [alert runModal];
        [self dismissViewController:self];
    }
}


@end
