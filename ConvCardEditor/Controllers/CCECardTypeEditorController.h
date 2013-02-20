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

@property NSManagedObject *cardType;

@property IBOutlet NSTextField *artworkFileName;
@property IBOutlet NSTextField *cardTypeName;

@property IBOutlet CCEControlsViewController *controlsView;

@property (weak, readonly) NSManagedObjectContext *managedObjectContext;

@property NSMutableSet *viewControllers;

    // create/edit card
- (IBAction)editNewCardType:(id)sender;
//- (IBAction)editCardType:(id)sender;
- (IBAction)openCard:(id)sender;

- (IBAction)changeArtwork:(id)sender;


    // controls
- (void)activateEditorWindow:(CCEControlsViewController *)viewController;

- (void)editorWindowClosing:(CCEControlsViewController *)controller;

@end
