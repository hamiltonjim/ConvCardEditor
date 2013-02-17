//
//  NSManagedObject+CCESerializer.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 2/14/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (CCESerializer)

    // convert object to dictionary; objectIdSet records converted objects, to
    // avoid duplicaiton; 
- (NSDictionary *)toDictionaryWithRecorder:(NSMutableSet *)objectIdSet
                             excludingKeys:(NSSet *)skipKeys
                             excludeLevels:(NSInteger)exLevels;

    // convenience method that sends nil for excludingKeys
- (NSDictionary *)toDictionaryWithRecorder:(NSMutableSet *)objectIdSet;

    // we can also build the recorder set internally...
- (NSDictionary *)toDictionaryExcludingKeys:(NSSet *)skipKeys excludeLevels:(NSInteger)exLevels;
- (NSDictionary *)toDictionary;

    // create a managed object from the given dictionary; entity name is
    // expected to be in the dictionary
+ (NSManagedObject *)createManagedObjectFromDictionary:(NSDictionary *)dict
                                             inContext:(NSManagedObjectContext *)context;
- (void)populateFromDictionary:(NSDictionary *)dictionary;

@end
