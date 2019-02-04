//
//  AppDelegate.h
//  BitcoinApp
//
//  Created by Peter Hauke on 12.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SOXLogWindowController;

@interface MacAppDelegate : NSObject <NSApplicationDelegate>

@property (readonly, strong, nonatomic) SOXLogWindowController *errorWindowController;
@property (readonly, strong, nonatomic) SOXLogWindowController *eventWindowController;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@end
