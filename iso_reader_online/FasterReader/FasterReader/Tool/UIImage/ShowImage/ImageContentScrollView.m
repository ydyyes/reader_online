	//
	//  ImageContentScrollView.m
	//  publicwine
	//
	//  Created by 何伟东 on 14-1-2.
	//  Copyright (c) 2014年 何伟东. All rights reserved.
	//

#import "ImageContentScrollView.h"
#import "ShowimageScrollView.h"
#import "UIImageView+WebCache.h"
@implementation ImageContentScrollView
@synthesize touchImageView;

- (id)initWithFrame:(CGRect)frame originalImageView:(UIImageView*)originalImageView imageUrl:(NSString*)url superView:(UIScrollView *)superView
{
	self = [super initWithFrame:frame];
	if (self) {
		for (UIView *view in [self subviews]) {
			[view removeFromSuperview];
		}
			// Initialization code
		self.minimumZoomScale = 1.0;
		self.maximumZoomScale = 6.0;
		self.delegate = self;

		_progressView = [[DACircularProgressView alloc] initWithFrame:CGRectMake(0, 0, 40.0f, 40.0f)];
		_progressView.progressTintColor = [UIColor whiteColor];
		[_progressView setCenter:CGPointMake(160,[JPTool screenWidth] == 320?250:210)];

		_progressView.trackTintColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.3f];

		[self addSubview:_progressView];

		UIImage *image=originalImageView.image;
		touchImageView = [[UIImageView alloc] init];
		if (originalImageView) {
			superView.alpha = 0;
			CGRect originalRect =[originalImageView convertRect:originalImageView.bounds toView:[UIApplication sharedApplication].keyWindow];
			[touchImageView setFrame:originalRect];
			[touchImageView setImage:originalImageView.image];
			[UIView animateWithDuration:0.38 animations:^{
				superView.alpha = 1;
				if (image.size.width >= image.size.height || ([JPTool screenWidth]*image.size.height/image.size.width) < self.frame.size.height) {
					[touchImageView setFrame:CGRectMake(0, (self.frame.size.height-([JPTool screenWidth]*image.size.height/image.size.width))/2, [JPTool screenWidth], [JPTool screenWidth]*image.size.height/image.size.width)];
				}else{
					[touchImageView setFrame:CGRectMake(0, 0, [JPTool screenWidth], [JPTool screenWidth]*image.size.height/image.size.width)];
					[self setContentSize:touchImageView.frame.size];
					[self setShowsHorizontalScrollIndicator:NO];
					[self setShowsVerticalScrollIndicator:NO];
				}
			} completion:^(BOOL finished) {


			}];
		}

		_tempImageView = [[UIImageView alloc] init];

		UITapGestureRecognizer* singleRecognizer;
		singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapFrom)];
		singleRecognizer.numberOfTapsRequired = 1; // 单击
		[self addGestureRecognizer:singleRecognizer];

		[_tempImageView yy_setImageWithURL:[NSURL URLWithString:url]
									  placeholder:nil
											options:YYWebImageOptionSetImageWithFadeAnimation
										  progress:^(NSInteger receivedSize, NSInteger expectedSize) {
											  _progressView.progress = (float)receivedSize / expectedSize;
										  }
										 transform:^UIImage *(UIImage *image, NSURL *url) {
											 image = [image yy_imageByResizeToSize:CGSizeMake(100, 100) contentMode:UIViewContentModeCenter];
											 return [image yy_imageByRoundCornerRadius:10];
										 }
										completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
											if (from == YYWebImageFromDiskCache) {
												NSLog(@"load from disk cache");
											}
											if (!image) {
												return ;
											}
											[_progressView removeFromSuperview];
											if (image.size.width >= image.size.height || ([JPTool screenWidth]*image.size.height/image.size.width) < self.frame.size.height) {
												[touchImageView setFrame:CGRectMake(0, (self.frame.size.height-([JPTool screenWidth]*image.size.height/image.size.width))/2, [JPTool screenWidth], [JPTool screenWidth]*image.size.height/image.size.width)];
											}else{
												[touchImageView setFrame:CGRectMake(0, 0, [JPTool screenWidth], [JPTool screenWidth]*image.size.height/image.size.width)];
												[self setContentSize:touchImageView.frame.size];
												[self setShowsHorizontalScrollIndicator:NO];
												[self setShowsVerticalScrollIndicator:NO];
											}
											touchImageView.image = image;
												// 双击的 Recognizer
											UITapGestureRecognizer* doubleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapFrom:)];
											doubleRecognizer.numberOfTapsRequired = 2; // 双击
											[self addGestureRecognizer:doubleRecognizer];
											[singleRecognizer requireGestureRecognizerToFail:doubleRecognizer];
										}];
			//        [_tempImageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"work_picture_load"] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
			//            _progressView.progress = (float)receivedSize/expectedSize;
			//
			//
			//        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
			//            if (!image) {
			//                return ;
			//            }
			//            [_progressView removeFromSuperview];
			//            if (image.size.width >= image.size.height || ([JPTool screenWidth]*image.size.height/image.size.width) < self.frame.size.height) {
			//                [touchImageView setFrame:CGRectMake(0, (self.frame.size.height-([JPTool screenWidth]*image.size.height/image.size.width))/2, [JPTool screenWidth], [JPTool screenWidth]*image.size.height/image.size.width)];
			//            }else{
			//                [touchImageView setFrame:CGRectMake(0, 0, [JPTool screenWidth], [JPTool screenWidth]*image.size.height/image.size.width)];
			//                [self setContentSize:touchImageView.frame.size];
			//                [self setShowsHorizontalScrollIndicator:NO];
			//                [self setShowsVerticalScrollIndicator:NO];
			//            }
			//            touchImageView.image = image;
			//            // 双击的 Recognizer
			//            UITapGestureRecognizer* doubleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapFrom:)];
			//            doubleRecognizer.numberOfTapsRequired = 2; // 双击
			//            [self addGestureRecognizer:doubleRecognizer];
			//            [singleRecognizer requireGestureRecognizerToFail:doubleRecognizer];
			//        }];

		[self addSubview:touchImageView];

	}
	return self;
}

-(void)handleSingleTapFrom{
	[self.delegate_size remove:touchImageView.frame.size];
		//    [self.superview performSelector:@selector(remove)];
}
static int scale = 1;
-(void)handleDoubleTapFrom:(UITapGestureRecognizer *)tap{
	scale = scale == 1 ? 5 : 1;
	CGRect zoomRect = [self zoomRectForScale:scale withCenter:[tap locationInView:self]];
	[self zoomToRect:zoomRect animated:YES];

}
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
	CGRect zoomRect;
	zoomRect.size.height = self.frame.size.height / scale;
	zoomRect.size.width  = self.frame.size.width  / scale;
	zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
	zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
	return zoomRect;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return touchImageView;
}


@end
