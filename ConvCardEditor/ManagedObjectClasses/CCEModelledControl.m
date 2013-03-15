//
//  CCEModelledControl.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/15/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "CCEModelledControl.h"
#import "CCELocationController.h"
#import "CommonStrings.h"

NSString *entityCheckbox = @"SingleCheck";
NSString *entityMultiCheck = @"MultiCheck";
NSString *entityText = @"Text";
NSString *entityLocation = @"Location";

@interface CCEModelledControl ()

@property (readwrite) NSString *controlType;
@property (readwrite) NSNumber *isIndexed;
@property (readwrite) NSNumber *numParts;

@property (readwrite) NSNumber *mightBeNumeric;

- (void)buildTransientProperties;

@end

@implementation CCEModelledControl

@synthesize controlType;
@synthesize isIndexed;
@synthesize numParts;

@synthesize mightBeNumeric;

@dynamic tabToNext;
@dynamic tabToPrevious;

- (void)awakeFromFetch
{
    [super awakeFromFetch];
    [self buildTransientProperties];
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    [self buildTransientProperties];
}

- (void)buildTransientProperties
{
    BOOL indexed = NO;
    NSInteger nParts = 1;
    mightBeNumeric = [NSNumber numberWithBool:NO];
    
    if ([[[self entity] name] isEqualToString:entityCheckbox]) {
        self.controlType = NSLocalizedString(@"Check Box", @"name for a single checkbox control");
    } else if ([[[self entity] name] isEqualToString:entityMultiCheck]) {
        switch ([[self valueForKey:@"shape"] intValue]) {
            case kCheckboxes:
                self.controlType = NSLocalizedString(@"Check Boxes", @"name for a multi-checkbox control");
                break;
                
            case kOvals:
                self.controlType = NSLocalizedString(@"Ovals", @"name for an Ovals control");
                break;
                
            default:
                break;
        }
        indexed = YES;
        nParts = [[self valueForKey:@"locations"] count];
    } else if ([[[self entity] name] isEqualToString:entityText]) {
        self.controlType = NSLocalizedString(@"Text", @"name of an arbitrary text control");
        mightBeNumeric = [NSNumber numberWithBool:YES];
    }
    
    self.isIndexed = [NSNumber numberWithBool:indexed];
    self.numParts = [NSNumber numberWithInteger:nParts];
}

- (id)valueForUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"numeric"]) {
            // key valid only for the Text subclass, but bound
        return nil;
    }
    
    return [super valueForUndefinedKey:key];
}

@end
