//
//  CCEPartnershipDocument.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 3/16/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "CCEPartnershipDocument.h"
#import "NSManagedObject+CCESerializer.h"
#import "CCEManagedObjectModels.h"
#import "CCEModelledControl.h"
#import "CommonStrings.h"
#import "AppDelegate.h"
#import "CCEFileOps.h"
#import "CCEEntityFetcher.h"
#import "CCEDuplicateNamer.h"

    // object keys
static NSString *partnershipNameKey = @"partnershipName";
static NSString *fontNameKey = @"fontName";

static NSString *cardNameKey = @"cardName";
static NSString *controlNameKey = @"controlName";
static NSString *controlTypeKey = @"controlType";

static NSString *valueKey = @"value";

static NSString *values = @"values";

static NSString *problemKey = @"problem";

    // KVO key under observation
static NSString *selectionKey = @"selection";

@interface CCEPartnershipDocument ()

@property AppDelegate *delegate;

@property NSDictionary *representation;

@property BOOL nibLoaded;
@property BOOL representationLoaded;

@property (weak) IBOutlet NSTextField *cardNameLabel;
@property (weak) IBOutlet NSTextField *partnershipLabel;
@property (weak) IBOutlet NSTextField *suggestedPartnershipName;
@property (weak) IBOutlet NSArrayController *cardTypes;

@property IBOutlet NSWindow *window;

@property NSManagedObjectContext *context;

@property IBOutlet NSPanel *importResultsPanel;
@property (weak) IBOutlet NSArrayController *importResultsCtlr;

@property NSManagedObject *createdPartnership;

- (void)buildRepresentationFrom:(NSManagedObject *)partnership;

- (void)showImport;
- (NSString *)suggestNameFor:(NSString *)partnershipName
                    withCard:(NSString *)cardName;

- (void)showResults:(NSSet *)cardValues
             errors:(NSArray *)errors
         mismatches:(NSArray *)mismatches;
- (BOOL)addDupFor:(NSString *)dupName inList:(NSArray *)list;

- (IBAction)buttonImport:(id)sender;

@end

enum EImportSheetResult {
    kCancelImport = 0,
    kAcceptImport,
    kRetryImport
};

static NSString *partnershipDocument = @"partnership";

@implementation CCEPartnershipDocument

@synthesize delegate;
@synthesize representation;

@synthesize nibLoaded;
@synthesize representationLoaded;

@synthesize cardNameLabel;
@synthesize partnershipLabel;
@synthesize suggestedPartnershipName;
@synthesize cardTypes;

@synthesize window;

@synthesize context;

@synthesize createdPartnership;

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
    return @"CCEPartnershipDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    nibLoaded = YES;
    [self showImport];
}

+ (NSArray *)allowedFileTypes
{
    return @[partnershipDocument];
}

- (NSFileWrapper *)fileWrapperOfType:(NSString *)typeName error:(NSError **)outError
{
    if (![self validateType:typeName error:outError]) {
        return nil;
    }
    
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]
                                 initForWritingWithMutableData:data];
    
    [archiver setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archiver encodeObject:representation forKey:values];
    [archiver finishEncoding];
    
    NSFileWrapper *wrapper = [[NSFileWrapper alloc] initRegularFileWithContents:data];
    
    return wrapper;
}

- (BOOL)readFromFileWrapper:(NSFileWrapper *)fileWrapper
                     ofType:(NSString *)typeName
                      error:(NSError *__autoreleasing *)outError
{
    NSError *error = nil;
    
    @try {
        if (![self validateType:typeName error:&error]) {
            return NO;
        }
        
        NSData *partnershipData = [fileWrapper regularFileContents];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]
                                         initForReadingWithData:partnershipData];
        representation = [unarchiver decodeObjectForKey:values];
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

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (void)customizeSavePanel:(NSSavePanel *)panel
{
    [panel setPrompt:NSLocalizedString(@"Export", @"Export")];
    [panel setNameFieldStringValue:[representation valueForKey:partnershipNameKey]];
    [panel setTitle:NSLocalizedString(@"Export Partnership",
                                      @"Export Partnership")];
}

    // Turn the partnership object into a dictionary; exclude card definition.
- (void)buildRepresentationFrom:(NSManagedObject *)partnership
{
    NSMutableDictionary *valueDict = [NSMutableDictionary dictionary];
    
    [valueDict setValue:partnership.partnershipName forKey:partnershipNameKey];
    [valueDict setValue:partnership.fontName forKey:fontNameKey];
    [valueDict setValue:partnership.cardType.cardName forKey:cardNameKey];
    
    NSMutableArray *iValues = [NSMutableArray arrayWithCapacity:partnership.values.count];
    for (NSManagedObject *setting in partnership.values) {;
        CCEModelledControl *model = setting.controls;
        NSString *ctlName = model.name;
        NSString *ctlType = model.controlType;
        
        NSDictionary *aValueD = [NSDictionary dictionaryWithObjectsAndKeys:
                                 setting.value, valueKey,
                                 ctlName, controlNameKey,
                                 ctlType, controlTypeKey,
                                 nil];
        [iValues addObject:aValueD];
    }
    
    [valueDict setValue:iValues forKey:values];
    representation = valueDict;
}

+ (void)exportPartnership:(NSManagedObject *)partnership
{
    CCEPartnershipDocument *document = [CCEPartnershipDocument new];
    
    [document buildRepresentationFrom:partnership];
    [document doSave];
}

+ (void)importPartnership
{
    [self doOpen];
}

+ (void)customizeOpenPanel:(NSOpenPanel *)panel
{
    [panel setMessage:NSLocalizedString(@"Import from:", @"Import from")];
    [panel setPrompt:NSLocalizedString(@"Import", @"Import")];
    [panel setTitle:NSLocalizedString(@"Import partnership agreements",
                                      @"Import partnership agreements")];
}

+ (void)completeOpen:(NSOpenPanel *)panel withResult:(NSInteger)result
{
    if (result == NSFileHandlingPanelOKButton) {
        NSURL *url = [[panel URLs] objectAtIndex:0];
        CCEPartnershipDocument *doc = [[CCEPartnershipDocument alloc]
                                       initWithContentsOfURL:url
                                       ofType:[url pathExtension]
                                       error:NULL];
        AppDelegate *delegate = (AppDelegate *)[NSApp delegate];
        [doc setDelegate:delegate];
        [doc makeWindowControllers];
        [doc showWindows];
        [delegate documentHasOpened:doc];        
    }
}

- (void)showImport
{
    if (!representationLoaded || !nibLoaded)
        return;
    
        // get NSManagedObjectContext from App delegate
    context = delegate.managedObjectContext;
    
    NSUInteger options = NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew;
    [cardTypes addObserver:self
                forKeyPath:selectionKey
                   options:options
                   context:NULL];
    
    [window makeKeyAndOrderFront:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object == cardTypes && [keyPath isEqualToString:selectionKey]) {
        NSString *cardName = [representation valueForKey:cardNameKey];
        NSString *partnershipName = [representation valueForKey:partnershipNameKey];
        
        [cardNameLabel setStringValue:cardName];
        [partnershipLabel setStringValue:partnershipName];
        [suggestedPartnershipName setStringValue:[self suggestNameFor:partnershipName
                                                             withCard:cardName]];

    }
}

- (NSString *)suggestNameFor:(NSString *)partnershipName
                    withCard:(NSString *)cardName
{
        // get card type matching card type name...
    NSManagedObject *cardType = [[CCEEntityFetcher instance] cardTypeWithName:cardName];
    if (cardType == nil) {
        return partnershipName;
    }
    
    [cardTypes setSelectedObjects:[NSArray arrayWithObject:cardType]];
    
    NSString *suggName = partnershipName;
    CCEDuplicateNamer *namer = [CCEDuplicateNamer instance];
    do {
        NSSet *pset = [cardType.cards objectsPassingTest:
                       ^BOOL(NSManagedObject *obj, BOOL *stop) {
                           return [obj.partnershipName isEqualToString:suggName];
                       }];
        if (pset.count == 0) {
            break;
        }
        suggName = [namer nameForDuplicateOfName:suggName];
    } while (YES);
    
    return suggName;
}

- (IBAction)importButton:(id)sender
{
    [self doImport];
//    [window performClose:sender];
}

- (IBAction)cancel:(id)sender
{
    [window performClose:sender];
}

- (void)doImport
{
    if (cardTypes.selectedObjects.count < 1) {
        NSDictionary *userInfo =
        @{NSLocalizedDescriptionKey: NSLocalizedString(@"No card type selected",
                                                       @"No card type selected")};
        NSError *error = [NSError errorWithDomain:applicationDomain
                                             code:2101
                                         userInfo:userInfo];
        [self displayError:error];
        return;
    }
    
    NSManagedObject *cardType = [cardTypes.selectedObjects objectAtIndex:0];
    
    createdPartnership =
    [NSEntityDescription insertNewObjectForEntityForName:@"ConventionCard"
                                  inManagedObjectContext:context];
    createdPartnership.partnershipName = suggestedPartnershipName.stringValue;
    createdPartnership.fontName = [representation valueForKey:fontNameKey];
    
    NSMutableSet *cards = [cardType mutableSetValueForKey:@"cards"];
    [cards addObject:createdPartnership];
    
        // match each setting to the corresponding control model
    NSManagedObject *settingModel;
    NSMutableSet *cardValues = [createdPartnership mutableSetValueForKey:values];
        // ...keep any mismatches in a separate set
    NSMutableArray *mismatches = [NSMutableSet set];
        // ...and other errors as well
    NSMutableArray *importErrors = [NSMutableSet set];
    NSString *dupErrStr
    = NSLocalizedString(@"ERROR: card has multiple controls named %@",
                        @"ERROR: multiple controls named");
    
    NSArray *iValues = [representation valueForKey:values];
    CCEEntityFetcher *fetcher = [CCEEntityFetcher instance];
    for (NSDictionary *value in iValues) {
        NSString *ctlName = [value valueForKey:controlNameKey];
        if (ctlName == nil)
            continue;
        
        NSSet *ctlSet = [fetcher modelByName:ctlName
                                 controlType:[value valueForKey:controlTypeKey]
                                     inModel:cardType];
        switch (ctlSet.count) {
            case 0:
                [mismatches addObject:value];
                break;
                
            case 1:
                settingModel = [NSEntityDescription
                                insertNewObjectForEntityForName:@"Setting"
                                inManagedObjectContext:context];
                settingModel.value = [value valueForKey:valueKey];
                [cardValues addObject:settingModel];
                [[[ctlSet anyObject] mutableSetValueForKey:values]
                 addObject:settingModel];
                break;
                
            default:
                    // error: multiple controls with same name
                if ([self addDupFor:ctlName inList:importErrors]) {
                    NSMutableDictionary *vdict = [value mutableCopy];
                    NSString *pstr = [NSString stringWithFormat:dupErrStr, ctlName];
                    [vdict setObject:pstr forKey:problemKey];
                    [importErrors addObject:vdict];
                }
                break;
        }
    }
    
        // TODO:  Errors & mismatches
    [self showResults:cardValues errors:importErrors mismatches:mismatches];
}

    // if there's a duplicate, it sure might be listed twice; prevent this
- (BOOL)addDupFor:(NSString *)dupName inList:(NSArray *)list
{
    BOOL needed = YES;
    for (NSDictionary *aDict in list) {
        if ([dupName isEqualToString:[aDict valueForKey:controlNameKey]]) {
            needed = NO;
            break;
        }
    };
    
    return needed;
}

- (void)showResults:(NSSet *)cardValues
             errors:(NSArray *)errors
         mismatches:(NSArray *)mismatches
{
    NSMutableArray *importList = [NSMutableArray array];
    
    NSDictionary *separator = @{
                                controlNameKey: @"",
                                valueKey:@"",
                                problemKey: @""
                                };
    
        // errors, straight up
    if (errors.count) {
        [importList addObjectsFromArray:errors];
        [importList addObject:separator];
    }
    
        // mismatches, describe
    if (mismatches.count) {
        NSString *mismatchStr = NSLocalizedString(@"No matching control in card",
                                                  @"No matching control in card");
        for (NSDictionary *mDict in mismatches) {
            NSMutableDictionary *md = [mDict mutableCopy];
            [md setObject:mismatchStr forKey:problemKey];
            [importList addObject:md];
        }
        [importList addObject:separator];
    }
    
        // successful items
    if (cardValues.count) {
        for (NSManagedObject *obj in cardValues) {
            NSDictionary *dct = @{
                                  controlNameKey: obj.controls.name,
                                  valueKey: obj.value/*,
                                  problemKey: [NSNull null]*/
                                  };
            [importList addObject:dct];
        }
    }

    [_importResultsCtlr setContent:importList];
    
    [NSApp beginSheet:_importResultsPanel
       modalForWindow:window
        modalDelegate:nil
       didEndSelector:nil
          contextInfo:NULL];
    
    NSInteger modalVal = [NSApp runModalForWindow:_importResultsPanel];
    
    [NSApp endSheet:_importResultsPanel];
    [_importResultsPanel orderOut:self];
    
    switch (modalVal) {
        case kCancelImport:
            [context deleteObject:createdPartnership];
            createdPartnership = nil;
                // fall thru to close window
            
        case kAcceptImport:
            [window close];
            break;
            
        case kRetryImport:
            [context deleteObject:createdPartnership];
            createdPartnership = nil;
            break;
            
        default:
            break;
    }
    
    [_importResultsCtlr setContent:nil];
}

- (IBAction)buttonImport:(id)sender
{
    [NSApp stopModalWithCode:[sender tag]];
}

- (BOOL)windowShouldClose:(id)sender
{
    if (window == sender) {
        [cardTypes removeObserver:self forKeyPath:selectionKey];
        if (delegate && [delegate respondsToSelector:@selector(documentWillClose:)]) {
            [delegate documentWillClose:self];
        }
    }
    
    return YES;
}

@end
