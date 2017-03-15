//
//  SOXBanner_BitcoinDE_Data.m
//  BitcoinApp
//
//  Created by Peter Hauke on 14.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXBanner_BitcoinDE_Data.h"
#import "SOXBannerData_Private.h"

#import "SOXMarket_BitcoinDE_Core.h"
// showAccountInfo
// BTC-Balance
NSString *const BitcoinDE_BTCBalanceKey = @"btc_balance"; // Infos zur BTC-Balance
NSString *const BitcoinDE_BTCTotalAmountKey = @"total_amount"; // Aktuelles BTC-Guthaben
NSString *const BitcoinDE_BTCAvailAmountKey = @"available_amount"; // Aktuell verfügbares BTC-Guthaben
NSString *const BitcoinDE_BTCReservedAmountKey = @"reserved_amount"; // Aktuell reserviertes BTC-Guthaben

// Fidor-Reservation
NSString *const BitcoinDE_FidorReservationKey = @"fidor_reservation"; // Infos zur ggfs. vorhandenen Fidor-Reservierung
NSString *const BitcoinDE_FidorTotalAmountKey = @"total_amount"; // Gesambetrag der Reservierung
NSString *const BitcoinDE_FidorAvailAmountKey = @"available_amount"; // Aktuell verfügbarer Betrag der Reservierung
NSString *const BitcoinDE_FidorReservedAtKey = @"reserved_at"; // Erstelldatum der Reservierung (Format: 2015-04-07T12:23:04+02:00 nach RFC 3339)
NSString *const BitcoinDE_FidorValidUntilKey = @"valid_until"; // Reservierung gültig bis (Format: 2015-04-07T12:23:04+02:00 gemäß RFC 3339)

//Encrypted-Information
NSString *const BitcoinDE_BankInformationKey = @"encrypted_information"; // verschlüsselte Infos
NSString *const BitcoinDE_BankBICshortKey = @"bic_short"; // Verschlüsselte Bankengruppe aus der BIC (ersten 4 Zeichen)
NSString *const BitcoinDE_BankBICfullKey = @"bic_full"; // Verschlüsselte komplette BIC
NSString *const BitcoinDE_BankUserUIDKey = @"uid"; // Verschlüsselte eigene User-Id

@interface SOXBanner_BitcoinDE_Data ()

@end

@implementation SOXBanner_BitcoinDE_Data

+ (void)startBannerUpdatesSceduleTime:(NSTimeInterval)timeInterval
                             delegate:(id <SOXBannerDataProtocol>)delegate {
    // timer
    weakify(self)
    NSTimer *reloadBannerDataTimer = [NSTimer timerWithTimeInterval:timeInterval
                                                            repeats:YES
                                                              block:^(NSTimer * _Nonnull timer) {
                                                                  strongify(self)
                                                                  [self startBannerUpdate];
                                                              }];
    [SOXBanner_BitcoinDE_Data sharedData].reloadBannerDataTimer = reloadBannerDataTimer;
    
    // delegate
    [SOXBanner_BitcoinDE_Data sharedData].delegate = delegate;
}

- (void)startBannerUpdate {
    NSLog(@"startBannerUpdate");
    
    [SOXMarket_BitcoinDE_Core]
}

@end
