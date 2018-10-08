//
//  AppDelegate.m
//  BitcoinApp
//
//  Created by Peter Hauke on 12.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "MacAppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#import "SOXPreferencesCore.h"

#import "SOXErrorMessage_BitcoinDE.h"

#import "SOXLogWindowController.h"

// Prefs
#import "MASPreferences.h"
#import "SOXKeysAndSecretPreferenceViewController.h"
#import "SOXSelectedCountriesPreferenceViewController.h"
#import "SOXDebugPreferencesViewController.h"


@interface MacAppDelegate ()

@property (readwrite, strong, nonatomic) SOXLogWindowController *errorWindowController;
@property (readwrite, strong, nonatomic) SOXLogWindowController *eventWindowController;
@property (strong, nonatomic) MASPreferencesWindowController *masPreferencesWindowController;

- (IBAction)saveAction:(id)sender;

@end

@implementation MacAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    [Fabric with:@[[Crashlytics class]]];

    { // CocoaLumberjack
#ifdef DEBUG
        [DDLog addLogger:[DDTTYLogger sharedInstance]]; // TTY = Xcode console
        [DDLog addLogger:[DDASLLogger sharedInstance]]; // ASL = Apple System Logs
#endif

        DDFileLogger *fileLogger = [[DDFileLogger alloc] init]; // File Logger
        fileLogger.maximumFileSize = 0; // no file size limitation
        fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
        fileLogger.logFileManager.maximumNumberOfLogFiles = 31;
        fileLogger.logFileManager.logFilesDiskQuota = 31 * 100 * 1024 * 1024; // 31 days * 100 MB per Day * 1024 B * 1024 B =  3.250.585.600 Byte = 3.2 GB
        [DDLog addLogger:fileLogger];
    }

    DDLogInfo(@"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    DDLogInfo(@"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    DDLogInfo(@"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    DDLogInfo(@"applicationDidFinishLaunching");
    DDLogInfo(@"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    DDLogInfo(@"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    DDLogInfo(@"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");

    { //Prepare error log window
        self.errorWindowController = [[SOXLogWindowController alloc] initWithWindowNibName:SOXLogWindowControllerNibKey
                                                                               windowTitle:@"Errors"];
        self.eventWindowController = [[SOXLogWindowController alloc] initWithWindowNibName:SOXLogWindowControllerNibKey
                                                                               windowTitle:@"Events"];
//        self.preferenceWindowController = [[SOXMainPreferencesWindowController alloc] initWithWindowNibName:@"SOXMainPreferencesWindowController"
//                                                                                                windowTitle:@"Preferences"];
    }

    // startup Preferences core
    
    [SOXPreferencesCore startupPreferencesCore];
    [self setupPreferenceWindow];
    if ([SOXPreferencesCore validKeychain] == NO) {
        SOXErrorMessage_BitcoinDE *errorMessage = [[SOXErrorMessage_BitcoinDE alloc] initWithServerRequestTitle:@"No keys and secrets!"];
        errorMessage.errorMessage = @"Use Preference pane.";
        [self.errorWindowController presentErrorMessage:errorMessage];

        // open prefs
        [self.masPreferencesWindowController showWindow:self];
    }
}

- (void)setupPreferenceWindow {

    // Keys and Secrets
    SOXKeysAndSecretPreferenceViewController *keyAndSecretPreferencesViewController
    = [[SOXKeysAndSecretPreferenceViewController alloc] initWithNibName:@"SOXKeysAndSecretPreferenceViewController"
                                                                 bundle:nil];

    SOXSelectedCountriesPreferenceViewController *selectedCountriesPreferenceViewController
    = [[SOXSelectedCountriesPreferenceViewController alloc] initWithNibName:@"SOXSelectedCountriesPreferenceViewController"
                                                                     bundle:nil];

    SOXDebugPreferencesViewController * debugPreferencesViewController = [[SOXDebugPreferencesViewController alloc] initWithNibName:@"SOXDebugPreferencesViewController" bundle:nil];

    NSArray *subPreferenceControllers = @[
                                          keyAndSecretPreferencesViewController,
                                          selectedCountriesPreferenceViewController,
                                          debugPreferencesViewController,
                                          ];

    MASPreferencesWindowController *masPreferencesWindowController
    = [[MASPreferencesWindowController alloc] initWithViewControllers:subPreferenceControllers
                                                                title:@"Preferences"];

    self.masPreferencesWindowController = masPreferencesWindowController;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    DDLogInfo(@"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    DDLogInfo(@"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    DDLogInfo(@"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    DDLogInfo(@"applicationWillTerminate");
    DDLogInfo(@"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    DDLogInfo(@"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    DDLogInfo(@"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
}

#pragma mark - Action methods
- (IBAction)showErrorLogWindow:(NSMenuItem *)sender {
    [self.errorWindowController showWindow:self];
}

- (IBAction)showEventLogWindow:(NSMenuItem *)sender {
    [self.eventWindowController showWindow:self];
}

- (IBAction)showPreferencesWindow:(NSMenuItem *)sender {
    [self.masPreferencesWindowController showWindow:self];
}

#pragma mark - Core Data stack

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "de.2sox.BitcoinApp" in the user's Application Support directory.
    NSURL *appSupportURL = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"de.2sox.BitcoinApp"];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"BitcoinApp" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationDocumentsDirectory = [self applicationDocumentsDirectory];
    BOOL shouldFail = NO;
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    
    // Make sure the application files directory is there
    NSDictionary *properties = [applicationDocumentsDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    if (properties) {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            failureReason = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationDocumentsDirectory path]];
            shouldFail = YES;
        }
    } else if ([error code] == NSFileReadNoSuchFileError) {
        error = nil;
        [fileManager createDirectoryAtPath:[applicationDocumentsDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    if (!shouldFail && !error) {
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        NSURL *url = [applicationDocumentsDirectory URLByAppendingPathComponent:@"BitcoinApp.storedata"];
        if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
            // Replace this implementation with code to handle the error appropriately.
             
            /*
             Typical reasons for an error here include:
             * The persistent store is not accessible, due to permissions or data protection when the device is locked.
             * The device is out of space.
             * The store could not be migrated to the current model version.
             Check the error message to determine what the actual problem was.
             */
            coordinator = nil;
        }
        _persistentStoreCoordinator = coordinator;
    }
    
    if (shouldFail || error) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        if (error) {
            dict[NSUnderlyingErrorKey] = error;
        }
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        DDLogInfo(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

#pragma mark - Core Data Saving and Undo support

- (IBAction)saveAction:(id)sender {
    // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
    NSManagedObjectContext *context = self.managedObjectContext;

    if (![context commitEditing]) {
        DDLogInfo(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    NSError *error = nil;
    if (context.hasChanges && ![context save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
    return [[self managedObjectContext] undoManager];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    // Save changes in the application's managed object context before the application terminates.
    NSManagedObjectContext *context = _managedObjectContext;

    if (!context) {
        return NSTerminateNow;
    }
    
    if (![context commitEditing]) {
        DDLogInfo(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (!context.hasChanges) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![context save:&error]) {

        // Customize this code block to include application-specific recovery steps.
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertSecondButtonReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

@end
