//
//  SOXErrorWindowController.m
//  mac BitcoinApp
//
//  Created by Peter Hauke on 04.10.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXErrorWindowController.h"

#import "SOXErrorMessage_BitcoinDE.h"

#import "SOXFormatters.h"

#pragma mark - Interface
@interface SOXErrorWindowController ()

#pragma mark | IBOutlets
@property (unsafe_unretained) IBOutlet NSTextView  *errorTextView;
@property (weak) IBOutlet NSScrollView *errorTextScrollView;
@property (weak) IBOutlet NSButton *clearTextViewButton;

#pragma mark | Properties

@property (strong, nonatomic) NSString *errorLogString;

@end

#pragma mark - Implementation
@implementation SOXErrorWindowController

#pragma mark Init&Co.
- (void)windowDidLoad {
    [super windowDidLoad];
    self.errorLogString = @"";
}

#pragma mark - Public methods
- (void)showErrorMessage:(SOXErrorMessage_BitcoinDE *)errorMessage {
//    if (!self.window.isVisible) {
        [self showWindow:nil];
//    }
    NSString *lineWithDate = [NSString stringWithFormat:@"%@"
                              , [SOXFormatters shortDateLongTimeStringForDate:[NSDate date]]];

    self.errorLogString = [self.errorLogString stringByAppendingString:@"\n-----------\n"];
    self.errorLogString = [self.errorLogString stringByAppendingString:lineWithDate];
    self.errorLogString = [self.errorLogString stringByAppendingString:@" - serverRequestTitle: "];
    self.errorLogString = [self.errorLogString stringByAppendingString:errorMessage.serverRequestTitle];
    self.errorLogString = [self.errorLogString stringByAppendingString:@"\n"];
    self.errorLogString = [self.errorLogString stringByAppendingString:errorMessage.errorMessage];

    [self updateErrorTextView];
}

#pragma mark - Private methods
- (void)updateErrorTextView {
    self.errorTextView.string = self.errorLogString;
    NSPoint pt = NSMakePoint(0.0, [[self.errorTextScrollView documentView]
                                   bounds].size.height);
    [self.errorTextScrollView.documentView scrollPoint:pt];
}


#pragma mark - Action methods
- (IBAction)clearErrorTextViewAction:(NSButton *)sender {
    self.errorLogString = @"";
    [self updateErrorTextView];
}

@end
