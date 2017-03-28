//
//  SOXAccountLedger_BitcoinDE_Data.h
//  BitcoinApp
//
//  Created by Peter Hauke on 28.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOXAccountLedger_BitcoinDE_Data : NSObject

@property (strong, nonatomic, readonly) NSString *positionDetails_Date;
@property (strong, nonatomic, readonly) NSString *positionDetails_Type;
@property (strong, nonatomic, readonly) NSString *positionDetails_Reference;
@property (strong, nonatomic, readonly) NSString *positionDetails_Cashflow;
@property (strong, nonatomic, readonly) NSString *positionDetails_Balance;

@property (strong, nonatomic, readonly) NSString *tradeDetails_Trade_id;
@property (strong, nonatomic, readonly) NSString *tradeDetails_Price;
@property (strong, nonatomic, readonly) NSString *tradeDetails_BTC_before_fee;
@property (strong, nonatomic, readonly) NSString *tradeDetails_BTC_after_fee;
@property (strong, nonatomic, readonly) NSString *tradeDetails_Euro_before_fee;
@property (strong, nonatomic, readonly) NSString *tradeDetails_Euro_after_fee;

+ (NSMutableArray *)accountLedgerDataArrayForAccountLedgerDictionary:(NSDictionary *)payloadDictionary;

@end
