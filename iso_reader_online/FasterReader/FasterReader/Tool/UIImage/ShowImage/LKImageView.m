//
//  LKImageView.m
//  
//
//  Created by luke on 10-11-12.
//  Copyright 2010 pica.com. All rights reserved.
//

#import "LKImageView.h"
#import "LKZoomableView.h"
#import <QuartzCore/QuartzCore.h>

@interface LKImageView ()<UIGestureRecognizerDelegate>
@property (nonatomic, retain) LKZoomableView *imgContainer;
@property (nonatomic, retain) UIImageView *imgView;
@property (nonatomic, retain) NSString *info;
@property (nonatomic, retain) UIView *infoBox;
@property (nonatomic, retain) UILabel *infoLabel;

- (void)layoutScrollViewAnimated:(BOOL)animated;
- (void)reallyKillZoom;
@end


@implementation LKImageView
@synthesize info;
@synthesize imgContainer = _imgContainer, imgView = _imgView;
@synthesize infoLabel = _infoLabel, infoBox = _infoBox;
/*
- (id)initWithImage:(UIImage *)pImage andInfo:(NSString *)pInfo {
	
	if (self = [super initWithImage:pImage]) {
		self.userInteractionEnabled = YES;
		self.info = pInfo;
		if (self.info) {
			self.infoBox = [[UIView alloc] initWithFrame:CGRectZero];
			infoBox.backgroundColor = [UIColor blackColor];
			infoBox.alpha = 0.8;
			
			self.infoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
			infoLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
			infoLabel.font = [UIFont systemFontOfSize:12.0f];
			infoLabel.textColor = [UIColor whiteColor];
			//infoLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
			//infoLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
			infoLabel.backgroundColor = [UIColor clearColor];
			infoLabel.textAlignment = UITextAlignmentCenter;
			infoLabel.text = self.info;
			[infoBox addSubview:infoLabel];
			[infoLabel release];
			[self addSubview:infoBox];
			[infoBox release];
		}
	}
	return self;
}
*/

#define LKPV_ZOOM_VIEW_TAG 101

- (id)initWithFrame:(CGRect)frame andInfo:(NSString *)pInfo {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor =  [UIColor blackColor];
		self.userInteractionEnabled = YES;
		self.info = pInfo;
		
		self.imgContainer = [[LKZoomableView alloc] initWithFrame:self.bounds];
		_imgContainer.backgroundColor = [UIColor blackColor];
		_imgContainer.delegate = self;
		[self addSubview:_imgContainer];
		
		self.imgView = [[UIImageView alloc] initWithFrame:self.bounds];
		_imgView.contentMode = UIViewContentModeScaleAspectFit;
		_imgView.tag = LKPV_ZOOM_VIEW_TAG;
		[_imgContainer addSubview:_imgView];
        
        self.imgView.userInteractionEnabled = YES;
        UILongPressGestureRecognizer *imageLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(imageLongPressAction:)];
        imageLongPress.delegate = self;
        imageLongPress.minimumPressDuration = 0.5f;
        imageLongPress.allowableMovement = 1.0f;
        [self.imgView addGestureRecognizer:imageLongPress];
		
		if (self.info) {
			self.infoBox = [[UIView alloc] initWithFrame:CGRectZero];
			_infoBox.backgroundColor = [UIColor blackColor];
			_infoBox.alpha = 0.8;
			
			self.infoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//			infoLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
			_infoLabel.font = [UIFont systemFontOfSize:12.0f];
			_infoLabel.textColor = [UIColor whiteColor];
			//infoLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
			//infoLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
			_infoLabel.backgroundColor = [UIColor clearColor];
			_infoLabel.textAlignment = NSTextAlignmentCenter;
			_infoLabel.text = self.info;
			[_infoBox addSubview:_infoLabel];
			[self addSubview:_infoBox];
		}
    }
    return self;
}

#pragma mark -- 图片长按调用
- (void)imageLongPressAction:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state==UIGestureRecognizerStateBegan) {
        UIImageView *imageV = (UIImageView *)longPress.view;
        if (self.lkImageViewImagePressBlock) {
            self.lkImageViewImagePressBlock(imageV);
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
	
	self.imgContainer = nil;
	self.imgView = nil;
	self.info = nil;
	self.infoBox = nil;
	self.infoLabel = nil;
}

- (void)hideInfoView:(BOOL)hidden {
	
	self.infoBox.hidden = hidden;
}

- (void)layoutSubviews {
	
	[super layoutSubviews];

	
	if (_imgContainer.zoomScale == 1.0f) {
		[self layoutScrollViewAnimated:YES];
	}
	
	CGSize infoSize = [self.info sizeWithFont:[UIFont systemFontOfSize:16] 
							constrainedToSize:self.bounds.size 
								lineBreakMode:NSLineBreakByCharWrapping];
	CGRect infoBoxFrame = CGRectMake(0, 416 - infoSize.height - 44, [JPTool screenWidth], infoSize.height);
	[self.infoBox setFrame:infoBoxFrame];
	
	CGRect infoFrameInInfoBox = CGRectMake(0, 0, infoBoxFrame.size.width, infoBoxFrame.size.height);
	[self.infoLabel setFrame:infoFrameInInfoBox];
}

- (void)layoutScrollViewAnimated:(BOOL)animated {
	
	if (animated) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.0001];
	}
	
	CGFloat hfactor = self.imgView.image.size.width / self.frame.size.width;
	CGFloat vfactor = self.imgView.image.size.height / self.frame.size.height;
	
	CGFloat factor = MAX(hfactor, vfactor);
	
	CGFloat newWidth = self.imgView.image.size.width / factor;
	CGFloat newHeight = self.imgView.image.size.height / factor;
	
	CGFloat leftOffset = (self.frame.size.width - newWidth) / 2;
	CGFloat topOffset = (self.frame.size.height - newHeight) / 2;
	
	self.imgContainer.frame = CGRectMake(leftOffset, topOffset, newWidth, newHeight);
	self.imgContainer.contentSize = CGSizeMake(self.imgContainer.bounds.size.width, self.imgContainer.bounds.size.height);
	self.imgContainer.contentOffset = CGPointMake(0.0f, 0.0f);
	self.imgView.frame = self.imgContainer.bounds;
	
	if (animated) {
		[UIView commitAnimations];
	}
}

#pragma mark Animation

- (CABasicAnimation *)fadeAnimation {
	
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	animation.fromValue = [NSNumber numberWithFloat:0.0f];
	animation.toValue = [NSNumber numberWithFloat:1.0f];
	animation.duration = .3f;
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
	
	return animation;
}

- (void)setupImgViewWithImage:(UIImage *)theImage {	
	
	//_loading = NO;
	//[_activityView stopAnimating];
	self.imgView.image = theImage; 
	[self layoutScrollViewAnimated:NO];
	[[self layer] addAnimation:[self fadeAnimation] forKey:@"opacity"];
	self.userInteractionEnabled = YES;
}

#pragma mark -
#pragma mark UIScrollView Delegate Methods

- (void)reallyKillZoom {
	
	[self.imgContainer setZoomScale:1.0f animated:NO];
	self.imgView.frame = self.imgContainer.bounds;
	[self layoutScrollViewAnimated:NO];
}

- (void)killScrollViewZoom {
	
	if (!self.imgContainer.zoomScale > 1.0f) return;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDidStopSelector:@selector(reallyKillZoom)];
	[UIView setAnimationDelegate:self];
	
	CGFloat hfactor = self.imgView.image.size.width / self.frame.size.width;
	CGFloat vfactor = self.imgView.image.size.height / self.frame.size.height;
	
	CGFloat factor = MAX(hfactor, vfactor);
	
	CGFloat newWidth = self.imgView.image.size.width / factor;
	CGFloat newHeight = self.imgView.image.size.height / factor;
	
	CGFloat leftOffset = (self.frame.size.width - newWidth) / 2;
	CGFloat topOffset = (self.frame.size.height - newHeight) / 2;
	
	self.imgContainer.frame = CGRectMake(leftOffset, topOffset, newWidth, newHeight);
	self.imgView.frame = self.imgContainer.bounds;
	[UIView commitAnimations];
	
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)imgContainer {
	
	return [self.imgContainer viewWithTag:LKPV_ZOOM_VIEW_TAG];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float )scale {
	
	if (scrollView.zoomScale > 1.0f) {		
		CGFloat height, width;
		
		
		if (CGRectGetMaxX(self.imgView.frame) > self.bounds.size.width) {
			width = CGRectGetWidth(self.bounds);
		} else {
			width = CGRectGetMaxX(self.imgView.frame);
		}
		
		if (CGRectGetMaxY(self.imgView.frame) > self.bounds.size.height) {
			height = CGRectGetHeight(self.bounds);
		} else {
			height = CGRectGetMaxY(self.imgView.frame);
		}
		
		CGRect frame = self.imgContainer.frame;
		self.imgContainer.frame = CGRectMake((self.bounds.size.width / 2) - (width / 2), (self.bounds.size.height / 2) - (height / 2), width, height);
		if (!CGRectEqualToRect(frame, self.imgContainer.frame)) {		
			
			CGFloat offsetY, offsetX;
			
			if (frame.origin.y < self.imgContainer.frame.origin.y) {
				offsetY = self.imgContainer.contentOffset.y - (self.imgContainer.frame.origin.y - frame.origin.y);
			} else {				
				offsetY = self.imgContainer.contentOffset.y - (frame.origin.y - self.imgContainer.frame.origin.y);
			}
			
			if (frame.origin.x < self.imgContainer.frame.origin.x) {
				offsetX = self.imgContainer.contentOffset.x - (self.imgContainer.frame.origin.x - frame.origin.x);
			} else {				
				offsetX = self.imgContainer.contentOffset.x - (frame.origin.x - self.imgContainer.frame.origin.x);
			}
			
			if (offsetY < 0) offsetY = 0;
			if (offsetX < 0) offsetX = 0;
			
			self.imgContainer.contentOffset = CGPointMake(offsetX, offsetY);
		}
		
	} else {
		[self layoutScrollViewAnimated:YES];
	}
}	


@end
