//
//  CCEValueBinder.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 2/26/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "CCEValueBinder.h"
#import "CommonStrings.h"
#import "CCEManagedObjectModels.h"
#import "CCEModelledControl.h"
#import "CCEEntityFetcher.h"
#import "AppDelegate.h"
#import "CCEValueBindingTransformer.h"

static NSInteger s_count;

static NSString *mutableSetKey = @"values";

static NSDictionary *sBindingOptions = nil;

@interface CCEValueBinder ()

@property (weak) NSControl <CCDebuggableControl> *control;

- (NSManagedObject *)settingForModel:(CCEModelledControl *)model
                      andPartnership:(NSManagedObject *)partnership;
- (void)setupBinding:(NSManagedObject *)setting;
- (NSDictionary *)bindingOptions;

@end

@implementation CCEValueBinder

@synthesize control;

+ (void)initialize
{
    [CCEValueBindingTransformer initialize];
}

- (NSDictionary *)bindingOptions
{
    if (sBindingOptions == nil) {
        @synchronized([self class]) {
            sBindingOptions = @{
                                @"NSContinuouslyUpdatesValueBindingOption": [NSNumber numberWithBool:YES],
                                @"NSValidatesImmediatelyBindingOption": [NSNumber numberWithBool:YES]
                                };
        }
    }
    return sBindingOptions;
}

- (id)initWithPartnership:(NSManagedObject *)partnership
                  control:(NSControl<CCDebuggableControl> *)modelledControl
{
    CCEModelledControl *model;
    if ([modelledControl respondsToSelector:@selector(modelledControl)]) {
        model = modelledControl.modelledControl;
    }
    if ((self = [self initWithPartnership:partnership control:modelledControl model:model])) {
        
    }
    
    return self;
}

- (id)initWithPartnership:(NSManagedObject *)partnership
                  control:(NSControl<CCDebuggableControl> *)modelledControl
                    model:(CCEModelledControl *)model
{
    if (model == nil) {
        NSLog(@"CCEValueBinder: nil model passed for control %@", modelledControl.description);
        return nil;
    } else if (modelledControl == nil) {
        NSLog(@"CCEValueBinder: nil control passed for model %@", model.description);
        return nil;
    } else if (partnership == nil) {
        NSLog(@"CCEValueBinder: nil partnership passed for model %@", model.description);
        return nil;
    }
    
    control = modelledControl;
    if ((self = [super init])) {
            // bind value
        NSManagedObject *setting = [self settingForModel:model andPartnership:partnership];
        [self setupBinding:setting];
    }
    
    ++s_count;

    return self;
}

- (void)dealloc
{
    [control unbind:NSValueBinding];
    --s_count;
}

- (void)setupBinding:(NSManagedObject *)setting
{
    NSDictionary *options = nil;
    if ([control respondsToSelector:@selector(valueBindingTransformerName)]) {
        options = [NSMutableDictionary dictionaryWithObject:[control valueBindingTransformerName]
                                                     forKey:NSValueTransformerNameBindingOption];
        [(NSMutableDictionary *)options addEntriesFromDictionary:[self bindingOptions]];
    } else {
        options = [self bindingOptions];
    }
    [control bind:NSValueBinding toObject:setting withKeyPath:NSValueBinding options:options];
}

- (NSManagedObject *)settingForModel:(CCEModelledControl *)model
                      andPartnership:(NSManagedObject *)partnership
{
    NSManagedObject *setting = [[CCEEntityFetcher instance] settingForModel:model
                                                             andPartnership:partnership];
    if (setting == nil) {
            // create one
        NSManagedObjectContext *moc = [(AppDelegate*)[NSApp delegate] managedObjectContext];
        setting = [NSEntityDescription insertNewObjectForEntityForName:@"Setting"
                                                inManagedObjectContext:moc];
            // the relationships are many-to-one...
        NSMutableSet *partnershipSettigns = [partnership mutableSetValueForKey:mutableSetKey];
        [partnershipSettigns addObject:setting];
        
        NSMutableSet *modelSettings = [model mutableSetValueForKey:mutableSetKey];
        [modelSettings addObject:setting];
        
        setting.value = @"";
    }
    
    return setting;
}

+ (NSInteger)count
{
    return s_count;
}

@end
