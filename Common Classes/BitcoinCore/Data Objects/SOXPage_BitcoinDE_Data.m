//
//  SOXPage_BitcoinDE_Data.m
//  BitcoinApp
//
//  Created by Peter Hauke on 13.08.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXPage_BitcoinDE_Data.h"

#import "SOXKeys_BitcoinDE.h"

@interface SOXPage_BitcoinDE_Data ()

@property (nonatomic, readwrite) NSInteger pageCurrent;
@property (nonatomic, readwrite) NSInteger pageLast;

@end

@implementation SOXPage_BitcoinDE_Data
#pragma mark Synthesize
@synthesize pageCurrent, pageLast;

+ (instancetype)pageDataForPayloadDictionary:(NSDictionary *)payloadDictionary {
    SOXPage_BitcoinDE_Data *pageData = [[SOXPage_BitcoinDE_Data alloc] init];

    [pageData setupDataForPayloadDictionary:payloadDictionary];

    return pageData;
}

- (void)setupDataForPayloadDictionary:(NSDictionary *)payloadDictionary {
    NSDictionary *pageDictionary = [payloadDictionary objectForKey:BitcoinDE_ShowMyTrades_Page];

    self.pageCurrent = [(NSNumber *)[pageDictionary objectForKey:BitcoinDE_ShowMyTrades_Page_Current] integerValue];
    self.pageLast    = [(NSNumber *)[pageDictionary objectForKey:BitcoinDE_ShowMyTrades_Page_Last] integerValue];
}

@end
