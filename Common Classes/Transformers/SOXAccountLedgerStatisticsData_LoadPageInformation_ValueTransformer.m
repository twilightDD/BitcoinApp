//
//  SOXAccountLedgerStatisticsData_LoadPageInformation_ValueTransformer.m
//  BitcoinApp
//
//  Created by Peter Hauke on 11.12.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXAccountLedgerStatisticsData_LoadPageInformation_ValueTransformer.h"

#import "SOXPageData.h"

#import "SOXAccountLedger_BitcoinDE_StatisticData.h"

@implementation SOXAccountLedgerStatisticsData_LoadPageInformation_ValueTransformer

+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {

    if ([value isKindOfClass:[SOXAccountLedger_BitcoinDE_StatisticData class]]) {
        SOXAccountLedger_BitcoinDE_StatisticData *accountLedgerStatisticData = value;
        NSString *transformedValue;
        if (accountLedgerStatisticData.isLoading) {
            if (accountLedgerStatisticData.currentPage == 0) {
                transformedValue = @"Loading first page";
            }
        }
        if (accountLedgerStatisticData.isActive) {
            if (accountLedgerStatisticData.isWaiting) {
                transformedValue = @"Waiting ...";
            }
            else if (accountLedgerStatisticData.currentPage == accountLedgerStatisticData.lastPage) {
                transformedValue = [NSString stringWithFormat:
                                    @"%ti pages fetched"
                                    , accountLedgerStatisticData.lastPage];
            }
            else {
                transformedValue = [NSString stringWithFormat:
                                    @"Fetching page %ti of %ti"
                                    , accountLedgerStatisticData.currentPage
                                    , accountLedgerStatisticData.lastPage];
            }
        }
        else {
            transformedValue = @"Not selected";
        }
        return transformedValue;
    }
    else {
        NSAssert(NO, @"Unknown value class");
    }

    return @"Error";
}

@end
