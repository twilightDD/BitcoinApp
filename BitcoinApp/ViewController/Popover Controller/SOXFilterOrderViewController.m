//
//  SOXFilterOrderViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 26.09.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXFilterOrderViewController.h"

#import "SOXPreferenceCenter.h"

@interface SOXFilterOrderViewController ()
@property (strong) IBOutlet NSButton *noSepaButton;
@property (strong) IBOutlet NSBox *selectCountriesBox;

@property (strong, nonatomic) NSArray <NSButton *> *countryButtons;

@end

@implementation SOXFilterOrderViewController

- (void)viewWillAppear {
    [super viewWillAppear];

    [self setupNoSepaButton];
    [self setupCountryButtons];
}

- (void)setupNoSepaButton {
    self.noSepaButton.title = @"No SEPA";
    NSControlStateValue noSEPAButtonControlState = [SOXPreferenceCenter sepaPaymentOptionStateForOrderType:self.orderType
                                                                                              currencyType:self.currencyType];
    self.noSepaButton.state = noSEPAButtonControlState;
}

- (void)setupCountryButtons {
    NSArray <NSString *> *supportedCountryCodes = [SOXPreferenceCenter supportedCountryCodes];
    NSArray <NSString *> *supportedCountryNames = [SOXPreferenceCenter supportedCountryNames];
    NSArray <NSString *> *activeCountryCodes = [SOXPreferenceCenter activeCountryCodesforOrderType:self.orderType
                                                                                      currencyType:self.currencyType];

    __block NSMutableArray *countryButtons = [NSMutableArray array];

    CGFloat basicX = 20;
    CGFloat basicY = -10;
    CGFloat deltaX = 58;
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
        countryButton.state = [activeCountryCodes containsObject:countryCode] ? NSControlStateValueOn : NSControlStateValueOff;
        countryButton.target = self;
        SEL countryButtonActionSelector = NSSelectorFromString(@"countryButtonAction:");
        countryButton.action = countryButtonActionSelector;
        
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

        [countryButton needsLayout];
        [self.selectCountriesBox addSubview:countryButton];

        [countryButtons addObject:countryButton];

    }];

    [self.selectCountriesBox needsLayout];
    self.countryButtons = countryButtons.copy;
}

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

#pragma mark - Action methods
- (void)countryButtonAction:(NSButton *)button {
    NSArray *selectedCountryCodes = [self selectedCountryCodes];
    [self informDelegateForKey:FilterOrderViewSelectedCountriesKey
                    withObject:selectedCountryCodes];
    
    // Update userDefaults
    NSString *countryCode = [[SOXPreferenceCenter supportedCountryCodes] objectAtIndex:button.tag];
    [SOXPreferenceCenter toggleActiveCountryCode:countryCode
                                    forOrderType:self.orderType
                                    currencyType:self.currencyType];
}

- (IBAction)noSepaButtonAction:(NSButton *)button {
    NSControlStateValue state = button.state;

    [self informDelegateForKey:FilterOrderViewNoSepaKey
                    withObject:@(state)];

    // Update user defalts
    [SOXPreferenceCenter setSepaPaymentFilterOption:state
                                       forOrderType:self.orderType
                                       currencyType:self.currencyType];
}

#pragma mark - Inform delegate
- (void)informDelegateForKey:(NSString *)key withObject:(id)object {
    NSParameterAssert(key);
    NSParameterAssert(object);
    
    [self.delegate filterSelectionChangedForKey:key
                                     withObject:object];
}

@end
