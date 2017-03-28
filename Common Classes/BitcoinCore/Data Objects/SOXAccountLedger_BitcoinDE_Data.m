//
//  SOXAccountLedger_BitcoinDE_Data.m
//  BitcoinApp
//
//  Created by Peter Hauke on 28.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXAccountLedger_BitcoinDE_Data.h"

#import "SOXKeys_BitcoinDE.h"

#pragma mark - Interface
@interface SOXAccountLedger_BitcoinDE_Data ()

#pragma mark Properties
@property (strong, nonatomic, readwrite) NSString *positionDetails_Date;
@property (strong, nonatomic, readwrite) NSString *positionDetails_Type;
@property (strong, nonatomic, readwrite) NSString *positionDetails_Reference;
@property (strong, nonatomic, readwrite) NSString *positionDetails_Cashflow;
@property (strong, nonatomic, readwrite) NSString *positionDetails_Balance;

@property (strong, nonatomic, readwrite) NSString *tradeDetails_Trade_id;
@property (strong, nonatomic, readwrite) NSString *tradeDetails_Price;
@property (strong, nonatomic, readwrite) NSString *tradeDetails_BTC_before_fee;
@property (strong, nonatomic, readwrite) NSString *tradeDetails_BTC_after_fee;
@property (strong, nonatomic, readwrite) NSString *tradeDetails_Euro_before_fee;
@property (strong, nonatomic, readwrite) NSString *tradeDetails_Euro_after_fee;

@end

#pragma mark - Implementation
@implementation SOXAccountLedger_BitcoinDE_Data

+ (NSMutableArray *)accountLedgerDataArrayForAccountLedgerDictionary:(NSDictionary *)payloadDictionary {
    NSMutableArray *accountLedgerDataArray = [NSMutableArray array];
    
    NSDictionary *accountLedgerDictionaries = [payloadDictionary objectForKey:BitcoinDE_ShowAccountLedger_Main];
    for (NSDictionary *aAccountLedgerDictionary in accountLedgerDictionaries) {
        [accountLedgerDataArray addObject:[self accountLedgerDataForAccountLedgerDictionary:aAccountLedgerDictionary]];
    }
    
    return accountLedgerDataArray;
}

#pragma mark - Class methods
+ (SOXAccountLedger_BitcoinDE_Data *)accountLedgerDataForAccountLedgerDictionary:(NSDictionary *)aAccountLedgerDictionary {
    SOXAccountLedger_BitcoinDE_Data *accountLedgerData = [[SOXAccountLedger_BitcoinDE_Data alloc] init];
    [accountLedgerData setupMyAccountLedgerDataForAccountLedgerDictionary:aAccountLedgerDictionary];
    
    return accountLedgerData;
}

#pragma mark - Instance methods
- (void)setupMyAccountLedgerDataForAccountLedgerDictionary:(NSDictionary *)aAccountLedgerDictionary {
    { // Ledger Position Details
        self.positionDetails_Date = [aAccountLedgerDictionary objectForKey:BitcoinDE_ShowAccountLedger_Date];
        self.positionDetails_Type = [aAccountLedgerDictionary objectForKey:BitcoinDE_ShowAccountLedger_Type];
        self.positionDetails_Reference = [aAccountLedgerDictionary objectForKey:BitcoinDE_ShowAccountLedger_Reference];
        self.positionDetails_Cashflow = [aAccountLedgerDictionary objectForKey:BitcoinDE_ShowAccountLedger_Cashflow];
        self.positionDetails_Balance = [aAccountLedgerDictionary objectForKey:BitcoinDE_ShowAccountLedger_Balance];
    }
    
    { // Trade details
        NSDictionary *tradeDetails = [aAccountLedgerDictionary objectForKey:BitcoinDE_ShowAccountLedger_Trade];
        if (tradeDetails) {
            self.tradeDetails_Trade_id = [tradeDetails objectForKey:BitcoinDE_ShowAccountLedger_Trade_TradeID];
            self.tradeDetails_Price = [tradeDetails objectForKey:BitcoinDE_ShowAccountLedger_Trade_Price];
            NSDictionary *btcDetails = [tradeDetails objectForKey:BitcoinDE_ShowAccountLedger_Trade_BTC];
            self.tradeDetails_BTC_before_fee = [btcDetails objectForKey:BitcoinDE_ShowAccountLedger_Trade_BTC_BeforeFee];
            self.tradeDetails_BTC_after_fee = [btcDetails objectForKey:BitcoinDE_ShowAccountLedger_Trade_BTC_AfterFee];
            NSDictionary *euroDetails = [tradeDetails objectForKey:BitcoinDE_ShowAccountLedger_Trade_Euro];
            self.tradeDetails_Euro_before_fee = [euroDetails objectForKey:BitcoinDE_ShowAccountLedger_Trade_Euro_BeforeFee];
            self.tradeDetails_Euro_after_fee = [euroDetails objectForKey:BitcoinDE_ShowAccountLedger_Trade_BTC_AfterFee];
        }
    }
}

@end
