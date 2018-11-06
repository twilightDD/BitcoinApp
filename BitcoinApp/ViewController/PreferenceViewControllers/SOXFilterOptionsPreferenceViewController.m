//
//  SOXFilterOptionsPreferenceViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 08.10.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXFilterOptionsPreferenceViewController.h"

#import "SOXPreferenceCenter.h"
#import "SOXView.h"

#pragma mark - Interface
@interface SOXFilterOptionsPreferenceViewController ()

#pragma mark | IBOutlets
@property (strong) IBOutlet NSTextField *headlineTextField;

// Countries
@property (strong) IBOutlet NSBox *countrySelectionBox;
@property (strong) IBOutlet SOXView *countrySelectionView;
@property (strong) IBOutlet NSButton *enableAllButton;
@property (strong) IBOutlet NSButton *enableDefaultsButton;
@property (strong) IBOutlet NSButton *disableAllButton;

// Payment Option
@property (strong) IBOutlet NSButton *noSepaButton;

#pragma mark | Properties
@property (strong, nonatomic) NSArray <NSButton *> *countryButtons;

@end

#pragma mark - Implementation
@implementation SOXFilterOptionsPreferenceViewController

#pragma mark Init & Co.
- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
}

#pragma mark - Public Class Methods
+ (NSArray <NSButton *> *)addCountryButtonsToView:(NSView *)view {
    __block NSMutableArray *countryButtons = [NSMutableArray array];

    NSArray <NSString *> *supportedCountryCodes = [SOXPreferenceCenter supportedCountryCodes];
    NSArray <NSString *> *supportedCountryNames = [SOXPreferenceCenter supportedCountryNames];


    CGFloat basicX = 20;
    CGFloat basicY = -10;
    CGFloat deltaY = 24;
    CGFloat height = 16;
    CGFloat width = 190;

    __block CGFloat currentX = basicX;
    __block CGFloat currentY = basicY;

    [supportedCountryCodes enumerateObjectsUsingBlock:^(NSString * _Nonnull countryCode
                                                        , NSUInteger idx
                                                        , BOOL * _Nonnull stop) {
        NSString *countryName = [supportedCountryNames objectAtIndex:idx];
        NSButton *countryButton = [NSButton checkboxWithTitle:countryName
                                                       target:nil
                                                       action:nil];
        countryButton.tag = idx;



        // set position
        {
            if (idx % 10 == 0
                && idx != 0) {
                currentX = currentX + width;
                currentY = basicY;
            }
            currentY = currentY + deltaY;
            countryButton.frame = CGRectMake(currentX, currentY, width, height);
        }
        [view addSubview:countryButton];

        [countryButtons addObject:countryButton];

    }];

    return [countryButtons copy];
}

#pragma mark - Private Methods
- (void)setupUI {
    self.headlineTextField.stringValue = @"Filter options for all Ordertables";
    self.countrySelectionBox.title = @"Show orders for countries";
    self.noSepaButton.title = @"Hide SEPA-only orders";

    [self setupCountryButtons];
    [self setupNoSepaButton];
}

- (void)setupCountryButtons {
    self.countrySelectionView.autoresizingMask = NSViewWidthSizable;

    self.countryButtons  = [SOXFilterOptionsPreferenceViewController addCountryButtonsToView:self.countrySelectionView];

    NSArray <NSString *> *supportedCountryCodes = [SOXPreferenceCenter supportedCountryCodes];
    NSArray <NSString *> *activeCountryCodes = [SOXPreferenceCenter activeCountryCodesforOrderType:self.orderType
                                                                                      currencyType:self.currencyType];
    SEL countryButtonActionSelector = NSSelectorFromString(@"countryButtonAction:");
    [self.countryButtons enumerateObjectsUsingBlock:^(NSButton * _Nonnull countryButton,
                                                      NSUInteger idx,
                                                      BOOL * _Nonnull stop) {
        NSString *countryCode = [supportedCountryCodes objectAtIndex:idx];
        countryButton.state = [activeCountryCodes containsObject:countryCode] ? NSControlStateValueOn : NSControlStateValueOff;
        countryButton.target = self;
        countryButton.action = countryButtonActionSelector;
    }];
}

- (void)setupNoSepaButton {
    NSControlStateValue noSepaButtonState = [SOXPreferenceCenter sepaPaymentOptionState];
    self.noSepaButton.state = noSepaButtonState;
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

- (void)updateSelectedCountriesUserDefaults {
    NSArray *selectedCountryCodes = [self selectedCountryCodes];

    [self informDelegateForKey:FilterOrderViewSelectedCountriesKey
                    withObject:selectedCountryCodes];

    [SOXPreferenceCenter setActiveCountryCodes:selectedCountryCodes
                                  forOrderType:self.orderType
                                  currencyType:self.currencyType];
}

- (void)updateShowSepaUserDefaults {
    NSControlStateValue sepaStateValue = self.noSepaButton.state;
    [SOXPreferenceCenter setSepaPaymentFilterOption:sepaStateValue
                                       forOrderType:self.orderType
                                       currencyType:self.currencyType];
}

#pragma mark - Action methods
- (IBAction)enableAllButtonAction:(NSButton *)sender {
    for (NSButton *countyButton in self.countryButtons) {
        countyButton.state = NSControlStateValueOn;
    }
    [self updateSelectedCountriesUserDefaults];
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
    [self updateSelectedCountriesUserDefaults];
}

- (IBAction)disableAllButtonAction:(NSButton *)sender {
    for (NSButton *countyButton in self.countryButtons) {
        countyButton.state = NSControlStateValueOff;
    }
    [self updateSelectedCountriesUserDefaults];
}

- (void)countryButtonAction:(NSButton *)button {
    [self updateSelectedCountriesUserDefaults];
}

- (IBAction)noSepaButtonAction:(NSButton *)button {
    NSControlStateValue state = button.state;
    [self informDelegateForKey:FilterOrderViewNoSepaKey
                    withObject:@(state)];

    [self updateShowSepaUserDefaults];
}

#pragma mark - SOXSelectedCountriesViewControllerDelegate
- (void)informDelegateForKey:(NSString *)key withObject:(id)object {
    NSParameterAssert(key);
    NSParameterAssert(object);

    [self.delegate filterSelectionChangedForKey:key
                                     withObject:object];
}

#pragma mark - MASPreferencesViewController
- (NSString *)toolbarItemLabel {
    return @"Filter Options";
}

- (NSImage *)toolbarItemImage {
    NSImage *image = [NSImage imageNamed:NSImageNameNetwork];
    return image;
}

//-(BOOL)hasResizableWidth {
//    return YES;
//}
@end
