//
//  AppDelegate.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 12/28/12.
//  Copyright (c) 2012 Jim Hamilton. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CCEPrefsController.h"
#import "Controllers/CCECardTypeEditorController.h"
#import "Documents/CCEDocumentDelegate.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, CCEDocumentDelegate>

@property IBOutlet CCEPrefsController *prefCtl;
@property IBOutlet CCECardTypeEditorController *typeEditorCtl;

@property IBOutlet NSPanel *chooseCardTypePanel;
@property IBOutlet NSTableColumn *cardTypesCol;
@property IBOutlet NSArrayController *cardChooser;
@property IBOutlet NSTextField *directionLabel;
@property IBOutlet NSButton *actionButton;
@property IBOutlet NSButton *removeButton;

@property IBOutlet NSPanel *choosePartnershipPanel;
@property IBOutlet NSArrayController *partnershipChooser;
@property IBOutlet NSTextField *partDirectionLabel;
@property IBOutlet NSButton *partActionButton;

@property (readonly, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;

@property NSColor *alertColor;
@property NSColor *announceColor;
@property NSColor *normalColor;

@property NSFont *cardFont;

@property NSMutableSet *myDocuments;

+ (AppDelegate *)instance;

- (id)openCardWindowNib;

- (NSColor *)colorForCode:(NSInteger)code;
- (NSString *)colorKeyForCode:(NSInteger)code;

- (NSURL *)applicationFilesDirectory;

- (IBAction)changeStdColor:(id)sender;

- (IBAction)saveAction:(id)sender;

- (IBAction)newPartnership:(id)sender;
- (IBAction)doNewPartnership:(id)sender;

- (IBAction)openPartnership:(id)sender;
- (IBAction)doOpenPartnership:(id)sender;

- (IBAction)newCardType:(id)sender;

- (IBAction)editCard:(id)sender;
- (IBAction)editCardType:(id)sender;

    // import/export card definition
- (IBAction)importCardType:(id)sender;
- (IBAction)exportCardType:(id)sender;
- (IBAction)doExport:(id)sender;

- (void)initialImport;

    // import/export partnership
- (IBAction)importPartnership:(id)sender;
- (IBAction)exportPartnership:(id)sender;
- (IBAction)doPartnershipExport:(id)sender;

- (void)watchCheckboxStyle;

- (IBAction)undo:(id)sender;
- (IBAction)redo:(id)sender;

- (IBAction)runPreferences:(id)sender;

- (void)cleanupNibObjects:(NSArray *)topLevelObjects;

#pragma mark DEBUGGING
- (IBAction)registeredObjects:(id)sender;
- (IBAction)updatedObjects:(id)sender;

- (IBAction)objectCounts:(id)sender;

- (IBAction)logClicks:(id)sender;


@end
