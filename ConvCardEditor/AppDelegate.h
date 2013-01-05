//
//  AppDelegate.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 12/28/12.
//  Copyright (c) 2012 Jim Hamilton. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CCEPrefsController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet CCEPrefsController *prefCtl;

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (assign) NSColor *alertColor;
@property (assign) NSColor *announceColor;
@property (assign) NSColor *normalColor;

@property (assign) NSFont *cardFont;

- (IBAction)saveAction:(id)sender;

- (IBAction)newPartnership:(id)sender;
- (IBAction)newCardType:(id)sender;

- (IBAction)openPartnership:(id)sender;

- (IBAction)editCard:(id)sender;

@end
