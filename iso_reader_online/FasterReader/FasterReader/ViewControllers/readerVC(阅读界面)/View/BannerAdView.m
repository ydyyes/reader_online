//
//  BannerAdView.m
//  NightReader
//
//  Created by 张俊平 on 2019/5/21.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import "BannerAdView.h"

#import "GDTUnifiedBannerView.h"

#import <BUAdSDK/BUBannerAdView.h>
@interface BannerAdView () <GDTUnifiedBannerViewDelegate,BUBannerAdViewDelegate>

@property (nonatomic, strong) GDTUnifiedBannerView *GDTBannerView;
@property (nonatomic, weak) UIViewController *controller;
@property(nonatomic, strong) BUBannerAdView *BUBannerView;

@end
@implementation BannerAdView

- (void)showBannerAdViewWithType:(NSString*)type InController:(UIViewController*)controller{
	_controller = controller;
	if ([type isEqualToString:@"1"]) {
		[self showGDTBannerView];
	}else if ([type isEqualToString:@"2"]){
		[self showBUBannerView];
	}
}

- (void)closeBannerAdView {
    [_GDTBannerView removeFromSuperview];
    _GDTBannerView = nil;
    [_BUBannerView removeFromSuperview];
    _BUBannerView = nil;
}
#pragma mark - 展示广点通的广告
- (void)showGDTBannerView {
	[self addSubview: self.GDTBannerView];
	[self.GDTBannerView loadAdAndShow];
    [MobClick event:@"gdt_banner_adv_load"];
}
#pragma mark - 展示穿山甲的广告
- (void)showBUBannerView {
	[self addSubview: self.BUBannerView];
	[self.BUBannerView loadAdData];
    [MobClick event:@"ttad_banner_adv_load"];
}

#pragma mark - lazy
- (GDTUnifiedBannerView *)GDTBannerView {
	if (!_GDTBannerView) {
		CGRect rect = {CGPointZero, CGSizeMake([JPTool screenWidth], self.height)};
		_GDTBannerView = [[GDTUnifiedBannerView alloc]
							initWithFrame:rect appId:kGDTMobSDKAppId
							placementId:GDT_Banner_PlacementId
							viewController:_controller];
//		_bannerView.animated = YES;
//		_bannerView.autoSwitchInterval = 5;
		_GDTBannerView.delegate = self;
	}
	return _GDTBannerView;
}
-(BUBannerAdView *)BUBannerView {
	if (!_BUBannerView) {
		BUSize *size = [BUSize sizeBy:BUProposalSize_Banner600_90];
		_BUBannerView = [[BUBannerAdView alloc] initWithSlotID:BUBannerAdId size:size rootViewController:_controller interval:30];
		const CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);

			//		CGFloat bannerHeight = screenWidth * size.height / size.width;
		_BUBannerView.frame = CGRectMake(0, 0, screenWidth, self.height);
		_BUBannerView.delegate = self;
	}
	return _BUBannerView;
}

#pragma mark - GDTUnifiedBannerViewDelegate
/**
 *  请求广告条数据成功后调用
 *  当接收服务器返回的广告数据成功后调用该函数
 */
- (void)unifiedBannerViewDidLoad:(GDTUnifiedBannerView *)unifiedBannerView
{
	NSLog(@"unified banner did load");
    [self.BUBannerView removeFromSuperview];
    self.BUBannerView = nil;
    
    [MobClick event:@"gdt_banner_adv_load_success"];
}

/**
 *  请求广告条数据失败后调用
 *  当接收服务器返回的广告数据失败后调用该函数
 */

- (void)unifiedBannerViewFailedToLoad:(GDTUnifiedBannerView *)unifiedBannerView error:(NSError *)error
{
	NSLog(@"%s",__FUNCTION__);
	[self.GDTBannerView removeFromSuperview];
	self.GDTBannerView = nil;
    [MobClick event:@"gdt_banner_adv_load_fail"];
}

/**
 *  banner2.0曝光回调
 */
- (void)unifiedBannerViewWillExpose:(nonnull GDTUnifiedBannerView *)unifiedBannerView {
	NSLog(@"%s",__FUNCTION__);
    // 当前时间存入本地
    [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:LAST_BANNER_AD_SHOW_TIME_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [MobClick event:@"gdt_banner_adv_show"];
    
}

/**
 *  banner2.0点击回调
 */
- (void)unifiedBannerViewClicked:(GDTUnifiedBannerView *)unifiedBannerView
{
	NSLog(@"%s",__FUNCTION__);
    [MobClick event:@"gdt_banner_adv_click"];
}

/**
 *  应用进入后台时调用
 *  当点击应用下载或者广告调用系统程序打开，应用将被自动切换到后台
 */
- (void)unifiedBannerViewWillLeaveApplication:(GDTUnifiedBannerView *)unifiedBannerView
{
	NSLog(@"%s",__FUNCTION__);
}

/**
 *  全屏广告页已经被关闭
 */
- (void)unifiedBannerViewDidDismissFullScreenModal:(GDTUnifiedBannerView *)unifiedBannerView
{
	NSLog(@"%s",__FUNCTION__);
}

/**
 *  全屏广告页即将被关闭
 */
- (void)unifiedBannerViewWillDismissFullScreenModal:(GDTUnifiedBannerView *)unifiedBannerView
{
	NSLog(@"%s",__FUNCTION__);
}

/**
 *  banner2.0广告点击以后即将弹出全屏广告页
 */
- (void)unifiedBannerViewWillPresentFullScreenModal:(GDTUnifiedBannerView *)unifiedBannerView
{
	NSLog(@"%s",__FUNCTION__);
}

/**
 *  banner2.0广告点击以后弹出全屏广告页完毕
 */
- (void)unifiedBannerViewDidPresentFullScreenModal:(GDTUnifiedBannerView *)unifiedBannerView
{
	NSLog(@"%s",__FUNCTION__);
}

/**
 *  banner2.0被用户关闭时调用
 */
- (void)unifiedBannerViewWillClose:(nonnull GDTUnifiedBannerView *)unifiedBannerView {
	[self.GDTBannerView removeFromSuperview];
	self.GDTBannerView = nil;
    //存入时间
    [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:LAST_BANNER_USER_CLOSE_TIME_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
	NSLog(@"%s",__FUNCTION__);
}

#pragma mark -  BUBannerAdViewDelegate implementation
- (void)bannerAdViewDidLoad:(BUBannerAdView * _Nonnull)bannerAdView WithAdmodel:(BUNativeAd *_Nullable)admodel {
	NSLog(@"banner data load sucess");
    [self.GDTBannerView removeFromSuperview];
    self.GDTBannerView = nil;
    
    [MobClick event:@"ttad_banner_adv_load_success"];

}

- (void)bannerAdView:(BUBannerAdView *_Nonnull)bannerAdView didLoadFailWithError:(NSError *_Nullable)error {
    NSLog(@"banner data load faiule");
    [self.BUBannerView removeFromSuperview];
    self.BUBannerView = nil;
    
    [MobClick event:@"ttad_banner_adv_load_fail"];
    
}

- (void)bannerAdViewDidBecomVisible:(BUBannerAdView *_Nonnull)bannerAdView WithAdmodel:(BUNativeAd *_Nullable)admodel {
	NSLog(@"banner becomVisible");
    // 当前时间存入本地
    [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:LAST_BANNER_AD_SHOW_TIME_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [MobClick event:@"ttad_banner_adv_show"];
    
}

- (void)bannerAdViewDidClick:(BUBannerAdView *_Nonnull)bannerAdView WithAdmodel:(BUNativeAd *_Nullable)admodel {
	NSLog(@"banner AdViewDidClick");
    [MobClick event:@"ttad_banner_adv_load_click"];
}

- (void)bannerAdView:(BUBannerAdView *)bannerAdView dislikeWithReason:(NSArray<BUDislikeWords *> *)filterwords {
    
    [self.BUBannerView removeFromSuperview];
    self.BUBannerView = nil;
    //存入时间
    [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:LAST_BANNER_USER_CLOSE_TIME_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}


@end
