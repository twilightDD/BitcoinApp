//
//  SOXErrorWindowController.h
//  mac BitcoinApp
//
//  Created by Peter Hauke on 04.10.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXWindowController.h"

@class SOXErrorMessage_BitcoinDE;

static NSString *SOXLogWindowControllerNibKey = @"SOXLogWindowController";

@interface SOXLogWindowController : SOXWindowController



- (void)showErrorMessage:(SOXErrorMessage_BitcoinDE *)errorMessage;
- (void)showMessage:(NSString *)messageString;

- (void)presentErrorMessage:(SOXErrorMessage_BitcoinDE *)errorMessage;

@end
