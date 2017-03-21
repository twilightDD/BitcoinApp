//
//  SOXOrdersViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 18.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXOrdersViewController.h"

#import "SOXMarket_BitcoinDE_Core.h"
#import "SOXShowOrderbook_BitcoinDE_Data.h"

@interface SOXOrdersViewController () <SOXMarketCoreServerRequestProtocol>

@property (strong, nonatomic) NSMutableArray *orderBook;

@end

@implementation SOXOrdersViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)viewWillAppear {
    [super viewWillAppear];
    if (self.orderType == OrdersBuyType) {
        [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowBuyOrderbookCommandType
                                                         respondTo:self];
    }
    else if (self.orderType == OrdersSellType) {
        [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowSellOrderbookCommandType
                                                    respondTo:self];
    }
    else {
        NSLog(@"SOXOrdersViewController - (void)viewWillAppear : self.orderType has wrong type");
    }
}

#pragma mark - SOXMarketCoreServerRequestProtocol
- (void)answerOfServerRequest:(NSDictionary *)answerOfServerRequest {
    if ([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ShowBuyOrderbookCommandType)]
        || [[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ShowSellOrderbookCommandType)]) {
        NSDictionary *payloadDictionary = [answerOfServerRequest objectForKey:ServerAnswerPayloadKey];
        NSMutableArray *orderBook = [SOXShowOrderbook_BitcoinDE_Data orderbookDataArrayForShowOrderbookDictionary:payloadDictionary];
        self.orderBook = orderBook;
    }
}

@end
