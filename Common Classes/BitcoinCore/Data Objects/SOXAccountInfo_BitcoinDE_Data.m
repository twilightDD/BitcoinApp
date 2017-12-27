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
@synthesize tradingPairBalances, tradingPairAllocations;
@synthesize bankReservation_exists, bankReservation_totalAmount, bankReservation_availableAmount, bankReservation_reservedAt, bankReservation_validUntil;
@synthesize bankInformation_bicShort, bankInformation_bicFull, bankInformation_UID;

#pragma mark - Init & Co.
+ (instancetype)accountInfoDataForAccountInfoDictionary:(NSDictionary *)accountInfoDictionary {
    SOXAccountInfo_BitcoinDE_Data *bannerData = [[SOXAccountInfo_BitcoinDE_Data alloc] init];

    [bannerData setupDataForAccountInfoDictionary:accountInfoDictionary];
    
    return bannerData;
}

#pragma mark - Public methods
- (NSDecimalNumber *)allocationPercentForCurrencyType:(BitcoinDE_CurrencyType)currencyType {
    SOXBitcoinDE_Allocation *tradingPairAllocation = [self tradingPairAllocationForCurrency:currencyType];
    NSDecimalNumber *allocationPercentForCurrency = tradingPairAllocation.allocation_percent;

    return allocationPercentForCurrency;
}

- (NSDecimalNumber *)allocationMaxEurVolumeForCurrencyType:(BitcoinDE_CurrencyType)currencyType {
    SOXBitcoinDE_Allocation *tradingPairAllocation = [self tradingPairAllocationForCurrency:currencyType];
    NSDecimalNumber *allocationMaxEurVolumeForCurrency = tradingPairAllocation.allocation_max_eur_volume;

    return allocationMaxEurVolumeForCurrency;
}

- (NSDecimalNumber *)allocationEurVolumeOpenOrdersForCurrencyType:(BitcoinDE_CurrencyType)currencyType {
    SOXBitcoinDE_Allocation *tradingPairAllocation = [self tradingPairAllocationForCurrency:currencyType];
    NSDecimalNumber *allocationEurVolumeOpenOrdersForCurrency = tradingPairAllocation.allocation_eur_volume_open_orders;

    return allocationEurVolumeOpenOrdersForCurrency;
}

- (NSDecimalNumber *)totalAmountForCurrencyType:(BitcoinDE_CurrencyType)currencyType {
    SOXBitcoinDE_Balance *tradingPairBalance = [self tradingPairBalanceForCurrencyType:currencyType];
    NSDecimalNumber *totalAmountForCurrencyType = tradingPairBalance.totalAmount;

    return totalAmountForCurrencyType;
}

- (NSDecimalNumber *)availableAmountForCurrencyType:(BitcoinDE_CurrencyType)currencyType {
    SOXBitcoinDE_Balance *tradingPairBalance = [self tradingPairBalanceForCurrencyType:currencyType];
    NSDecimalNumber *availableAmountForCurrencyType = tradingPairBalance.availableAmount;

    return availableAmountForCurrencyType;
}

- (NSDecimalNumber *)reservedAmountForCurrencyType:(BitcoinDE_CurrencyType)currencyType {
    SOXBitcoinDE_Balance *tradingPairBalance = [self tradingPairBalanceForCurrencyType:currencyType];
    NSDecimalNumber *reservedAmountForCurrencyType = tradingPairBalance.reservedAmount;

    return reservedAmountForCurrencyType;
}


#pragma mark - Private methods
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
    }
    // Fidor information
    {
        NSDictionary *fidor_reservation = [dataDict objectForKey:BitcoinDE_ShowAccountInfoFidorReservation_fidor_reservation];
        if (fidor_reservation) {
            self.bankReservation_exists = YES;
            self.bankReservation_totalAmount = [NSDecimalNumber decimalNumberWithDecimal:
                                                [[fidor_reservation objectForKey:BitcoinDE_ShowAccountInfoFidorReservation_total_amount] decimalValue ]];
            self.bankReservation_availableAmount = [NSDecimalNumber decimalNumberWithDecimal:[[fidor_reservation objectForKey:BitcoinDE_ShowAccountInfoFidorReservation_available_amount] decimalValue]];
            self.bankReservation_reservedAt = [fidor_reservation objectForKey:BitcoinDE_ShowAccountInfoFidorReservation_reserved_at];
            self.bankReservation_validUntil = [fidor_reservation objectForKey:BitcoinDE_ShowAccountInfoFidorReservation_valid_until];

            // Allocations
            NSDictionary *fidor_allocations = [fidor_reservation objectForKey:BitcoinDE_ShowAccountInfoFidorReservation_allocation];
            NSMutableDictionary *tradingPairAllocationsHelper = [NSMutableDictionary dictionary];
            [fidor_allocations enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull currencyShort, NSDictionary * _Nonnull allocationDict, BOOL * _Nonnull stop) {
                SOXBitcoinDE_Allocation *allocation = [[SOXBitcoinDE_Allocation alloc] init];
                allocation.allocation_percent = [NSDecimalNumber decimalNumberWithDecimal:
                                                  [[allocationDict objectForKey:BitcoinDE_ShowAccountInfoFidorReservation_allocation_percent] decimalValue]];
                allocation.allocation_max_eur_volume = [NSDecimalNumber decimalNumberWithDecimal:
                                                        [[allocationDict objectForKey:BitcoinDE_ShowAccountInfoFidorReservation_allocation_max_eur_volume] decimalValue]];
                allocation.allocation_eur_volume_open_orders = [NSDecimalNumber decimalNumberWithDecimal:
                                                                [[allocationDict objectForKey:BitcoinDE_ShowAccountInfoFidorReservation_allocation_eur_volume_open_orders] decimalValue]];
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

- (SOXBitcoinDE_Allocation *)tradingPairAllocationForCurrency:(BitcoinDE_CurrencyType)currencyType {
    NSString *currencyTypeString = [SOXMarket_BitcoinDE_DefTypes tradingPairShortStringForCurrencyType:currencyType];
    SOXBitcoinDE_Allocation *tradingPairAllocationForCurrency = [self.tradingPairAllocations objectForKey:currencyTypeString];

    return tradingPairAllocationForCurrency;
}

- (SOXBitcoinDE_Balance *)tradingPairBalanceForCurrencyType:(BitcoinDE_CurrencyType)currencyType {
    NSString *currencyTypeString = [SOXMarket_BitcoinDE_DefTypes tradingPairShortStringForCurrencyType:currencyType];
    SOXBitcoinDE_Balance *tradingPairBalanceForCurrencyType  = [self.tradingPairBalances objectForKey:currencyTypeString];

    return tradingPairBalanceForCurrencyType;
}


@end
