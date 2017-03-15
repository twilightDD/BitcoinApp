//
//  SOXBannerData.m
//  BitcoinApp
//
//  Created by Peter Hauke on 14.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXBannerData.h"
#import "SOXBannerData_Private.h"
@implementation SOXBannerData

+ (instancetype )sharedData {
    static id sharedData;
    
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        sharedData = [[self class] new];
    });
    return sharedData;
}

+ (void)startBannerUpdatesWitdScheduleTime:(NSTimeInterval)timeInterval delegate:(id <SOXBannerDataProtocol>)delegate {
    NSLog(@"Method need an implementation in subClass");
}

+ (void)stopBannerUpdates {
    [[SOXBannerData sharedData].reloadBannerDataTimer invalidate];
    [SOXBannerData sharedData].delegate = nil;
}

@end
