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

#import "SOXKeys_BitcoinDE.h"

NSString const * _Nonnull ExecuteTradeViewControllerIdentifierKey = @"ExecuteTradeViewControllerIdentifier";

#pragma mark - Interface
@interface SOXExecuteTradeViewController () <NSControlTextEditingDelegate>

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
@property (weak) IBOutlet NSTextField *volumeToTradeDescriptionTextField;
@property (weak) IBOutlet NSTextField *volumeToTradeTextField;
// Buttons
@property (weak) IBOutlet NSButton *executeTradeButton;
@property (weak) IBOutlet NSButton *cancelButton;

#pragma mark Properties
@property (nonatomic) BOOL mayExecuteTrade;
@end

#pragma mark - Implementation
@implementation SOXExecuteTradeViewController
#pragma mark Init&Co.
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)viewWillAppear {
    [super viewWillAppear];
    
    self.mayExecuteTrade = NO;
    
    [self setupUI];
}

#pragma mark - Private methods
- (void)setupUI {
    // Descriptions
    self.tradingPartnerInformationDescriptionTextField.stringValue = @"Trading partner";
    self.priceDescriptionTextField.stringValue      = @"Price per BTC";
    self.minBTCDescriptionTextField.stringValue     = @"Minimum BTC";
    self.maxBTCDescriptionTextField.stringValue     = @"Maximum BTC";
    self.minVolumeDescriptionTextField.stringValue  = @"Minimum Volume";
    self.maxVolumeDescriptionTextField.stringValue  = @"Maximum Volume";
    self.orderIDTextDescriptionField.stringValue    = @"Order ID";
    self.userNameDescriptionTextField.stringValue   = @"User name";
    self.isKYCDescriptionTextField.stringValue      = @"User is known";
    self.trustLevelDescriptionTextField.stringValue = @"Trust level";
    self.tradesDescriptionTextField.stringValue     = @"Trades";
    self.ratingDescriptionTextField.stringValue     = @"Positiv ratings [%]";
    
    NSString *titleText;
    NSString *amountToTradeDescriptionText;
    NSString *executeTradeButtonText;
    if ([self.orderBookData.orderInformation_type isEqualToString:@"buy"]
        || [self.orderBookData.orderInformation_type isEqualToString:@"order"]) {
        titleText = @"Sell bitcoins";
        amountToTradeDescriptionText = @"Sell bitcoins";
        executeTradeButtonText = @"Execute sell";
    }
    else if ([self.orderBookData.orderInformation_type isEqualToString:@"sell"]
             || [self.orderBookData.orderInformation_type isEqualToString:@"offer"]) {
        titleText = @"Buy bitcoins";
        amountToTradeDescriptionText = @"Buy bitcoins";
        executeTradeButtonText = @"Execute buy";
    }
    self.titleTextField.stringValue = titleText;
    
    self.amountToTradeDescriptionTextField.stringValue = amountToTradeDescriptionText;
    self.volumeToTradeDescriptionTextField.stringValue = @"Volume";
    
    self.executeTradeButton.title = executeTradeButtonText;
    self.cancelButton.title = @"Cancel";
    

    self.priceTextField.doubleValue     = self.orderBookData.orderInformation_price.doubleValue ? : -1;
    self.minBTCTextField.doubleValue    = self.orderBookData.orderInformation_minAmount.doubleValue ? : -1;
    self.maxBTCTextField.doubleValue    = self.orderBookData.orderInformation_maxAmount.doubleValue ? : -1;
    self.minVolumeTextField.doubleValue = self.orderBookData.orderInformation_minVolume.doubleValue ? : -1;
    self.maxVolumeTextField.doubleValue = self.orderBookData.orderInformation_maxVolume.doubleValue ? : -1;
    self.orderIDTextField.stringValue   = self.orderBookData.orderInformation_orderID ? : @" - ";
    
    // Trading partner information
    self.userNameTextField.stringValue      = self.orderBookData.tradingPartnerInformation_username ? : @" ? ";
    self.isKYCTextField.stringValue         = self.orderBookData.tradingPartnerInformation_isKYCFull ? @"Yes" : @"NO";
    self.trustLevelTextField.stringValue    = self.orderBookData.tradingPartnerInformation_trustLevel ? : @" ? ";
    self.tradesTextField.stringValue        = self.orderBookData.tradingPartnerInformation_amountTrades.stringValue ? : @" ? ";
    self.ratingTextField.stringValue        = self.orderBookData.tradingPartnerInformation_rating.stringValue ? : @" ? ";
}

- (void)updateVolumeTextFieldWithInput:(double)inputValue {
    double volume = inputValue * self.orderBookData.orderInformation_price.doubleValue;
    self.volumeToTradeTextField.doubleValue = volume;
}

#pragma mark - Action methods
- (IBAction)executeTradeAction:(NSButton *)sender {
}

- (IBAction)cancelAction:(NSButton *)sender {
    [self dismissViewController:self];
}

#pragma mark - NSControlTextEditingDelegate
- (void)controlTextDidChange:(NSNotification *)notification {
    NSTextField* valueField = notification.object;
    NSNumberFormatter* fieldFormatter = valueField.formatter;
    NSText* fieldEditor = valueField.currentEditor;
    
    id newValue = ( fieldEditor!=nil ? [fieldFormatter numberFromString:fieldEditor.string] : valueField.objectValue );
    
    
    NSLog(@"objectValue: %@ (class: %@)", newValue, [newValue class]);
    
    NSNumber *value = newValue;
    [self updateVolumeTextFieldWithInput:value.doubleValue];
    
//    if (notification.object == self.amountToTradeTextField) {
//        double inputValue = self.amountToTradeTextField.doubleValue;
//        if (inputValue < self.orderBookData.orderInformation_maxAmount.doubleValue) {
//            self.mayExecuteTrade = YES;
//        }
//        else {
//            self.mayExecuteTrade = NO;
//        }
//        [self updateVolumeTextFieldWithInput:inputValue];
//    }
}

- (BOOL)control:(NSControl *)control isValidObject:(id)obj {
    return YES;
}

@end
