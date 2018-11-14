//
//  SOXNegativCurrencySignOnBuyValueTransformer.m
//  BitcoinApp
//
//  Created by Peter Hauke on 14.11.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXNegateTradeDetailsEuroAfterFeeOnBuyValueTransformer.h"

#import "SOXAccountLedger_BitcoinDE_Data_Private.h"

@implementation SOXNegateTradeDetailsEuroAfterFeeOnBuyValueTransformer

+ (Class)transformedValueClass {
    return [NSDecimalNumber class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    if ([value isKindOfClass:[SOXAccountLedger_BitcoinDE_Data class]]) {
        SOXAccountLedger_BitcoinDE_Data *accountLedgerData = (SOXAccountLedger_BitcoinDE_Data *)value;
        NSDecimalNumber *tradeDetails_Euro_after_fee = accountLedgerData.tradeDetails_Euro_after_fee;
        if ([accountLedgerData.positionDetails_Type isEqualToString:BitcoinDE_AccountLedgerParameter_BuyOrderTypeKey]) {
            tradeDetails_Euro_after_fee = [tradeDetails_Euro_after_fee decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"-1"]];
        }

        return tradeDetails_Euro_after_fee;
    }

    return value;
}

@end
