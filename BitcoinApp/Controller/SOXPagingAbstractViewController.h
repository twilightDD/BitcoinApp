//
//  SOXPagingAbstractViewController.h
//  BitcoinApp
//
//  Created by Peter Hauke on 27.08.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXAbstractViewController.h"

@interface SOXPagingAbstractViewController : SOXAbstractViewController

// Outlets
@property (strong) IBOutlet NSButton *loadMoreTradeDatasButton;
@property (strong) IBOutlet NSButton *loadAllTradeDatasButton;
@property (weak) IBOutlet NSButton *fetchDataButton;

// Properties
@property (strong, nonatomic) NSMutableArray *arrayControllerDatas;
@property (nonatomic) NSInteger currentPage;
@property (nonatomic) BOOL shouldLoadAllTradeDatas;

- (void)setupUI;
- (void)loadNextPage;
- (void)updatePagingButtons:(NSDictionary *)payloadDictionary;
@end
