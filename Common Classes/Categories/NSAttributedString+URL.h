//
//  NSAttributedString+URL.h
//  BitcoinApp
//
//  Created by Peter Hauke on 27.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (URL)

+ (instancetype)hyperlinkFromString:(NSString *)inString withURL:(NSURL *)aURL;

@end
