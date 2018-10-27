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

@protocol SOXPagingViewControllerProtocol
- (void)popupButtonAction:(NSPopUpButton *)sender;

- (void)loadAllTradeDatas;
- (void)loadMoreTradeDatas;
- (void)fetchDatas;
- (void)startExport;

- (void)resetTradeDatas;
- (void)loadNextPage;

- (void)presentNoDataView;
- (void)hideNoDataView;
- (void)enableSpinningWheel;
- (void)disableSpinningWheel;

@end

@interface SOXPagingViewController : NSViewController

@property (strong, readonly) IBOutlet NSPopUpButton *firstSelectionPopUpButton;
@property (strong, readonly) IBOutlet NSPopUpButton *secondSelectionPopUpButton;
@property (strong, readonly) IBOutlet NSPopUpButton *thirdSelectionPopUpButton;

@property (weak) SOXPagingAbstractViewController <SOXPagingViewControllerProtocol> *delegate;

@property (strong, nonatomic, readonly) NSDate *selectedStartDate;
@property (strong, nonatomic, readonly) NSDate *selectedEndDate;

- (void)resetPagingButtons;
- (void)updatePagingButtons;
- (void)updatePagingButtons:(NSDictionary *)payload;

//- (void)updatePagingButtons:(NSDictionary *)payloadDictionary;
//- (void)resetPagingButtons;
//- (void)resetTradeDatas; // TODO: Rename

@end
