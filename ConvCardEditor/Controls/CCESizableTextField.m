//
//  CCESizableTextField.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/24/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "CCESizableTextField.h"
#import "CCESizableTextFieldCell.h"

/*
    Creates a rect with the two given points as opposite corners.
    It doesn't matter whether the corners are top-right and bottom-left
    or top-left and bottom-right, or which is which
 */
NSRect JFH_RectFromPoints(NSPoint p1, NSPoint p2)
{
    NSPoint origin;
    origin.x = MIN(p1.x, p2.x);
    origin.y = MIN(p1.y, p2.y);
    
    NSSize size;
    size.width = p1.x - p2.x;
    if (size.width < 0)
        size.width = -size.width;
    
    size.height = p1.y - p2.y;
    if (size.height < 0)
        size.height = -size.height;
    
    NSRect answer;
    answer.origin = origin;
    answer.size = size;
    
    return answer;
}

static NSString *loremIpsum;

@interface CCESizableTextField ()

- (void)contentInit;

@end

@implementation CCESizableTextField

+ (Class)cellClass
{
    return [CCESizableTextFieldCell class];
}

+ (void)initialize
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"loremipsum" withExtension:@"text"];
    loremIpsum = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
}

- (void)contentInit
{
    [[self cell] setPlaceholderString:loremIpsum];
    [self setStringValue:@""];
}

- (void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    [self calcSize];
}

- (id)initWithLocation:(CCELocation *)location
{
    if (self = [super initWithLocation:location]) {
        [self contentInit];
    }
    
    return self;
}

- (id)initWithLocation:(CCELocation *)location isNumber:(BOOL)isNum colorCode:(NSInteger)colorCode
{
    if (self = [super initWithLocation:location isNumber:isNum colorCode:colorCode]) {
        [self contentInit];
    }
    
    return self;
}

- (id)initWithLocation:(CCELocation *)location isNumber:(BOOL)isNum color:(NSColor *)aColor
{
    if (self = [super initWithLocation:location isNumber:isNum color:aColor]) {
        [self contentInit];
    }
    
    return self;
}

- (id)initWithTextModel:(CCETextModel *)model
{
    if (self = [super initWithTextModel:model]) {
        [self contentInit];
    }
    
    return self;
}

//- (void)drawRect:(NSRect)dirtyRect
//{
//    // Drawing code here.
//    [super drawRect:dirtyRect];
//}

#pragma mark MOUSE HANDLING

- (BOOL)becomeFirstResponder
{
        // send the action
    id target = [self target];
    SEL action = [self action];
    
    if (target != nil && action != nil) {
        [target performSelector:action withObject:self];
    }
    
    return YES;
}

@end
