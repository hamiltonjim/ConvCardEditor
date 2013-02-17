//
//  CCEFileOps.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/10/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *CCEF_BadFileURL;
extern NSString *CCEF_FileMoveError;
extern NSString *CCEF_FileCopyError;

@interface CCEFileOps : NSObject

@property NSURL *appSupportURL;

+ (CCEFileOps *)instance;

- (NSURL *)safeRemoveFile:(NSURL *)file;
- (NSURL *)copyFileToAppSupport:(NSURL *)file;
- (NSError *)undoSafeRemoveFile:(NSURL *)trashFile backTo:(NSURL *)originalFile;
- (NSError *)finalizeRemoveFile:(NSURL *)file;

    // return URL for file named with the last component of path, in
    // the app support directory
- (NSURL *)appSupportFileURL:(NSString *)path;

- (BOOL)fileExistsAtURL:(NSURL *)url;
- (NSError *)writeFileAtURL:(NSURL *)url withData
                           :(NSData *)data;
- (NSError *)writeFileAtURL:(NSURL *)url
                   withData:(NSData *)data
             withAttributes:(NSDictionary *)attributes;

    // at startup: make sure any files not used in data store are removed
- (void)checkFileTypes:(NSArray *)types;

@end
