//
//  UIImage+Tools.m
//  NightReader
//
//  Created by 张俊平 on 2019/2/28.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import "UIImage+Tools.h"

@implementation UIImage (Tools)

#pragma mark -- 生成一张图片
+ (UIImage *)imageWithColor:(UIColor *)color
{
	CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
	UIGraphicsBeginImageContext(rect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(context, [color CGColor]);
	CGContextFillRect(context, rect);
	UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return theImage;
}
#pragma mark -- 生成带有透明度的图片【滚动情况下】
- (UIImage *)imageByScrollAlpha:(CGFloat)alpha
{
	UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGRect area = CGRectMake(0.0f, 0.0f, self.size.width, self.size.height);
	CGContextScaleCTM(ctx, 1, -1);
	CGContextTranslateCTM(ctx, 0, -area.size.height);
	CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
	CGContextSetAlpha(ctx, alpha);
	CGContextDrawImage(ctx, area, self.CGImage);
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}
#pragma mark -- 生成纯色图片
+ (UIImage *)js_createImageWithColor:(UIColor *)color withSize:(CGSize)imageSize
{
	CGRect rect = CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height);
	UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(context, color.CGColor);
	CGContextFillRect(context, rect);
	UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return resultImage;
}
#pragma mark -- 生成圆角图片
+ (UIImage *)js_imageWithOriginalImage:(UIImage *)originalImage
{
	CGRect rect = CGRectMake(0, 0, originalImage.size.width, originalImage.size.height);
	UIGraphicsBeginImageContextWithOptions(originalImage.size, NO, 0.0);
	CGFloat cornerRadius = MIN(originalImage.size.width, originalImage.size.height) * 0.5;
	[[UIBezierPath bezierPathWithRoundedRect:rect
										 cornerRadius:cornerRadius] addClip];
	[originalImage drawInRect:rect];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return image;
}
#pragma mark -- 生成圆角任意圆角图片
+ (UIImage *)js_imageWithOriginalImage:(UIImage *)originalImage cornerRadius:(CGFloat)cornerRadius
{
	CGRect rect = CGRectMake(0, 0, originalImage.size.width, originalImage.size.height);
	UIGraphicsBeginImageContextWithOptions(originalImage.size, NO, 0.0);
	[[UIBezierPath bezierPathWithRoundedRect:rect
										 cornerRadius:cornerRadius] addClip];
	[originalImage drawInRect:rect];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return image;
}
#pragma mark -- 生成纯色圆角图片
+ (UIImage *)js_createRoundedImageWithColor:(UIColor *)color withSize:(CGSize)imageSize
{
	UIImage *originalImage = [self js_createImageWithColor:color withSize:imageSize];
	return [self js_imageWithOriginalImage:originalImage];
}
#pragma mark -- 生成纯色任意圆角图片
+ (UIImage *)js_createRoundedImageWithColor:(UIColor *)color withSize:(CGSize)imageSize cornerRadius:(CGFloat)cornerRadius
{
	UIImage *originalImage = [self js_createImageWithColor:color withSize:imageSize];
	return [self js_imageWithOriginalImage:originalImage cornerRadius:cornerRadius];
}
#pragma mark -- 生成带圆环的圆角图片
+ (UIImage *)js_imageWithOriginalImage:(UIImage *)originalImage withBorderColor:(UIColor *)borderColor withBorderWidth:(CGFloat)borderWidth
{
	CGRect rect = CGRectMake(0, 0, originalImage.size.width, originalImage.size.height);
	UIGraphicsBeginImageContextWithOptions(originalImage.size, NO, 0.0);
	CGFloat cornerRadius = MIN(originalImage.size.width, originalImage.size.height) * 0.5;
	[[UIBezierPath bezierPathWithRoundedRect:rect
										 cornerRadius:cornerRadius] addClip];
	[originalImage drawInRect:rect];

	CGPoint center = CGPointMake(originalImage.size.width * 0.5, originalImage.size.height * 0.5);
	UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:center radius:cornerRadius - borderWidth*0.5 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
	circlePath.lineWidth = borderWidth;
	[borderColor setStroke];
	[circlePath stroke];

	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}
#pragma mark image scale utility
+ (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage
{
	if (sourceImage.size.width < [JPTool screenWidth]) return sourceImage;
	CGFloat btWidth = 0.0f;
	CGFloat btHeight = 0.0f;
	if (sourceImage.size.width > sourceImage.size.height) {
		btHeight = [JPTool screenWidth];
		btWidth = sourceImage.size.width * ([JPTool screenWidth] / sourceImage.size.height);
	} else {
		btWidth = [JPTool screenWidth];
		btHeight = sourceImage.size.height * ([JPTool screenWidth] / sourceImage.size.width);
	}
	CGSize targetSize = CGSizeMake(btWidth, btHeight);
	return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

+ (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize
{
	UIImage *newImage = nil;
	CGSize imageSize = sourceImage.size;
	CGFloat width = imageSize.width;
	CGFloat height = imageSize.height;
	CGFloat targetWidth = targetSize.width;
	CGFloat targetHeight = targetSize.height;
	CGFloat scaleFactor = 0.0;
	CGFloat scaledWidth = targetWidth;
	CGFloat scaledHeight = targetHeight;
	CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
	if (CGSizeEqualToSize(imageSize, targetSize) == NO)
		 {
		CGFloat widthFactor = targetWidth / width;
		CGFloat heightFactor = targetHeight / height;

		if (widthFactor > heightFactor)
			scaleFactor = widthFactor; // scale to fit height
		else
			scaleFactor = heightFactor; // scale to fit width
		scaledWidth  = width * scaleFactor;
		scaledHeight = height * scaleFactor;

			// center the image
		if (widthFactor > heightFactor)
			 {
			thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
			 }
		else
			if (widthFactor < heightFactor)
				 {
				thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
				 }
		 }
	UIGraphicsBeginImageContext(targetSize); // this will crop
	CGRect thumbnailRect = CGRectZero;
	thumbnailRect.origin = thumbnailPoint;
	thumbnailRect.size.width  = scaledWidth;
	thumbnailRect.size.height = scaledHeight;

	[sourceImage drawInRect:thumbnailRect];

	newImage = UIGraphicsGetImageFromCurrentImageContext();
	if(newImage == nil) NSLog(@"could not scale image");

		//pop the context to get back to the default
	UIGraphicsEndImageContext();
	return newImage;
}

#pragma  mark 绘制虚线
+ (UIImage *)drawLineByImageView:(UIImageView *)imageView{
	UIGraphicsBeginImageContext(imageView.frame.size); //开始画线 划线的frame
	[imageView.image drawInRect:CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];
		//设置线条终点形状
	CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);

	CGFloat lengths[] = {5,5};
	CGContextRef line = UIGraphicsGetCurrentContext();
		// 设置颜色
	CGContextSetStrokeColorWithColor(line, [UIColor colorWithHexString:@"cccccc"].CGColor);
	CGContextSetLineDash(line, 0, lengths, 2); //画虚线
	CGContextMoveToPoint(line, 0.0, 0.0); //开始画线
	CGContextAddLineToPoint(line, [JPTool screenWidth] - 10, 0.0);

	CGContextStrokePath(line);
		// UIGraphicsGetImageFromCurrentImageContext()返回的就是image
	return UIGraphicsGetImageFromCurrentImageContext();
}



#pragma mark -	//按照一定大小缩放图片
-(UIImage *)scaleImageToSize:(CGSize)size{
	UIGraphicsBeginImageContext(size);//设定大小
	[self drawInRect:CGRectMake(0, 0, size.width, size.height)];
	UIImage *scaleImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return scaleImage;
}

#pragma mark -	//裁剪图片
-(UIImage *)clipImageWithClipRect:(CGRect)clipRect{

	CGImageRef clipImageRef = CGImageCreateWithImageInRect(self.CGImage, clipRect);
	UIGraphicsBeginImageContext(clipRect.size);

	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextDrawImage(context, clipRect, clipImageRef);
	UIImage *clipImage = [UIImage imageWithCGImage :clipImageRef];

	UIGraphicsEndImageContext();

	return clipImage;
}

#pragma mark -	拼接
+(UIImage *)combineWithImages:(NSArray *)images orientation:(YFImageCombineType)orientation{
	NSMutableArray *sizeArray = [[NSMutableArray alloc] init];
	CGFloat maxHeight = 0, maxWidth = 0;
	for (id image in images) {
			//        if([image isKindOfClass:[UIImage class]]){
		CGSize size = ((UIImage *)image).size;
		if(orientation == YFImageCombineHorizental){//横向
			maxWidth += size.width;
			maxHeight = (size.height > maxHeight) ? size.height : maxHeight;
		}
		else{
			maxHeight += size.height;
			maxWidth = (size.width > maxWidth) ? size.width : maxWidth;
		}
		[sizeArray addObject:[NSValue valueWithCGSize:size]];
			//        }
	}

	CGFloat lastLength = 0;//记录上一次的最右或者最下边值
	UIGraphicsBeginImageContext(CGSizeMake(maxWidth, maxHeight));
	for (int i = 0; i < sizeArray.count; i++){
		CGSize size = [[sizeArray objectAtIndex:i] CGSizeValue];
		CGRect currentRect;
		if(orientation == YFImageCombineHorizental){//横向
			currentRect = CGRectMake(lastLength, (maxHeight - size.height) / 2.0, size.width, size.height);
			[[images objectAtIndex:i] drawInRect:currentRect];
			lastLength = CGRectGetMaxX(currentRect);
		}
		else{
			currentRect = CGRectMake((maxWidth - size.width) / 2.0, lastLength, size.width, size.height);
			[[images objectAtIndex:i] drawInRect:currentRect];
			lastLength = CGRectGetMaxY(currentRect);
		}
	}
	UIImage* combinedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return combinedImage;
}

#pragma mark -	局部收缩
- (UIImage *)shrinkImageWithCapInsets:(UIEdgeInsets)capInsets actualSize:(CGSize)actualSize{//默认拉伸好了 暂时不处理平铺的情况
//一块区域  分为三块  两边不变 中间收缩
	UIImage *newAllImage = self;
		//如果横向变短了  处理横向
	if(actualSize.width < self.size.width){
		NSMutableArray *imageArray = [[NSMutableArray alloc] init];
			//左边:
		if(capInsets.left > 0){
			UIImage *leftImage = [newAllImage clipImageWithClipRect:CGRectMake(0, 0, capInsets.left, newAllImage.size.height)];
			[imageArray addObject:leftImage];
		}
			//中间: 缩短
		CGFloat shrinkWidth = actualSize.width - capInsets.left - capInsets.right;//需要缩到的距离
		if(shrinkWidth > 0){
			UIImage *centerImage = [newAllImage clipImageWithClipRect:CGRectMake(capInsets.left, 0, newAllImage.size.width - capInsets.left - capInsets.right, newAllImage.size.height)];
			centerImage = [centerImage scaleImageToSize:CGSizeMake(shrinkWidth, newAllImage.size.height)];
			[imageArray addObject:centerImage];
		}
			//右边:
		if(capInsets.right > 0){
			UIImage *rightImage = [newAllImage clipImageWithClipRect:CGRectMake(newAllImage.size.width - capInsets.right, 0, capInsets.right, newAllImage.size.height)];
			[imageArray addObject:rightImage];
		}

			//拼接
		if(imageArray.count > 0){
			newAllImage = [UIImage combineWithImages:imageArray orientation:YFImageCombineHorizental];
			if(actualSize.height >= self.size.height){
				return newAllImage;
			}//否则继续纵向处理
		}
	}

		//如果纵向变短了 处理纵向(在横向处理完的基础上)
	if(actualSize.height < self.size.height){
		NSMutableArray *imageArray = [[NSMutableArray alloc] init];
			//上边:
		if(capInsets.top > 0){
			UIImage *topImage = [newAllImage clipImageWithClipRect:CGRectMake(0, 0, self.size.width,capInsets.top)];
			[imageArray addObject:topImage];
		}
			//中间: 缩短
		CGFloat shrinkHeight = actualSize.height - capInsets.top - capInsets.bottom;//需要缩到的距离
		if(shrinkHeight > 0){
			UIImage *centerImage = [newAllImage clipImageWithClipRect:CGRectMake(0, capInsets.top, newAllImage.size.width,newAllImage.size.height - capInsets.bottom - capInsets.top)];
			centerImage = [centerImage scaleImageToSize:CGSizeMake(newAllImage.size.width,shrinkHeight)];
			[imageArray addObject:centerImage];
		}
			//下边:
		if(capInsets.bottom > 0){
			UIImage *bottomImage = [newAllImage clipImageWithClipRect:CGRectMake(0, newAllImage.size.height - capInsets.bottom, newAllImage.size.width,capInsets.bottom)];
			[imageArray addObject:bottomImage];
		}

			//拼接
		if(imageArray.count > 0){
			newAllImage = [UIImage combineWithImages:imageArray orientation:YFImageCombineVertical];
			return newAllImage;
		}
	}

	return nil;
}
@end
