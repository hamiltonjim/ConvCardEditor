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
#import "NSUserDefaults+CCEColorOps.h"
#import "CCEMathTransformer.h"
#import "CCEManagedObjectModels.h"

    // for counts
#import "CCELocationController.h"
#import "CCEControlsViewController.h"
#import "CCEValueBinder.h"
#import "CCEToolPaletteController.h"
#import "CCESizableTextField.h"
#import "CCTextField.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSMenuItem *debugMenu;

- (void)flushColors;
- (void)flushFonts;

- (void)loadColors;

+ (NSColor *)stdAlertColor;
+ (NSColor *)stdAnnounceColor;
+ (NSColor *)stdNormalColor;

- (void)ensureMyDocumentsExists;
- (void)watchCheckboxStyle;
- (void)watchEnableDebug;

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
@synthesize removeButton;

@synthesize choosePartnershipPanel;
@synthesize partnershipChooser;

@synthesize myDocuments;

@synthesize debugMenu;

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
                            [NSNumber numberWithDouble:(1200.0/72.0)], cceMaximumScale,
                            [NSNumber numberWithDouble:0.5], cceMinimumScale,
                            nil];
    [ud registerDefaults:regDef];
    [ud setBool:YES forKey:@"NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints"];
    [ud setBool:YES forKey:@"NSViewRaiseOnInvalidFrames"];
}

+ (AppDelegate *)instance
{
    AppDelegate *it = (AppDelegate *)[NSApp delegate];
    return it;
}

- (void)loadColors
{
    [self flushColors];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    self.alertColor = [ud colorForKey:ccAlertColor];
    self.announceColor = [ud colorForKey:ccAnnounceColor];
    self.normalColor = [ud colorForKey:ccNormalColor];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
        // initialize preferences
    [prefCtl windowDidLoad];
    
    CCEFileOps *fileOps = [CCEFileOps instance];
    [fileOps setAppSupportURL:[self applicationFilesDirectory]];
    [fileOps checkFileTypes:[NSImage imageFileTypes]];
    
        // observe standard colors
    [self loadColors];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [@[ccNormalColor, ccAlertColor, ccAnnounceColor] enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        [ud addObserver:self forKeyPath:obj options:0 context:NULL];
    }];
    
        // if there are no card definitions (i.e., first-run or reset), load defaults
    [self initialImport];
    
    [self watchCheckboxStyle];
    [self watchEnableDebug];
}

- (id)openCardWindowNib
{
    id nib = [[NSNib alloc] initWithNibNamed:@"CardWindow" bundle:nil];
    
        // I am responsible for cleaning up retain-counts on top-level objects; see below.
    NSArray *topObjs;
    [nib instantiateNibWithOwner:self topLevelObjects:&topObjs];
    
    typeEditorCtl.topObjects = topObjs;
    
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
            error = [NSError errorWithDomain:applicationDomain code:101 userInfo:dict];
            
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
        NSError *error = [NSError errorWithDomain:applicationDomain code:9999 userInfo:dict];
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
        [alert addButtonWithTitle:cancelButton];    // 2nd button: see below...

        NSInteger answer = [alert runModal];
        if (answer == NSAlertSecondButtonReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

- (IBAction)changeStdColor:(id)sender
{
    [self loadColors];
}

- (IBAction)newPartnership:(id)sender {
    [directionLabel setStringValue:NSLocalizedString(@"Choose card style for new partnership:",
                                                     @"prompt for new partnership")];
    [actionButton setTitle:NSLocalizedString(@"Create", @"Create")];
    [actionButton setAction:@selector(doNewPartnership:)];
    
    [removeButton setHidden:YES];
    
    [chooseCardTypePanel makeKeyAndOrderFront:sender];
}

- (IBAction)doNewPartnership:(id)sender
{
    [chooseCardTypePanel orderOut:sender];
    
    NSManagedObject *cardType = [[cardChooser selectedObjects] objectAtIndex:0];
    
    [self openCardWindowNib];
    
    typeEditorCtl.cardType = cardType;
    [typeEditorCtl createPartnership:self];
    self.typeEditorCtl = nil;
}

- (IBAction)openPartnership:(id)sender {
    [choosePartnershipPanel makeKeyAndOrderFront:self];
}

- (IBAction)doOpenPartnership:(id)sender
{
    [choosePartnershipPanel orderOut:sender];
    
    NSManagedObject *partnership = [[partnershipChooser selectedObjects] objectAtIndex:0];
    
    [self openCardWindowNib];
    
    typeEditorCtl.partnership = partnership;
    typeEditorCtl.cardType = partnership.cardType;
    
    [typeEditorCtl editPartnership:self];
    self.typeEditorCtl = nil;
}

- (IBAction)newCardType:(id)sender {
    [self openCardWindowNib];
    [typeEditorCtl editNewCardType:self];
    self.typeEditorCtl = nil;
}

    // Edit menu action.  Opens card chooser, completed below
- (IBAction)editCardType:(id)sender
{
    [directionLabel setStringValue:NSLocalizedString(@"Choose card style to edit:", @"edit card direction")];
    [actionButton setTitle:NSLocalizedString(@"Edit", @"Edit")];
    [actionButton setAction:@selector(editCard:)];
    [removeButton setHidden:NO];
    
    [chooseCardTypePanel makeKeyAndOrderFront:sender];
}

    // completion from card chooser
- (IBAction)editCard:(id)sender {
    [chooseCardTypePanel orderOut:sender];
    
    [self openCardWindowNib];
        // opening the nib set typeEditorCtl

    typeEditorCtl.cardType = [[cardChooser selectedObjects] objectAtIndex:0];
    [typeEditorCtl openCard:self];
    self.typeEditorCtl = nil;
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
    [removeButton setHidden:NO];
    
    [chooseCardTypePanel makeKeyAndOrderFront:sender];
}

- (void)doExport:(id)sender
{
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

- (void)watchEnableDebug
{
    NSKeyValueObservingOptions opts = NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew;
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:cceEnableDebugging
                                               options:opts
                                               context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([ccCheckboxDrawStyle isEqualToString:keyPath]) {
        [CCCheckboxCell setCheckboxStyle:[object integerForKey:keyPath]];
    } else if ([ccAlertColor isEqualToString:keyPath]) {
        self.alertColor = [object colorForKey:keyPath];
    } else if ([ccAnnounceColor isEqualToString:keyPath]) {
        self.announceColor = [object colorForKey:keyPath];
    } else if ([ccNormalColor isEqualToString:keyPath]) {
        self.normalColor = [object colorForKey:keyPath];
    } else if ([cceEnableDebugging isEqualToString:keyPath]) {
        NSNumber *val = [change valueForKey:NSKeyValueChangeNewKey];
        BOOL state = !val.boolValue;
        [debugMenu setHidden:state];
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
        [self saveAction:self];
        
        [doc close];
    }];
}

- (IBAction)runPreferences:(id)sender
{
    [prefCtl showWindow:sender];
}

#pragma mark NIB CLEANUP

- (void)cleanupNibObjects:(NSArray *)topLevelObjects
{
        // Kluge--clean up the extra retains in top-level objects.
    [topLevelObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BOOL doit = YES;
        if ([obj isKindOfClass:[NSWindow class]]) {
            NSWindow *win = obj;
            doit = !win.isReleasedWhenClosed;
        }
//        NSLog(@"Release %@? %@", [obj class], doit ? @"yes" : @"no");
        if (doit) {
                // release it manually, then
            CFRelease((__bridge CFTypeRef)obj);
        }
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

- (IBAction)objectCounts:(id)sender
{
    NSLog(@"CCECardTypeEditorControllers: %ld", [CCECardTypeEditorController count]);
    NSLog(@"Location Controllers: %ld", [CCELocationController count]);
    NSLog(@"CCEControlViewControllers: %ld", [CCEControlsViewController count]);
    NSLog(@"CCEValueBinders: %ld", [CCEValueBinder count]);
    NSLog(@"CCEToolPaletteControllers: %ld", [CCEToolPaletteController count]);
    NSLog(@"CCESizableTextFields: %ld", [CCESizableTextField count]);
    NSLog(@"CCTextFields: %ld", [CCTextField count]);
}

- (IBAction)logClicks:(id)sender
{
    [CCDebuggableControlEnable toggleLogClicks];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    if ([menuItem action] == @selector(logClicks:)) {
        [menuItem setState:[CCDebuggableControlEnable logClicks]];
        return YES;
    }
    
    return YES;
}

- (IBAction)keyViewLoop:(id)sender
{
    NSView *aKeyView = [NSView focusView];
    NSLog(@"Starting key view: %@", aKeyView);
    NSView *nextView = aKeyView;
    while (nextView) {
        nextView = nextView.nextKeyView;
        if (nextView == aKeyView) {
            NSLog(@"Loop complete");
            break;
        }
        NSLog(@"Keyview: %@", nextView);
    }
}

@end
