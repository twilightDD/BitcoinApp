//
//  SOXBanner_BitcoinDE_Data.m
//  BitcoinApp
//
//  Created by Peter Hauke on 14.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXAccountInfo_BitcoinDE_Data.h"

#import "SOXKeys_BitcoinDE.h"

NSString *const BannerDataKey = @"BannerData";

NSString *const BitcoinDEBannerDataDictionary = @"BitcoinDE_BannerData";
// BitcoinDE_ShowAccountInfo
// BTC-Balance
NSString *const BitcoinDE_BTCBalanceKey = @"btc_balance"; // Infos zur BTC-Balance
NSString *const BitcoinDE_BTCTotalAmountKey = @"total_amount"; // Aktuelles BTC-Guthaben
NSString *const BitcoinDE_BTCAvailAmountKey = @"available_amount"; // Aktuell verfügbares BTC-Guthaben
NSString *const BitcoinDE_BTCReservedAmountKey = @"reserved_amount"; // Aktuell reserviertes BTC-Guthaben

// Fidor-Reservation
NSString *const BitcoinDE_bankReservationKey = @"fidor_reservation"; // Infos zur ggfs. vorhandenen Fidor-Reservierung
NSString *const BitcoinDE_FidorTotalAmountKey = @"total_amount"; // Gesambetrag der Reservierung
NSString *const BitcoinDE_FidorAvailAmountKey = @"available_amount"; // Aktuell verfügbarer Betrag der Reservierung
NSString *const BitcoinDE_FidorReservedAtKey = @"reserved_at"; // Erstelldatum der Reservierung (Format: 2015-04-07T12:23:04+02:00 nach RFC 3339)
NSString *const BitcoinDE_FidorValidUntilKey = @"valid_until"; // Reservierung gültig bis (Format: 2015-04-07T12:23:04+02:00 gemäß RFC 3339)

//Encrypted-Information
NSString *const BitcoinDE_BankInformationKey = @"encrypted_information"; // verschlüsselte Infos
NSString *const BitcoinDE_BankBICshortKey = @"bic_short"; // Verschlüsselte Bankengruppe aus der BIC (ersten 4 Zeichen)
NSString *const BitcoinDE_BankBICfullKey = @"bic_full"; // Verschlüsselte komplette BIC
NSString *const BitcoinDE_BankUserUIDKey = @"uid"; // Verschlüsselte eigene User-Id

#pragma mark - Interface
@interface SOXAccountInfo_BitcoinDE_Data ()

#pragma mark Properties

@property (strong, nonatomic, readwrite) NSString *btcBalance_totalAmount;
@property (strong, nonatomic, readwrite) NSString *btcBalance_availableAmount;
@property (strong, nonatomic, readwrite) NSString *btcBalance_reservedAmount;

@property (nonatomic, readwrite) BOOL bankReservation_exists;
@property (strong, nonatomic, readwrite) NSString *bankReservation_totalAmount;
@property (strong, nonatomic, readwrite) NSString *bankReservation_availableAmount;
@property (strong, nonatomic, readwrite) NSString *bankReservation_reservedAt;
@property (strong, nonatomic, readwrite) NSString *bankReservation_validUntil;

@property (strong, nonatomic, readwrite) NSString *bankInformation_bicShort;
@property (strong, nonatomic, readwrite) NSString *bankInformation_bicFull;
@property (strong, nonatomic, readwrite) NSString *bankInformation_UID;

@end

#pragma mark - Implementation
@implementation SOXAccountInfo_BitcoinDE_Data

@dynamic btcBalance_totalAmount, btcBalance_availableAmount, btcBalance_reservedAmount;
@dynamic bankReservation_exists, bankReservation_totalAmount, bankReservation_availableAmount, bankReservation_reservedAt, bankReservation_validUntil;
@dynamic bankInformation_bicShort, bankInformation_bicFull, bankInformation_UID;

+ (instancetype)accountInfoDataForAccountInfoDictionary:(NSDictionary *)accountInfoDictionary {
    SOXAccountInfo_BitcoinDE_Data *bannerData = [[SOXAccountInfo_BitcoinDE_Data alloc] init];

    [bannerData setupDataForAccountInfoDictionary:accountInfoDictionary];
    
    return bannerData;
}

#pragma mark - Class methods
- (void)setupDataForAccountInfoDictionary:(NSDictionary *)accountInfoDictionary {
    NSDictionary *dataDict = [accountInfoDictionary objectForKey:BitcoinDE_ShowAccountInfo_MainKey];

    // BTC information
    {
        NSDictionary *btc_balance = [dataDict objectForKey:BitcoinDE_ShowAccountInfoBTCBalance_btc_balance];
        self.btcBalance_totalAmount = [btc_balance objectForKey:BitcoinDE_ShowAccountInfoBTCBalance_total_amount];
        self.btcBalance_availableAmount = [btc_balance objectForKey:BitcoinDE_ShowAccountInfoBTCBalance_available_amount];
        self.btcBalance_reservedAmount = [btc_balance objectForKey:BitcoinDE_ShowAccountInfoBTCBalance_reserved_amount];
    }
    // Fidor information
    {
        NSDictionary *fidor_reservation = [dataDict objectForKey:BitcoinDE_ShowAccountInfoFidorReservation_fidor_reservation];
        if (fidor_reservation) {
            self.bankReservation_exists = YES;
            self.bankReservation_totalAmount = [fidor_reservation objectForKey:BitcoinDE_ShowAccountInfoFidorReservation_total_amount];
            self.bankReservation_availableAmount = [fidor_reservation objectForKey:BitcoinDE_ShowAccountInfoFidorReservation_available_amount];
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
