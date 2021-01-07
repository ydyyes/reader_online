// 原图显示页面,首页缩略图点击/微博正文图片点击均进入此页面
//  LCPicShowerViewController.m
//  LanChaoClient
//
//  Created by xydd12345 on 11-12-3.
//  Copyright (c) 2011年 PICA. All rights reserved.
//

#import "LCPicShowerViewController.h"

#import "LKImageView.h"

#include <QuartzCore/CoreAnimation.h>

#import "UIImage+Tools.h"

enum {
    TYPE_OF_IMAGE_URL       = 0,
    TYPE_OF_IMAGE_SOURCE,
};

@interface LCPicShowerViewController ()

@property (nonatomic, retain) UIScrollView *photoScrollView;
@property (nonatomic, assign) BOOL isBarsHidden;
@property (nonatomic, strong) UIButton *rightBtn;

- (void)toggleBarsNotification:(NSNotification *)noti;
- (void)hideBars:(BOOL)hidden animated:(BOOL)animated;
- (void)setStatusBarHidden:(BOOL)hidden animated:(BOOL)animated;

- (void)saveImage;
@end


@implementation LCPicShowerViewController

#define kAImgView_w Get[JPTool screenWidth]()

@synthesize photoScrollView, theStatus, imageView, removeImage;
@synthesize tag;

//- (NSString*)photoURL{
//    return theStatus.image1;
//}

- (void) setAStatus:(ESStatus*) aStatus
{
	
	self.theStatus = aStatus;
	type = TYPE_OF_IMAGE_URL;
}

- (id)initWithAStatus:(NSString *)imageUrl {
	
	if (self = [super init]) {
        type = TYPE_OF_IMAGE_URL;
        _imageUrl = imageUrl;
		//return self;
        UIImage *image = [UIImage imageNamed:@"hei.png"];
        if (imageUrl && [imageUrl length]) {

            UIImage* tempImage = [UIImage imageWithContentsOfFile:imageUrl];
                image = tempImage;
//                isSave = YES;
        }
        
		self.imageView = [[LKImageView alloc] initWithFrame:self.view.bounds andInfo:nil];
		CGRect rect = imageView.frame;
		//image.size =  rect.size;
		[imageView setupImgViewWithImage:image];

        rect.size.height = self.photoScrollView.bounds.size.height;
		imageView.frame = rect;
		imageView.tag = 0;
		[photoScrollView addSubview:imageView];
	}
	return self;
}



- (id)initWithImage:(UIImage*)anImage
{	
	if (self = [super init]) {
        
        type = TYPE_OF_IMAGE_SOURCE;
		self.imageView = [[LKImageView alloc] initWithFrame:self.view.bounds andInfo:nil];
		[imageView setupImgViewWithImage:anImage];
		CGRect rect = imageView.frame;
		rect.size.height = self.photoScrollView.bounds.size.height;
        WS(ws);
        self.imageView.lkImageViewImagePressBlock = ^(UIImageView *imageV) {
            [[SureCanceAlert shareAlert] setTitleText:@"确认保存图片？" withSureBtnTitle:@"确定" withMaxHeight:100 withAlertStyle:AlertButtonTypeStyleDefault withSureBtnClick:^(UIButton *sender) {
                [ws saveImage:imageV.image];
            } withCancelBtnClick:^(UIButton *sender) {

            }];
        };

		imageView.frame = rect;
		imageView.tag = 0;
        [self.view addSubview:imageView];
		[photoScrollView addSubview:imageView];
	}
	return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
    [super viewDidLoad];

    self.view.tag = 1;
    self.view.bounds = CGRectMake(0, 0, [JPTool screenWidth], [JPTool screenHeight]-NavBarHeight);
//    if (isIphone5) {
//        self.view.height = 506;
//    }
	
	isViewAppeared = NO;
    removeImage = NO;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleBarsNotification:) name:@"LKPhotoView_ToggleBars" object:nil];

	self.view.backgroundColor =[UIColor clearColor];
	photoScrollView.backgroundColor = [UIColor clearColor];
	//photoScrollView.hidden = YES;
	
	
	photoScrollView.clipsToBounds = YES;
	photoScrollView.scrollEnabled = YES;
	photoScrollView.pagingEnabled = YES;
	photoScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	
    UIBarButtonItem *anItem = nil;
    if (type == TYPE_OF_IMAGE_URL){
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
        self.navigationController.navigationBar.tintColor = nil;
//        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
        self.navigationController.navigationBar.translucent = NO;
		
		anItem = [[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"返回", nil)
                                                  style: UIBarButtonItemStylePlain
                                                 target: self
                                                 action: @selector(cancel:)];
        self.navigationItem.leftBarButtonItem = anItem;
        
        anItem = [[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"保存", nil)
                                                  style: UIBarButtonItemStylePlain
                                                 target: self
                                                 action: @selector(saveImage)];
        self.navigationItem.rightBarButtonItem = anItem;
    }
    else {

        
        UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        leftBtn.frame = CGRectMake(0, 0, 50, 40);
        [leftBtn setTitle:@"返回" forState:UIControlStateNormal];
        [leftBtn setTitleColor:[UIColor colorWithHexString:@"ffffff"] forState:UIControlStateNormal];
        leftBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [leftBtn addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
        [self.navigationItem setLeftBarButtonItem:leftBarButtonItem];
        
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        rightBtn.frame = CGRectMake(0, 0, 50, 40);
        [rightBtn setTitle:@"删除" forState:UIControlStateNormal];
        [rightBtn setTitleColor:[UIColor colorWithHexString:@"ffffff"] forState:UIControlStateNormal];
        rightBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [rightBtn addTarget:self action:@selector(remove:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
        self.rightBtn = rightBtn;
        
        [self.navigationItem setRightBarButtonItem:rightBarButtonItem];
    }

    self.navigationController.navigationBar.tintColor =[UIColor colorWithHexString:@"ff5c5c"];

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
     [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"top_navigation_bg_6p"] imageByScrollAlpha:1] forBarMetrics:UIBarMetricsDefault];
}


- (void)viewWillDisappear:(BOOL)animated {
	
	[super viewWillDisappear:animated];
//	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
/*	[[LKLoadingCenter defaultCenter] disposeLoadingViewAndIgnoreTouch:YES];
 isViewAppeared = NO;
    REM_IMAGE([self photoURL]);
*/}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
		return  (interfaceOrientation == UIInterfaceOrientationPortrait);
}



- (void)viewDidUnload {
//	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [super viewDidUnload];
}


- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.photoScrollView = nil;
}

#pragma mark action

- (void)cancel: (id)sender
{
    [[ZJPAlert shareAlert] hiddenHUD];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)remove: (id)sender{
    removeImage = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteImgSucceed" object:self];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];}

- (void)saveImage:(UIImage *)tempImage {
    if (!tempImage) {
        tempImage = [UIImage imageWithContentsOfFile:_imageUrl];
    }
    
	if (tempImage != nil) {
        [[ZJPAlert shareAlert] showLodingWithTitle:@"保存中..."];
		UIImageWriteToSavedPhotosAlbum(tempImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
	}
    else {
        [[ZJPAlert shareAlert] showLodingWithTitle:@"保存失败..." delay:1];
	}
}

-(void)returnAction
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)roundAction
{
//	imageView.layer.transform = CATransform3DRotate(imageView.layer.transform, M_PI/2, 0, 0, 1);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
	[[ZJPAlert shareAlert] hiddenHUD];
	if(error != nil)
	{
		UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"提示" message:PhotoTips delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
		[alert show];
        
    } else {
        [ZJPAlert showAlertWithMessage:@"图片已保存" time:2.0f];
    }
}


#pragma mark touch handle
@synthesize isBarsHidden;

- (void)toggleBarsNotification:(NSNotification *)noti {

}

- (void)hideBars:(BOOL)hidden animated:(BOOL)animated {
	
	if (hidden && isBarsHidden) return;
	[self setHidesBottomBarWhenPushed:hidden];
	[self setStatusBarHidden:hidden animated:animated];
    [self.navigationController setNavigationBarHidden:hidden animated:animated];
	isBarsHidden = hidden;
}


- (void)setStatusBarHidden:(BOOL)hidden animated:(BOOL)animated {
    
    UIApplication* anApp = [UIApplication sharedApplication];
    if ([anApp respondsToSelector: @selector(setStatusBarHidden:withAnimation:)]){
        [anApp setStatusBarHidden: hidden withAnimation: UIStatusBarAnimationFade]; 
    }
    else {
        [anApp setStatusBarHidden:hidden withAnimation: animated];
    }
}

-(void)doPop
{
	[self cancel:nil];	
}

-(void)doPopTo
{
    
 //   
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setIsHiddenDeleteBtn:(BOOL)isHiddenDeleteBtn
{
    _isHiddenDeleteBtn = isHiddenDeleteBtn;
    if (_isHiddenDeleteBtn==YES) {
        self.rightBtn.hidden = YES;
    } else {
        self.rightBtn.hidden = NO;
    }
}
@end
