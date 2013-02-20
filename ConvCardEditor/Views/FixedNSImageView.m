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

@interface FixedNSImageView ()

- (double)constrainZoom:(double)zoom;

@end

@implementation FixedNSImageView

@synthesize imageSize;
@synthesize zoomFactor;
@synthesize parentView;

@synthesize maxZoom;
@synthesize minZoom;

- (void)awakeFromNib
{
    [self setTranslatesAutoresizingMaskIntoConstraints:NO]; // compatibility with Auto Layout; without this, there could be Auto Layout error messages when we are resized (delete this line if your app does not use Auto Layout)
    if (parentView != nil) {
        [parentView setDocumentView:self];
    }
}

    // Override setImageWithUrl: to call super, then setFrame:
- (void)setImageWithURL:(NSURL *)url
{
    NSImage *image = [[NSImage alloc] initWithData:[[NSData alloc] initWithContentsOfURL:url]];
    imageSize = [image size];
    
    [super setImage:image];
    
    NSRect rect = NSZeroRect;   // ignored by overridden setFrame:
    [self setFrame:rect];
}

    // FixedNSImageView must *only* be used embedded within an NSScrollView. This means that setFrame: should never be called explicitly from outside the scroll view. Instead, this method is overridden here to provide the correct behavior within a scroll view. The new implementation ignores the frameRect parameter.
- (void)setFrame:(NSRect)frameRect
{
    NSSize  clipViewSize = [[self superview] frame].size;
    
        // The content of our scroll view (which is ourselves) should stay at least as large as the scroll clip view, so we make ourselves as large as the clip view in case our (zoomed) image is smaller. However, if our image is larger than the clip view, we make ourselves as large as the image, to make the scrollbars appear and scale appropriately.
    CGFloat newWidth = (imageSize.width * zoomFactor < clipViewSize.width)?  clipViewSize.width : imageSize.width * zoomFactor;
    CGFloat newHeight = (imageSize.height * zoomFactor < clipViewSize.height)?  clipViewSize.height : imageSize.height * zoomFactor;
    
    NSRect rect = NSMakeRect(0, 0, newWidth - 2, newHeight - 2);
    [super setFrame: rect]; // actually, the clip view is 1 pixel larger than the content view on each side, so we must take that into account
    
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
    zoomFactor = zoomTo;
    
    [[NSUserDefaults standardUserDefaults] setDouble:zoomFactor forKey:ccDefaultScale];
    
    [self setScale:zoomTo];
    [self setFrame:NSZeroRect];
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


@end
