//
//  SOXBanner_BitcoinDE_Data.m
//  BitcoinApp
//
//  Created by Peter Hauke on 14.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXAccountInfo_BitcoinDE_Data.h"

#import "SOXKeys_BitcoinDE.h"

#pragma mark - Balance
@interface SOXBitcoinDE_Balance ()
@property (strong, nonatomic, readwrite) NSDecimalNumber *totalAmount;
@property (strong, nonatomic, readwrite) NSDecimalNumber *availableAmount;
@property (strong, nonatomic, readwrite) NSDecimalNumber *reservedAmount;
@end

@implementation SOXBitcoinDE_Balance
@end

#pragma mark -  Reservation
@interface SOXBitcoinDE_Allocation ()
@property (strong, nonatomic, readwrite) NSDecimalNumber *allocation_percent;
@property (strong, nonatomic, readwrite) NSDecimalNumber *allocation_max_eur_volume;
@property (strong, nonatomic, readwrite) NSDecimalNumber *allocation_eur_volume_open_orders;
@end

@implementation SOXBitcoinDE_Allocation
@end


#pragma mark - Interface
@interface SOXAccountInfo_BitcoinDE_Data ()

#pragma mark Properties

@property (strong, nonatomic, readwrite) NSDecimalNumber *btcBalance_totalAmount;
@property (strong, nonatomic, readwrite) NSDecimalNumber *btcBalance_availableAmount;
@property (strong, nonatomic, readwrite) NSDecimalNumber *btcBalance_reservedAmount;

@property (strong, nonatomic, readwrite) NSDictionary *tradingPairBalances;
@property (strong, nonatomic, readwrite) NSDictionary *tradingPairAllocations;

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
@synthesize tradingPairBalances, tradingPairAllocations;
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
        NSDictionary *balances = [dataDict objectForKey:BitcoinDE_ShowAccountInfo_Balances];
        NSMutableDictionary *tradingPairBalancesHelper = [NSMutableDictionary dictionary];

        [balances enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull currencyShort, NSDictionary * _Nonnull currencyDict, BOOL * _Nonnull stop) {
            SOXBitcoinDE_Balance *balance = [[SOXBitcoinDE_Balance alloc] init];
            balance.totalAmount = [NSDecimalNumber decimalNumberWithString:[currencyDict objectForKey:BitcoinDE_ShowAccountInfo_Balance_total_amount]];
            balance.availableAmount = [NSDecimalNumber decimalNumberWithString:[currencyDict objectForKey:BitcoinDE_ShowAccountInfo_Balance_available_amount]];
            balance.reservedAmount = [NSDecimalNumber decimalNumberWithString:[currencyDict objectForKey:BitcoinDE_ShowAccountInfo_Balance_reserved_amount]];
            [tradingPairBalancesHelper setObject:balance
                                          forKey:currencyShort];
        }];

        self.tradingPairBalances = [tradingPairBalancesHelper copy];
        NSLog(@"");
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

            // Allocations
            NSDictionary *fidor_allocations = [fidor_reservation objectForKey:BitcoinDE_ShowAccountInfoFidorReservation_allocation];
            NSMutableDictionary *tradingPairAllocationsHelper = [NSMutableDictionary dictionary];
            [fidor_allocations enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull currencyShort, NSDictionary * _Nonnull allocationDict, BOOL * _Nonnull stop) {
                SOXBitcoinDE_Allocation *allocation = [[SOXBitcoinDE_Allocation alloc] init];
                allocation.allocation_percent = [allocationDict objectForKey:BitcoinDE_ShowAccountInfoFidorReservation_allocation_percent];
                allocation.allocation_max_eur_volume = [allocationDict objectForKey:BitcoinDE_ShowAccountInfoFidorReservation_allocation_max_eur_volume];
                allocation.allocation_eur_volume_open_orders = [allocationDict objectForKey:BitcoinDE_ShowAccountInfoFidorReservation_allocation_eur_volume_open_orders];
                [tradingPairAllocationsHelper setObject:allocation
                                                 forKey:currencyShort];
            }];
            self.tradingPairAllocations = [tradingPairAllocationsHelper copy];
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
