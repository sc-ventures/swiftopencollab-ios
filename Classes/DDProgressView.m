//
//  DDProgressView.m
//  DDProgressView
//
//  Created by Damien DeVille on 3/13/11.
//  Copyright 2011 Snappy Code. All rights reserved.
//

#import "DDProgressView.h"

#define kProgressBarHeight  10.0f
#define kProgressBarWidth	160.0f
//#define kOuterLineWidth     2.0f
#define kOuterLineWidth     1.5f

@implementation DDProgressView

@synthesize innerColor ;
@synthesize outerColor ;
@synthesize progress ;

- (id)init
{
	return [self initWithFrame: CGRectZero] ;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame: frame] ;
	if (self)
	{
		self.backgroundColor = [UIColor clearColor] ;
		self.innerColor = [UIColor whiteColor]; // [UIColor lightGrayColor] ;
		self.outerColor = [UIColor whiteColor]; //[UIColor lightGrayColor] ;
		if (frame.size.width == 0.0f)
			frame.size.width = kProgressBarWidth ;
	}
	return self ;
}

- (void)dealloc
{
	[innerColor release], innerColor = nil ;
	[outerColor release], outerColor = nil ;
	
	[super dealloc] ;
}

- (void)setProgress:(float)theProgress
{
	// make sure the user does not try to set the progress outside of the bounds
	if (theProgress > 1.0f)
		theProgress = 1.0f ;
	if (theProgress < 0.0f)
		theProgress = 0.0f ;
	
	progress = theProgress ;
	[self setNeedsDisplay] ;
}

- (void)setFrame:(CGRect)frame
{
	// we set the height ourselves since it is fixed
	frame.size.height = kProgressBarHeight ;
	[super setFrame: frame] ;
}

- (void)setBounds:(CGRect)bounds
{
	// we set the height ourselves since it is fixed
	bounds.size.height = kProgressBarHeight ;
	[super setBounds: bounds] ;
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext() ;
	
	// save the context
	CGContextSaveGState(context) ;
	
	// allow antialiasing
	CGContextSetAllowsAntialiasing(context, TRUE) ;
	
	// we first draw the outter rounded rectangle
	rect = CGRectInset(rect, 1.0f, 1.0f) ;
	CGFloat radius = 0.5f * rect.size.height ;
    
	CGContextSetStrokeColorWithColor(context, outerColor.CGColor) ;
	CGContextSetLineWidth(context, kOuterLineWidth) ;
	
	CGContextBeginPath(context) ;
	CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMidY(rect)) ;
	CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMidX(rect), CGRectGetMinY(rect), radius) ;
	CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMidY(rect), radius) ;
	CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect), CGRectGetMidX(rect), CGRectGetMaxY(rect), radius) ;
	CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMidY(rect), radius) ;
	CGContextClosePath(context) ;
	CGContextDrawPath(context, kCGPathStroke) ;
    
	// draw the inside moving filled rounded rectangle
	//rect = CGRectInset(rect, 3.0f, 3.0f) ;
    rect = CGRectInset(rect, 2.0f, 2.0f) ;
	radius = 0.5f * rect.size.height ;
	
	// make sure the filled rounded rectangle is not smaller than 2 times the radius
	rect.size.width *= progress ;
	if (rect.size.width < 2 * radius)
		rect.size.width = 2 * radius ;
	
	CGContextSetFillColorWithColor(context, innerColor.CGColor) ;
	
	CGContextBeginPath(context) ;
	CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMidY(rect)) ;
	CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMidX(rect), CGRectGetMinY(rect), radius) ;
	CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMidY(rect), radius) ;
	CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect), CGRectGetMidX(rect), CGRectGetMaxY(rect), radius) ;
	CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMidY(rect), radius) ;
	CGContextClosePath(context) ;
	CGContextFillPath(context) ;
	
	// restore the context
	CGContextRestoreGState(context) ;
}


- (void)moveProgress {
    if (self.progress < targetProgress) {
        self.progress = MIN(self.progress + 0.01, targetProgress);
    } else {
        self.progress = targetProgress;
        [progressTimer invalidate];
        progressTimer = nil;
    }
}

- (void)setProgress:(CGFloat)newProgress animated:(BOOL)animated {
    if (animated) {
        targetProgress = newProgress;
        if (progressTimer == nil) {
            progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(moveProgress) userInfo:nil repeats:YES];
        }
    } else {
        self.progress = newProgress;
    }
}

@end
