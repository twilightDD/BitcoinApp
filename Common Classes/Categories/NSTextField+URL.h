//
//  NSTextField+URL.h
//  BitcoinApp
//
//  Created by Peter Hauke on 27.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSTextField (URL)

- (void)setHyperlinkFormattingFromString:(NSString *)hyperlink withURLString:(NSString *)urlString;
- (void)resetHyperlinkFormatting;


@end
