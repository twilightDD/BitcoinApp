//
//  SOXMyTrades_BitcoinDE_Data.m
//  BitcoinApp
//
//  Created by Peter Hauke on 03.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXMyTrades_BitcoinDE_Data.h"

#import "SOXDateFormatter.h"

@implementation SOXMyTrades_BitcoinDE_Data

+ (NSDictionary *)parameterFor {
    NSString *dateStart = [SOXDateFormatter rfc3339DateTimeStringDate:[NSDate dateWithTimeInterval:-86400*7
                                                                                         sinceDate:[NSDate date]]];
    NSString *dateEnd = [SOXDateFormatter rfc3339DateTimeStringDate:[NSDate date]];
    
    NSLog(@"SOXMyTrades_BitcoinDE_Data dateStart %@", dateStart);
    NSLog(@"SOXMyTrades_BitcoinDE_Data dateEnd   %@", dateEnd);
    
    NSDictionary *parameterDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"buy", @"type"
                                   , @(1), @"state"
                                   , dateStart, @"date_start"
                                   , dateEnd, @"date_end"
                                   , @(1), @"page"
                                   , nil];
    
    return parameterDict;
}

@end
