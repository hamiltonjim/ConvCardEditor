//
//  FixedIKImageView.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/12/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "FixedNSImageView.h"
#import "NSView+ScaleUtilities.h"
#import "CommonStrings.h"
#import "fuzzyMath.h"

@interface FixedNSImageView ()

- (double)constrainZoom:(double)zoom;

@end

@implementation FixedNSImageView

@synthesize imageSize;
@synthesize zoomFactor;
@synthesize parentView;

@synthesize maxZoom;
@synthesize minZoom;


- (id)initWithFrame:(NSRect)frameRect
{
//    NSLog(@"%@ -initWithFrame(Rect: %@)", [self class], NSStringFromRect(frameRect));
    
    self = [super initWithFrame:frameRect];
    if (self) {
        zoomFactor = 1.0;   // MUST be initialized, or all heck breaks loose.
    }
    
    return self;
}

- (void)awakeFromNib
{
    [self setTranslatesAutoresizingMaskIntoConstraints:NO]; // compatibility with Auto Layout; without this, there could be Auto Layout error messages when we are resized (delete this line if your app does not use Auto Layout)
    if (parentView != nil) {
        [parentView setDocumentView:self];
    }
    
        // init: make sure zoomFactor makes sense; it will probably be set after initialization
    if (zoomFactor <= 0.0) {
        zoomFactor = 1.0;
    }
}

    // Override setImageWithUrl: to call super, then setFrame:
- (void)setImageWithURL:(NSURL *)url
{
    NSImage *image = [[NSImage alloc] initWithData:[[NSData alloc] initWithContentsOfURL:url]];
    imageSize = [image size];
    
    [super setImage:image];
    
    [self setFrame:NSZeroRect];     // ignored by overridden setFrame:
}

    /*
        FixedNSImageView must *only* be used embedded within an NSScrollView. This means 
        that setFrame: should never be called explicitly from outside the scroll view. 
        Instead, this method is overridden here to provide the correct behavior within a 
        scroll view. The new implementation ignores the frameRect parameter.
     */

- (void)setFrame:(NSRect)frameRect
{
    NSSize  clipViewSize = [[self superview] frame].size;
    
        /*
         * The content of our scroll view (which is ourselves) should stay at least as large 
         * as the scroll clip view, so we make ourselves as large as the clip view in case our
         * (zoomed) image is smaller. However, if our image is larger than the clip view, we make
         * ourselves as large as the image, to make the scrollbars appear and scale appropriately.
         */
    CGFloat newWidth = MAX(imageSize.width * zoomFactor, clipViewSize.width);
    CGFloat newHeight = MAX(imageSize.height * zoomFactor, clipViewSize.height);
    
        /*
         * Actually, the clip view is 1 pixel larger than the content view on each side, so
         * we must take that into account.
         */
    NSRect rect = NSMakeRect(0, 0, newWidth - 2, newHeight - 2);
    [super setFrame: rect];
}

- (BOOL)canZoomOut
{
    if (minZoom != nil) {
        return zoomFactor > [minZoom doubleValue];
    }
    
    return YES;
}

- (BOOL)canZoomIn
{
    if (maxZoom != nil) {
        return zoomFactor < [maxZoom doubleValue];
    }
    
    return YES;
}

- (double)constrainZoom:(double)zoom
{
    if (minZoom != nil) {
        double minz = [minZoom doubleValue];
        if (zoom < minz)
            zoom = minz;
    }
    
    if (maxZoom != nil) {
        double maxz = [maxZoom doubleValue];
        if (zoom > maxz)
            zoom = maxz;
    }
    
    return zoom;
}

    //// We forward size affecting messages to our superclass, but add [self setFrame:NSZeroRect] to update the scroll bars. We also add [self setAutoresizes:NO]. Since IKImageView, instead of using [self setAutoresizes:NO], seems to set the autoresizes instance variable to NO directly, the scrollers would not be activated again without invoking [self setAutoresizes:NO] ourselves when these methods are invoked.

- (void)setZoomFactor:(CGFloat)zoomTo
{
    zoomTo = [self constrainZoom:zoomTo];
    
    NSDictionary *notifyDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithDouble:zoomFactor]
                                                           forKey:cceZoomFactor];
    [[NSNotificationCenter defaultCenter] postNotificationName:cceZoomFactorChanging
                                                        object:self.window
                                                      userInfo:notifyDict];
    
    double oldscale = zoomFactor;
    zoomFactor = zoomTo;
    if (0 == fuzzyCompare(oldscale, zoomTo))
        return;
    
    double chg = zoomTo / oldscale;
    
    [[NSUserDefaults standardUserDefaults] setDouble:zoomFactor forKey:ccDefaultScale];
    
    [self deepScaleBy:chg];
    [self setFrame:NSZeroRect];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:cceZoomFactorChanged
                                                        object:self.window
                                                      userInfo:notifyDict];
}

- (void)fill
{
    [self zoomImageToRect:[self frame]];
}

- (void)zoomImageToRect:(NSRect)rect
{
    NSSize rsize = rect.size;
    double xFactor = rsize.width / imageSize.width;
    double yFactor = rsize.height / imageSize.height;
    
    double newZoom = fmin(xFactor, yFactor);
    self.zoomFactor = newZoom;
    [self setFrame:NSZeroRect];
}

- (void)logZoom
{
    NSLog(@"New zoom factor: %g", zoomFactor);
}

- (void)zoomIn:(id)sender
{
    double newzoom = zoomFactor * 1.25;
    self.zoomFactor = newzoom;

    [self setFrame:NSZeroRect];
}


- (void)zoomOut:(id)sender
{
    double newzoom = zoomFactor * 0.8;
    self.zoomFactor = newzoom; // reduces by SAME factor as zoomIn:   1.25 * 0.8 == 1.0
    
    [self setFrame:NSZeroRect];
}


- (void)zoomImageToActualSize:(id)sender
{
    self.zoomFactor = 1.0;

    [self setFrame:NSZeroRect];
}

- (void)drawRect:(NSRect)dirtyRect {
        // Drawing code here.
    [NSGraphicsContext saveGraphicsState];
    
    NSAffineTransform *xform = [NSAffineTransform transform];
    
    [xform scaleBy:zoomFactor];
    [xform concat];
    
    NSColor *white = [NSColor whiteColor];
    [white set];
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:[self frame]];
    [path fill];
    
    if (self.image)
        [self.image drawAtPoint:NSMakePoint(0.0, 0.0)
                       fromRect:self.bounds operation:NSCompositeSourceOver fraction:1.0];
    
    [NSGraphicsContext restoreGraphicsState];
}


@end
