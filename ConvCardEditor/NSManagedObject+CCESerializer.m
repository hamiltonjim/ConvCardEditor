//
//  NSManagedObject+CCESerializer.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 2/14/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "NSManagedObject+CCESerializer.h"

static NSString *entityKey = @"Entity";

@implementation NSManagedObject (CCESerializer)

- (NSDictionary *)toDictionary
{
    return [self toDictionaryExcludingKeys:nil excludeLevels:0];
}

- (NSDictionary *)toDictionaryExcludingKeys:(NSSet *)skipKeys excludeLevels:(NSInteger)exLevels
{
    NSMutableSet *idset = [[NSMutableSet alloc] initWithCapacity:100];
    return [self toDictionaryWithRecorder:idset excludingKeys:skipKeys excludeLevels:exLevels];
}

- (NSDictionary *)toDictionaryWithRecorder:(NSMutableSet *)objectIdSet
{
    return [self toDictionaryWithRecorder:objectIdSet excludingKeys:nil excludeLevels:0];
}

- (NSDictionary *)toDictionaryWithRecorder:(NSMutableSet *)objectIdSet
                             excludingKeys:(NSSet *)skipKeys
                             excludeLevels:(NSInteger)exLevels
{
    if (objectIdSet) {
            // record my objectID (so I don't get written twice)
        [objectIdSet addObject:[self objectID]];
    }
    
    if (exLevels <= 0) {
        skipKeys = nil;
    } else {
        --exLevels;
    }
    
    NSArray* attributes = [[[self entity] attributesByName] allValues];
    NSArray* relationships = [[[self entity] relationshipsByName] allKeys];
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:
                                 [attributes count] + [relationships count] + 1];
    
    [dict setObject:[[self entity] name] forKey:entityKey];
    
    for (NSAttributeDescription *attr in attributes) {
        NSString *aname = attr.name;
        if ([skipKeys containsObject:aname])
            continue;
        if (attr.isTransient)
            continue;
        
        NSObject *value = [self valueForKey:aname];
        
        if (value != nil) {
            [dict setObject:value forKey:aname];
        }
    }
    
    for (NSString *relationship in relationships) {
        if ([skipKeys containsObject:relationship])
            continue;

        NSObject *value = [self valueForKey:relationship];
        
        if ([value isKindOfClass:[NSSet class]]) {
                // To-many relationship
            
                // The core data set holds a collection of managed objects
            NSSet *relatedObjects = (NSSet *) value;
            
                // Our set holds a collection of dictionaries
            NSMutableArray *dictSet = [NSMutableArray arrayWithCapacity:[relatedObjects count]];
            
            for (NSManagedObject *relatedObject in relatedObjects) {
                if (objectIdSet && ![objectIdSet containsObject:[relatedObject objectID]]) {
                    [dictSet addObject:[relatedObject toDictionaryWithRecorder:objectIdSet
                                                                 excludingKeys:skipKeys
                                                                 excludeLevels:exLevels]];
                }
            }
            
            [dict setObject:dictSet forKey:relationship];
        }
        else if ([value isKindOfClass:[NSManagedObject class]]) {
                // To-one relationship
            
            NSManagedObject *relatedObject = (NSManagedObject *) value;
            
            if (objectIdSet && ![objectIdSet containsObject:[relatedObject objectID]]) {
                    // Call toDictionary on the referenced object and put the result back into our dictionary.
                [dict setObject:[relatedObject toDictionaryWithRecorder:objectIdSet
                                                          excludingKeys:skipKeys
                                                          excludeLevels:exLevels]
                         forKey:relationship];
            }
        }
    }
    
    return dict;
}

- (void) populateFromDictionary:(NSDictionary*)dict
{
    NSManagedObjectContext* context = [self managedObjectContext];
    
    for (NSString* key in dict) {
        if ([key isEqualToString:entityKey]) {
            continue;
        }
        
        NSObject* value = [dict objectForKey:key];
        
        if ([value isKindOfClass:[NSDictionary class]]) {
                // This is a to-one relationship
            NSManagedObject* relatedObject =
            [NSManagedObject createManagedObjectFromDictionary:(NSDictionary*)value
                                                     inContext:context];
            
            [self setValue:relatedObject forKey:key];
        }
        else if ([value isKindOfClass:[NSArray class]]) {
                // This is a to-many relationship
            NSArray* relatedObjectDictionaries = (NSArray*) value;
            
                // Get a proxy set that represents the relationship, and add related objects to it.
                // (Note: this is provided by Core Data)
            NSMutableSet* relatedObjects = [self mutableSetValueForKey:key];
            
            for (NSDictionary* relatedObjectDict in relatedObjectDictionaries) {
                NSManagedObject* relatedObject =
                [NSManagedObject createManagedObjectFromDictionary:relatedObjectDict
                                                         inContext:context];
                [relatedObjects addObject:relatedObject];
            }
        }
        else if (value != nil) {
                // This is an attribute
            [self setValue:value forKey:key];
        }
    }
}

+ (NSManagedObject*) createManagedObjectFromDictionary:(NSDictionary*)dict
                                             inContext:(NSManagedObjectContext*)context
{
    NSString* class = [dict objectForKey:entityKey];
    NSManagedObject* newObject = [NSEntityDescription insertNewObjectForEntityForName:class
                                                               inManagedObjectContext:context];
    
    [newObject populateFromDictionary:dict];
    
    return newObject;
}


@end
