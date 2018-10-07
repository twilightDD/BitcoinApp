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

@property (strong, nonatomic) NSArray *countryButtons;

@end

@implementation SOXFilterOrderViewController

- (void)viewWillAppear {
    [super viewWillAppear];



    NSArray <NSString *> *supportedCountryCodes = [SOXPreferenceCenter supportedCountryCodes];
    NSSet <NSString *> *activeCountryCodes = [SOXPreferenceCenter activeCountryCodesforOrderType:self.orderType
                                                                                    currencyType:self.currencyType];

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
            [countryButtons addObject:countryButton];
        }
        [self.view addSubview:countryButton];

    }];

    self.countryButtons = countryButtons.copy;
}


- (NSArray <NSString *> *)selectedCountryCodes {
    NSArray <NSString *> *supportedCountryCodes = [SOXPreferenceCenter supportedCountryCodes];

    NSMutableArray *selectedCountryCodes = [NSMutableArray array];
    [supportedCountryCodes enumerateObjectsUsingBlock:^(NSString * _Nonnull countryCode
                                                        , NSUInteger idx
                                                        , BOOL * _Nonnull stop) {
        NSButton *countryButton = [self.countryButtons objectAtIndex:idx];
        if (countryButton.state == NSControlStateValueOn) {
            [selectedCountryCodes addObject:countryCode];
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

#pragma mark - Inform delegate
- (void)informDelegateForKey:(NSString *)key withObject:(id)object {
    NSParameterAssert(key);
    NSParameterAssert(object);

    [self.delegate filterSelectionChangedForKey:key
                                     withObject:object];
}

@end
