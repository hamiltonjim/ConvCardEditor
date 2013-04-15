//
//  CCELocationFetcher.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/18/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "CCEEntityFetcher.h"
#import "AppDelegate.h"
#import "CCEModelledControl.h"
#import "CCEManagedObjectModels.h"
#import "CommonStrings.h"

static CCEEntityFetcher *theInstance = nil;

    // let (pixel) location be fuzzy; search for Locations close to the given spot
static const double fuzziness = 5.0;

@interface CCEEntityFetcher ()

@property NSManagedObjectContext *appContext;
@property NSString *entityLocation;
@property NSEntityDescription *locationDescription;

- (CCELocation *)locationFrom:(NSArray *)closeLocations closestTo:(NSPoint)pt;

@end

@implementation CCEEntityFetcher

@synthesize appContext;
@synthesize entityLocation;
@synthesize locationDescription;

+ (CCEEntityFetcher *)instance
{
    if (theInstance == nil) {
        @synchronized(self) {
            theInstance = [CCEEntityFetcher new];
            theInstance.entityLocation = ccLocation;
        }
    }
    
    return theInstance;
}

- (id)init
{
    if ((self = [super init]) != nil) {
        AppDelegate *del = (AppDelegate *)[NSApp delegate];
        appContext = [del managedObjectContext];
    }
    
    return self;
}

- (CCELocation *)locationObjectAt:(NSPoint)pt
{
    if (locationDescription == nil) {
        locationDescription = [NSEntityDescription entityForName:entityLocation
                                          inManagedObjectContext:appContext];
    }
    NSFetchRequest *request = [NSFetchRequest new];
    [request setEntity:locationDescription];
    
    NSNumber *minX = [NSNumber numberWithDouble:pt.x - fuzziness];
    NSNumber *maxX = [NSNumber numberWithDouble:pt.x + fuzziness];
    
    NSNumber *minY = [NSNumber numberWithDouble:pt.y - fuzziness];
    NSNumber *maxY = [NSNumber numberWithDouble:pt.y + fuzziness];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"locX > %@ AND locX < %@ AND locY > %@ AND locY < %@",
                              minX, maxX, minY, maxY];
    [request setPredicate:predicate];
    [request setSortDescriptors:nil];
    
    NSError *err;
    NSArray *array = [appContext executeFetchRequest:request error:&err];
    
    return [self locationFrom:array closestTo:pt];
}

- (CCEModelledControl *)modelledControlAt:(NSPoint)pt
{
    CCELocation *location = [self locationObjectAt:pt];
    CCEModelledControl *ctl = nil;
    
    if (location != nil) {
            // exactly ONE of the control relationships will be non-nil
        if ((ctl = [location checkControl]) != nil) {
            
        } else if ((ctl = [location multiCheckControl]) != nil) {
            
        } else if ((ctl = [location textControl]) != nil) {
            
        }
    }
    
    return ctl;
}

- (CCELocation *)locationFrom:(NSArray *)closeLocations closestTo:(NSPoint)pt
{
    if (closeLocations == nil) {
        return nil;
    }

        // Block updates values; nil bestObject implies minDisplacement is invalid
    __block double minDisplacement;
    __block CCELocation * __weak bestObject;
    
    [closeLocations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        double deltaX = pt.x - [[obj locX] doubleValue];
        double deltaY = pt.y - [[obj locY] doubleValue];
        
            // Thank you Pythagoras
        double disp = sqrt(deltaX * deltaX + deltaY * deltaY);
        
        if (bestObject == nil || disp < minDisplacement) {
            bestObject = obj;
            minDisplacement = disp;
        }
    }];
    
    return bestObject;
}

- (NSArray *)allModelledControls
{
    NSEntityDescription *ctlDesc = [NSEntityDescription entityForName:@"Control"
                                               inManagedObjectContext:appContext];
    NSFetchRequest *req = [NSFetchRequest new];
    
    [req setEntity:ctlDesc];
    
    return [appContext executeFetchRequest:req error:nil];
}

- (NSManagedObject *)cardUsingGraphicsFile:(NSString *)path
{
    NSManagedObject *object = nil;
    NSEntityDescription *cardDesc = [NSEntityDescription entityForName:@"CardType"
                                               inManagedObjectContext:appContext];
    NSFetchRequest *req = [NSFetchRequest new];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"fileUrl like %@", path];
    [req setEntity:cardDesc];
    [req setPredicate:predicate];
    [req setSortDescriptors:nil];
    
    NSArray *result = [appContext executeFetchRequest:req error:NULL];
    if (result != nil && [result count] > 0) {
            // return ANY result
        object = [result objectAtIndex:0];
    }
    return object;
}

- (NSArray *)allCardTypes
{
    NSEntityDescription *cardDesc = [NSEntityDescription entityForName:@"CardType"
                                                inManagedObjectContext:appContext];
    NSFetchRequest *req = [NSFetchRequest new];
    NSPredicate *predicate = nil;
    [req setEntity:cardDesc];
    [req setPredicate:predicate];
    [req setSortDescriptors:nil];
    
    NSArray *result = [appContext executeFetchRequest:req error:nil];

    return result;
}

- (NSManagedObject *)cardTypeWithName:(NSString *)name
{
    NSEntityDescription *cardDesc = [NSEntityDescription entityForName:@"CardType"
                                                inManagedObjectContext:appContext];
    NSFetchRequest *req = [NSFetchRequest new];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cardName like %@", name];
    [req setEntity:cardDesc];
    [req setPredicate:predicate];
    [req setSortDescriptors:nil];
    
    NSArray *result = [appContext executeFetchRequest:req error:NULL];
    
    NSManagedObject *object = nil;
    if (result != nil && [result count] > 0) {
            // return ANY result
        object = [result objectAtIndex:0];
    }
    return object;
}

- (NSManagedObject *)settingForModel:(CCEModelledControl *)model
                      andPartnership:(NSManagedObject *)partnership
{
    NSMutableSet *partnershipSettings = [partnership.values mutableCopy];
    [partnershipSettings intersectSet:model.values];
    
    NSManagedObject *obj = (partnershipSettings == nil || partnershipSettings.count == 0) ?
            nil : [partnershipSettings anyObject];
    return obj;
}

- (NSSet *)modelByName:(NSString *)name
           controlType:(NSString *)type
               inModel:(NSManagedObject *)card
{
    return
    [card.settings objectsPassingTest:^BOOL(CCEModelledControl *obj, BOOL *stop) {
        return [name isEqualToString:obj.name] && [type isEqualToString:obj.controlType];
    }];
}

@end
