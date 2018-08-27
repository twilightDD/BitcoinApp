//
//  SOXAbstractViewController.h
//  BitcoinApp
//
//  Created by Peter Hauke on 05.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SOXMarket_BitcoinDE_Core.h"

@interface SOXAbstractViewController : NSViewController <SOXMarketCoreServerRequestProtocol>

- (void)enableSpinningWheel;
- (void)disableSpinningWheel;

@end
