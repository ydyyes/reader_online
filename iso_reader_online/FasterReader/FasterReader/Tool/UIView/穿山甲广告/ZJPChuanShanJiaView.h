//
//  jpView.h
//  BUADDemo
//
//  Created by 张俊平 on 2019/5/9.
//  Copyright © 2019 Bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BUAdSDK/BUNativeAd.h>
#import <BUAdSDK/BUNativeAdRelatedView.h>


NS_ASSUME_NONNULL_BEGIN

@interface ZJPChuanShanJiaView : UIView

@property (nonatomic, strong, nullable) UIView *separatorLine;
@property (nonatomic, strong, nullable) UIImageView *iv1;
@property (nonatomic, strong, nullable) UILabel *adTitleLabel;
@property (nonatomic, strong, nullable) UILabel *adDescriptionLabel;
@property (nonatomic, strong) BUNativeAd *nativeAd;
@property (nonatomic, strong) UIButton *customBtn;
@property (nonatomic, strong) BUNativeAdRelatedView *nativeAdRelatedView;
//@property (nonatomic, strong) BUNativeAd *)model



+ (CGFloat)cellHeightWithModel:(BUNativeAd *_Nonnull)model width:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END
