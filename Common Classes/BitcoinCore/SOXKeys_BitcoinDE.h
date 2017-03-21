//
//  SOXKeys_BitcoinDE.h
//  BitcoinApp
//
//  Created by Peter Hauke on 21.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOXKeys_BitcoinDE : NSObject

#pragma mark - BitcoinDE_ShowAccountInfo
FOUNDATION_EXPORT NSString *const BitcoinDE_ShowAccountInfo_MainKey;
#pragma mark | BTC-Balance
FOUNDATION_EXPORT NSString *const BitcoinDE_ShowAccountInfoBTCBalance_btc_balance;
FOUNDATION_EXPORT NSString *const BitcoinDE_ShowAccountInfoBTCBalance_total_amount;
FOUNDATION_EXPORT NSString *const BitcoinDE_ShowAccountInfoBTCBalance_available_amount;
FOUNDATION_EXPORT NSString *const BitcoinDE_ShowAccountInfoBTCBalance_reserved_amount;

#pragma mark | Fidor-Reservation
FOUNDATION_EXPORT NSString *const BitcoinDE_ShowAccountInfoFidorReservation_fidor_reservation;
FOUNDATION_EXPORT NSString *const BitcoinDE_ShowAccountInfoFidorReservation_total_amount;
FOUNDATION_EXPORT NSString *const BitcoinDE_ShowAccountInfoFidorReservation_available_amount;
FOUNDATION_EXPORT NSString *const BitcoinDE_ShowAccountInfoFidorReservation_reserved_at;
FOUNDATION_EXPORT NSString *const BitcoinDE_ShowAccountInfoFidorReservation_valid_until;

#pragma mark | Encrypted-Information
FOUNDATION_EXPORT NSString *const BitcoinDE_ShowAccountInfoEncryptedInformation_encrypted_information;
FOUNDATION_EXPORT NSString *const BitcoinDE_ShowAccountInfoEncryptedInformation_bic_short;
FOUNDATION_EXPORT NSString *const BitcoinDE_ShowAccountInfoEncryptedInformation_bic_full;
FOUNDATION_EXPORT NSString *const BitcoinDE_ShowAccountInfoEncryptedInformation_uid;

#pragma mark - BitcoinDE_ShowRates
FOUNDATION_EXPORT NSString *const BitcoinDE_ShowRates_MainKey;
#pragma mark | Rates
FOUNDATION_EXPORT NSString *const BitcoinDE_ShowRates_rate_weighted;
FOUNDATION_EXPORT NSString *const BitcoinDE_ShowRates_rate_weighted_3h;
FOUNDATION_EXPORT NSString *const BitcoinDE_ShowRates_rate_weighted_12h;


@end
