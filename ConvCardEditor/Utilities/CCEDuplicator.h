//
//  CCEDuplicator.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 3/3/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCEModelledControl;
@class CCEControlsViewController;

@interface CCEDuplicator : NSObject

@property (readonly) NSString *relX;
@property (readonly) NSString *relY;

+ (CCEDuplicator *)instance;

+ (NSSize)locationDiff:(NSManagedObject *)newLocation from:(NSManagedObject *)oldlocation;

- (NSManagedObject *)cloneModel:(NSManagedObject *)original;
- (NSManagedObject *)cloneModel:(NSManagedObject *)original offsetBy:(NSSize)offset;

- (IBAction)acceptButton:(id)sender;
- (IBAction)cancelButton:(id)sender;

- (IBAction)valueChange:(id)sender;

- (IBAction)moveBy:(id)sender;

- (void)askConfirm:(CCEModelledControl *)newModel
              from:(CCEModelledControl *)original
     forController:(CCEControlsViewController *)controller;

@end
