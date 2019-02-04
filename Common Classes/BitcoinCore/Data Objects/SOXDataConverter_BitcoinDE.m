//
//  SOXDataConverter_BitcoinDE.m
//  BitcoinApp
//
//  Created by Peter Hauke on 21.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXDataConverter_BitcoinDE.h"

#import "SOXAccountInfo_BitcoinDE_Data.h"   // for BitcoinDE_ShowAccountInfoCommandType
#import "SOXRates_BitcoinDE_Data.h"         // for BitcoinDE_ShowRatesCommandType
#import "SOXMyOrderBook_BitcoinDE_Data.h"   // for BitcoinDE_CreateOrderType

@implementation SOXDataConverter_BitcoinDE

+ (id)payloadForServerDictionary:(NSDictionary *)payloadDictionary
                forServerCommand:(BitcoinDE_ServerCommandType)serverCommandType {
    id payload;
    switch (serverCommandType) {
        case BitcoinDE_ShowBuyOrderbookCommandType:;
        case BitcoinDE_ShowSellOrderbookCommandType:
            payload = payloadDictionary;   //[SOXShowOrderbook_BitcoinDE_Data orderbookDataArrayForShowOrderbookDictionary:payloadDictionary];
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
        case BitcoinDE_ShowMyTradesType:
            payload = payloadDictionary;
            break;
        case BitcoinDE_ShowAccountLedgerType:
            payload = payloadDictionary;
            break;
        case BitcoinDE_RemoveOrderType:
            payload = payloadDictionary;
            break;
        case BitcoinDE_CreateOrderType:
            payload = [SOXMyOrderBook_BitcoinDE_Data myOrderBookDataForCreateInfoDictionary:payloadDictionary];
            break;
        case BitcoinDE_ExecuteTrade:
            payload = @"Das ist nur ein Payloaddummy. Bei success bekommen wir keine Payload, aber wir brauchen irgendwas, "
                       "was als Payload fungiert, weil sonst gibt es einen Fehler und der BalanceTrade wird nicht ausgeführt";
            break;
        default:
            // error

            break;
    }

    return payload;
}

@end
