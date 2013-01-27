//
//  FixedIKImageView.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/12/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import <Quartz/Quartz.h>

@interface FixedNSImageView : NSImageView

@property (assign, nonatomic) NSSize imageSize;
@property (assign, nonatomic) CGFloat zoomFactor;

@property (weak, nonatomic) IBOutlet NSScrollView *parentView;

@property NSNumber *maxZoom;
@property NSNumber *minZoom;

- (void)setImageWithURL:(NSURL *)url;

- (void)fill;
- (void)zoomImageToRect:(NSRect)rect;
- (void)zoomIn:(id)sender;
- (void)zoomOut:(id)sender;
- (void)zoomImageToActualSize:(id)sender;

- (BOOL)canZoomOut;
- (BOOL)canZoomIn;


@end
