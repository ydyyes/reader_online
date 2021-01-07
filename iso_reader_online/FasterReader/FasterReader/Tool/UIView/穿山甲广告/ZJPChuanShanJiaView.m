//
//  jpView.m
//  BUADDemo
//
//  Created by 张俊平 on 2019/5/9.
//  Copyright © 2019 Bytedance. All rights reserved.
//

#import "ZJPChuanShanJiaView.h"
#import "BUDFeedStyleHelper.h"
#import "UIImageView+AFNetworking.h"

#define BUD_RGB(a,b,c) [UIColor colorWithRed:(a/255.0) green:(b/255.0) blue:(c/255.0) alpha:1]
static CGFloat const margin = 15;
static CGSize const logoSize = {15, 15};
static UIEdgeInsets const padding = {10, 15, 10, 15};

@implementation ZJPChuanShanJiaView


-(instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self initFara];
	}
	return self;
}

- (void)initFara {

	CGFloat width = CGRectGetWidth(self.frame);
	CGFloat contentWidth = (width - 2 * margin);
	CGFloat y = padding.top;

	NSAttributedString *attributedText = [BUDFeedStyleHelper titleAttributeText:@""];
	CGSize titleSize = [attributedText boundingRectWithSize:CGSizeMake(contentWidth, 0) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:0].size;
	self.adTitleLabel = [[UILabel alloc]init];
	self.adTitleLabel.frame = CGRectMake(padding.left, y , contentWidth, titleSize.height);
	self.adTitleLabel.attributedText = attributedText;
	[self addSubview:self.adTitleLabel];

	y += titleSize.height;
	y += 5;

	const CGFloat imageHeight = 100;//contentWidth * (image.height / image.width);
	self.iv1 = [[UIImageView alloc]init];
	self.iv1.frame = CGRectMake(padding.left, y, contentWidth, imageHeight);

	self.nativeAdRelatedView = [[BUNativeAdRelatedView alloc]init];
	self.nativeAdRelatedView.logoImageView.frame = CGRectMake(contentWidth - logoSize.width, imageHeight - logoSize.height, logoSize.width, logoSize.height);
	[self addSubview:self.iv1];
//	self.iv1.backgroundColor = [UIColor grayColor];

	y += imageHeight;
	y += 10;

	CGFloat originInfoX = padding.left;
	self.nativeAdRelatedView.adLabel.frame = CGRectMake(originInfoX, y + 3, 26, 14);
	originInfoX += 24;
	originInfoX += 10;

	CGFloat dislikeX = width - 24 - padding.right;
	self.nativeAdRelatedView.dislikeButton.frame = CGRectMake(dislikeX, y, 24, 20);
	[self.iv1 addSubview:self.nativeAdRelatedView.logoImageView];
	[self addSubview:self.nativeAdRelatedView.dislikeButton];
	[self addSubview:self.nativeAdRelatedView.adLabel];


	CGFloat maxInfoWidth = width - 2 * margin - 24 - 24 - 10 - 100;
	self.adDescriptionLabel = [[UILabel alloc]init];
	self.adDescriptionLabel.frame = CGRectMake(originInfoX , y , maxInfoWidth, 20);
	self.adDescriptionLabel.attributedText = [BUDFeedStyleHelper subtitleAttributeText:@""];
	[self addSubview:self.adDescriptionLabel];

	self.customBtn.frame = CGRectMake(0, 0, 0, 20);
	[self addSubview:self.customBtn];
}
- (void)setNativeAd:(BUNativeAd *)nativeAd  {

	CGFloat width = CGRectGetWidth(self.frame);
	CGFloat contentWidth = (width - 2 * margin);
	CGFloat y = padding.top;

	NSAttributedString *attributedText = [BUDFeedStyleHelper titleAttributeText:nativeAd.data.AdTitle];
	CGSize titleSize = [attributedText boundingRectWithSize:CGSizeMake(contentWidth, 0) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:0].size;
	self.adTitleLabel.frame = CGRectMake(padding.left, y , contentWidth, titleSize.height);
	self.adTitleLabel.attributedText = attributedText;
//	self.adTitleLabel.backgroundColor = [UIColor orangeColor];

	y += titleSize.height;
	y += 5;

	BUImage *image = nativeAd.data.imageAry.firstObject;
	const CGFloat imageHeight = contentWidth * (image.height / image.width);
	self.iv1.frame = CGRectMake(padding.left, y, contentWidth, imageHeight);
	[self.iv1 setImageWithURL:[NSURL URLWithString:image.imageURL] placeholderImage:nil];
	self.nativeAdRelatedView.logoImageView.frame = CGRectMake(contentWidth - logoSize.width, imageHeight - logoSize.height, logoSize.width, logoSize.height);

	y += imageHeight;
	y += 5;

	CGFloat originInfoX = padding.left;
	self.nativeAdRelatedView.adLabel.frame = CGRectMake(originInfoX, y + 3, 26, 14);
	originInfoX += 24;
	originInfoX += 10;

	CGFloat dislikeX = width - 24 - padding.right;
	self.nativeAdRelatedView.dislikeButton.frame = CGRectMake(dislikeX, y, 24, 20);
	[self.nativeAdRelatedView refreshData:nativeAd];

	CGFloat maxInfoWidth = width - 2 * margin - 24 - 24 - 10 - 100;
	self.adDescriptionLabel.frame = CGRectMake(originInfoX , y , maxInfoWidth, 20);
	self.adDescriptionLabel.attributedText = [BUDFeedStyleHelper subtitleAttributeText:nativeAd.data.AdDescription];

	CGFloat customBtnWidth = 80;
	self.customBtn.frame = CGRectMake(dislikeX - customBtnWidth-10, y-5, customBtnWidth, 25);


}
//+ (CGFloat)cellHeightWithModel:(BUNativeAd *_Nonnull)model width:(CGFloat)width {
//	CGFloat contentWidth = (width - 2 * margin);
//	NSAttributedString *attributedText = [BUDFeedStyleHelper titleAttributeText:model.data.AdTitle];
//	CGSize titleSize = [attributedText boundingRectWithSize:CGSizeMake(contentWidth, 0) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:0].size;
//
//	BUImage *image = model.data.imageAry.firstObject;
//	const CGFloat imageHeight = contentWidth * (image.height / image.width);
//	return padding.top + titleSize.height + 5+ imageHeight + 10 + 20 + padding.bottom;
//}
+ (CGFloat)cellHeightWithModel:(BUNativeAd *_Nonnull)model width:(CGFloat)width {
	CGFloat height = padding.top;
	BUImage *image = model.data.imageAry.firstObject;
	const CGFloat contentWidth = (width - 2 * margin);
	const CGFloat imageHeight = contentWidth * (image.height / image.width);
	height += 10 + imageHeight;
	height += padding.bottom;
	NSAttributedString *attributedText = [BUDFeedStyleHelper titleAttributeText:model.data.AdTitle];
	CGSize titleSize = [attributedText boundingRectWithSize:CGSizeMake(contentWidth, 0) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:0].size;
	height += 15 + titleSize.height;
	if (model.data.interactionType == BUInteractionTypeDownload) {
		height += 25;
	}
	return height;
}
- (UIButton *)customBtn {
	if (!_customBtn) {
		_customBtn = [[UIButton alloc] init];
		[_customBtn setTitle:@"点击下载" forState:UIControlStateNormal];
		[_customBtn setTitleColor:BUD_RGB(0x47, 0x8f, 0xd2) forState:UIControlStateNormal];
		_customBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
//		_customBtn.backgroundColor = [UIColor magentaColor];
	}
	return _customBtn;
}



@end
