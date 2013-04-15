//
//  CCELocationFetcher.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/18/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCEModelledControl;
@class CCELocation;

@interface CCEEntityFetcher : NSObject

+ (CCEEntityFetcher *)instance;

- (CCELocation *)locationObjectAt:(NSPoint)pt;
- (CCEModelledControl *)modelledControlAt:(NSPoint)pt;

- (NSArray *)allModelledControls;

- (NSManagedObject *)cardUsingGraphicsFile:(NSString *)path;

- (NSArray *)allCardTypes;
- (NSManagedObject *)cardTypeWithName:(NSString *)name;

- (NSManagedObject *)settingForModel:(CCEModelledControl *)model
                      andPartnership:(NSManagedObject *)partnership;

- (NSSet *)modelByName:(NSString *)name
           controlType:(NSString *)type
               inModel:(NSManagedObject *)card;

@end
