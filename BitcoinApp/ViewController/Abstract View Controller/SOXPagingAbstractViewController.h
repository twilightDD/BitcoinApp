//
//  SOXPagingAbstractViewController.h
//  BitcoinApp
//
//  Created by Peter Hauke on 27.08.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXAbstractViewController.h"
#import "SOXPagingViewController.h"

#import "SOXMarket_BitcoinDE_DefTypes.h"

@protocol SOXExportDataProtocol

- (void)copy:(id)sender;
- (NSString *)suggestedExportFileName;

@end

@interface SOXPagingAbstractViewController : SOXAbstractViewController <SOXPagingViewControllerProtocol, SOXExportDataProtocol>


@end
