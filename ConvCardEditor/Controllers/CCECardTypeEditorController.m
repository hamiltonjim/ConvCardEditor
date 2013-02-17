//
//  CCECardTypeEditorController.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/3/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "CCECardTypeEditorController.h"
#import "CCEManagedObjectModels.h"
#import "CommonStrings.h"
#import "NSView+ScaleUtilities.h"
#import "CCEFileOps.h"
#import "AppDelegate.h"
#import "CCDebuggableControlEnable.h"
#import "CCEControlsViewController.h"
#import "CCEModelledControl.h"
#import "CCEMultiCheckModel.h"
#import "CCEUnitTransformer.h"
#include "fuzzyMath.h"

@interface CCECardTypeEditorController ()

- (void)fitWindowToArtwork:(NSURL *)url;
- (void)finishLoadingCard;

- (AppDelegate *)cceAppDelegate;

@end

@implementation CCECardTypeEditorController

@synthesize cardType;

@synthesize artworkFileName;
@synthesize cardTypeName;

@synthesize controlsView;

@synthesize viewControllers;

@synthesize managedObjectContext;

- (void)dealloc
{
    NSLog(@"%@ dealloc", [self class]);
}

- (AppDelegate *)cceAppDelegate
{
    return (AppDelegate *) [NSApp delegate];
}

- (void)awakeFromNib
{
    managedObjectContext = [[self cceAppDelegate] managedObjectContext];
    
    [controlsView setController:self];
    
    [viewControllers addObject:controlsView];
}

- (IBAction)editNewCardType:(id)sender
{
    NSManagedObjectContext *moc = [self managedObjectContext];
    if (moc == nil) {
        [NSException raise:@"NoManagedObjectContext" format:@"No managed object context"];
    }
    
    self.cardType = [NSEntityDescription insertNewObjectForEntityForName:@"CardType" inManagedObjectContext:moc];
    
    [self changeArtwork:sender];
}

- (IBAction)openCard:(id)sender
{
    NSURL *url = [NSURL fileURLWithPath:[cardType fileUrl]];
    [controlsView setImageWithURL:url];
    
    [artworkFileName setStringValue:[cardType filename]];
    
    [self finishLoadingCard];
}

- (IBAction)changeArtwork:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    
    [panel setAllowsMultipleSelection:NO];
    [panel setAllowedFileTypes:[NSImage imageFileTypes]];
    
    [panel beginWithCompletionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            NSURL *url = [[panel URLs] objectAtIndex:0];
            [self fitWindowToArtwork:url];
        }
    }];
}

- (void)fitWindowToArtwork:(NSURL *)url
{
        // copy file to ApplicationSupport folder; delete old file if necessary
    NSURL *oldFile = nil;
    NSURL *trashedOldFile = nil;
    
    CCEFileOps *fileOps = [CCEFileOps instance];
    
    @try {
        if ([[cardType fileUrl] length] > 0) {
            oldFile = [NSURL fileURLWithPath:[cardType fileUrl]];
            trashedOldFile = [fileOps safeRemoveFile:oldFile];
        }
        
        NSURL *newFile = [fileOps copyFileToAppSupport:url];
        [cardType setFileUrl:[newFile path]];
        [controlsView setImageWithURL:newFile];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", [exception description]);
        NSString *message;
        if ([[exception name] isEqualToString:CCEF_BadFileURL]) {
            message = NSLocalizedString(@"No file specified for operation", @"");
        } else if ([[exception name] isEqualToString:CCEF_FileMoveError]) {
            message = NSLocalizedString(@"Could not remove old file", @"");
        } else if ([[exception name] isEqualToString:CCEF_FileCopyError]) {
            message = NSLocalizedString(@"Could not copy image file", @"");
        }
        
        NSRunAlertPanel(nil, message, nil, nil, nil);
        [fileOps undoSafeRemoveFile:trashedOldFile backTo:oldFile];
        trashedOldFile = nil;
    }
    @finally {
        [fileOps finalizeRemoveFile:trashedOldFile];
    }

    NSString *filename = [url lastPathComponent];
    [cardType setFilename:filename];
    [artworkFileName setStringValue:filename];
    
    [self finishLoadingCard];
}

- (void)finishLoadingCard
{
        // resize
    NSSize iSize = [controlsView imageSize];
    
    [cardType setWidth:[NSNumber numberWithDouble:iSize.width]];
    [cardType setHeight:[NSNumber numberWithDouble:iSize.height]];
    
    [controlsView load:cardType editMode:YES];
    
    [controlsView showWindow:self];
}

- (void)activateEditorWindow:(CCEControlsViewController *)viewController
{
    if (viewController != controlsView) {
        [controlsView resignFront];
        controlsView = viewController;
    }
}

- (void)editorWindowClosing:(CCEControlsViewController *)controller
{
    [viewControllers removeObject:controller];
}

@end
