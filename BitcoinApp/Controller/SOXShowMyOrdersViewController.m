//
//  SOXShowMyOrdersViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 27.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXShowMyOrdersViewController.h"
#import "SOXAbstractViewController_Private.h"

#import "SOXMyOrderDetailsViewController.h"

#import "SOXMarket_BitcoinDE_Core.h"
#import "SOXMyOrderBook_BitcoinDE_Data.h"

#import "SOXDateFormatter.h"

NSString *const PresentMyTradesSegueKey = @"PresentMyTradesSegue";
NSString *const PresentMyAccountSegueKey = @"PresentMyAccountSegue";

#pragma mark - Interface
@interface SOXShowMyOrdersViewController () <SOXMarketCoreServerRequestProtocol, NSTableViewDelegate>

#pragma mark IBOutlets
@property (weak) IBOutlet NSTextField *titleTextField;

@property (weak) IBOutlet NSTableView *tableView;

@property (weak) IBOutlet NSButton *reloadButton;
@property (weak) IBOutlet NSButton *removeButton;

@property (strong) IBOutlet NSArrayController *myOrderArrayController;

#pragma mark Properties
@property (strong, nonatomic) NSMutableArray <SOXMyOrderBook_BitcoinDE_Data *> *myOrderBook;
@property (nonatomic) NSInteger countOfMyOrderBook_BitcoinDE_DatasToDelete;
@property (nonatomic) NSInteger countOfDeletedMyOrderBook_BitcoinDE_Datas;

@end

#pragma mark - Implementation
@implementation SOXShowMyOrdersViewController
#pragma mark Init&Co.
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear {
    [super viewWillAppear];
    
    [self setupUI];
    [self enableSpinningWheel]; // has to be here
    [self requestServerData];
}

#pragma mark - Private methods
- (void)setupUI {
    self.titleTextField.stringValue = @"My active orders";
    
    {
        self.reloadButton.title = @"Reload";
        self.removeButton.title = @"Remove order";
    }
    
    {
        [self.tableView setDoubleAction:@selector(tableViewDoubleAction:)];
    }
}

- (void)requestServerData {
    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ShowMyOrdersCommandType
                                                respondTo:self];
}

#pragma mark - Table view methods
- (void)tableViewDoubleAction:(NSTableView *)tableView {
    NSArray <SOXMyOrderBook_BitcoinDE_Data *> *selectedObjects = [self.myOrderArrayController selectedObjects];
    SOXMyOrderBook_BitcoinDE_Data *selectedMyOrder = selectedObjects.firstObject;
    
    NSStoryboard *storyBoard = [NSStoryboard storyboardWithName:@"MacMain" bundle:nil];
    SOXMyOrderDetailsViewController *viewC = [storyBoard instantiateControllerWithIdentifier:@"MyOrderDetailsViewControllerIdentifier"];
    viewC.myOrder = selectedMyOrder;
    [self presentViewControllerAsSheet:viewC];
}

#pragma mark - SOXMarketCoreServerRequestProtocol
- (void)answerOfServerRequest:(NSDictionary * _Nonnull)answerOfServerRequest {
    
    if ([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ShowMyOrdersCommandType)]) {
        NSDictionary *payloadDictionary = [answerOfServerRequest objectForKey:ServerAnswerPayloadKey];
        NSMutableArray *myOrderBook = [SOXMyOrderBook_BitcoinDE_Data myOrderbookDataArrayForMyOrderbookDictionary:payloadDictionary];
        self.myOrderBook = myOrderBook;
        
        [self disableSpinningWheel];
    }
    else if ([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_RemoveOrderType)]){
        NSDictionary *errors = [answerOfServerRequest objectForKey:ServerAnswerErrorKey];
        if (errors.count == 0) {
            self.countOfMyOrderBook_BitcoinDE_DatasToDelete++;
            if (self.countOfMyOrderBook_BitcoinDE_DatasToDelete == self.countOfDeletedMyOrderBook_BitcoinDE_Datas) {
                
                // Start tableView update
                [self requestServerData];
                
                // inform user
                [self informUserAboutDeletion:self.countOfDeletedMyOrderBook_BitcoinDE_Datas];
                // reset counters
                self.countOfMyOrderBook_BitcoinDE_DatasToDelete = 0;
                self.countOfDeletedMyOrderBook_BitcoinDE_Datas  = 0;
            }
        }
        
    }
    // TODO: TODO DEBUG
    else if ([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_CreateOrderType)]) {
        NSLog(@"BitcoinDE_CreateOrderType %@", answerOfServerRequest);
       // [self enableSpinningWheel];
        // Start tableView update
    //    [self requestServerData];
    }
    else if ([[answerOfServerRequest objectForKey:ServerAnswerServerCommandKey] isEqual:@(BitcoinDE_ExecuteTrade)]) {
        NSLog(@"BitcoinDE_ExecuteTrade %@", answerOfServerRequest);
       //  [self enableSpinningWheel];
        // Start tableView update
        //    [self requestServerData];
    }
    
    
}

#pragma mark - User information
- (void)informUserAboutDeletion:(NSInteger)countofDeletedObjects {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"Deletion successfull";
    alert.informativeText = [NSString stringWithFormat:@"%ti orders deleted.", countofDeletedObjects];
    alert.alertStyle = NSAlertStyleInformational;
    [alert runModal];
}

#pragma mark - Action methods
- (IBAction)removeButtonAction:(NSButton *)sender {
    NSArray <SOXMyOrderBook_BitcoinDE_Data *> *selectedDatas = self.myOrderArrayController.selectedObjects;
    // get parameterDictionaries for data to delete
    NSArray *myOrderBookParametersToDelete = [SOXMyOrderBook_BitcoinDE_Data parametersForDeletingMyOrderBookDatas:selectedDatas];
    //
    self.countOfMyOrderBook_BitcoinDE_DatasToDelete = myOrderBookParametersToDelete.count;
    if (self.countOfMyOrderBook_BitcoinDE_DatasToDelete > 0) {
        self.removeButton.enabled = NO;
        [self enableSpinningWheel];
    
        for (NSDictionary *myOrderBookParameter in myOrderBookParametersToDelete) {
            [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_RemoveOrderType
                                                    withParameter:myOrderBookParameter
                                                        respondTo:self];
        }
    }
}

- (IBAction)reloadButtonAction:(NSButton *)sender {
    [self enableSpinningWheel];
    [self requestServerData];
}


#pragma mark - TESTING
- (IBAction)new5kOrder:(NSButton *)sender {

    NSString *end_datetime = @"2017-04-07T15:00:00+02:00";//[SOXDateFormatter rfc3339DateTimeStringDate:[NSDate dateWithTimeIntervalSinceNow:60]];
    
    NSDictionary *parameters = [SOXMyOrderBook_BitcoinDE_Data parameterForNewOrderWithOrderType:BitcoinDE_SellOrderType
                                                                                     max_amount:@(0.1)
                                                                                          price:@(2000)
                                                                                     min_amount:@(0.1)
                                                                                   end_datetime:end_datetime
                                                                 new_order_for_remaining_amount:NO
                                                                                min_trust_level:BitcoinDE_GoldMinimalTrustLevel
                                                                                  only_kyc_full:YES
                                                                                 payment_option:BitcoinDE_SEPAOnlyPaymentOption
                                                                                   seat_of_bank:nil];
    NSLog(@"parameters: \n%@", parameters);
    
    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_CreateOrderType
                                            withParameter:parameters
                                                respondTo:self];

//    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
//                                 @(0.0001), @"amount"
//                                , @"buy", @"type"
//                                , nil];
//    
//    [SOXMarket_BitcoinDE_Core requestDataForServerCommand:BitcoinDE_ExecuteTrade
//                                            withParameter:parameters
//                                                respondTo:self];
}


@end
