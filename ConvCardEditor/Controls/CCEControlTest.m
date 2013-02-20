//
//  CCEControlTest.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/31/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "CCEControlTest.h"
#import "CCEModelledControl.h"

NSString *kTesterIsRunning = @"isRunning";

static NSMutableDictionary *testers;

const NSUInteger kInitialCapacity = 10;

    // want test interval to be 1/3 of a second
const NSTimeInterval kInterval = 1.0 / 3.0;
    // want test to run for 5 minutes (5 * 60 seconds * 3 per second)
const NSInteger kNumInvokations = 3 * 60 * 5;

@interface CCEControlTest ()

@property NSTimer *timer;
@property NSInteger invocations;
@property (weak, readwrite) NSControl <CCDebuggableControl> *control;
@property NSString *ctlName;

@property NSMutableArray *observers;

@property (readwrite) BOOL isRunning;


    // designated; public initializers call this
- (id)initWithControlName:(NSString *)name
                  control:(NSControl<CCDebuggableControl> *)control
                   notify:(id)notifyTarget;

- (void)invoke:(NSTimer *)timer;

+ (void)addObject:(CCEControlTest *)object;
+ (void)removeObject:(CCEControlTest *)object;
+ (CCEControlTest *)objectForControl:(NSControl <CCDebuggableControl> *)control;

@end

@implementation CCEControlTest

@synthesize timer;
@synthesize invocations;
@synthesize control;
@synthesize ctlName;
@synthesize observers;

@synthesize isRunning;

+ (void)initialize
{
    if (self == [CCEControlTest class]) {
        testers = [[NSMutableDictionary alloc] initWithCapacity:kInitialCapacity];
    }
}

+ (void)stopAllTesters
{
        // get array of all tester objects
    NSArray *tempArray = [NSArray arrayWithArray:[testers allValues]];
    
    [tempArray enumerateObjectsUsingBlock:^(NSSet *set, NSUInteger idx, BOOL *stop) {
        [set enumerateObjectsUsingBlock:^(CCEControlTest *obj, BOOL *stop) {
            [obj cancel];
        }];
    }];
}

+ (void)stopAllTestersInWindow:(NSWindow *)window
{
    NSArray *tempArray = [NSArray arrayWithArray:[testers allValues]];
    
    [tempArray enumerateObjectsUsingBlock:^(NSSet *set, NSUInteger idx, BOOL *stop) {
        [set enumerateObjectsUsingBlock:^(CCEControlTest *obj, BOOL *stop2) {
            if ([obj.control.window isEqualTo:window]) {
                [obj cancel];
                *stop2 = YES;
            }
        }];
    }];
}

+ (NSUInteger)testerCount
{
    return [testers count];
}

    // take care of removing observers when I go away
- (void)addObserver:(NSObject *)observer
         forKeyPath:(NSString *)keyPath
            options:(NSKeyValueObservingOptions)options
            context:(void *)context
{
    [super addObserver:observer forKeyPath:keyPath options:options context:context];
    if ([keyPath isEqualToString:kTesterIsRunning])
        [observers addObject:observer];
}

- (void)dealloc
{
    [observers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self removeObserver:obj forKeyPath:kTesterIsRunning];
    }];
}

+ (CCEControlTest *)testerForControl:(NSControl<CCDebuggableControl> *)aControl
{
    return [self objectForControl:aControl];
}

+ (NSSet *)testerForName:(NSString *)name
{
    return [testers objectForKey:name];
}

+ (CCEControlTest *)newTesterForControl:(NSControl<CCDebuggableControl> *)aControl
                                 notify:(id)notifyTarget
{
    return [[CCEControlTest alloc] initWithControl:aControl notify:notifyTarget];
}

- (id)initWithControl:(NSControl<CCDebuggableControl> *)aControl
               notify:(id)notifyTarget
{
    CCEModelledControl *model = aControl.modelledControl;
    return [self initWithControlName:model.name control:aControl notify:notifyTarget];
}

- (id)initWithControlName:(NSString *)name
                  control:(NSControl<CCDebuggableControl> *)aControl
                   notify:(id)notifyTarget
{
    self = [super init];
    if (self) {
        control = aControl;
        ctlName = name;
        
        [self.class addObject:self];
        
        observers = [NSMutableArray array];
        
        invocations = kNumInvokations;
        
        if (notifyTarget != nil) {
            [self addObserver:notifyTarget
                   forKeyPath:kTesterIsRunning
                      options:0
                      context:nil];
        }
        
        timer = [NSTimer scheduledTimerWithTimeInterval:kInterval
                                                 target:self
                                               selector:@selector(invoke:)
                                               userInfo:nil
                                                repeats:YES];
        [control setDebugMode:kOff];
    }
    
    return self;
}

- (void)invoke:(NSTimer *)timer
{
    if (!isRunning) {
        self.isRunning = YES;
    }
    
        // if control goes away, so do I.
    if (control == nil) {
        [self cancel];
        return;
    }
     
    if ([control respondsToSelector:@selector(advanceTest)]) {
        [control advanceTest];
    } else {
            // this will do for toggles...
        [control setIntegerValue:(![control integerValue])];
    }
    
    if (--invocations <= 0) {
        [self cancel];
    }
}

- (void)cancel
{
    [control setDebugMode:kShowUnselected];
    self.isRunning = NO;
    
    [timer invalidate];
    
    if ([control respondsToSelector:@selector(resetTest)]) {
        [control resetTest];
    } else {
        [control setIntegerValue:0];
    }
    
    [[self class] removeObject:self];
}

+ (void)addObject:(CCEControlTest *)object
{
    NSMutableSet *nameArray = [testers objectForKey:object.ctlName];
    if (nameArray == nil) {
        nameArray = [NSMutableSet setWithObject:object];
        [testers setObject:nameArray forKey:object.ctlName];
    } else {
        [nameArray addObject:object];
    }
}
    // safely remove an object; last reference
+ (void)removeObject:(CCEControlTest *)object
{
    NSMutableSet *nameArray = [testers objectForKey:object.ctlName];
    if (nameArray != nil) {
        [nameArray removeObject:object];
        
        if (nameArray.count <= 0) {
            [testers removeObjectForKey:object.ctlName];
        }
    }
}

+ (CCEControlTest *)objectForControl:(NSControl<CCDebuggableControl> *)control
{
    NSMutableSet *nameSet = [testers objectForKey:control.modelledControl.name];
    NSSet *foundObjects = [nameSet objectsPassingTest:^BOOL(CCEControlTest *obj, BOOL *stop) {
        BOOL found = obj.control == control;
        if (found) {
            *stop = YES;
        }
        return found;
    }];
        // foundObjects will be a set of zero or one objects
    
    return foundObjects.anyObject;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"CCEControlTest{%@}", ctlName];
}

@end
