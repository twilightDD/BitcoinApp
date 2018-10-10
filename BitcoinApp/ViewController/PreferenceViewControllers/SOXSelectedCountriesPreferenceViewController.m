//
//  SOXSelectedCountriesPreferenceViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 08.10.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXSelectedCountriesPreferenceViewController.h"

#import "SOXPreferenceCenter.h"

@class SOXView;

#pragma mark - Interface
@interface SOXSelectedCountriesPreferenceViewController ()

#pragma mark | IBOutlets
@property (strong) IBOutlet NSTextField *headlineTextField;
@property (strong) IBOutlet SOXView *countrySelectionView;

@property (strong) IBOutlet NSButton *enableAllButton;
@property (strong) IBOutlet NSButton *enableDefaultsButton;
@property (strong) IBOutlet NSButton *disableAllButton;


#pragma mark | Properties
@property (strong, nonatomic) NSArray <NSButton *> *countryButtons;

@end

#pragma mark - Implementation
@implementation SOXSelectedCountriesPreferenceViewController

#pragma mark Init & Co.
- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
}


#pragma mark - Private Methods
- (void)setupUI {
    self.headlineTextField.stringValue = @"Einstellungen für alle OrderViews";

    [self setupCountryButtons];
}

- (void)setupCountryButtons {
    NSArray <NSString *> *supportedCountryCodes = [SOXPreferenceCenter supportedCountryCodes];
    NSArray <NSString *> *activeCountryCodes = [SOXPreferenceCenter activeCountryCodes];

    __block NSMutableArray *countryButtons = [NSMutableArray array];

    __block CGFloat basicX = 20;
    CGFloat basicY = 20;
    CGFloat deltaX = 58;
    CGFloat deltaY = 24;
    CGFloat height = 16;
    CGFloat width = 50;

    __block CGFloat currentX = 0;
    __block CGFloat currentY = 0;
    [supportedCountryCodes enumerateObjectsUsingBlock:^(NSString * _Nonnull countryCode
                                                        , NSUInteger idx
                                                        , BOOL * _Nonnull stop) {
        NSButton *countryButton = [NSButton checkboxWithTitle:countryCode
                                                       target:nil
                                                       action:nil];
        countryButton.tag = idx;
        countryButton.state = [activeCountryCodes containsObject:countryCode] ? NSControlStateValueOn : NSControlStateValueOff;
        countryButton.target = self;
        SEL countryButtonActionSelector = NSSelectorFromString(@"countryButtonAction:");
        countryButton.action = countryButtonActionSelector;

        // set position
        {
            if (idx % 10 == 0) {
                currentX = currentX + width;
                currentY = basicY;
            }
            currentY = currentY + deltaY;
            countryButton.frame = CGRectMake(currentX, currentY, width, height);
        }
        [self.view addSubview:countryButton];
        [countryButtons addObject:countryButton];
    }];

    self.countryButtons = countryButtons.copy;
}

#pragma mark - Private methods
- (NSArray <NSString *> *)selectedCountryCodes {
    NSArray <NSString *> *supportedCountryCodes = [SOXPreferenceCenter supportedCountryCodes];

    __block NSMutableArray *selectedCountryCodes = [NSMutableArray array];
    [self.countryButtons enumerateObjectsUsingBlock:^(NSButton * _Nonnull button, NSUInteger idx, BOOL * _Nonnull stop) {
        if (button.state == NSControlStateValueOn) {
            [selectedCountryCodes addObject:[supportedCountryCodes objectAtIndex:idx]];
        }
    }];

    return selectedCountryCodes.copy;
}

- (void)updateUserDefaults {
    NSArray *selectedCountryCodes = [self selectedCountryCodes];
    [SOXPreferenceCenter setActiveCountryCodes:selectedCountryCodes];
}

#pragma mark - Action methods
- (IBAction)enableAllButtonAction:(NSButton *)sender {
    for (NSButton *countyButton in self.countryButtons) {
        countyButton.state = NSControlStateValueOn;
    }
    [self updateUserDefaults];
}

- (IBAction)enableDefaultButtonAction:(NSButton *)sender {
    // disable all buttons
    for (NSButton *countyButton in self.countryButtons) {
        countyButton.state = NSControlStateValueOff;
    }

    NSArray <NSString *> *supportedCountryCodes = [SOXPreferenceCenter supportedCountryCodes];
    NSArray <NSString *> *defaultTradingCountries = [SOXPreferenceCenter defaultCountryCodes];
    for (NSString *defaultTradingCountry in defaultTradingCountries) {
        NSUInteger idx = [supportedCountryCodes indexOfObject:defaultTradingCountry];
        NSButton *countryButton = [self.countryButtons objectAtIndex:idx];
        countryButton.state = NSControlStateValueOn;
    }
    [self updateUserDefaults];
}

- (IBAction)disableAllButtonAction:(NSButton *)sender {
    for (NSButton *countyButton in self.countryButtons) {
        countyButton.state = NSControlStateValueOff;
    }
    [self updateUserDefaults];
}

- (void)countryButtonAction:(NSButton *)button {
    [self updateUserDefaults];
}


#pragma mark - MASPreferencesViewController
- (NSString *)toolbarItemLabel {
    return @"Selected countries";
}

- (NSImage *)toolbarItemImage {
    NSImage *image = [NSImage imageNamed:@"countries"];
    return image;
}
@end
