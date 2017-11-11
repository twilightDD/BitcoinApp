//
//  SOXMyOrderDetailsViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 28.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXMyOrderDetailsViewController.h"

#import "SOXMyOrderBook_BitcoinDE_Data.h"

#import "SOXFormatters.h"

#pragma mark - Interface
@interface SOXMyOrderDetailsViewController ()

#pragma mark IBOutlets
@property (weak) IBOutlet NSTextField *titleTextField;

@property (weak) IBOutlet NSTextField *orderIDDescriptionTextField;
@property (weak) IBOutlet NSTextField *typeDescriptionTextField;
@property (weak) IBOutlet NSTextField *maxAmountDescriptionTextField;
@property (weak) IBOutlet NSTextField *minAmountDescriptionTextField;
@property (weak) IBOutlet NSTextField *priceDescriptionTextField;
@property (weak) IBOutlet NSTextField *maxVolumeDescriptionTextField;
@property (weak) IBOutlet NSTextField *minVolumeDescriptionTextField;

@property (weak) IBOutlet NSTextField *createNewForRemainingDescriptionTextField;
@property (weak) IBOutlet NSTextField *stateDescriptionTextField;
@property (weak) IBOutlet NSTextField *minTrustLevelDescriptionTextField;
@property (weak) IBOutlet NSTextField *onlyKYCFullDescriptionTextField;
@property (weak) IBOutlet NSTextField *paymentOptionDescriptionTextField;
@property (weak) IBOutlet NSTextField *seatOfBankDescriptionTextField;

@property (weak) IBOutlet NSTextField *orderIDTextField;
@property (weak) IBOutlet NSTextField *typeTextField;
@property (weak) IBOutlet NSTextField *maxAmountTextField;
@property (weak) IBOutlet NSTextField *minAmountTextField;
@property (weak) IBOutlet NSTextField *priceTextField;
@property (weak) IBOutlet NSTextField *maxVolumeTextField;
@property (weak) IBOutlet NSTextField *minVolumeTextField;

@property (weak) IBOutlet NSTextField *createNewForRemainingTextField;
@property (weak) IBOutlet NSTextField *stateTextField;
@property (weak) IBOutlet NSTextField *minTrustLevelTextField;
@property (weak) IBOutlet NSTextField *onlyKYCFullTextField;
@property (weak) IBOutlet NSTextField *paymentOptionTextField;
@property (weak) IBOutlet NSTextField *seatOfBankDTextField;

@property (weak) IBOutlet NSTextField *createdAtDescriptionTextField;
@property (weak) IBOutlet NSTextField *endDateTimeDescriptionTextField;
@property (weak) IBOutlet NSTextField *createdAtTextField;
@property (weak) IBOutlet NSTextField *endDateTimeTextField;

@property (weak) IBOutlet NSButton *closeButton;

@end

#pragma mark - Implementation
@implementation SOXMyOrderDetailsViewController

#pragma mark Init&Co.
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear {
    [super viewWillAppear];
    
    [self setupUI];
}

#pragma mark - Private methods
- (void)setupUI {
    self.titleTextField.stringValue = @"Order details";
    
    {
        self.orderIDDescriptionTextField.stringValue = @"Order ID";
        self.typeDescriptionTextField.stringValue = @"Type";
        self.maxAmountDescriptionTextField.stringValue = @"Max. amount";
        self.minAmountDescriptionTextField.stringValue = @"Min. amoun";
        self.priceDescriptionTextField.stringValue = @"Price";
        self.maxVolumeDescriptionTextField.stringValue = @"Max. Volume";
        self.minVolumeDescriptionTextField.stringValue = @"Min. Volume";
        
        self.createNewForRemainingDescriptionTextField.stringValue = @"Create new for remaining";
        self.stateDescriptionTextField.stringValue = @"State";
        self.minTrustLevelDescriptionTextField.stringValue = @"Min. trust level";
        self.onlyKYCFullDescriptionTextField.stringValue = @"Only KYC Full";
        self.paymentOptionDescriptionTextField.stringValue = @"Payment option";
        self.seatOfBankDescriptionTextField.stringValue = @"Seat Of Bank";
        
        self.closeButton.stringValue = @"Close";
    }
    
    {
//        self.orderIDTextField.stringValue = self.myOrder.orderInformation_orderID;
        self.typeTextField.stringValue = self.myOrder.orderInformation_type;
        self.maxAmountTextField.doubleValue = self.myOrder.orderInformation_maxAmount.doubleValue;
        self.minAmountTextField.doubleValue = self.myOrder.orderInformation_minAmount.doubleValue;
        self.priceTextField.doubleValue = self.myOrder.orderInformation_price.doubleValue;
        self.maxVolumeTextField.doubleValue = self.myOrder.orderInformation_maxVolume.doubleValue;
        self.minVolumeTextField.doubleValue = self.myOrder.orderInformation_minVolume.doubleValue;
        
        self.createNewForRemainingTextField.stringValue = self.myOrder.orderInformation_newOrderForRemainingAmount ? @"Yes" : @"No";
        self.stateTextField.stringValue = self.myOrder.orderInformation_state.stringValue;
        NSString *minTrustLevel = self.myOrder.orderRequirements_minTrustLevel;
        if (!minTrustLevel) {
            minTrustLevel = @"-";
        }
        self.minTrustLevelTextField.stringValue = minTrustLevel;
        self.onlyKYCFullTextField.stringValue = self.myOrder.orderRequirements_onlyKYCFull ? @"Yes" : @"No";
        
        NSString *paymentOption = self.myOrder.orderRequirements_paymentOption;
        if (!paymentOption) {
            paymentOption = @"-";
        }
        self.paymentOptionTextField.stringValue = paymentOption;
        
        NSArray *seatsOfBank = self.myOrder.orderRequirements_seatOfBank;
        NSString *seatsOfBankString;
        if (!seatsOfBank) {
            seatsOfBankString = @"-";
        }
        else if ([seatsOfBank containsObject:@"DE"] ) {
            seatsOfBankString = [NSString stringWithFormat:@"DE + %tu andere", seatsOfBank.count - 1];
        }
        else {
            seatsOfBankString = [NSString stringWithFormat:@"Kein DE + %tu andere", seatsOfBank.count -1];
        }
        self.seatOfBankDTextField.stringValue = seatsOfBankString;
    }
    
    {
        self.createdAtDescriptionTextField.stringValue = @"Created At";
        self.endDateTimeDescriptionTextField.stringValue = @"End Date";
        
        NSString *createdAt = self.myOrder.orderInformation_createdAt;
        self.createdAtTextField.stringValue = createdAt ? createdAt : @"-";
        NSString *endDateTime = self.myOrder.orderInformation_endDateTime;
        self.endDateTimeTextField.stringValue = endDateTime ? endDateTime : @"-";
    }
}

- (IBAction)closeButtonAction:(id)sender {
    [self dismissController:self];
}

@end
