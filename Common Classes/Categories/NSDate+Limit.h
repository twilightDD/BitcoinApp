//
//  NSDate+Limit.h
//  BitcoinApp
//
//  Created by Peter Hauke on 15.03.21.
//  Copyright © 2021 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (Limit)

- (NSDate *)limitedToNow;
- (NSDate *)limitedToYesterday;

@end

NS_ASSUME_NONNULL_END
