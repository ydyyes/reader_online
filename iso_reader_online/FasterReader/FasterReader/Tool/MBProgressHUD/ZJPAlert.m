//
//  ZJPAlert.m
//  NightReader
//
//  Created by 张俊平 on 2019/2/20.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import "ZJPAlert.h"

@implementation ZJPAlert

- (void)showLodingWithView:(UIView *)view {

	YYImage *image = [YYImage imageNamed:@"Loading"];
	YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] initWithImage:image];
	imageView.frame =  CGRectMake(0, 0, 45, 45);

	if (!view) {
		UIWindow *window = [[UIApplication sharedApplication] keyWindow];
		HUD = [[MBProgressHUD alloc] initWithView:window];
		//		HUD = [MBProgressHUD showHUDAddedTo:window animated:YES];
		HUD.mode = MBProgressHUDModeCustomView;//MBProgressHUDModeCustomView 自定义图片
		//		HUD.customView = imageView;
		HUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
		HUD.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:0.5];
		HUD.backgroundView.color = [UIColor redColor];
		HUD.minSize = CGSizeMake(45, 45);
		HUD.bezelView.layer.masksToBounds = NO;
		[HUD.bezelView addSubview:imageView];
		[window addSubview:HUD];
	}else{
		if (HUD) {
			[HUD hideAnimated:YES];
		}
		// 自定义
//		HUD = [[MBProgressHUD alloc] initWithView:view];
//		HUD.bezelView.backgroundColor = [UIColor redColor];
//		HUD.mode = MBProgressHUDModeCustomView;//MBProgressHUDModeIndeterminate;
//		HUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
//		HUD.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:0.0];
//		HUD.backgroundView.color = [UIColor clearColor];
//		HUD.minSize = CGSizeMake(70, 80);
//		HUD.bezelView.layer.masksToBounds = NO;
//		[HUD.bezelView addSubview:imageView];
//		UILabel *lb = [[UILabel alloc]initWithFrame:CGRectMake(0, imageView.bottom+5, 70, 20)];
//		lb.text = @"加载中...";
//		lb.font = [UIFont systemFontOfSize:14];
//		[HUD.bezelView addSubview:lb];
//		[view addSubview:HUD];

		HUD = [[MBProgressHUD alloc] initWithView:view];
		HUD.mode = MBProgressHUDModeIndeterminate;
		HUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
		HUD.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:0.4];
		HUD.backgroundView.color = [[UIColor blackColor] colorWithAlphaComponent:0.0];//[UIColor clearColor];
		HUD.bezelView.layer.masksToBounds = YES;
		[view addSubview:HUD];


	}
	HUD.delegate = self;
	HUD.label.text = @"加载中...";
		//			HUD.detailsLabel.text = message;
//	HUD.contentColor = [UIColor colorWithRed:0.f green:0.6f blue:0.7f alpha:1.f];
	HUD.square = NO;
	[HUD showAnimated:YES];
}

- (void)showLoding {
	UIWindow *window = [[UIApplication sharedApplication] keyWindow];
	HUD = [MBProgressHUD showHUDAddedTo:window animated:YES];
	HUD.label.text = @"努力加载中...";
	HUD.delegate = self;
}

+ (void)alertWithMessage:(NSString *)message title:(NSString*)title{
		// open an alert with an OK button
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
																	message:message
																  delegate:nil
													  cancelButtonTitle:@"知道了"
													  otherButtonTitles: nil];
	[alert show];
//	[alert release];

}

+ (void)alertWithMessage:(NSString *)message{
	[ZJPAlert alertWithMessage:message title:@"提示"];

}
+(void)showLodingWithTitle:(NSString*)title message:(NSString*)message
{
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
	if (title) {
		[dictionary setObject:title forKey:@"title"];
	}
	if (message) {
		[dictionary setObject:message forKey:@"message"];
	}
	[NSThread detachNewThreadSelector:@selector(threedLKLoading:) toTarget:self withObject:dictionary];
}
+(void)timerFireMethod:(NSTimer*)theTimer//弹出框
{
	UIAlertView *promptAlert = (UIAlertView*)[theTimer userInfo];
	[promptAlert dismissWithClickedButtonIndex:0 animated:NO];
	promptAlert =NULL;
}
+(void)showAlertWithMessage:(NSString*)message time:(NSTimeInterval)time{
		//    UIAlertView *promptAlert = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
		//    [NSTimer scheduledTimerWithTimeInterval:1.0f
		//                                     target:self
		//                                   selector:@selector(timerFireMethod:)
		//                                   userInfo:promptAlert
		//                                    repeats:YES];
		//    [promptAlert show];

	if (!time) {
		time = 0.25;
	}
	for (UIView *view in [[UIApplication sharedApplication].keyWindow subviews]) {
		if (view.tag == 10000) {
			return;
		}
	}

	UILabel *messageLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 120, [JPTool screenWidth], 45)];
	messageLable.numberOfLines = 0;

	CGRect size = [message boundingRectWithSize:CGSizeMake([JPTool screenWidth]-60, [JPTool screenHeight])options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15]} context:nil];
	if (size.size.height<40) {
		size.size.height = 40;
	}

	messageLable.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - size.size.width -  40) /2, ([UIScreen mainScreen].bounds.size.height - size.size.height) / 2, size.size.width + 40, size.size.height);
	if ([JPTool screenHeight] == 480) {
		messageLable.top = 180;
	}
	[messageLable setTag:10000];
		//    [messageLable setBackgroundColor:[UIColor colorWithHexString:@"#000000" alpha:0.6]];
	messageLable.backgroundColor = [UIColor grayColor];
	[messageLable setTextAlignment:NSTextAlignmentCenter];
	[messageLable setTextColor:[UIColor whiteColor]];
	[messageLable setText:message];
	messageLable.layer.cornerRadius = 7;
	messageLable.clipsToBounds = YES;
	[messageLable setAdjustsFontSizeToFitWidth:YES];

	dispatch_async(dispatch_get_main_queue(), ^{
		[[UIApplication sharedApplication].keyWindow addSubview:messageLable];

	});

		//    [UIView animateWithDuration:1.5 animations:^{
		//        messageLable.transform = CGAffineTransformMakeScale(0.7, 0.7);
		//        messageLable.alpha = 0;
		//    } completion:^(BOOL finished) {
		//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)( 1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		//          [UIView animateWithDuration:0.5 animations:^{
		//              [messageLable removeFromSuperview];
		//              [messageLable release];
		//          }];
		//        });
		//
		//    }];

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)( 0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[UIView animateWithDuration:time animations:^{
			messageLable.transform = CGAffineTransformMakeScale(0.5, 0.5);
			messageLable.alpha = 0;
		} completion:^(BOOL finished) {
			[messageLable removeFromSuperview];
//			[messageLable release];
		}];
	});


		//    [UIView animateWithDuration:0.2 animations:^{
		//        [alertView setFrame:CGRectMake(0,40, [JPTool screenWidth], 45)];
		//    } completion:^(BOOL finish) {
		//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		//            [UIView animateWithDuration:0.2 animations:^{
		//                [alertView setFrame:CGRectMake(0, -20, [JPTool screenWidth], 45)];
		//            } completion:^(BOOL finish) {
		//                [alertView removeFromSuperview];
		//                [alertView release];
		//            }];
		//        });
		//
		//    }];


}
+(void) hideTabBar:(UITabBarController *) tabbarcontroller {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	for(UIView *view in tabbarcontroller.view.subviews)
		 {
		if([view isKindOfClass:[UITabBar class]])
			 {
			[view setFrame:CGRectMake(view.frame.origin.x, [JPTool screenHeight], view.frame.size.width, view.frame.size.height)];
			 }
		else
			 {
			[view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, [JPTool screenHeight])];
			 }
		 }
	[UIView commitAnimations];
}

+(void) showTabBar:(UITabBarController *) tabbarcontroller {

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	for(UIView *view in tabbarcontroller.view.subviews)
		 {
			//        NSLog(@"%@", view);

		if([view isKindOfClass:[UITabBar class]])
			 {
			[view setFrame:CGRectMake(view.frame.origin.x, [JPTool screenHeight]-49, view.frame.size.width, view.frame.size.height)];
			 }
		else
			 {
			[view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width,  [JPTool screenHeight]-49)];
			 }
		 }

	[UIView commitAnimations];
}

#pragma mark Singleton
+ (ZJPAlert *)shareAlert
{
	static ZJPAlert *defaultAlert = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		defaultAlert = [[ZJPAlert alloc] init];
	});
	return defaultAlert;
}
#pragma mark - MBProgressHUD
- (void)showLodingWithTitle:(NSString*)title delay:(NSTimeInterval)time {

	UIWindow *window = [[UIApplication sharedApplication] keyWindow];
	HUD = [[MBProgressHUD alloc] initWithView:window];
	[window addSubview:HUD];
	HUD.delegate = self;
	HUD.label.text = title;
	HUD.square = YES;
	[HUD showAnimated:YES];
	[HUD hideAnimated:YES afterDelay:time];
}
- (void)showLodingWithTitle:(NSString*)title
{
	[[ZJPAlert shareAlert] showLodingWithTitle:title message:@"" withView:nil];
}
- (void)showLodingWithTitle:(NSString*)title message:(NSString*)message
{
	[[ZJPAlert shareAlert] showLodingWithTitle:title message:message withView:nil];
}
- (void)showLodingWithTitle:(NSString*)title withView:(UIView *)view{
	[[ZJPAlert shareAlert] showLodingWithTitle:title message:@"" withView:view];
}
- (void)showLodingWithTitle:(NSString*)title message:(NSString*)message withView:(UIView *)view{

	UIImage  *image = [UIImage imageNamed:@"niconiconi"];
	UIImageView *imageView = [YYAnimatedImageView new];
	imageView.image = image;
//	imageView.yy_imageURL = [NSURL URLWithString:@"http://github.com/ani.webp"];
//	YYImage *image = [YYImage imageNamed:name];
//YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] initWithImage:image];

//	UIImage  *image = [UIImage sd_animatedGIFNamed:@"h1"];
//	UIImageView *_activeView = [[UIImageView alloc]init];
//	_activeView.backgroundColor = [UIColor clearColor];
//	_activeView.image = image;
//	_activeView.frame = CGRectMake((view.width - 72) /2, (view.height - 72) / 2 - 40, 72, 72);
		//    [_activeView startAnimating];

	if (!view) {
		UIWindow *window = [[UIApplication sharedApplication] keyWindow];

		HUD = [[MBProgressHUD alloc] initWithView:window];
		HUD.customView = imageView;
		HUD.mode = MBProgressHUDModeCustomView;//MBProgressHUDModeCustomView 自定义图片
//		HUD.opacity = 0.0f;
		[window addSubview:HUD];
	}else{
		if (HUD) {
			[HUD hideAnimated:YES];
		}
		HUD = [[MBProgressHUD alloc] initWithView:view];
		HUD.customView = imageView;
		HUD.mode = MBProgressHUDModeIndeterminate;
		[view addSubview:HUD];
	}
	HUD.delegate = self;
	HUD.label.text = @"";
	HUD.detailsLabel.text = message;
	HUD.square = YES;
	[HUD showAnimated:YES];
}
- (void)hiddenHUD
{
	if (HUD) {
		[HUD hideAnimated:YES afterDelay:0.2];
	}
}

- (void)showHUD
{
	if (HUD) {
		[HUD showAnimated:YES];
	}
}

#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
		// Remove HUD from screen when the HUD was hidded
	
	[HUD removeFromSuperview];
//	[HUD release];
	HUD = nil;
}

@end
