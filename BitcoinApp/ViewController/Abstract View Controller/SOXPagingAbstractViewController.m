//
//  SOXPagingAbstractViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 27.08.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXPagingAbstractViewController.h"
#import "SOXPagingAbstractViewController_Private.h"

#import "SOXPagingViewController.h"

#import "SOXFormatters.h"

#import "SOXKeys_BitcoinDE.h"
#import "SOXPage_BitcoinDE_Data.h"

@interface SOXPagingAbstractViewController ()

#pragma mark | Properties
@property (nonatomic) BOOL shouldLoadAllTradeDatas;

@end

@implementation SOXPagingAbstractViewController
#pragma mark - Init & Co.
- (void)viewDidLoad {
    [super viewDidLoad];
    self.arrayControllerDatas = [NSMutableArray array];
}

- (void)viewWillAppear {
    [super viewWillAppear];

    if (self.arrayControllerDatas.count == 0) {
        [self resetTradeDatas];
        [self loadNextPage];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:BitcoinDE_Notification_PresentBannerInformationForCurrency
                                                        object:@(self.selectedCurrencyType)];
}

#pragma mark - Segue handling
- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender]; // call superClass!

    if ([segue.destinationController isKindOfClass:[SOXPagingViewController class]]) {
        self.pagingViewController = segue.destinationController;
        self.pagingViewController.delegate = self;
        // TODO: setup popUpButtons

    }
}

#pragma mark - Public methods
- (void)updateControllerDatasWithDataObjects:(NSArray *)dataObjects
                        andPayloadDictionary:(NSDictionary *)payloadDictionary {
    if (dataObjects.count > 0) {
        [self.arrayControllerDatas addObjectsFromArray:dataObjects];
        [self.arrayController rearrangeObjects];
    }

    SOXPage_BitcoinDE_Data *pageData = [SOXPage_BitcoinDE_Data pageDataForPayloadDictionary:payloadDictionary];
    if (pageData
        && pageData.pageCurrent == pageData.pageLast) {
        self.shouldLoadAllTradeDatas = NO;
    }

    // Load more data if needed
    if (self.shouldLoadAllTradeDatas) {
        [self loadNextPage];
    }

    // No Data View
    if (self.arrayControllerDatas.count == 0) {
        [self presentNoDataView];
    }
    else {
        [self hideNoDataView];
    }

    // Spinning Wheel View
    if (self.shouldLoadAllTradeDatas) {
        [self enableSpinningWheel];
    }
    else {
        [self disableSpinningWheel];
    }

    // Update embedded custom views
    [self.pagingViewController updatePagingButtonsWithPageData:pageData
                                         whileLoadingMorePages:self.shouldLoadAllTradeDatas];
    [self updateTradeStatistics];
}

#pragma mark Paging
- (void)loadNextPage {
    [self hideNoDataView];
    [self enableSpinningWheel];

    self.currentPage = self.currentPage + 1;

    [self.pagingViewController loadingPagingButton];

    // loading in concrete sublcass
}

- (void)resetTradeDatas {
    self.arrayControllerDatas = [NSMutableArray array];
    [self.pagingViewController resetPagingButtons];
}

#pragma mark - Manual getters
- (NSDate *)selectedStartDate {
    NSDate *selectedStartDate = self.pagingViewController.selectedStartDate;
    if (selectedStartDate == nil) {
        selectedStartDate = [NSDate date];
    }
    return selectedStartDate;
}

- (NSDate *)selectedEndDate {
    NSDate *selectedEndDate = self.pagingViewController.selectedEndDate;
    if (selectedEndDate == nil) {
        selectedEndDate = [NSDate date];
    }
    return selectedEndDate;
}

#pragma mark - Private methods
- (void)updateTradeStatistics {
    NSAssert(NO, @"Is implemented in subclass SOXStatisticsAbstractViewController");
}

#pragma mark Export
- (void)exportButtonPressed {
    // get columnTitles
    NSArray <NSString *> *columnTitles = [self.tableView.tableColumns valueForKey:@"identifier"];
    NSUInteger columnTitlesCount = columnTitles.count - 1;

    // get objects to export
    NSArray *arrayControllerObjects = self.arrayController.selectedObjects;
    if (arrayControllerObjects.count == 0) {
        arrayControllerObjects = self.arrayController.arrangedObjects;
    }
    NSUInteger dataObjectsCounts = arrayControllerObjects.count - 1;

    // first line in a csv are headers
    __block NSString *exportString = [columnTitles componentsJoinedByString:@";"];
    exportString = [exportString stringByAppendingString:@"\n"];

    // enum objects
    [arrayControllerObjects enumerateObjectsUsingBlock:^(id _Nonnull dataObj, NSUInteger dataIdx, BOOL * _Nonnull stop) {
        // enum columns
        [columnTitles enumerateObjectsUsingBlock:^(NSString * _Nonnull columnTitle, NSUInteger columnIdx, BOOL * _Nonnull stop) {
            if (columnTitle.length > 0) {
                // get value for columnTitle and convert it to string
                id valueForColumnTitle = [dataObj valueForKey:columnTitle];
                if (valueForColumnTitle) {
                    // convert to string, if needed
                    if ([valueForColumnTitle isKindOfClass:[NSNumber class]]) {
                        if ([columnTitle containsString:@"volume"]
                            || [columnTitle containsString:@"price"]
                            || [columnTitle containsString:@"Price"]
                            || [columnTitle containsString:@"Eur"]) {
                            valueForColumnTitle = [SOXFormatters currencyStringForNumber:valueForColumnTitle
                                                                            roundingMode:NSNumberFormatterRoundHalfEven];
                        }
                        else if ([columnTitle containsString:@"amount"]
                                 || [columnTitle containsString:@"BTC"]
                                 || [columnTitle containsString:@"Cash"]
                                 || [columnTitle containsString:@"Balance"]) {
                            valueForColumnTitle = [[SOXFormatters bitcoinNumberWithoutCurrencySymbolFormatter] stringFromNumber:valueForColumnTitle];
                        }
                        else {
                            valueForColumnTitle = [valueForColumnTitle stringValue];
                        }
                    }
                    else if ([valueForColumnTitle isKindOfClass:[NSDate class]]) {
                        valueForColumnTitle = [SOXFormatters shortDateShortTimeStringForDate:valueForColumnTitle];
                    }
                    exportString = [exportString stringByAppendingString:valueForColumnTitle];
                }

                // there is no separator after the last value
                if (columnIdx < columnTitlesCount) {
                    exportString = [exportString stringByAppendingString:@";"];
                }
            }
        }];

        // next line for next object
        if (dataIdx < dataObjectsCounts) {
            exportString = [exportString stringByAppendingString:@"\n"];
        }
    }];

    [self addToPasteBoard:exportString];

    [self saveString:exportString];

}

- (void)saveString:(NSString *)stringToSave {
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    savePanel.allowedFileTypes = @[@"csv"];
    savePanel.nameFieldStringValue = [self suggestedExportFileName];

    [savePanel beginWithCompletionHandler:^(NSModalResponse result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSError *error = nil;
            NSURL *selectedURL = savePanel.URL;
            [stringToSave writeToURL:selectedURL
                          atomically:YES
                            encoding:NSUTF16StringEncoding
                               error:&error];
            if (error) {
                NSLog(@"File save error %@", error.localizedDescription);
                NSAlert *alert = [NSAlert alertWithError:error];
                [alert runModal];
            }
        }
    }];
}

#pragma mark Fetch and load buttons
- (void)loadAllTradeDatas {
    self.shouldLoadAllTradeDatas = YES;
    [self loadNextPage];
}

- (void)loadMoreTradeDatas {
    self.shouldLoadAllTradeDatas = NO;
    [self loadNextPage];
}

- (void)fetchDatas {
    if (self.shouldLoadAllTradeDatas) {
        self.shouldLoadAllTradeDatas = NO;
        [self updateControllerDatasWithDataObjects:nil
                              andPayloadDictionary:nil];
        return;
    }
    self.arrayControllerDatas = [NSMutableArray array];
    self.currentPage = 0;

    [self loadNextPage];
}

#pragma - Pasteboard
- (void)addToPasteBoard:(NSString *)pasteboardString {
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];

    [pasteboard setString:pasteboardString
                  forType:NSPasteboardTypeString];
}

#pragma mark - SOXPagingViewControllerProtocol
- (void)popupButtonAction:(NSPopUpButton *)sender {
    NSAssert(NO, @"Implement in subclass");
}

- (void)pagingViewControllerDidLoad {
    NSAssert(NO, @"Implement in subclass");
}

#pragma mark - Subclass methods
- (NSString *)suggestedExportFileName {
    NSAssert(NO, @"Implement in subclass");
    return nil;
}

@end
