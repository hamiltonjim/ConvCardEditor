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

enum EViewType {
    kCardType = 0,
    kPartnershipType
};

static NSInteger s_count;

@interface CCECardTypeEditorController ()

- (void)fitWindowToArtwork:(NSURL *)url;
- (void)finishLoadingCard;

- (AppDelegate *)cceAppDelegate;

- (void)loadCardImage;

- (void)showHeaderType:(NSInteger)type;

@end

@implementation CCECardTypeEditorController

@synthesize cardTypeHeaderView;
@synthesize cardType;
@synthesize artworkFileName;
@synthesize cardTypeName;

@synthesize partnershipHeaderView;
@synthesize partnership;
@synthesize partnershipName;

@synthesize controlsView;

@synthesize viewControllers;

@synthesize managedObjectContext;

@synthesize editMode;

+ (NSInteger)count
{
    return s_count;
}

- (void)dealloc
{
    --s_count;
}

- (AppDelegate *)cceAppDelegate
{
    return (AppDelegate *) [NSApp delegate];
}

- (void)awakeFromNib
{
    ++s_count;
    managedObjectContext = [[self cceAppDelegate] managedObjectContext];
    
    [controlsView setController:self];
    
    @synchronized([self class]) {
        if (viewControllers == nil) {
            viewControllers = [NSMutableSet set];
        }
    }
    [viewControllers addObject:self];
}

- (IBAction)editNewCardType:(id)sender
{
    NSManagedObjectContext *moc = [self managedObjectContext];
    if (moc == nil) {
        [NSException raise:@"NoManagedObjectContext" format:@"No managed object context"];
    }
    
    self.cardType = [NSEntityDescription insertNewObjectForEntityForName:@"CardType"
                                                  inManagedObjectContext:moc];
    
    editMode = YES;
    [self changeArtwork:sender];
}

- (void)loadCardImage
{
    NSURL *url = [NSURL fileURLWithPath:[cardType fileUrl]];
    [controlsView setImageWithURL:url];
    
    [artworkFileName setStringValue:[cardType filename]];
}

- (IBAction)openCard:(id)sender
{
    [self loadCardImage];
    
    editMode = YES;
    [self finishLoadingCard];
}

- (IBAction)createPartnership:(id)sender
{
    
    NSManagedObjectContext *moc = [self managedObjectContext];
    self.partnership = [NSEntityDescription insertNewObjectForEntityForName:@"ConventionCard"
                                                     inManagedObjectContext:moc];
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    partnership.partnershipName = [NSString stringWithFormat:@"%@-%ld", cardType.cardName, (NSInteger)now];
    partnership.cardType = self.cardType;
    
    [self loadCardImage];
    editMode = NO;
    [self finishLoadingCard];
}

- (void)editPartnership:(id)sender
{
    [self loadCardImage];
    
    editMode = NO;
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
    
    if (editMode) {
        [controlsView load:cardType editMode:YES];
        [self showHeaderType:kCardType];
    } else {
        [controlsView load:cardType for:partnership];
        [self showHeaderType:kPartnershipType];
    }
    
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
    [viewControllers removeObject:self];
    controller = nil;
}

- (void)showHeaderType:(NSInteger)type
{
    switch (type) {
        case kCardType:
            [cardTypeHeaderView setHidden:NO];
            [partnershipHeaderView setHidden:YES];
            break;
            
        case kPartnershipType:
            [cardTypeHeaderView setHidden:YES];
            [partnershipHeaderView setHidden:NO];
            break;
            
        default:
            break;
    }
}

@end
