//
//  ZJPAlert.h
//  NightReader
//
//  Created by 张俊平 on 2019/2/20.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZJPAlert : NSObject<MBProgressHUDDelegate>{
	MBProgressHUD *HUD;
}

+ (ZJPAlert *)shareAlert;

/** 页面进入第一次加载 */
- (void)showLodingWithView:(UIView *)view ;
- (void)showLoding;

- (void)showLodingWithTitle:(NSString*)title message:(NSString*)message withView:(UIView *)view;
- (void)showLodingWithTitle:(NSString*)title withView:(UIView *)view;
- (void)showLodingWithTitle:(NSString*)title message:(NSString*)message;
- (void)showLodingWithTitle:(NSString*)title;
- (void)showLodingWithTitle:(NSString*)title delay:(NSTimeInterval)time;

- (void)hiddenHUD;
- (void)showHUD;

/**
 提示语 带按钮

 @param message 提示语
 @param title 标题
 */
+ (void)alertWithMessage:(NSString *)message title:(NSString*)title;


/**
 提示语

 @param message 提示语
 @param time 提示时间
 */
+ (void)showAlertWithMessage:(NSString*)message time:(NSTimeInterval)time;


/**
 提示语 带按钮

 @param message 提示语
 */
+ (void)alertWithMessage:(NSString *)message;

+ (void)hideTabBar:(UITabBarController *) tabbarcontroller;

+ (void)showTabBar:(UITabBarController *) tabbarcontroller;

@end

NS_ASSUME_NONNULL_END
