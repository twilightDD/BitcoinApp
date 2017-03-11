//
//  AppDelegate.h
//  iOS BitcoinApp
//
//  Created by Peter Hauke on 12.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

