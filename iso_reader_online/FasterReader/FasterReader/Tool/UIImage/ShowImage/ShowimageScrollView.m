	//
	//  ShowimageScrollView.m
	//  publicwine
	//
	//  Created by 何伟东 on 14-1-2.
	//  Copyright (c) 2014年 何伟东. All rights reserved.
	//

#import "ShowimageScrollView.h"
#import "ImageContentScrollView.h"
#import "UIImageView+WebCache.h"

static ShowimageScrollView *showimageScrollView;

@interface ShowimageScrollView ()<UIGestureRecognizerDelegate>

@end
@implementation ShowimageScrollView

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
			// Initialization code
	}
	return self;
}

-(id)init{
	self  = [super init];
	if (self) {
		_imagePageControl = [[UIPageControl alloc] init];
		_pageLabel = [[UILabel alloc] init];
		_pageLabel.textColor = [UIColor whiteColor];
		_pageLabel.layer.cornerRadius  = 5;
		_pageLabel.layer.masksToBounds = YES;
		_pageLabel.backgroundColor     = [UIColor colorWithHexString:@"000000" alpha:0.3];
	}
	return self;
}

+(ShowimageScrollView*)share{
		//    if (!showimageScrollView) {
		//
		//    }
	showimageScrollView = [[ShowimageScrollView alloc] init];
	return showimageScrollView;

}

-(void)showWithImageArray:(NSArray*)imageArray currentView:(UIImageView*)currentView index:(int)index{
	self.imageArray = imageArray;
	_originalImageView = currentView;
	UIWindow *window = [UIApplication sharedApplication].keyWindow;
	[window addSubview:self];
	[self setDelegate:self];
	[self setBackgroundColor:[UIColor blackColor]];
	[self setPagingEnabled:YES];
	[self setShowsHorizontalScrollIndicator:NO];
	[self setFrame:CGRectMake(0, 0, window.frame.size.width, window.frame.size.height)];

	[self setContentSize:CGSizeMake(self.frame.size.width*[imageArray count], self.frame.size.height)];
	for (int i = 0; i < [imageArray count]; i++) {
		ImageContentScrollView *imageScrollView = [[ImageContentScrollView alloc] initWithFrame:CGRectMake(self.frame.size.width*i, 0, self.frame.size.width, self.frame.size.height) originalImageView:i==index?currentView:nil imageUrl:[imageArray objectAtIndex:i] superView:self];
		imageScrollView.delegate_size = self;
		[imageScrollView setBackgroundColor:[UIColor whiteColor]];
		[self addSubview:imageScrollView];

		imageScrollView.tag = i;
		imageScrollView.userInteractionEnabled = YES;
		UILongPressGestureRecognizer *imageLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(imageLongPressAction:)];
		imageLongPress.delegate = self;
		imageLongPress.minimumPressDuration = 0.5f;
		imageLongPress.allowableMovement = 1.0f;
		[imageScrollView addGestureRecognizer:imageLongPress];
	}
	[self setContentOffset:CGPointMake(self.frame.size.width, self.frame.size.width*index)];

	_pageLabel.frame = CGRectMake(0, 0, 50,30);
	[window addSubview:_pageLabel];
	_pageLabel.textAlignment = NSTextAlignmentCenter;
	_pageLabel.center = self.center;
	_pageLabel.bottom = TabBarHeight ? [JPTool screenHeight] - 34 : [JPTool screenHeight] - 20;;
	_pageLabel.text   = [NSString stringWithFormat:@"%d/%zi",index+1,_imageArray.count];

	[self setContentOffset:CGPointMake(self.frame.size.width*index, 0)];

	_saveButton = [[UIButton alloc] initWithFrame:CGRectMake([JPTool screenWidth] - 60, [JPTool screenHeight] - 60, 40, 40)];
	_saveButton.bottom = [JPTool screenHeight] - 10;
	_saveButton.backgroundColor = [UIColor clearColor];
	[_saveButton setImage:[UIImage imageNamed:@"download_normal"] forState:UIControlStateNormal];
	[_saveButton setImage:[UIImage imageNamed:@"download_press"] forState:UIControlStateHighlighted];
	[_saveButton addTarget:self action:@selector(saveImage:) forControlEvents:UIControlEventTouchUpInside];
	[window addSubview:_saveButton];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{

	int index = scrollView.contentOffset.x/self.frame.size.width;
	_pageLabel.text = [NSString stringWithFormat:@"%d/%zi",index+1,_imageArray.count];
}
-(void)remove:(CGSize )size{

	dispatch_async(dispatch_get_main_queue(), ^{
		[_saveButton removeFromSuperview];
			//        CGRect originalRect =[_originalImageView convertRect:_originalImageView.bounds toView:[UIApplication sharedApplication].keyWindow];
		[_imagePageControl removeFromSuperview];
		[_pageLabel removeFromSuperview];
		[UIView animateWithDuration:0.5 animations:^{
				//            self.center = CGPointMake(originalRect.origin.x+originalRect.size.width/2, originalRect.origin.y+originalRect.size.height/2);
				//            double proportion_y = originalRect.size.height/size.height;
				//            double proportion_x = originalRect.size.width/size.width;
				//            self.transform = CGAffineTransformMakeScale(proportion_x, proportion_y);//将要显示的view按照proportion比例显示出来
			self.alpha = 0;

		} completion:^(BOOL finished) {
			for (UIView *view in [self subviews]) {
				[view removeFromSuperview];
			}
			[self removeFromSuperview];
		}];
	});
}

#pragma mark -- 长按保存图片
- (void)imageLongPressAction:(UILongPressGestureRecognizer *)longPress
{
	if (longPress.state == UIGestureRecognizerStateBegan) {
		WS(ws);
		[[SureCanceAlert shareAlert] setTitleText:@"确认保存图片？" withSureBtnTitle:@"确定" withMaxHeight:100 withAlertStyle:AlertButtonTypeStyleDefault withSureBtnClick:^(UIButton *sender) {
			UIImageView *imgView = [[UIImageView alloc] init];
			int index = ws.contentOffset.x/ws.frame.size.width;
			[imgView sd_setImageWithURL:[NSURL URLWithString:_imageArray[index]]];
			if (imgView.image) {
				[[ZJPAlert shareAlert] showLodingWithTitle:@"加载中..."];
				UIImageWriteToSavedPhotosAlbum(imgView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
			}else{
				[ZJPAlert showAlertWithMessage:@"图片保存失败!" time:0.5];
			}
		} withCancelBtnClick:^(UIButton *sender) {

		}];
	}
}
- (void)saveImage:(UIButton*)button {

	UIImageView *imgView = [[UIImageView alloc] init];
	int index = self.contentOffset.x/self.frame.size.width;
		//    [imgView setImageWithURL:[NSURL URLWithString:_imageArray[index]]];
	[imgView setYy_imageURL:[NSURL URLWithString:_imageArray[index]]];
	if (imgView.image) {
		UIImageWriteToSavedPhotosAlbum(imgView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
	}else{
		[ZJPAlert showAlertWithMessage:@"图片保存失败!" time:0.5];
	}
}
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
	[[ZJPAlert shareAlert] hiddenHUD];
	if(error != NULL){
		[ZJPAlert showAlertWithMessage:@"图片保存失败!" time:0.5];
		if (error.code == -3310) {
			[ZJPAlert alertWithMessage:PhotoTips title:@"提示"];
		}
	}else{
		[ZJPAlert showAlertWithMessage:@"图片已保存当前相册!" time:0.5];
	}

}

@end
