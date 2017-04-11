//
//  SOXAutomaticTradingViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 11.04.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXAutomaticTradingViewController.h"



#pragma mark - Interface
@interface SOXAutomaticTradingViewController ()

#pragma mark IBOutlets
@property (weak) IBOutlet NSButton *runAutomaticButton;
@property (weak) IBOutlet NSTextField *statusTextField;

@property (weak) IBOutlet NSView *automaticBackgroundView;

@property (weak) IBOutlet NSView *maxInvestmentDescriptionTextField;
@property (weak) IBOutlet NSView *automaticInvestmentTextField;
@property (weak) IBOutlet NSButton *useMaxReservationButton;
@property (weak) IBOutlet NSTextField *minInterestDescriptionTextField;
@property (weak) IBOutlet NSTextField *minInvestmentTextField;
@property (weak) IBOutlet NSButton *startAutomaticButton;

@property (weak) IBOutlet NSTextField *logDescriptionTextField;
@property (unsafe_unretained) IBOutlet NSTextView *logTextView;
@property (weak) IBOutlet NSButton *clearLogButton;


#pragma mark Properties

@end

@implementation SOXAutomaticTradingViewController

#pragma mark - Init&Co.
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

#pragma mark - Public methods

#pragma mark - Private methods

#pragma mark - Action methods
- (IBAction)useMaxReservation:(NSButton *)sender {
}


- (IBAction)runAutomaticAction:(NSButton *)sender {
}

- (IBAction)clearLogAction:(NSButton *)sender {
}


@end
