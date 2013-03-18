//
//  CCEDocument.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 3/17/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

    // Abstract parent of document types for ConvCardEditor
    // Subclasses will implement all the "guts", but this
    // class just implements some common behaviors, such as
    // validation of file/package types.

#import <Cocoa/Cocoa.h>

@class AppDelegate;

@interface CCEDocument : NSDocument

    // subclass responsibility: return file types in preference order
+ (NSArray *)allowedFileTypes;
    // Default "instance" version just calls class method, and is suitable
    // for subclasses to inherit.
- (NSArray *)allowedFileTypes;

- (BOOL)validateType:(NSString *)typeName error:(NSError **)outError;

    // save the current document
- (void)customizeSavePanel:(NSSavePanel *)panel;
- (void)doSave;

    // open into a new document
+ (void)customizeOpenPanel:(NSOpenPanel *)panel;
+ (void)doOpen;
+ (void)completeOpen:(NSOpenPanel *)panel
          withResult:(NSInteger)result;

@end
