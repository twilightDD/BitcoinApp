//
//  SOXDataStatistics.h
//  BitcoinApp
//
//  Created by Peter Hauke on 05.12.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SOXAccountLedger_BitcoinDE_Data;


@interface SOXDataStatistics : NSObject

+ (NSDictionary *)statisticsForAccountLedgerDatas:(NSArray<SOXAccountLedger_BitcoinDE_Data *> *)accountLedgerDatas;

@end
