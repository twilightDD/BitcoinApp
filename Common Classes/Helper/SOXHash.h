//
//  SOXHash.h
//  URLTester
//
//  Created by Peter Hauke on 26.06.16.
//  Copyright © 2016 Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOXHash : NSObject

#pragma mark - Class methods
+ (NSString *)md5StringForString:(NSString *)string;
+ (NSString *)hexadecimalHMACForString:(NSString *)string withKey:(NSString *)key;

@end
