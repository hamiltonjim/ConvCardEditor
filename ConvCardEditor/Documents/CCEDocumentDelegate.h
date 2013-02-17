//
//  CCEDocumentDelegate.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 2/16/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CCEDocumentDelegate <NSObject>

- (void)documentHasOpened:(NSDocument *)document;
- (void)documentWillClose:(NSDocument *)document;

@end
