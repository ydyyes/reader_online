//
//  BannerAdView.h
//  NightReader
//
//  Created by 张俊平 on 2019/5/21.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BannerAdView : UIView

/** 注释 */
- (void)showBannerAdViewWithType:(NSString*)type InController:(UIViewController*)controller;

- (void)closeBannerAdView;

@end

NS_ASSUME_NONNULL_END
