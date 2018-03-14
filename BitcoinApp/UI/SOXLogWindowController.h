//
//  SOXErrorWindowController.h
//  mac BitcoinApp
//
//  Created by Peter Hauke on 04.10.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SOXErrorMessage_BitcoinDE;

static NSString *SOXLogWindowControllerNibKey = @"SOXLogWindowController";

@interface SOXLogWindowController : NSWindowController

- (instancetype)initWithWindowNibName:(NSNibName)windowNibName windowTitle:(NSString *)windowTitle;

- (void)showErrorMessage:(SOXErrorMessage_BitcoinDE *)errorMessage;
- (void)showMessage:(NSString *)messageString;

@end
