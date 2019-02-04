//
//  SOXPagingViewController.h
//  BitcoinApp
//
//  Created by Peter Hauke on 26.10.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SOXMarket_BitcoinDE_DefTypes.h"

@class SOXPagingAbstractViewController;
@class SOXPage_BitcoinDE_Data;

@protocol SOXPagingViewControllerProtocol
- (void)pagingViewControllerDidLoad;
- (void)popupButtonAction:(NSPopUpButton *)sender;

- (void)loadAllTradeDatas;
- (void)loadMoreTradeDatas;
- (void)fetchDatas;

- (void)resetTradeDatas;

@optional
- (void)exportButtonPressed;
- (void)changeOrderButtonPressed;
- (void)removeOrderButtonPressed;

@end

@interface SOXPagingViewController : NSViewController

#pragma mark | IBOutlets
@property (strong, readonly) IBOutlet NSPopUpButton *firstSelectionPopUpButton;
@property (strong, readonly) IBOutlet NSPopUpButton *secondSelectionPopUpButton;
@property (strong, readonly) IBOutlet NSPopUpButton *thirdSelectionPopUpButton;
@property (strong, readonly) IBOutlet NSButton *changeOrderButton;
@property (strong, readonly) IBOutlet NSButton *removeOrderButton;

#pragma mark | Properties
@property (weak) SOXPagingAbstractViewController<SOXPagingViewControllerProtocol> *delegate;

@property (strong, nonatomic, readonly) NSDate *selectedStartDate;
@property (strong, nonatomic, readonly) NSDate *selectedEndDate;

#pragma mark | Public methods
- (void)loadingPagingButton;
- (void)resetPagingButtons;
- (void)updatePagingButtonsWithPageData:(SOXPage_BitcoinDE_Data *)pageData
                  whileLoadingMorePages:(BOOL)whileLoadingMorePages;

@end
