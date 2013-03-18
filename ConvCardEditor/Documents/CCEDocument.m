//
//  CCEDocument.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 3/17/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "CCEDocument.h"
#import "CommonStrings.h"
#import "CCEFileOps.h"

@interface CCEDocument ()

@end

@implementation CCEDocument

+ (BOOL)autosavesInPlace
{
    return YES;
}

    // subclass responsibility; default returns nil (all allowed)
- (NSArray *)allowedFileTypes
{
    return [[self class] allowedFileTypes];
}
+ (NSArray *)allowedFileTypes
{
    return nil;
}

- (BOOL)validateType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    if ([self.allowedFileTypes indexOfObject:typeName] == NSNotFound) {
        if (outError) {
            NSString *errStr = NSLocalizedString(@"inappropriate data type: ", @"inappropriate data type");
            NSString *qualErrStr = [errStr stringByAppendingString:typeName];
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: qualErrStr};
            *outError = [NSError errorWithDomain:applicationDomain
                                            code:-50
                                        userInfo:userInfo];
        }
        return NO;
    }

    return YES;
}

- (void)customizeSavePanel:(NSSavePanel *)panel
{
        // subclass responsibility
}

- (void)doSave
{
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel setMessage:NSLocalizedString(@"Export to:", @"Export to:")];
    [savePanel setAllowedFileTypes:[self allowedFileTypes]];
    [savePanel setCanSelectHiddenExtension:YES];
    [savePanel setExtensionHidden:YES];
    [savePanel setTreatsFilePackagesAsDirectories:NO];
    
    [self customizeSavePanel:savePanel];
    
    [savePanel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSError *error;
            NSURL *dest = [savePanel URL];
            NSURL *temp = nil;
            CCEFileOps *fileOps = [CCEFileOps instance];
            if ([fileOps fileExistsAtURL:dest]) {
                temp = [fileOps safeRemoveFile:dest];
            }
            
            BOOL did = [self writeToURL:dest ofType:dest.pathExtension error:&error];
            
            if (!did) {
                NSLog(@"Error %@", error);
                [fileOps undoSafeRemoveFile:temp backTo:dest];
            } else {
                [fileOps finalizeRemoveFile:temp];
            }
        }
    }];
}

+ (void)customizeOpenPanel:(NSOpenPanel *)panel
{
        // subclass responsibility
}
+ (void)doOpen
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    
    [openPanel setAllowedFileTypes:[self allowedFileTypes]];
    [openPanel setExtensionHidden:YES];
    [openPanel setTreatsFilePackagesAsDirectories:NO];

    [self customizeOpenPanel:openPanel];
    
    [openPanel beginWithCompletionHandler:^(NSInteger result) {
        [self completeOpen:openPanel withResult:result];
    }];
}
+ (void)completeOpen:(NSOpenPanel *)panel
          withResult:(NSInteger)result
{
        // subclass responsibility
}

@end
