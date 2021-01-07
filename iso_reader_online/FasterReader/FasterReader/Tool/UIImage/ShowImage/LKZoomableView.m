//
//  LKZoomableView.m
//  
//
//  Created by luke on 10-11-15.
//  Copyright 2010 pica.com. All rights reserved.
//

#import "LKZoomableView.h"
#import "LKImageView.h"

@implementation LKZoomableView

@synthesize isInfoboxHidden;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		
		self.isInfoboxHidden = NO;
		self.scrollEnabled = YES;
		self.pagingEnabled = NO;
		self.clipsToBounds = NO;
		self.maximumZoomScale = 3.0f;
		self.minimumZoomScale = 1.0f;
		self.showsVerticalScrollIndicator = NO;
		self.showsHorizontalScrollIndicator = NO;
		self.alwaysBounceVertical = NO;
		self.alwaysBounceHorizontal = NO;
		self.bouncesZoom = YES;
		self.bounces = YES;
		self.scrollsToTop = NO;
		self.backgroundColor = [UIColor blackColor];
		self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
		self.decelerationRate = UIScrollViewDecelerationRateFast;
		
    }
    return self;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {

}

#pragma mark -
#pragma mark zoomScale

#ifndef LKPV_ZOOM_SCALE
#define LKPV_ZOOM_SCALE 2.5
#endif
- (void)zoomRectWithCenter:(CGPoint)center {
	
	if (self.zoomScale > 1.0f) {
		[((LKImageView *)self.superview) killScrollViewZoom];
		return;
	}
	
	CGRect rect;
	rect.size = CGSizeMake(self.frame.size.width / LKPV_ZOOM_SCALE, self.frame.size.height / LKPV_ZOOM_SCALE);
	rect.origin.x = MAX((center.x - (rect.size.width / 2.0f)), 0.0f);		
	rect.origin.y = MAX((center.y - (rect.size.height / 2.0f)), 0.0f);
	
	CGRect frame = [self.superview convertRect:self.frame toView:self.superview];
	CGFloat borderX = frame.origin.x;
	CGFloat borderY = frame.origin.y;
	
	if (borderX > 0.0f && (center.x < borderX || center.x > self.frame.size.width - borderX)) {
		if (center.x < (self.frame.size.width / 2.0f)) {
			rect.origin.x += (borderX/LKPV_ZOOM_SCALE);
		} else {
			rect.origin.x -= ((borderX/LKPV_ZOOM_SCALE) + rect.size.width);
		}	
	}
	
	if (borderY > 0.0f && (center.y < borderY || center.y > self.frame.size.height - borderY)) {
		if (center.y < (self.frame.size.height / 2.0f)) {
			rect.origin.y += (borderY/LKPV_ZOOM_SCALE);
		} else {
			rect.origin.y -= ((borderY/LKPV_ZOOM_SCALE) + rect.size.height);
		}
	}
	
	[self zoomToRect:rect animated:YES];	
}

#pragma mark -
#pragma mark touches handle

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	[super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	[super touchesEnded:touches withEvent:event];
	UITouch *touch = [touches anyObject];
	
	if (touch.tapCount == 1) {
		[self performSelector:@selector(toggleBars) withObject:nil afterDelay:.2];
	} else if (touch.tapCount == 2) {
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(toggleBars) object:nil];
		[self zoomRectWithCenter:[[touches anyObject] locationInView:self]];
	}
}

- (void)toggleBars {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"LKPhotoView_ToggleBars" object:nil];
//	((LKImageView *)self.superview).frame = CGRectMake(0, 0, ((LKImageView *)self.superview).frame.size.width, ((LKImageView *)self.superview).frame.size.height);
//	[((LKImageView *)self.superview) layoutSubviews];
	isInfoboxHidden = !isInfoboxHidden;
	[((LKImageView *)self.superview) hideInfoView:isInfoboxHidden];
}

@end
