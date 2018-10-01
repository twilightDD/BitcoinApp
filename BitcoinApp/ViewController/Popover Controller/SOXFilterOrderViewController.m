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

        if ([activeCountryCodes containsObject:countryCode]) {
            countryButton.state = NSControlStateValueOn;
        }
        else {
            countryButton.state = NSControlStateValueOff;
        }

        NSLog(@" idx: %tu => rest %tu",idx,  idx % 10);

        if (idx % 10 == 0) {
            // nächste Spalte
            currentX = currentX + width;
            currentY = basicY;
        }

        currentY = currentY + deltaY;

        countryButton.frame = CGRectMake(currentX, currentY, width, height);

        [countryButtons addObject:countryButton];

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
@end
