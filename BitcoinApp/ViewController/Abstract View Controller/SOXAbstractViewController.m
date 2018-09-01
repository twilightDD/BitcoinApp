//
//  SOXAbstractViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 05.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXAbstractViewController.h"

#import "SOXLogWindowController.h"
#import "MacAppDelegate.h"

@interface SOXAbstractViewController ()

@property (weak) IBOutlet NSView *spinningBackgroundView;
@property (weak) IBOutlet NSProgressIndicator *circularProgressIndicator;

@end

@implementation SOXAbstractViewController

- (void)viewWillAppear {
    [super viewWillAppear];
    self.spinningBackgroundView.hidden = YES;
    self.spinningBackgroundView.layer.backgroundColor = [NSColor colorWithCalibratedRed:0
                                                                                  green:0
                                                                                   blue:0
                                                                                  alpha:0.1].CGColor;
}
#pragma mark - Spinning Wheel

- (void)enableSpinningWheel {
    self.spinningBackgroundView.hidden = NO;
    [self.circularProgressIndicator startAnimation:nil];
}

- (void)disableSpinningWheel {
    self.spinningBackgroundView.hidden = YES;
    [self.circularProgressIndicator stopAnimation:nil];
}



#pragma mark - SOXMarketCoreServerRequestProtocol
- (void)answerOfServerRequest:(NSDictionary *)answerOfServerRequest {
    NSAssert(NO, @"Must be implemented in subClass");
}

- (void)presentErrorWithErrorDictionary:(SOXErrorMessage_BitcoinDE *)errorMessage {
    MacAppDelegate* appDelegate = (MacAppDelegate*)[[NSApplication sharedApplication] delegate];
    SOXLogWindowController *errorWindowController = appDelegate.errorWindowController;
    [errorWindowController performSelectorOnMainThread:@selector(presentErrorMessage:)
                                            withObject:errorMessage
                                         waitUntilDone:NO];
}

@end
