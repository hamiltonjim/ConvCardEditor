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

    // at startup: make sure any files not used in data store are removed
- (void)checkFileTypes:(NSArray *)types;

@end
