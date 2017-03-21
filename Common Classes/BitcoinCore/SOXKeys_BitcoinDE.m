//
//  SOXKeys_BitcoinDE.m
//  BitcoinApp
//
//  Created by Peter Hauke on 21.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXKeys_BitcoinDE.h"

@implementation SOXKeys_BitcoinDE

#pragma mark - BitcoinDE_ShowAccountInfo
NSString *const BitcoinDE_ShowAccountInfo_MainKey = @"data";
#pragma mark | BTC-Balance
NSString *const BitcoinDE_ShowAccountInfoBTCBalance_btc_balance       = @"btc_balance";
NSString *const BitcoinDE_ShowAccountInfoBTCBalance_total_amount      = @"total_amount";
NSString *const BitcoinDE_ShowAccountInfoBTCBalance_available_amount  = @"available_amount";
NSString *const BitcoinDE_ShowAccountInfoBTCBalance_reserved_amount   = @"reserved_amount";

#pragma mark | Fidor-Reservation
NSString *const BitcoinDE_ShowAccountInfoFidorReservation_fidor_reservation   = @"fidor_reservation";
NSString *const BitcoinDE_ShowAccountInfoFidorReservation_total_amount        = @"total_amount";
NSString *const BitcoinDE_ShowAccountInfoFidorReservation_available_amount    = @"available_amount";
NSString *const BitcoinDE_ShowAccountInfoFidorReservation_reserved_at         = @"reserved_at";
NSString *const BitcoinDE_ShowAccountInfoFidorReservation_valid_until         = @"valid_until";

#pragma mark | Encrypted-Information
NSString *const BitcoinDE_ShowAccountInfoEncryptedInformation_encrypted_information   = @"encrypted_information";
NSString *const BitcoinDE_ShowAccountInfoEncryptedInformation_bic_short               = @"bic_short";
NSString *const BitcoinDE_ShowAccountInfoEncryptedInformation_bic_full                = @"bic_full";
NSString *const BitcoinDE_ShowAccountInfoEncryptedInformation_uid                     = @"uid";

#pragma mark - BitcoinDE_ShowRates
NSString *const BitcoinDE_ShowRates_MainKey = @"rates";
#pragma mark | Rates
NSString *const BitcoinDE_ShowRates_rate_weighted     = @"rate_weighted";
NSString *const BitcoinDE_ShowRates_rate_weighted_3h  = @"rate_weighted_3h";
NSString *const BitcoinDE_ShowRates_rate_weighted_12h = @"rate_weighted_12h";

@end
