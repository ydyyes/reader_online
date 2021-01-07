	//
	//  JPLoadingView.m
	//  NightReader
	//
	//  Created by 张俊平 on 2019/2/21.
	//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
	//

#import "JPLoadingView.h"

@implementation JPLoadingView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self initView];
	}
	return self;
}
- (void)initView {
	self.backgroundColor = [UIColor whiteColor];
//	NSMutableArray *refreshingImages = [NSMutableArray array];
//	for (NSUInteger i = 1; i<=24; i++) {
//		UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"page_loading%zd", i]];
//		[refreshingImages addObject:image];
//	}
//	UIImage *image = [UIImage animatedImageWithImages:refreshingImages duration:1.0f];
		//    UIImage  *image=[UIImage sd_animatedGIFNamed:@"page_loading"];
//	_activeView = [[UIImageView alloc]init];
//	_activeView.backgroundColor=[UIColor clearColor];
//	_activeView.image=image;
//	_activeView.frame = CGRectMake((self.width - 70) /2, (self.height - 70) / 2 , 70, 70);
	YYImage *image = [YYImage imageNamed:@"Loading"];
	YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] initWithImage:image];
	imageView.frame =  CGRectMake((self.width - 50) /2, (self.height - 50) / 2-50 , 50, 50);
	_activeView = imageView;
	[self addSubview:_activeView];

//	_click_loadView = [[UIImageView alloc] initWithFrame:CGRectMake((self.width - 200) / 2,( self.height - 160) /2-50, 200, 160)];
//	_click_loadView.image = [UIImage imageNamed:@"no_network"];
////	[self addSubview:_click_loadView];
//	_click_loadView.hidden = YES;
	
	_label_title = [[UILabel alloc]initWithFrame:CGRectMake(0, _activeView.bottom+30, self.width, 18)];//(0, _click_loadView.bottom+30, self.width, 18)
	_label_title.text = @"咦？咋木有网了呢~";
	_label_title.textAlignment = NSTextAlignmentCenter;
	_label_title.textColor = [UIColor lightGrayColor];
	_label_title.font = [UIFont systemFontOfSize:17];
	[self addSubview:_label_title];
	_label_title.hidden = YES;
	
	_label_content = [[UILabel alloc]initWithFrame:CGRectMake(0, _label_title.bottom+8, self.width, 14)];
	_label_content.text = @"请检查您的网络连接";
	_label_content.textAlignment = NSTextAlignmentCenter;
	_label_content.textColor = [UIColor grayColor];
	_label_content.font = [UIFont systemFontOfSize:14];
	[self addSubview:_label_content];
	_label_content.hidden = YES;
	
	_button = [UIButton buttonWithType:UIButtonTypeCustom];
	_button.frame = CGRectMake(0, 0, self.width, self.height);
	[self addSubview:_button];
	_button.hidden = YES;
	
	
}
- (void)setLoadFailStatus:(BOOL)loadFailStatus {
	
	_loadFailStatus = loadFailStatus;
	
	if (loadFailStatus) {
		_click_loadView.image = [UIImage imageNamed:@"no_network"];
		_label_title.text = @"咦？咋木有网了呢~";
		_label_content.text = @"请检查您的网络连接";
		
	}else{
		_click_loadView.image = [UIImage imageNamed:@"the_server"];
		_label_title.text = @"咦？服务器开小差了~";
		_label_content.text = @"请您点击屏幕重试";
	}
	
}
- (void)setLoadFail:(BOOL)loadFail {
	
	_loadFail = loadFail;
	if (_loadFail) {
		
//		[_activeView stopAnimating];
		_activeView.hidden = YES;
		_label_title.hidden = NO;
		_label_content.hidden = NO;
		_button.hidden = NO;
		_button.userInteractionEnabled = YES;
		_click_loadView.hidden = NO;
		self.enabled = YES;
		self.userInteractionEnabled = YES;
		
	}else{
		
//		[_activeView startAnimating];
		_activeView.hidden = NO;
		_label_title.hidden = YES;
		_label_content.hidden = YES;
		_button.hidden = YES;
		_button.userInteractionEnabled = NO;
		_click_loadView.hidden = YES;
		self.enabled = NO;
		self.userInteractionEnabled = NO;
		
	}
}


@end
