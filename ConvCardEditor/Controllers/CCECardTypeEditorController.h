//
//  CCECardTypeEditorController.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/3/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import "FixedNSImageView.h"


@class CCEControlsViewController;
@class CCEToolPaletteController;

@interface CCECardTypeEditorController : NSObject <NSWindowDelegate>

@property IBOutlet NSWindow *window;
@property NSManagedObject *type;
@property int cardControlType;

@property IBOutlet NSTextField *artworkFileName;
@property IBOutlet NSTextField *cardTypeName;

@property IBOutlet FixedNSImageView *cardImageView;
@property IBOutlet CCEControlsViewController *controlsView;

@property IBOutlet NSPanel *chooseCardTypePanel;
@property IBOutlet NSTableColumn *cardTypesCol;
@property IBOutlet NSArrayController *cardChooser;

@property IBOutlet NSPanel *infoPanel;
@property IBOutlet NSColorWell *controlColorWell;
@property IBOutlet NSMatrix *stdControlColorGroup;

@property IBOutlet NSTextField *xField;
@property IBOutlet NSTextField *yField;
@property IBOutlet NSTextField *widthField;
@property IBOutlet NSTextField *heightField;

@property IBOutlet NSObjectController *selectedObject;
@property IBOutlet NSObjectController *locationObject;
@property (weak, readonly) NSManagedObjectContext *managedObjectContext;

@property IBOutlet CCEToolPaletteController *toolsPaletteController;

@property (nonatomic) BOOL gridState;
@property (readonly) NSString *gridStateLabel;

- (void)windowDidLoad;

- (IBAction)showWindow:(id)sender;

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem;

- (IBAction)setControlType:(id)sender;

    // create/edit card
- (IBAction)newCardType:(id)sender;
- (IBAction)editCardType:(id)sender;
- (IBAction)openCard:(id)sender;

- (IBAction)changeArtwork:(id)sender;

- (IBAction)absoluteScale:(id)sender;
- (IBAction)scaleZero:(id)sender;

- (IBAction)scaleLarger:(id)sender;
- (IBAction)scaleSmaller:(id)sender;

- (IBAction)scaleToWindow:(id)sender;

    // controls

- (IBAction)coltrolInfo:(id)sender;

- (IBAction)setControlColorCode:(id)sender;

- (IBAction)updateUnits:(id)sender;

- (IBAction)toggleGridState:(id)sender;

- (void)selectControlObject:(NSManagedObject *)object;

- (void)chooseNextControl;

#pragma mark DEBUGGING

- (IBAction)showSelectedControlInfo:(id)sender;

@end
