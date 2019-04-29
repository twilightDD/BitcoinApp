//
//  SOXIAPHelper.m
//  BitcoinApp
//
//  Created by Peter Hauke on 05.04.19.
//  Copyright © 2019 2sox / Peter Hauke. All rights reserved.
//

#import "SOXIAPHelper.h"
#import <StoreKit/StoreKit.h>

@interface SOXIAPHelper () < SKProductsRequestDelegate>

@property (strong, nonatomic) NSSet<NSString *> *productIdentifiers;

@property (strong, nonatomic) NSArray<SKProduct *> *products;
@property (strong, nonatomic) SKProductsRequest *productsRequest;


@end

@implementation SOXIAPHelper

- (void)requestAvaibleIAPs {
    self.productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:self.productIdentifiers];
//    self.productsRequest = [[SKProductsRequest alloc] init];
    self.productsRequest.delegate = self;
    
    [self.productsRequest start];
}


#pragma mark - Manual Setter and Getter
- (NSSet<NSString *> *)productIdentifiers {
    NSSet<NSString *> *productIdentifiers = [NSSet setWithObjects:@"de.2sox.soxtrade.demo.iap_1000_1", nil];
    return productIdentifiers;
}

#pragma mark - SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    self.products = response.products;
    
    for (NSString *invalidIdentifier in response.invalidProductIdentifiers) {
        NSLog(@"invalidProductIdentifiers: %@", invalidIdentifier);
    }
    
    for (SKProduct *product in response.products) {
        NSLog(@"response.product.productIdentifier: %@", product.productIdentifier);
    }
}

@end
