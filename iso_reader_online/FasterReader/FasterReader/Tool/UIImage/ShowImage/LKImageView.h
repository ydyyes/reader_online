//
//  LKImageView.h
//  
//
//  Created by luke on 10-11-12.
//  Copyright 2010 pica.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LKZoomableView;

typedef void(^LKImageViewImagePressBlock)(UIImageView *imageV);
@interface LKImageView : UIScrollView <UIScrollViewDelegate>
{
	NSString *info;
@private
	LKZoomableView *_imgContainer;
	UIImageView *_imgView;
	UIView *_infoBox;
	UILabel *_infoLabel;
}
/** 图片长按手势回调 */
@property (nonatomic, copy) LKImageViewImagePressBlock lkImageViewImagePressBlock;

//- (id)initWithImage:(UIImage *)pImage andInfo:(NSString *)pInfo;
- (id)initWithFrame:(CGRect)frame andInfo:(NSString *)pInfo;
- (void)setupImgViewWithImage:(UIImage *)theImage;
- (void)hideInfoView:(BOOL)hidden;

- (void)killScrollViewZoom;

@end
