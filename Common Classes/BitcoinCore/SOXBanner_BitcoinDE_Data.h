//
//  SOXBanner_BitcoinDE_Data.h
//  BitcoinApp
//
//  Created by Peter Hauke on 14.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>


// showAccountInfo
// BTC-Balance
FOUNDATION_EXPORT NSString *const BitcoinDE_BTCBalanceKey;
FOUNDATION_EXPORT NSString *const BitcoinDE_BTCTotalAmountKey;
FOUNDATION_EXPORT NSString *const BitcoinDE_BTCAvailAmountKey;
FOUNDATION_EXPORT NSString *const BitcoinDE_BTCReservedAmountKey;

// Fidor-Reservation
FOUNDATION_EXPORT NSString *const BitcoinDE_FidorReservationKey;
FOUNDATION_EXPORT NSString *const BitcoinDE_FidorTotalAmountKey;
FOUNDATION_EXPORT NSString *const BitcoinDE_FidorAvailAmountKey;
FOUNDATION_EXPORT NSString *const BitcoinDE_FidorReservedAtKey;
FOUNDATION_EXPORT NSString *const BitcoinDE_FidorValidUntilKey;

//Encrypted-Information
FOUNDATION_EXPORT NSString *const BitcoinDE_BankInformationKey;
FOUNDATION_EXPORT NSString *const BitcoinDE_BankBICshortKey;
FOUNDATION_EXPORT NSString *const BitcoinDE_BankBICfullKey;
FOUNDATION_EXPORT NSString *const BitcoinDE_BankUserUIDKey;

@interface SOXBanner_BitcoinDE_Data : NSObject

@end
