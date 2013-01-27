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

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property IBOutlet CCEPrefsController *prefCtl;
@property IBOutlet CCECardTypeEditorController *typeEditorCtl;

@property IBOutlet NSWindow *window;

@property (readonly, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;

@property NSColor *alertColor;
@property NSColor *announceColor;
@property NSColor *normalColor;

@property NSFont *cardFont;

+ (AppDelegate *)instance;

- (NSColor *)colorForCode:(NSInteger)code;
- (NSString *)colorKeyForCode:(NSInteger)code;

- (NSURL *)applicationFilesDirectory;

- (IBAction)saveAction:(id)sender;

- (IBAction)newPartnership:(id)sender;
- (IBAction)newCardType:(id)sender;

- (IBAction)openPartnership:(id)sender;

- (IBAction)editCard:(id)sender;

#pragma mark DEBUGGING
- (IBAction)registeredObjects:(id)sender;
- (IBAction)updatedObjects:(id)sender;

@end
