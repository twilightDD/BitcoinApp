//
//  SOXErrorMessage_BitcoinDE.h
//  BitcoinApp
//
//  Created by Peter Hauke on 28.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOXErrorMessage_BitcoinDE : NSObject

@property (copy, nonatomic, nullable) NSString *serverRequestTitle;
@property (copy, nonatomic, nullable) NSString *errorMessage;
@property (nonatomic, readonly) BOOL hasError;

- (SOXErrorMessage_BitcoinDE * _Nonnull)initWithServerRequestTitle:(NSString * _Nullable)serverRequestTitle;

- (void)checkNSURLResonse:(NSURLResponse * _Nullable)response;
- (void)checkJsonError:(NSError * _Nullable)jsonError;
- (void)checkforAPIErrors:(NSArray * _Nullable)apiErrors;
- (void)appendErrorDescripton:(NSString * _Nullable)errorDescripton;

- (NSString *)description;
@end
