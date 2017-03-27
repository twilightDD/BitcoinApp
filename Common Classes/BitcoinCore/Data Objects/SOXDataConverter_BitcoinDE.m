//
//  SOXDataConverter_BitcoinDE.m
//  BitcoinApp
//
//  Created by Peter Hauke on 21.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXDataConverter_BitcoinDE.h"
#import "SOXKeys_BitcoinDE.h"

#import "SOXShowOrderbook_BitcoinDE_Data.h" // BitcoinDE_ShowBuyOrderbookCommandType and BitcoinDE_ShowSellOrderbookCommandType
#import "SOXAccountInfo_BitcoinDE_Data.h"   // for BitcoinDE_ShowAccountInfoCommandType
#import "SOXRates_BitcoinDE_Data.h"         // for BitcoinDE_ShowRatesCommandType

@implementation SOXDataConverter_BitcoinDE

+ (id)payloadForServerDictionary:(NSDictionary *)payloadDictionary
                forServerCommand:(BitcoinDE_ServerCommandType)serverCommandType {
    id payload;
    switch (serverCommandType) {
        case BitcoinDE_ShowBuyOrderbookCommandType:;
        case BitcoinDE_ShowSellOrderbookCommandType:
            payload = payloadDictionary; //[SOXShowOrderbook_BitcoinDE_Data orderbookDataArrayForShowOrderbookDictionary:payloadDictionary];
            break;
        case BitcoinDE_ShowMyOrdersCommandType:
            payload = payloadDictionary;
            break;
        case BitcoinDE_ShowMyOrderDetailsCommandType:
            
            break;
        case BitcoinDE_ShowAccountInfoCommandType:
            payload = [SOXAccountInfo_BitcoinDE_Data accountInfoDataForAccountInfoDictionary:payloadDictionary];
            break;
        case BitcoinDE_ShowOrderbookCompactCommandType:
            
            break;
        case BitcoinDE_ShowPublicTradeHistoryCommandType:
            
            break;
        case BitcoinDE_ShowRatesCommandType:
            payload = [SOXRates_BitcoinDE_Data rateDataForRateInfoDictionary:payloadDictionary];
            break;
        default:
            // error
            
            break;
    }
    
    return payload;
}

@end
