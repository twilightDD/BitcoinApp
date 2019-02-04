//
//  SOXErrorWindowController.m
//  mac BitcoinApp
//
//  Created by Peter Hauke on 04.10.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXLogWindowController.h"

#import "SOXErrorMessage_BitcoinDE.h"

#import "SOXFormatters.h"

#pragma mark - Interface
@interface SOXLogWindowController ()

#pragma mark | IBOutlets
@property (unsafe_unretained) IBOutlet NSTextView *logTextView;
@property (weak) IBOutlet NSScrollView *logScrollView;
@property (weak) IBOutlet NSButton *clearTextViewButton;

#pragma mark | Properties

@property (strong, nonatomic) NSString *logString;

@end

#pragma mark - Implementation
@implementation SOXLogWindowController

#pragma mark Init&Co.
- (void)windowDidLoad {
    [super windowDidLoad];
    self.logString = @"";
}


- (void)showErrorMessage:(SOXErrorMessage_BitcoinDE *)errorMessage {
    //    if (!self.window.isVisible) {
    [self showWindow:nil];
    //    }
    NSString *lineWithDate = [NSString stringWithFormat:@"%@", [SOXFormatters shortDateLongTimeStringForDate:[NSDate date]]];

    self.logString = [self.logString stringByAppendingString:@"\n-----------\n"];
    self.logString = [self.logString stringByAppendingString:lineWithDate];
    self.logString = [self.logString stringByAppendingString:@" - serverRequestTitle: "];
    self.logString = [self.logString stringByAppendingString:errorMessage.serverRequestTitle];
    self.logString = [self.logString stringByAppendingString:@"\n"];
    self.logString = [self.logString stringByAppendingString:errorMessage.errorMessage];

    [self updateTextView];
}

- (void)showMessage:(NSString *)messageString {
    [self showWindow:nil];

    self.logString = [self.logString stringByAppendingString:@"\n-----------\n"];

    NSString *lineWithDate = [NSString stringWithFormat:@"%@", [SOXFormatters shortDateLongTimeStringForDate:[NSDate date]]];
    self.logString         = [self.logString stringByAppendingString:lineWithDate];

    self.logString = [self.logString stringByAppendingString:messageString];

    [self updateTextView];
}

- (void)presentErrorMessage:(SOXErrorMessage_BitcoinDE *)errorMessage {
    [self showErrorMessage:errorMessage];
    // we don't have any valid api/secret pair in keychain => don't send anything
    // User beschimpfen

    NSAlert *alert        = [[NSAlert alloc] init];
    alert.messageText     = errorMessage.serverRequestTitle;
    alert.informativeText = errorMessage.errorMessage;
    alert.alertStyle      = NSAlertStyleCritical;
    [alert runModal];
}

#pragma mark - Private methods
- (void)updateTextView {
    self.logTextView.string = self.logString;
    NSPoint pt              = NSMakePoint(0.0, [[self.logScrollView documentView]
                                      bounds]
                                      .size.height);
    [self.logScrollView.documentView scrollPoint:pt];
}


#pragma mark - Action methods
- (IBAction)clearTextViewAction:(NSButton *)sender {
    self.logString = @"";
    [self updateTextView];
}

- (IBAction)saveLogAction:(NSButton *)sender {

    NSString *desktopDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES) objectAtIndex:0];

    NSString *dateString            = [[NSDate date] description];
    NSString *fileName              = [self.window.title stringByAppendingString:dateString];
    NSString *filePath              = [desktopDirectoryPath stringByAppendingPathComponent:fileName];
    NSString *filePathWithExtension = [filePath stringByAppendingPathExtension:@"txt"];

    NSError *writeError = nil;
    [self.logString writeToFile:filePathWithExtension
                     atomically:YES
                       encoding:NSStringEncodingConversionAllowLossy
                          error:&writeError];
    if (writeError) {
        NSLog(@"WRITE ERROR %@", writeError.localizedDescription);
    }
}


@end
