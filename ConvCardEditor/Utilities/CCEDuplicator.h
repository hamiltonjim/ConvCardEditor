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

@property IBOutlet NSPanel *panel;

@property IBOutlet NSTextField *leftRight;
@property IBOutlet NSTextField *updown;

@property IBOutlet NSTextField *deltaX;
@property IBOutlet NSTextField *deltaY;

@property IBOutlet NSTextField *absX;
@property IBOutlet NSTextField *absY;

@property IBOutlet NSObjectController *location1;

@property (nonatomic) NSNumber *numDeltaX;
@property (nonatomic) NSNumber *numDeltaY;

@property (readonly) NSString *relX;
@property (readonly) NSString *relY;

+ (CCEDuplicator *)instance;

+ (NSSize)locationDiff:(NSManagedObject *)newLocation from:(NSManagedObject *)oldlocation;

- (NSManagedObject *)cloneModel:(NSManagedObject *)original;
- (NSManagedObject *)cloneModel:(NSManagedObject *)original offsetBy:(NSSize)offset;

- (IBAction)acceptButton:(id)sender;
- (IBAction)cancelButton:(id)sender;

- (IBAction)valueChange:(id)sender;

- (void)askConfirm:(CCEModelledControl *)newModel
              from:(CCEModelledControl *)original
     forController:(CCEControlsViewController *)controller;

@end
