//
//  CCECardTypeEditorController.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/3/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>


@class CCEControlsViewController;
@class CCEModelledControl;

@interface CCECardTypeEditorController : NSResponder <NSWindowDelegate>

    // Top objects in the nib; these need to be cleaned up manually.
@property NSArray *topObjects;

@property (weak) IBOutlet NSView *cardTypeHeaderView;
@property NSManagedObject *cardType;
@property (weak) IBOutlet NSTextField *artworkFileName;

@property (weak) IBOutlet NSView *partnershipHeaderView;
@property NSManagedObject *partnership;

@property IBOutlet CCEControlsViewController *controlsView;

@property (weak, readonly) NSManagedObjectContext *managedObjectContext;

    // editMode is YES to edit the card itself, NO to edit the partnership agreements
@property BOOL editMode;

    // create/edit card
- (IBAction)editNewCardType:(id)sender;
//- (IBAction)editCardType:(id)sender;
- (IBAction)openCard:(id)sender;

- (IBAction)changeArtwork:(id)sender;


    // create/edit partnership
- (IBAction)createPartnership:(id)sender;
- (IBAction)editPartnership:(id)sender;

    // controls
- (void)activateEditorWindow:(CCEControlsViewController *)viewController;

- (void)editorWindowClosing:(CCEControlsViewController *)controller;

+ (NSInteger)count;

@end
