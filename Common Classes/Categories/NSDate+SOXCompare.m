//
//  NSDate+SOXCompare.m
//  BitcoinApp
//
//  Created by Peter Hauke on 26.11.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import "NSDate+SOXCompare.h"

@implementation NSDate (SOXCompare)

- (BOOL)isLaterThan:(NSDate *)dateToCompare {
    NSComparisonResult compareResult = [self compare:dateToCompare];

    switch (compareResult) {
        case NSOrderedAscending:
            return NO;
            break;
        case NSOrderedSame:
            return YES;
            break;
        case NSOrderedDescending:
            return YES;
            break;
        default:
            break;
    }
}


@end
