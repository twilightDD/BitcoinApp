//
//  SOXErrorMessage_BitcoinDE.m
//  BitcoinApp
//
//  Created by Peter Hauke on 28.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXErrorMessage_BitcoinDE.h"

NSString static *APIError_BitcoinDE_MessageKey = @"message";
NSString static *APIError_BitcoinDE_CodeKey    = @"code";
NSString static *APIError_BitcoinDE_FieldKey   = @"field";

#pragma mark - Interface
@interface SOXErrorMessage_BitcoinDE ()

#pragma mark Properties
@property (nonatomic, readwrite) BOOL hasError;
@property (nonatomic, readwrite) NSInteger apiErrorCode;

@end

#pragma mark - Implementation
@implementation SOXErrorMessage_BitcoinDE

#pragma mark Init&Co.
- (SOXErrorMessage_BitcoinDE * _Nonnull)initWithServerRequestTitle:(NSString * _Nullable)serverRequestTitle {
    self = [super init];
    if (self) {
        self.serverRequestTitle = serverRequestTitle;
        self.hasError = NO;
        self.apiErrorCode = 0; // 0 == no error
    }

    return self;
}

#pragma mark - Public methods
- (void)checkNSURLResonse:(NSURLResponse * _Nullable)response {
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse *)response;
        NSString *errorDescription = [self errorDescriptionForURLResponseStatusCode:httpURLResponse.statusCode];
        if (errorDescription) {
            [self appendErrorDescripton:errorDescription];
        }
    }
}

- (void)checkJsonError:(NSError * _Nullable)jsonError {
    if (jsonError) {
        [self appendErrorDescripton:jsonError.description];
    }
}

- (void)checkforAPIErrors:(NSArray * _Nullable)apiErrors {
    if (!apiErrors || apiErrors.count == 0) {
        return;
    }
    
    for (NSDictionary *apiError in apiErrors) {
        /* BitcoinDE
         Name       Required	Type	Value	Notes
         message	true        string	--      Infotext
         code       true        string	--      Fehlercode
         field      false       string	--      Feld, auf den sich der Fehler bezieht.
         */
        
        NSString *message = [apiError objectForKey:APIError_BitcoinDE_MessageKey];
        NSString *code    = [apiError objectForKey:APIError_BitcoinDE_CodeKey];
        NSString *field   = [apiError objectForKey:APIError_BitcoinDE_FieldKey];
        
        // api error code
        NSInteger apiErrorCode = code.integerValue;
        self.apiErrorCode = apiErrorCode;
        
        NSString *errorDescription = [NSString stringWithFormat:@"%@ - %@", code, message];
        if (field) {
            NSString *fieldString = [NSString stringWithFormat:@" (%@)", field];
            errorDescription = [errorDescription stringByAppendingString:fieldString];
        }
        
        [self appendErrorDescripton:errorDescription];
    }
}

- (void)appendErrorDescripton:(NSString * _Nullable)errorDescripton {
    if (!errorDescripton) {
        return;
    }
    
    if (self.errorMessage) {
        NSString *errorDescriptionToAppend = [NSString stringWithFormat:@"\n%@", errorDescripton];
        self.errorMessage = [self.errorMessage stringByAppendingString:errorDescriptionToAppend];
    }
    else {
        self.errorMessage = errorDescripton;
        self.hasError = YES;
    }
}

- (NSString *)description {
    NSString *serverRequestTitleString = [NSString stringWithFormat:@"ServerRequest: %@", self.serverRequestTitle];
    NSString *hasErrorString = [NSString stringWithFormat:@"hasError: %@", self.hasError ? @"YES" : @"NO"];
    NSString *description = [NSString stringWithFormat:@"\n%@\n%@\n%@/napiError: %ti"
                             , serverRequestTitleString
                             , hasErrorString,
                             self.errorMessage,
                             self.apiErrorCode];
    
    return description;
}

#pragma mark - Private methods
- (NSString * _Nullable)errorDescriptionForURLResponseStatusCode:(NSUInteger)responseErrorCode {
    if (responseErrorCode == 0//) {
        || responseErrorCode == 200
        || responseErrorCode == 201) {
        return nil;
    }
    
    NSString *errorDescription = @"errorDescription";
    switch (responseErrorCode) {
        case 200:
            errorDescription = @"200 - GET-/ DELETE-Request wurde erfolgreich durchgeführt";
            break;
        case 201:
            errorDescription = @"201 - POST-Request wurde erfolgreich durchgeführt und die neue Ressource angelegt (z.B. Trade)";
            break;
        case 400:
            errorDescription = @"400 - Bad Request";
            break;
        case 403:
            errorDescription = @"403 - Forbidden";
            break;
        case 404:
            errorDescription = @"404 - Angefragte Entität konnte nicht gefunden werden";
            break;
        case 422:
            errorDescription = @"422 - Anfrage konnte nicht erfolgreich durchgeführt werden.";
            break;
        case 429:
            errorDescription = @"429 - Too many requests";
            break;
        default:
            errorDescription = @"Unknown URLResponse error";
            break;
    }
    
    return errorDescription;
}

- (NSString * _Nullable)errorDescriptionForAPIErrorCode:(NSUInteger)apiErrorCode {
    if (apiErrorCode == 0) {
        return nil;
    }
    
    NSString *errorDescription = @"errorDescription";
    switch (apiErrorCode) {
        case 1:
            errorDescription = @"1 - Missing header";
            break;
        case 2:
            errorDescription = @"2 - Inactive api key";
            break;
        case 3:
            errorDescription = @"3 - Invalid api key";
            break;
        case 4:
            errorDescription = @"4 - Invalid nonce";
            break;
        case 5:
            errorDescription = @"5 - Invalid signature";
            break;
        case 6:
            errorDescription = @"6 - Insufficient credits";
            break;
        case 7:
            errorDescription = @"7 - Invalid route";
            break;
        case 8:
            errorDescription = @"8 - Unkown api action";
            break;
        case 9:
            errorDescription = @"9 - Additional agreement not accepted";
            break;
        case 10:
            errorDescription = @"10 - No 2 factor authentication";
            break;
        case 11:
            errorDescription = @"11 - No beta group user";
            break;
        case 12:
            errorDescription = @"12 - Technical reason";
            break;
        case 13:
            errorDescription = @"13 - Trading api currently unavailable";
            break;
        case 14:
            errorDescription = @"14 - No action permission for api key";
            break;
        case 15:
            errorDescription = @"15 - Missing post parameter";
            break;
        case 16:
            errorDescription = @"16 - Missing get parameter";
            break;
        case 17:
            errorDescription = @"17 - Invalid number";
            break;
        case 18:
            errorDescription = @"18 - Number too low";
            break;
        case 19:
            errorDescription = @"19 - Number too big";
            break;
        case 20:
            errorDescription = @"20 - Too many decimal places";
            break;
        case 21:
            errorDescription = @"21 - Invalid boolean value";
            break;
        case 22:
            errorDescription = @"22 - Forbidden parameter value";
            break;
        case 23:
            errorDescription = @"23 - Invalid min amount";
            break;
        case 24:
            errorDescription = @"24 - Invalid datetime format";
            break;
        case 25:
            errorDescription = @"25 - Date lower than min date";
            break;
        case 26:
            errorDescription = @"26 - Invalid value";
            break;
        case 27:
            errorDescription = @"27 - Forbidden value for get parameter";
            break;
        case 28:
            errorDescription = @"28 - Forbidden value for post parameter";
            break;
        case 29:
            errorDescription = @"29 - Express trade temporarily not available";
            break;
        case 30:
            errorDescription = @"30 - End datetime younger than start datetime";
            break;
        case 31:
            errorDescription = @"31 - Page greater than last page";
            break;
        case 32:
            errorDescription = @"32 - Api key banned";
            break;
        case 33:
            errorDescription = @"33 - IP address banned";
            break;
        case 44:
            errorDescription = @"44 - No kyc full";
            break;
        case 50:
            errorDescription = @"50 - Order not found";
            break;
        case 51:
            errorDescription = @"51 - Order not possible";
            break;
        case 52:
            errorDescription = @"52 - Invalid order type";
            break;
        case 53:
            errorDescription = @"53 - Payment option not allowed for type buy";
            break;
        case 54:
            errorDescription = @"54 - Cancellation not allowed";
            break;
        case 55:
            errorDescription = @"55 - Trading suspended";
            break;
        case 56:
            errorDescription = @"56 - Express trade not possible";
            break;
        case 57:
            errorDescription = @"57 - No bank account";
            break;
        case 70:
            errorDescription = @"70 - No active reservation";
            break;
        case 71:
            errorDescription = @"71 - Express trade not allowed";
            break;
        case 72:
            errorDescription = @"72 - Express trade failure temporary";
            break;
        case 73:
            errorDescription = @"73 - Express trade failure";
            break;
        case 74:
            errorDescription = @"74 - Invalid trade state";
            break;
        case 75:
            errorDescription = @"75 - Trade not found";
            break;
        default:
            errorDescription = @"Unknown API error";
            break;
    }
    
    return errorDescription;
}

@end

