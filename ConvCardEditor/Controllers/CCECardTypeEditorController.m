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
#import "CCEColorBindableButtonCell.h"
#import "CCDebuggableControlEnable.h"
#import "CCEControlsViewController.h"
#import "CCEModelledControl.h"
#import "CCEToolPaletteController.h"

static NSString *showGrid;
static NSString *hideGrid;

@interface CCECardTypeEditorController ()

@property (readwrite) NSString *gridStateLabel;

- (void)fitWindowToArtwork:(NSURL *)url;
- (void)finishLoadingCard;

- (void)rescale:(double)newScale;

- (AppDelegate *)cceAppDelegate;

- (void)infoPanelInit;

@end

@implementation CCECardTypeEditorController

@synthesize window;
@synthesize type;
@synthesize cardControlType;

@synthesize artworkFileName;
@synthesize cardTypeName;

@synthesize cardImageView;
@synthesize controlsView;

@synthesize chooseCardTypePanel;
@synthesize cardTypesCol;
@synthesize cardChooser;

@synthesize infoPanel;
@synthesize controlColorWell;
@synthesize stdControlColorGroup;

@synthesize xField;
@synthesize yField;
@synthesize widthField;
@synthesize heightField;

@synthesize selectedObject;
@synthesize locationObject;

@synthesize managedObjectContext;

@synthesize toolsPaletteController;

@synthesize gridState;
@synthesize gridStateLabel;

+ (void)initialize
{
    if (self == [CCECardTypeEditorController class]) {
        showGrid = NSLocalizedString(@"Show Grid", @"show grid label");
        hideGrid = NSLocalizedString(@"Hide Grid", @"hide grid label");
    }
}

- (AppDelegate *)cceAppDelegate
{
    return (AppDelegate *) [NSApp delegate];
}

- (void)windowDidLoad
{
    [cardImageView setImageAlignment:NSImageAlignBottomLeft];
    [cardImageView setMaxZoom:[NSNumber numberWithDouble:4.0]];
    [cardImageView setMinZoom:[NSNumber numberWithDouble:1.0]];
    
    [cardImageView setAutoresizingMask:NSViewWidthSizable + NSViewHeightSizable];
    [cardImageView setAutoresizesSubviews:YES];
    
    self.gridState = [[NSUserDefaults standardUserDefaults] boolForKey:cceGridState];
    
    managedObjectContext = [[self cceAppDelegate] managedObjectContext];
    
    [controlsView setController:self];
    [self infoPanelInit];
}

- (IBAction)showWindow:(id)sender
{
    [window makeKeyAndOrderFront:sender];
}

- (BOOL)windowShouldClose:(id)sender {
    if (sender == window) {
        [sender orderOut:self];
    }
    
    return NO;
}

- (IBAction)setControlType:(id)sender
{
    NSInteger ccType = [sender tag];
    switch (ccType) {
        case kPointerControl:
        case kTextControl:
        case kSingleCheckboxControl:
        case kMultiCheckboxControl:
        case kCircleChoiceControl:
            cardControlType = (int)ccType;
            [controlsView setControlType:cardControlType];
            break;
            
        default:
            break;
    }


}

- (IBAction)newCardType:(id)sender
{
    NSManagedObjectContext *moc = [self managedObjectContext];
    if (moc == nil) {
        [NSException raise:@"NoManagedObjectContext" format:@"No managed object context"];
    }
    
    self.type = [NSEntityDescription insertNewObjectForEntityForName:@"CardType" inManagedObjectContext:moc];
    
    [self changeArtwork:sender];
}

- (IBAction)editCardType:(id)sender
{
    [chooseCardTypePanel makeKeyAndOrderFront:sender];
}

- (IBAction)openCard:(id)sender
{
    [chooseCardTypePanel orderOut:sender];
    self.type = [[cardChooser selectedObjects] objectAtIndex:0];
    
    NSURL *url = [NSURL fileURLWithPath:[type fileUrl]];
    [cardImageView setImageWithURL:url];
    
    [artworkFileName setStringValue:[type filename]];
    
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
        if ([[type fileUrl] length] > 0) {
            oldFile = [NSURL fileURLWithPath:[type fileUrl]];
            trashedOldFile = [fileOps safeRemoveFile:oldFile];
        }
        
        NSURL *newFile = [fileOps copyFileToAppSupport:url];
        [type setFileUrl:[newFile path]];
        [cardImageView setImageWithURL:newFile];
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
    [type setFilename:filename];
    [artworkFileName setStringValue:filename];
    
    [self finishLoadingCard];
}

- (void)finishLoadingCard
{
        // resize
    NSSize iSize = [cardImageView imageSize];
    
    [type setWidth:[NSNumber numberWithDouble:iSize.width]];
    [type setHeight:[NSNumber numberWithDouble:iSize.height]];
    
    [controlsView load:type editMode:YES];
    
        // scale
    NSNumber *scaleNumber = [[NSUserDefaults standardUserDefaults] valueForKey:ccDefaultScale];
    [self absoluteScale:scaleNumber];
    
    [self showWindow:self];
}

- (IBAction)absoluteScale:(id)sender
{
    double newScale;
    if ([sender isKindOfClass:[NSControl class]]) {
        NSControl *slider = (NSControl *)sender;
        newScale = [slider doubleValue];
    } else if ([sender isKindOfClass:[NSNumber class]]) {
        NSNumber *num = (NSNumber *)sender;
        newScale = [num doubleValue];
    } else {
        [NSException raise:@"UnrecognizedIdType"
                    format:@"sender (%@) is neither a NSControl nor NSNumber", sender];
    }
    
    [self rescale:newScale];
}

- (IBAction)scaleZero:(id)sender
{
    [cardImageView zoomImageToActualSize:sender];
}

- (IBAction)scaleLarger:(id)sender
{
    [cardImageView zoomIn:sender];
}

- (IBAction)scaleSmaller:(id)sender
{
    [cardImageView zoomOut:sender];
}

- (IBAction)scaleToWindow:(id)sender
{
    [cardImageView fill];
}

- (void)rescale:(double)newScale
{
//    [controlsView setScale:NSMakeSize(newScale, newScale)];
    [cardImageView setZoomFactor:newScale];
}


- (IBAction)coltrolInfo:(id)sender
{
    if ([infoPanel isVisible]) {
        [infoPanel orderOut:sender];
    } else {
        [infoPanel orderFront:sender];
    }
}

    // enable the "controls visible" mode when template window (or infoPanel) is key
- (void)windowDidBecomeKey:(NSNotification *)notification
{
    NSWindow *keyWindow = (NSWindow *)[notification object];
    if (keyWindow == window || keyWindow == infoPanel) {
        [CCDebuggableControlEnable setEnabled:YES];
    }
}

- (void)chooseNextControl
{
    [toolsPaletteController chooseNextControl];
}

    // disable "controls visible" when neither is key
- (void)windowDidResignKey:(NSNotification *)notification
{
    if ([window isKeyWindow] || [infoPanel isKeyWindow]) {
        return;
    }
    
    [CCDebuggableControlEnable setEnabled:NO];
}


- (IBAction)setControlColorCode:(id)sender
{
    if (![sender respondsToSelector:@selector(selectedCell)]) {
        return;
    }
    NSInteger code = [[sender selectedCell] tag];
    
    [controlColorWell setColor:[[self cceAppDelegate] colorForCode:code]];
}

- (IBAction)updateUnits:(id)sender
{
    [xField setNeedsDisplay:YES];
    [yField setNeedsDisplay:YES];
    [widthField setNeedsDisplay:YES];
    [heightField setNeedsDisplay:YES];
}

- (void)selectControlObject:(CCEModelledControl *)object
{
    [selectedObject setContent:object];
    
    if ([[object isIndexed] boolValue]) {
        
    } else {
        [locationObject setContent:[object valueForKey:@"location"]];
    }
    
    [infoPanel orderFront:self];
}

#pragma mark VALIDATION

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem
{
    if ([theItem action] == @selector(toggleGridState:)) {
        [theItem setLabel:gridStateLabel];
    }
    return type != nil;
}

- (BOOL)validateUserInterfaceItem:(NSObject <NSValidatedUserInterfaceItem> *)anItem
{
    if ([anItem action] == @selector(showSelectedControlInfo:)) {
        id obj = [selectedObject content];
        return obj != nil;
    } else if ([anItem action] == @selector(scaleLarger:)) {
        return [cardImageView canZoomIn];
    } else if ([anItem action] == @selector(scaleSmaller:)) {
        return [cardImageView canZoomOut];
    } else if ([anItem action] == @selector(toggleGridState:)) {
        if ([anItem isKindOfClass:[NSMenuItem class]]) {
            NSMenuItem *menuItem = (NSMenuItem *)anItem;
            [menuItem setState:gridState ? NSOnState : NSOffState];
        }
        return YES;
    }
    
    return YES;
}
- (IBAction)toggleGridState:(id)sender
{
    self.gridState = !gridState;
}

- (void)setGridState:(BOOL)state
{
    gridState = state;
    [[NSUserDefaults standardUserDefaults] setBool:state forKey:cceGridState];
    self.gridStateLabel = state ? hideGrid : showGrid;
    [controlsView setGridState:state];
}


#pragma mark WINDOW_INITIALIZATION

- (void)infoPanelInit
{
        // standard colors for controls
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    for (int index = kStandardColorsLowerBound; index < kNumberStandardColors; ++index) {
        CCEColorBindableButtonCell *cell = [stdControlColorGroup cellWithTag:index];
        
        if (cell == nil)
            continue;
        if (![cell isKindOfClass:[CCEColorBindableButtonCell class]])
            continue;
        
        [cell observeTextColorFrom:ud keypath:[CommonStrings standardColorKey:index]];
    }
}

#pragma mark WINDOW DELEGATE

- (void)windowWillClose:(NSNotification *)notification
{
    [infoPanel orderOut:self];
    [toolsPaletteController.toolsPalette orderOut:self];
}

- (void)windowDidBecomeMain:(NSNotification *)notification
{
    [toolsPaletteController.toolsPalette orderFront:self];
}

#pragma mark DEBUGGING

- (IBAction)showSelectedControlInfo:(id)sender
{
    CCEModelledControl *ctl = [selectedObject content];
    if (ctl == nil) {
        NSLog(@"No control is selected--abort");
        return;
    }
    
    NSRect frame, bounds;
    
    NSControl *selected = [ctl controlInView];
    frame = [selected frame];
    bounds = [selected bounds];
    
    NSLog(@"In itself: frame:%@ bounds:%@", NSStringFromRect(frame), NSStringFromRect(bounds));
    
        // in view
    [controlsView convertRect:frame fromView:selected];
    [controlsView convertRect:bounds fromView:selected];
    
    NSLog(@"In view: frame:%@ bounds:%@", NSStringFromRect(frame), NSStringFromRect(bounds));
    
        // in window
    [controlsView convertRect:frame toView:nil];
    [controlsView convertRect:bounds toView:nil];
    
    NSLog(@"In window: frame:%@ bounds:%@", NSStringFromRect(frame), NSStringFromRect(bounds));
    
    NSLog(@"un-nest view frames:");
    
    for (NSView *view = selected; view != nil; view = [view superview]) {
        NSLog(@"view %@ (%p): frame %@ zoom %g", NSStringFromClass([view class]), view,
              NSStringFromRect([view frame]), [view scale].width);
    }
}


@end
