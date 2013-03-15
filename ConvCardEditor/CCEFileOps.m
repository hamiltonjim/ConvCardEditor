//
//  CCEFileOps.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/10/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "CCEFileOps.h"
#import "CCEEntityFetcher.h"
#import "CommonStrings.h"

NSString *CCEF_BadFileURL = @"BadFileURL";
NSString *CCEF_FileMoveError = @"FileMoveError";
NSString *CCEF_FileCopyError = @"FileCopyError";

@interface CCEFileOps ()

- (NSFileManager *)fileManager;
- (NSURL *)genAppSupportURL;

@end

@implementation CCEFileOps

@synthesize appSupportURL;

static NSFileManager *fmgr = nil;
static CCEFileOps *theInstance = nil;

+ (CCEFileOps *)instance
{
    if (theInstance == nil) {
        theInstance = [CCEFileOps new];
    }
    return theInstance;
}

- (NSFileManager *)fileManager
{
    if (fmgr == nil) {
        fmgr = [NSFileManager defaultManager];
    }
    return fmgr;
}

- (NSURL *)genAppSupportURL
{
    if (appSupportURL == nil) {
        appSupportURL = [[self fileManager] URLForDirectory:NSApplicationSupportDirectory
                                                   inDomain:NSUserDomainMask
                                          appropriateForURL:nil
                                                     create:YES
                                                      error:nil];
        if (appSupportURL == nil) {
            [NSException raise:@"AppSupportDirectoryErr"
                        format:@"Application support directory could not be created"];
        }
    }

    return appSupportURL;
}

- (NSURL *)safeRemoveFile:(NSURL *)file
{
    if (file == nil) {
        [NSException raise:CCEF_BadFileURL format:@"original file URL is nil"];
    }
    
    NSError *error = nil;
    
    NSURL *tempDir = [NSURL fileURLWithPath:NSTemporaryDirectory()];
//    NSLog(@"tempDir is %@", tempDir);
    
    NSString *origFileName = [file lastPathComponent];
    NSURL *tempFile = [tempDir URLByAppendingPathComponent:origFileName];
    int counter = 0;
    while ([[self fileManager] fileExistsAtPath:[tempFile path]]) {
        tempFile = [tempDir URLByAppendingPathComponent:[NSString stringWithFormat:@"%@-%d",
                                                         origFileName, ++counter]];
    }
    
    if (![[self fileManager] moveItemAtURL:file toURL:tempFile error:&error]) {
        [NSException raise:CCEF_FileMoveError
                    format:@"Error moving file %@ to %@: %@", file, tempFile, error];
    }
    
    return tempFile;
}

- (NSURL *)copyFileToAppSupport:(NSURL *)file
{
    if (file == nil) {
        [NSException raise:CCEF_BadFileURL format:@"original file URL is nil"];
    }
    
    NSError *error = nil;
    
    [self genAppSupportURL];
    
    NSURL *asFile = [[NSURL alloc] initWithString:[file lastPathComponent] relativeToURL:appSupportURL];

    if (![[self fileManager] copyItemAtURL:file toURL:asFile error:&error]) {
        [NSException raise:CCEF_FileCopyError
                    format:@"Error copying file %@ to %@: %@", file, asFile, error];
    }

    return asFile;
}

- (NSError *)undoSafeRemoveFile:(NSURL *)trashFile backTo:(NSURL *)originalFile
{
    if (trashFile == nil || originalFile == nil) {
        return nil;
    }
    
    NSError *error = nil;
    [[self fileManager] moveItemAtURL:trashFile toURL:originalFile error:&error];
    
    return error;
}

    // Remove old file; if file is nil, nothing happens.
- (NSError *)finalizeRemoveFile:(NSURL *)file
{
    NSError *error = nil;
    if (file != nil) {
        [[self fileManager] removeItemAtURL:file error:&error];
    }
    return error;
}

- (NSURL *)appSupportFileURL:(NSString *)path
{
    return [[NSURL alloc] initWithString:[path lastPathComponent] relativeToURL:appSupportURL];
}

- (BOOL)fileExistsAtURL:(NSURL *)url
{
    return [[self fileManager] fileExistsAtPath:[url path]];
}

- (NSError *)writeFileAtURL:(NSURL *)url withData:(NSData *)data
{
    return [self writeFileAtURL:url withData:data withAttributes:nil];
}

- (NSError *)writeFileAtURL:(NSURL *)url
                   withData:(NSData *)data
             withAttributes:(NSDictionary *)attributes
{
    NSError *error = nil;
    
    BOOL wrote = [[self fileManager] createFileAtPath:[url path]
                                             contents:data
                                           attributes:attributes];
    if (!wrote) {
        error = [NSError errorWithDomain:applicationDomain
                                    code:2
                                userInfo:@{
                      NSFilePathErrorKey: [url path],
               NSLocalizedDescriptionKey: NSLocalizedString(@"The operation couldn't be completed.", @"not completed")
                 }];
    }
    
    return error;
}

- (void)checkFileTypes:(NSArray *)types
{
    [self genAppSupportURL];
    
    NSDirectoryEnumerator *dirEnum = [[self fileManager] enumeratorAtPath:[appSupportURL path]];
    
    NSString *filename;
    while ((filename = [dirEnum nextObject]) != nil) {
        if ([types containsObject:[filename pathExtension]]) {
                // make sure there's a card using that file
            NSString *path = [[appSupportURL path] stringByAppendingPathComponent:filename];
            NSManagedObject *card = [[CCEEntityFetcher instance] cardUsingGraphicsFile:path];
            if (card == nil) {
                    // no cards using that file
                [[self fileManager] removeItemAtPath:path error:nil];
            }
        }
    }
}

@end
