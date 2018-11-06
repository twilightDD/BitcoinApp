//
//  SOXAbstractViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 05.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXAbstractViewController.h"

#import "SOXAbstractViewController_Private.h"

#import "SOXLogWindowController.h"
#import "MacAppDelegate.h"

@interface SOXAbstractViewController ()

#pragma mark | IBOutlets
@property (weak) IBOutlet NSView *spinningBackgroundView;
@property (weak) IBOutlet NSProgressIndicator *circularProgressIndicator;

@property (strong) IBOutlet NSView *noDataBackgroundView;

#pragma mark | Properties
@property (strong, nonatomic) id apiKeysAndSecretsDidChangeObserver;

@end

@implementation SOXAbstractViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    for (NSTableColumn *column in self.tableView.tableColumns) {
        NSFont *font = [NSFont systemFontOfSize:[NSFont systemFontSize]];

        if ([NSFont respondsToSelector:@selector(monospacedDigitSystemFontOfSize:weight:)]) {
            font = [NSFont monospacedDigitSystemFontOfSize:[NSFont systemFontSize]
                                                    weight:NSFontWeightRegular];
        }

        [column.dataCell setFont:font];
    }

    weakify(self);
    self.apiKeysAndSecretsDidChangeObserver =
    [[NSNotificationCenter defaultCenter] addObserverForName:SOXAPIKeysAndSecretsDidChangeNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      strongify(self);
                                                      self.arrayControllerDatas = [NSMutableArray array];
                                                      [self.arrayController rearrangeObjects];
                                                  }];
}

- (void)viewWillAppear {
    [super viewWillAppear];
    self.spinningBackgroundView.hidden = YES;
    self.spinningBackgroundView.layer.backgroundColor = [NSColor colorWithCalibratedRed:0
                                                                                  green:0
                                                                                   blue:0
                                                                                  alpha:0.1].CGColor;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.apiKeysAndSecretsDidChangeObserver];
}

#pragma mark - Custom Views
- (void)enableSpinningWheel {
    self.spinningBackgroundView.hidden = NO;
    [self.circularProgressIndicator startAnimation:nil];
}

- (void)disableSpinningWheel {
    self.spinningBackgroundView.hidden = YES;
    [self.circularProgressIndicator stopAnimation:nil];
}

- (void)presentNoDataView {
    self.noDataBackgroundView.hidden = NO;
}

- (void)hideNoDataView {
    self.noDataBackgroundView.hidden = YES;
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
