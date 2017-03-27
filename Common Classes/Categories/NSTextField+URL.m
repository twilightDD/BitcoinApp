//
//  NSTextField+URL.m
//  BitcoinApp
//
//  Created by Peter Hauke on 27.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "NSTextField+URL.h"
#import "NSAttributedString+URL.h"

@implementation NSTextField (URL)

- (void)setHyperlinkFormattingFromString:(NSString *)hyperlink withURLString:(NSString *)urlString {
    self.allowsEditingTextAttributes= YES;
    self.selectable                 = YES;
    
    NSAttributedString *string = [NSAttributedString hyperlinkFromString:hyperlink
                                                                 withURL:[NSURL URLWithString:urlString]];
    
    self.attributedStringValue = string;
}

- (void)resetHyperlinkFormatting {
    self.allowsEditingTextAttributes = NO;
    self.selectable                  = NO;
}

@end
