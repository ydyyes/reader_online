//
//  SureCanceAlert.h
//  ShareDoctorNew
//
//  Created by iOS on 2017/12/8.
//  Copyright © 2017年 iOS. All rights reserved.
//
/*
 使用方式 1 推荐使用 注意防止循环引用
 [[SureCanceAlert shareAlert] setTitleText:@"确定删除此消息？" withMaxHeight:100 withSureBtnClick:^(UIButton *sender) {
 NSLog(@"确定啦");
 } withCancelBtnClick:^(UIButton *sender) {
 NSLog(@"取消啦");
 }];
 使用方式 2
 [[SureCanceAlert shareAlert] setTitleText:@"确定删除此消息？" withMaxHeight:100];
 [[SureCanceAlert shareAlert] alertShow];
 [[SureCanceAlert shareAlert] setSureBtnClickBlock:^(UIButton *sender) {
 NSLog(@"确定啦");
 }];
 [[SureCanceAlert shareAlert] setCancelBtnClickBlock:^(UIButton *sender) {
 NSLog(@"取消啦");
 }];
 */

#import <UIKit/UIKit.h>

typedef void(^SureAlertBtnClickBlock)(UIButton *sender);
typedef void(^CancelAlertBtnClickBlock)(UIButton *sender);

typedef NS_ENUM(NSUInteger,AlertButtonTypeStyle) {
    AlertButtonTypeStyleDefault=0, // 默认确定取消按钮
    AlertButtonTypeStyleAlone, // 只有确定按钮
};

@interface SureCanceAlert : UIView

/**
 确定按钮点击回调
 */
@property (nonatomic, copy) SureAlertBtnClickBlock sureBtnClickBlock;

/**
 取消按钮点击回调
 */
@property (nonatomic, copy) CancelAlertBtnClickBlock cancelBtnClickBlock;

/**
  单例

 @return  self
 */
+ (instancetype)shareAlert;

/**
 设置标题和回到方法 推荐使用

 @param text 要显示的标题
 @param sureTitle 确定按钮文字
 @param aleryStyle 是否只有一个按钮
 @param maxHeight 最大显示的高度
 @param sureBtnClickBlock 确定按钮点击回调
 @param cancelBtnClickBlock 取消按钮点击回到
 */
- (void)setTitleText:(NSString *)text withSureBtnTitle:(NSString *)sureTitle withMaxHeight:(CGFloat)maxHeight withAlertStyle:(AlertButtonTypeStyle)aleryStyle withSureBtnClick:(SureAlertBtnClickBlock)sureBtnClickBlock withCancelBtnClick:(CancelAlertBtnClickBlock)cancelBtnClickBlock;

/**
 设置标题无回调

 @param text  要显示的标题
 @param maxHeight 最大显示的高度
 */
- (void)setTitleText:(NSString *)text withMaxHeight:(CGFloat)maxHeight;

/**
 显示
 */
- (void)alertShow;

/**
 隐藏
 */
- (void)alertHidden;

@end
