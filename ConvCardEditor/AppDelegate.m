//
//  AppDelegate.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 12/28/12.
//  Copyright (c) 2012 Jim Hamilton. All rights reserved.
//

#import "AppDelegate.h"
#import "CommonStrings.h"
#import "CCCheckboxCell.h"
#import "CCEFileOps.h"
#import "CCEUnitNameTransformer.h"
#import "CCEUnitTransformer.h"
#import "CCECardStyleDocument.h"
#import "CCEEntityFetcher.h"

@interface AppDelegate ()

- (void) flushColors;
- (void) flushFonts;

+ (NSColor *) stdAlertColor;
+ (NSColor *) stdAnnounceColor;
+ (NSColor *) stdNormalColor;

- (void)ensureMyDocumentsExists;

@end


@implementation AppDelegate

@synthesize prefCtl;
@synthesize typeEditorCtl;

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

@synthesize alertColor;
@synthesize announceColor;
@synthesize normalColor;

@synthesize cardFont;

@synthesize chooseCardTypePanel;
@synthesize cardTypesCol;
@synthesize cardChooser;
@synthesize directionLabel;
@synthesize actionButton;

@synthesize myDocuments;

- (void) flushColors {
    self.alertColor = nil;
    self.announceColor = nil;
    self.normalColor = nil;
}

- (void) flushFonts {
    self.cardFont = nil;
}

+ (NSColor *) stdAlertColor {
    return [NSColor colorWithCalibratedRed:ALERT_COLOR_R
                                     green:ALERT_COLOR_G
                                      blue:ALERT_COLOR_B
                                     alpha:1.0];
}

+ (NSColor *) stdAnnounceColor {
    return [NSColor colorWithCalibratedRed:ANNOUNCE_COLOR_R
                                     green:ANNOUNCE_COLOR_G
                                      blue:ANNOUNCE_COLOR_B
                                     alpha:1.0];
}

+ (NSColor *) stdNormalColor {
    return [NSColor blackColor];
}

+ (void) initialize {
    if (self != [AppDelegate class]) return;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *regDef = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"Helvetica", ccDefaultFontName,
                            [NSNumber numberWithInteger:8], ccDefaultFontSize,
                            [NSNumber numberWithDouble:SCALE_MULT], ccDefaultScale,
                            [NSArchiver archivedDataWithRootObject:[self stdAlertColor]], ccAlertColor,
                            [NSArchiver archivedDataWithRootObject:[self stdAnnounceColor]], ccAnnounceColor,
                            [NSArchiver archivedDataWithRootObject:[self stdNormalColor]], ccNormalColor,
                            [NSNumber numberWithInteger:CCCheckboxStyleSolid], ccCheckboxDrawStyle,
                            [NSNumber numberWithDouble:1.0], ccLeadCircleStrokeWidth,
                            [NSArchiver archivedDataWithRootObject:[self stdNormalColor]], ccLeadCircleColorKey,
                            [NSNumber numberWithBool:YES], ccChecksAreSquare,
                            [NSNumber numberWithDouble:6.0], ccCheckboxWidth, // points, both sides when square
                            [NSNumber numberWithDouble:6.0], ccCheckboxHeight,
                            [NSNumber numberWithBool:NO], ccCirclesAreRound,
                            [NSNumber numberWithDouble:7.0], ccCircleWidth,  // points, diameter when round
                            [NSNumber numberWithDouble:10.0], ccCircleHeight,
                            [NSNumber numberWithBool:YES], cceGridState,
                            [NSNumber numberWithDouble:1.0], cceStepIncrement,
                            nil];
    [ud registerDefaults:regDef];
    [ud setBool:YES forKey:@"NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints"];
}

+ (AppDelegate *)instance
{
    AppDelegate *it = (AppDelegate *)[NSApp delegate];
    return it;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
        // initialize preferences
    [prefCtl windowDidLoad];
    
    CCEFileOps *fileOps = [CCEFileOps instance];
    [fileOps setAppSupportURL:[self applicationFilesDirectory]];
    [fileOps checkFileTypes:[NSImage imageFileTypes]];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    alertColor = [NSUnarchiver unarchiveObjectWithData:[ud dataForKey:ccAlertColor]];
    announceColor = [NSUnarchiver unarchiveObjectWithData:[ud dataForKey:ccAnnounceColor]];
    normalColor = [NSUnarchiver unarchiveObjectWithData:[ud dataForKey:ccNormalColor]];
    
        // if there are no card definitions (i.e., first-run or reset), load defaults
    [self initialImport];
}

- (id)openCardWindowNib
{
    id nib = [[NSNib alloc] initWithNibNamed:@"CardWindow" bundle:nil];
    [nib instantiateNibWithOwner:self topLevelObjects:nil];
    return nib;
}

- (NSString *)colorKeyForCode:(NSInteger)code
{
    NSString *color;
    switch (code) {
        case kAlertColor:
            color = ccAlertColor;
            break;
            
        case kAnnounceColor:
            color = ccAnnounceColor;
            break;
            
        case kNormalColor:
            color = ccNormalColor;
            break;
            
        default:
            color = nil;
            break;
    }
    
    return color;
}

- (NSColor *)colorForCode:(NSInteger)code
{
    NSColor *color;
    
    switch (code) {
        case kAlertColor:
            color = alertColor;
            break;
            
        case kAnnounceColor:
            color = announceColor;
            break;
            
        case kNormalColor:
            color = normalColor;
            break;
            
        default:
            color = nil;
            break;
    }
    
    return color;
}

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "com.shokwave.ConvCardEditor" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"com.shokwave.ConvCardEditor"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ConvCardEditor" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![[properties valueForKey:NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"ConvCardEditor.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) 
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [NSManagedObjectContext new];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        NSLog(@"Detailed errors: %@", [[error userInfo] objectForKey:@"NSDetailedErrors"]);
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        NSLog(@"Detailed errors: %@", [[error userInfo] objectForKey:@"NSDetailedErrors"]);
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [NSAlert new];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        NSLog(@"quit answer: %ld", answer);
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

- (IBAction)newPartnership:(id)sender {
    NSLog(@"newPartnership not implemented yet");
}

- (IBAction)newCardType:(id)sender {
    [self openCardWindowNib];
    [NSApp sendAction:@selector(editNewCardType:) to:nil];
        //    [self.typeEditorCtl showWindow:sender];
}

- (IBAction)openPartnership:(id)sender {
    NSLog(@"openPartnership not implemented yet");
}

- (IBAction)editCard:(id)sender {
    [chooseCardTypePanel orderOut:sender];
    
    [self openCardWindowNib];

    typeEditorCtl.cardType = [[cardChooser selectedObjects] objectAtIndex:0];
    [typeEditorCtl openCard:self];
}

- (IBAction)editCardType:(id)sender
{
    [directionLabel setStringValue:NSLocalizedString(@"Choose card style to edit:", @"edit card direction")];
    [actionButton setTitle:NSLocalizedString(@"Edit", @"Edit")];
    [actionButton setAction:@selector(editCard:)];
    
    [chooseCardTypePanel makeKeyAndOrderFront:sender];
}

- (void)ensureMyDocumentsExists
{
    if (myDocuments != nil)
        return;
    @synchronized(self) {
        if (myDocuments == nil) {
            myDocuments = [NSMutableSet set];
        }
    }
}

- (void)documentHasOpened:(NSDocument *)document
{
    [self ensureMyDocumentsExists];
    [myDocuments addObject:document];
}

- (void)documentWillClose:(NSDocument *)document
{
    [self ensureMyDocumentsExists];
    [myDocuments removeObject:document];
}

- (IBAction)importCardType:(id)sender
{
    [CCECardStyleDocument importCardStyleTo:self];
}

- (IBAction)exportCardType:(id)sender
{
    [directionLabel setStringValue:NSLocalizedString(@"Choose card style to export:", @"export card direction")];
    [actionButton setTitle:NSLocalizedString(@"Export", @"Export")];
    [actionButton setAction:@selector(doExport:)];
    
    [chooseCardTypePanel makeKeyAndOrderFront:sender];
}

- (void)doExport:(id)sender
{
//    NSLog(@"exportCardType not implemented yet");
    [chooseCardTypePanel orderOut:sender];
    
    NSManagedObject *cardType = [[cardChooser selectedObjects] objectAtIndex:0];
    
    [CCECardStyleDocument exportCardStyle:cardType];
    return;
}

- (IBAction)importPartnership:(id)sender
{
    NSLog(@"importPartnership not implemented yet");
}
- (IBAction)exportPartnership:(id)sender
{
    NSLog(@"exportPartnership not implemented yet");
}

- (void)watchCheckboxStyle
{
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:ccCheckboxDrawStyle
                                               options:NSKeyValueObservingOptionNew
                                               context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([ccCheckboxDrawStyle isEqualToString:keyPath]) {
        [CCCheckboxCell setCheckboxStyle:[object integerForKey:keyPath]];
    }
    
}

#pragma mark FIRST TIME RUN or RESET

- (void)initialImport
{
    NSArray *cardTypes = [[CCEEntityFetcher instance] allCardTypes];
    if ([cardTypes count] > 0)
        return;
    
    NSBundle *mb = [NSBundle mainBundle];
    NSString *resourcePath = @"";
    
        // card styles
    NSArray *styles = [mb pathsForResourcesOfType:cceStyledocType
                                      inDirectory:resourcePath];
    
    [styles enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL *stop) {
        NSURL *url = [NSURL fileURLWithPath:path];
        CCECardStyleDocument *doc = [[CCECardStyleDocument alloc] initWithContentsOfURL:url
                                                                                 ofType:cceStyledocType
                                                                                  error:NULL];
        [doc doImport];
    }];
}

#pragma mark UNDO/REDO

- (IBAction)undo:(id)sender
{
    [[self managedObjectContext] undo];
}

- (IBAction)redo:(id)sender
{
    [[self managedObjectContext] redo];
}

#pragma mark DEBUGGING
- (IBAction)registeredObjects:(id)sender
{
    NSLog(@"Registered objects: %@", [[self managedObjectContext] registeredObjects]);
}

- (IBAction)updatedObjects:(id)sender
{
    NSLog(@"Updated objects: %@", [[self managedObjectContext] updatedObjects]);
}

@end
