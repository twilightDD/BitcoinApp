//
//  SOXBanner_BitcoinDE_Data.m
//  BitcoinApp
//
//  Created by Peter Hauke on 14.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXAccountInfo_BitcoinDE_Data.h"

#import "SOXKeys_BitcoinDE.h"

#pragma mark - Interface
@interface SOXAccountInfo_BitcoinDE_Data ()

#pragma mark Properties

@property (strong, nonatomic, readwrite) NSDecimalNumber *btcBalance_totalAmount;
@property (strong, nonatomic, readwrite) NSDecimalNumber *btcBalance_availableAmount;
@property (strong, nonatomic, readwrite) NSDecimalNumber *btcBalance_reservedAmount;

@property (nonatomic, readwrite) BOOL bankReservation_exists;
@property (strong, nonatomic, readwrite) NSDecimalNumber *bankReservation_totalAmount;
@property (strong, nonatomic, readwrite) NSDecimalNumber *bankReservation_availableAmount;
@property (strong, nonatomic, readwrite) NSString *bankReservation_reservedAt;
@property (strong, nonatomic, readwrite) NSString *bankReservation_validUntil;

@property (strong, nonatomic, readwrite) NSString *bankInformation_bicShort;
@property (strong, nonatomic, readwrite) NSString *bankInformation_bicFull;
@property (strong, nonatomic, readwrite) NSString *bankInformation_UID;

@end

#pragma mark - Implementation
@implementation SOXAccountInfo_BitcoinDE_Data

#pragma mark Synthesize
@synthesize btcBalance_totalAmount, btcBalance_availableAmount, btcBalance_reservedAmount;
@synthesize bankReservation_exists, bankReservation_totalAmount, bankReservation_availableAmount, bankReservation_reservedAt, bankReservation_validUntil;
@synthesize bankInformation_bicShort, bankInformation_bicFull, bankInformation_UID;

#pragma mark - Init & Co.
+ (instancetype)accountInfoDataForAccountInfoDictionary:(NSDictionary *)accountInfoDictionary {
    SOXAccountInfo_BitcoinDE_Data *bannerData = [[SOXAccountInfo_BitcoinDE_Data alloc] init];

    [bannerData setupDataForAccountInfoDictionary:accountInfoDictionary];
    
    return bannerData;
}

#pragma mark - Instance methods
- (void)setupDataForAccountInfoDictionary:(NSDictionary *)accountInfoDictionary {
    NSDictionary *dataDict = [accountInfoDictionary objectForKey:BitcoinDE_ShowAccountInfo_MainKey];

    // BTC information
    {
        NSDictionary *btc_balance = [dataDict objectForKey:BitcoinDE_ShowAccountInfoBTCBalance_btc_balance];
        self.btcBalance_totalAmount = [NSDecimalNumber decimalNumberWithString:[btc_balance objectForKey:BitcoinDE_ShowAccountInfoBTCBalance_total_amount]];
        self.btcBalance_availableAmount = [NSDecimalNumber decimalNumberWithString:[btc_balance objectForKey:BitcoinDE_ShowAccountInfoBTCBalance_available_amount]];
        self.btcBalance_reservedAmount = [NSDecimalNumber decimalNumberWithString:[btc_balance objectForKey:BitcoinDE_ShowAccountInfoBTCBalance_reserved_amount]];
    }
    // Fidor information
    {
        NSDictionary *fidor_reservation = [dataDict objectForKey:BitcoinDE_ShowAccountInfoFidorReservation_fidor_reservation];
        if (fidor_reservation) {
            self.bankReservation_exists = YES;
            self.bankReservation_totalAmount = [NSDecimalNumber decimalNumberWithDecimal:[[fidor_reservation objectForKey:BitcoinDE_ShowAccountInfoFidorReservation_total_amount] decimalValue ]];
            self.bankReservation_availableAmount = [NSDecimalNumber decimalNumberWithDecimal:[[fidor_reservation objectForKey:BitcoinDE_ShowAccountInfoFidorReservation_available_amount] decimalValue]];
            self.bankReservation_reservedAt = [fidor_reservation objectForKey:BitcoinDE_ShowAccountInfoFidorReservation_reserved_at];
            self.bankReservation_validUntil = [fidor_reservation objectForKey:BitcoinDE_ShowAccountInfoFidorReservation_valid_until];
        }
        else {
            self.bankReservation_exists = NO;
        }
    }
    
    // Encrypted information
    {
        NSDictionary *encrypted_Information = [dataDict objectForKey:BitcoinDE_ShowAccountInfoEncryptedInformation_encrypted_information];
        self.bankInformation_bicShort = [encrypted_Information objectForKey:BitcoinDE_ShowAccountInfoEncryptedInformation_bic_short];
        self.bankInformation_bicFull = [encrypted_Information objectForKey:BitcoinDE_ShowAccountInfoEncryptedInformation_bic_full];
        self.bankInformation_UID = [encrypted_Information objectForKey:BitcoinDE_ShowAccountInfoEncryptedInformation_uid];
    }
}


@end
