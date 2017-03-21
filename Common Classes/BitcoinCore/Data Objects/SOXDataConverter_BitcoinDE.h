//
//  SOXDataConverter_BitcoinDE.h
//  BitcoinApp
//
//  Created by Peter Hauke on 21.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOXMarket_BitcoinDE_Core.h"

@interface SOXDataConverter_BitcoinDE : NSObject

+ (id)payloadForServerDictionary:(NSDictionary *)payloadDictionary forServerCommand:(BitcoinDE_ServerCommandType)serverCommandType;

@end
