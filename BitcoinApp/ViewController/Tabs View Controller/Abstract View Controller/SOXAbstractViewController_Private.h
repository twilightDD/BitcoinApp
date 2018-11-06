//
//  SOXAbstractViewController_Private.h
//  BitcoinApp
//
//  Created by Peter Hauke on 05.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXAbstractViewController.h"
#import "SOXMarket_BitcoinDE_Core.h"

#import "SOXKeys_BitcoinDE.h"
#import "SOXMarket_BitcoinDE_DefTypes.h"

#import "SOXFormatters.h"

@interface SOXAbstractViewController() <SOXMarketCoreServerRequestProtocol>

@property (strong) IBOutlet NSArrayController *arrayController;
@property (strong, nonatomic) NSMutableArray *arrayControllerDatas;

- (void)enableSpinningWheel;
- (void)disableSpinningWheel;

@end
