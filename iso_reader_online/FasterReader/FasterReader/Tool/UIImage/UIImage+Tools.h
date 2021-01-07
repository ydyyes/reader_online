//
//  UIImage+Tools.h
//  NightReader
//
//  Created by 张俊平 on 2019/2/28.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, YFImageCombineType) {
	YFImageCombineHorizental,
	YFImageCombineVertical
};


@interface UIImage (Tools)

/**
 生成一张图片

 @param color 颜色值
 @return 图片
 */
+ (UIImage *)imageWithColor:(UIColor *)color;
/**
 设置图片的透明度

 @param alpha 透明度
 @return 图片
 */
- (UIImage *)imageByScrollAlpha:(CGFloat)alpha;

/**
 *  创建纯色图片
 *
 *  @param color     生成纯色图片的颜色
 *  @param imageSize 需要创建纯色图片的尺寸
 *
 *  @return 纯色图片
 */
+ (UIImage *)js_createImageWithColor:(UIColor *)color withSize:(CGSize)imageSize;
/**
 *  创建圆角图片
 *
 *  @param originalImage 原始图片
 *
 *  @return 带圆角的图片
 */
+ (UIImage *)js_imageWithOriginalImage:(UIImage *)originalImage;
/**
 *  创建圆角纯色图片
 *
 *  @param color     设置圆角纯色图片的颜色
 *  @param imageSize 设置元角纯色图片的尺寸
 *
 *  @return 圆角纯色图片
 */
+ (UIImage *)js_createRoundedImageWithColor:(UIColor *)color withSize:(CGSize)imageSize;
/**
 *  生成带圆环的圆角图片
 *
 *  @param originalImage 原始图片
 *  @param borderColor   圆环颜色
 *  @param borderWidth   圆环宽度
 *
 *  @return 带圆环的圆角图片
 */
+ (UIImage *)js_imageWithOriginalImage:(UIImage *)originalImage withBorderColor:(UIColor *)borderColor withBorderWidth:(CGFloat)borderWidth;

/**
 创建任意圆角纯色图片

 @param color 生成图片颜色
 @param imageSize 生成图片大小
 @param cornerRadius 圆角大小
 @return 生成的图片
 */
+ (UIImage *)js_createRoundedImageWithColor:(UIColor *)color withSize:(CGSize)imageSize cornerRadius:(CGFloat)cornerRadius;


/**
 压缩图片

 @param sourceImage 原始图片
 @return 压缩后的图片
 */
+ (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage;


/**
 绘制虚线
 @param imageView 需要加载虚线的 imageView
 */
+ (UIImage *)drawLineByImageView:(UIImageView *)imageView;

#pragma mark - 缩放图片
///缩放图片
-(UIImage *)scaleImageToSize:(CGSize)size;

#pragma mark - 裁剪图片
///裁剪图片
-(UIImage *)clipImageWithClipRect:(CGRect)clipRect;

#pragma mark - 拼接图片
///拼接图片
+(UIImage *)combineWithImages:(NSArray *)images orientation:(YFImageCombineType)orientation;

#pragma mark - 局部收缩
///局部收缩
- (UIImage *)shrinkImageWithCapInsets:(UIEdgeInsets)capInsets actualSize:(CGSize)actualSize;



@end

NS_ASSUME_NONNULL_END
