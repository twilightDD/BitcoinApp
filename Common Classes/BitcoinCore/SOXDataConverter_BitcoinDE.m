//
//  SOXDataConverter_BitcoinDE.m
//  BitcoinApp
//
//  Created by Peter Hauke on 21.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXDataConverter_BitcoinDE.h"
#import "SOXKeys_BitcoinDE.h"

#import "SOXBanner_BitcoinDE_Data.h" // for BitcoinDE_ShowAccountInfoCommandType
@implementation SOXDataConverter_BitcoinDE

+ (id)payloadForServerDictionary:(NSDictionary *)payloadDictionary
                forServerCommand:(BitcoinDE_ServerCommandType)serverCommandType {
    id payload;
    switch (serverCommandType) {
        case BitcoinDE_ShowBuyOrderbookCommandType:
            
            break;
        case BitcoinDE_ShowSellOrderbookCommandType:
            
            break;
        case BitcoinDE_ShowMyOrdersCommandType:
            
            break;
        case BitcoinDE_ShowMyOrderDetailsCommandType:
            
            break;
        case BitcoinDE_ShowAccountInfoCommandType:
            payload = [self showAccountPayloadForServerDictionary:payloadDictionary];
            break;
        case BitcoinDE_ShowOrderbookCompactCommandType:
            
            break;
        case BitcoinDE_ShowPublicTradeHistoryCommandType:
            
            break;
        case BitcoinDE_ShowRatesCommandType:
            payload = [self ratesPayloadForServerDictionary:payloadDictionary];
            break;
        default:
            // error
            
            break;
    }
    
    return payload;
}

+ (SOXBanner_BitcoinDE_Data *)showAccountPayloadForServerDictionary:(NSDictionary *)payloadDictionary {
    SOXBanner_BitcoinDE_Data *payload = [SOXBanner_BitcoinDE_Data bannerDataForAccountInfo:payloadDictionary];
    return  payload;
}

+ (id)ratesPayloadForServerDictionary:(NSDictionary *)payloadDictionary {
    id payload;
    return payload;
}

@end
