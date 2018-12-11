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
        switch (accountLedgerStatisticData.state) {
            case SOXStatisticData_StateType_New :
                transformedValue = @"Not selected";
                break;
            case SOXStatisticData_StateType_WaitingForLoading :
                transformedValue = @"Waiting ...";
                break;
            case SOXStatisticData_StateType_IsLoadingFirstPage :
                transformedValue = @"Fetching first page";
                break;
            case SOXStatisticData_StateType_IsLoadingMorePages :
                transformedValue = [NSString stringWithFormat:
                                    @"Fetching page %ti of %ti"
                                    , accountLedgerStatisticData.currentPage + 1
                                    , accountLedgerStatisticData.lastPage];
                break;
            case SOXStatisticData_StateType_FullyLoaded :
                transformedValue = [NSString stringWithFormat:
                                    @"%ti pages fetched"
                                    , accountLedgerStatisticData.lastPage];
                break;
            default:
                break;
        }
        return transformedValue;
    }
    else {
        NSAssert(NO, @"Unknown value class");
    }

    return @"Error";
}

@end
