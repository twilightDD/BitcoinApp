//
//  SOXWindowController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 27.06.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXWindowController.h"

@interface SOXWindowController ()

@end

@implementation SOXWindowController

#pragma mark - Public methods
- (instancetype)initWithWindowNibName:(NSNibName)windowNibName windowTitle:(NSString *)windowTitle {
    self = [super initWithWindowNibName:windowNibName];

    self.window.title = windowTitle;
    [self.window setIsVisible:NO];

    return self;
}

@end
