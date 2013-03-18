//
//  CCECardStyleDocument.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 2/15/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "CCECardStyleDocument.h"
#import "NSManagedObject+CCESerializer.h"
#import "CCEManagedObjectModels.h"
#import "CommonStrings.h"
#import "AppDelegate.h"
#import "CCEFileOps.h"
#import "FixedNSImageView.h"

@interface CCECardStyleDocument ()

@property IBOutlet NSTextField *label;
@property IBOutlet NSTextField *renameTo;
@property IBOutlet FixedNSImageView *image;
@property IBOutlet NSWindow *window;

@property NSDictionary *representation;
@property NSURL *packageUrl;

@property BOOL nibLoaded;
@property BOOL representationLoaded;

@property AppDelegate *delegate;

@property NSFileWrapper *artworkFile;

- (void)buildRepresentationFrom:(NSManagedObject *)cardStyle;

- (void)showImport;

@end

NSString *cceStyledocType = @"cardstyle";

static NSString *cceArtwork = @"artwork";
static NSString *cceCardData = @"cardData";

static NSString *dictKey = @"dict";

@implementation CCECardStyleDocument

@synthesize window;
@synthesize label;
@synthesize renameTo;
@synthesize image;

@synthesize representation;
@synthesize packageUrl;

@synthesize nibLoaded;
@synthesize representationLoaded;

@synthesize artworkFile;

@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
    }
    return self;
}

- (NSString *)windowNibName
{
    return @"CCECardStyleDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    
    nibLoaded = YES;
    [self showImport];
}

- (BOOL)windowShouldClose:(id)sender
{
        // ensure close occurs after we go out of scope
    CCECardStyleDocument * __strong holder = self;

    if (window == sender) {
        if (delegate && [delegate respondsToSelector:@selector(documentWillClose:)]) {
            [delegate documentWillClose:self];
        }
    }
    
    holder.representation = nil;
    return YES;
}

- (void)showImport
{
    if (!representationLoaded || !nibLoaded)
        return;
    
    NSString *cardName = [representation valueForKey:@"cardName"];
    NSImage *art = [[NSImage alloc] initWithData:[artworkFile regularFileContents]];
    
    [image setImage:art];
    
    [label setStringValue:cardName];
    [renameTo setStringValue:cardName];
    
    [window makeKeyAndOrderFront:self];
}

+ (NSArray *)allowedFileTypes
{
    return @[cceStyledocType];
}

- (NSFileWrapper *)fileWrapperOfType:(NSString *)typeName error:(NSError **)outError
{
    if (![self validateType:typeName error:outError]) {
        return nil;
    }
    
        // artwork
    NSString *dictUrl = [representation valueForKey:@"fileUrl"];
    NSURL *artworkUrl = [NSURL fileURLWithPath:dictUrl];
    NSData *artworkData = [NSData dataWithContentsOfURL:artworkUrl];
    
    NSFileWrapper *artwork = [[NSFileWrapper alloc] initRegularFileWithContents:artworkData];
    [artwork setPreferredFilename:cceArtwork];
    
        // data
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archiver encodeObject:representation forKey:dictKey];
    [archiver finishEncoding];
    
    NSFileWrapper *dataFile = [[NSFileWrapper alloc] initRegularFileWithContents:data];
    [dataFile setPreferredFilename:cceCardData];
    
    NSFileWrapper *package = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:@{
                                                                       cceArtwork: artwork,
                                                                      cceCardData: dataFile
                              }];
    
    return package;
}

- (BOOL)readFromFileWrapper:(NSFileWrapper *)fileWrapper
                     ofType:(NSString *)typeName
                      error:(NSError *__autoreleasing *)outError
{
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    NSError *error = nil;
    @try {
        if (![self validateType:typeName error:&error]) {
            return NO;
        }
        if (![fileWrapper isDirectory]) {
            error = [NSError errorWithDomain:applicationDomain code:100 userInfo:@{@"BadFileType": [NSNull null]}];
            return NO;
        }
        
        NSDictionary *wrappers = [fileWrapper fileWrappers];    // i.e., the entrails
        
        artworkFile = [wrappers valueForKey:cceArtwork];
        NSFileWrapper *data = [wrappers valueForKey:cceCardData];
        if (artworkFile == nil || data == nil) {
            error = [NSError errorWithDomain:applicationDomain code:101 userInfo:@{
                        @"Corrupted file": [NSNumber numberWithBool:YES],
                           @"dataMissing": [NSNumber numberWithBool:data == nil],
                        @"artworkMissing": [NSNumber numberWithBool:artworkFile == nil]
                     }];
            return NO;
        }
        
        NSData *cardData = [data regularFileContents];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:cardData];
        representation = [unarchiver decodeObjectForKey:dictKey];
        [unarchiver finishDecoding];
        representationLoaded = YES;
        
        [self showImport];
    }
    @catch (NSException *exception) {
            // swallow
        NSLog(@"exception: %@", exception);
    }
    @finally {
        if (outError != NULL)
            *outError = error;
    }
    
    return error == nil;
}


+ (void)exportCardStyle:(NSManagedObject *)card
{
    CCECardStyleDocument *document = [CCECardStyleDocument new];
    
    [document buildRepresentationFrom:card];
    [document doSave];

}

+ (void)customizeOpenPanel:(NSOpenPanel *)panel
{
    [panel setMessage:NSLocalizedString(@"Import from:", @"Import from:")];
    [panel setPrompt:NSLocalizedString(@"Import", @"Import")];
    [panel setTitle:NSLocalizedString(@"Import Card Definition", @"Import Card Definition")];
}

+ (void)importCardStyle
{
    [self doOpen];
}

+ (void)completeOpen:(NSOpenPanel *)panel
          withResult:(NSInteger)result
{
    if (result == NSFileHandlingPanelOKButton) {
        NSURL *url = [[panel URLs] objectAtIndex:0];
        CCECardStyleDocument *doc =
        [[CCECardStyleDocument alloc] initWithContentsOfURL:url
                                                     ofType:[url pathExtension]
                                                      error:NULL];
        if (!result) {
            NSBeep();
        } else {
            AppDelegate *delegate = (AppDelegate *)[NSApp delegate];
            [doc makeWindowControllers];
            [doc showWindows];
            [doc setDelegate:delegate];
            [delegate documentHasOpened:doc];
        }
    }
}

    // Turn the card object into a dictionary; exclude _instances_ of the card.
- (void)buildRepresentationFrom:(NSManagedObject *)cardStyle
{
    NSSet *excludeSet = [NSSet setWithObjects:@"cards", @"values", nil];
    representation = [cardStyle toDictionaryExcludingKeys:excludeSet excludeLevels:2];
}

- (void)customizeSavePanel:(NSSavePanel *)panel
{
    [panel setPrompt:NSLocalizedString(@"Export", @"Export")];
    [panel setNameFieldStringValue:[representation valueForKey:@"cardName"]];
    [panel setTitle:NSLocalizedString(@"Export Card Definition", @"Export Card Definition")];

}

- (IBAction)importButton:(id)sender
{
    [self doImport];
    [window performClose:sender];
}

- (IBAction)cancel:(id)sender
{
    [window performClose:sender];
}

- (void)doImport
{
    NSError *error = nil;
    BOOL copiedArtwork = NO;
    NSManagedObjectContext *context = nil;
    CCEFileOps *fileMgr = nil;
    
    context = [(AppDelegate *)[NSApp delegate] managedObjectContext];
    
    NSManagedObject *cardType = nil;
    if (context != nil) {
        cardType = [NSManagedObject createManagedObjectFromDictionary:representation
                                                            inContext:context];
        if (cardType == nil) {
            error = [NSError errorWithDomain:applicationDomain
                                        code:2001
                                    userInfo:@{@"badRepresentation": [NSNumber numberWithBool:YES]}];
        } else {
            NSString *newname = [renameTo stringValue];
            if (newname != nil)
                cardType.cardName = newname;
        }
        
        if (error == nil) {
                // copy artwork?
            fileMgr = [CCEFileOps instance];
            NSString *path = cardType.fileUrl;
            NSURL *asFile = [fileMgr appSupportFileURL:path];
            if (![fileMgr fileExistsAtURL:asFile]) {
                error = [fileMgr writeFileAtURL:asFile
                                       withData:[artworkFile regularFileContents]
                                 withAttributes:[artworkFile fileAttributes]];
                copiedArtwork = error == nil;
            }
        }
    }
    
    if (error) {
        if (cardType != nil)
            [context deleteObject:cardType];
        if (copiedArtwork) {
                // TODO remove copied artwork!
        }
            // TODO display error
        NSLog(@"Error: %@", error);
    }
}

@end
