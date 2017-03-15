//
//  SOXBannerData.h
//  BitcoinApp
//
//  Created by Peter Hauke on 14.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SOXBannerDataProtocol <NSObject>

- (void)didUpdateBannerData:(id)bannerData;

@end

@interface SOXBannerData : NSObject

@property (weak, nonatomic) id <SOXBannerDataProtocol> delegate;

+ (instancetype)sharedData;

+ (void)startBannerUpdatesWitdScheduleTime:(NSTimeInterval)timeInterval delegate:(id <SOXBannerDataProtocol>)delegate;
+ (void)stopBannerUpdates;

@end
