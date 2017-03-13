//
//  SOXHash.m
//  URLTester
//
//  Created by Peter Hauke on 26.06.16.
//  Copyright © 2016 Peter Hauke. All rights reserved.
//

#import "SOXHash.h"

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

#pragma mark - Helpers
NS_RETURNS_NOT_RETAINED NSString *md5_string(NSString *string) {
    const char    *ptr = [string UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(ptr, (CC_LONG)strlen(ptr), md5Buffer);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", md5Buffer[i]];
    
    return output;
}

@implementation SOXHash
+ (NSString *)md5StringForString:(NSString *)string {
    NSString *md5String = md5_string(string);
    return md5String;
}

+ (NSString *)hexadecimalHMACForString:(NSString *)string withKey:(NSString *)key {
    // Calculate hmac
    const char    *keyAsChar    = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char    *stringAsChar = [string cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char hmacAsChar[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256,
           keyAsChar, strlen(keyAsChar),
           stringAsChar, strlen(stringAsChar),
           hmacAsChar);

    // Convert hmac to hexadecimal
    NSData              *hmacAsData = [[NSData alloc] initWithBytes:hmacAsChar length:sizeof(hmacAsChar)];
    NSString            *hmac       = [NSMutableString stringWithCapacity:hmacAsData.length * 2];
    const unsigned char *buffer     = (const unsigned char *)[hmacAsData bytes];
    for (int i = 0; i < hmacAsData.length; ++i)
        hmac = [hmac stringByAppendingFormat:@"%02lx", (unsigned long)buffer[i]];

    return hmac;
}

@end
