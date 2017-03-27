//
//  NSAttributedString+URL.m
//  BitcoinApp
//
//  Created by Peter Hauke on 27.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "NSAttributedString+URL.h"

#import <Cocoa/Cocoa.h>

@implementation NSAttributedString (URL)

+ (instancetype)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL {
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString: inString];
    NSRange range = NSMakeRange(0, [attrString length]);
    
    [attrString beginEditing];
    [attrString addAttribute:NSLinkAttributeName
                       value:[aURL absoluteString]
                       range:range];
    
    // make the text appear in blue
    [attrString addAttribute:NSForegroundColorAttributeName
                       value:[NSColor blueColor]
                       range:range];
    
    // next make the text appear with an underline
    [attrString addAttribute:NSUnderlineStyleAttributeName
                       value:[NSNumber numberWithInt:NSUnderlineStyleSingle]
                       range:range];
    
    [attrString endEditing];
    
    return attrString;
}

@end
