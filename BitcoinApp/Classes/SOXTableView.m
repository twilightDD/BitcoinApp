//
//  SOXTableView.m
//  BitcoinApp
//
//  Created by Peter Hauke on 02.07.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "SOXTableView.h"

@implementation SOXTableView
// http://www.knowstack.com/nstableview-tab-return/


//Subclass NSTableView and override the textDidEndEditing method. Then change the custom class of NSTableView instance in IB to the subclass.
- (void)textDidEndEditing:(NSNotification *)notification {
    NSInteger editedColumn = [self editedColumn];
    NSInteger editedRow    = [self editedRow];
    NSInteger lastRow      = [self numberOfRows];
    NSInteger lastCol      = [self numberOfColumns];
    NSDictionary *userInfo = [notification userInfo];
    int textMovement       = [(NSNumber *)[userInfo valueForKey:@"NSTextMovement"] intValue];
    [super textDidEndEditing:notification];

    if (textMovement == NSTabTextMovement) {
        if (editedColumn != lastCol - 1) {
            //            [self selectRowIndexes:[NSIndexSet indexSetWithIndex:editedRow]
            //              byExtendingSelection:NO];
            [self editColumn:editedColumn + 1
                         row:editedRow
                   withEvent:nil
                      select:YES];
        }
        else {
            if (editedRow != lastRow - 1) {
                [self editColumn:0
                             row:editedRow + 1
                       withEvent:nil
                          select:YES];
            }
            else {
                // Go to the first cell
                [self editColumn:0
                             row:0
                       withEvent:nil
                          select:YES];
            }
        }
    }
    else if (textMovement == NSReturnTextMovement) {
        if (editedRow != lastRow - 1) {
            //            [self selectRowIndexes:[NSIndexSet indexSetWithIndex:editedRow+1]
            //              byExtendingSelection:NO];
            [self editColumn:editedColumn
                         row:editedRow + 1
                   withEvent:nil
                      select:YES];
        }
        else {
            if (editedColumn != lastCol - 1) {
                [self editColumn:editedColumn + 1
                             row:0
                       withEvent:nil
                          select:YES];
            }
            else {
                //Go to the first cell
                [self editColumn:0
                             row:0
                       withEvent:nil
                          select:YES];
            }
        }
    }
}

@end
