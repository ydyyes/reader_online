//
//  ADContentViewController.m
//  reader
//
//  Created by beequick on 2017/8/4.
//  Copyright © 2017年 beequick. All rights reserved.
//

#import "ADContentViewController.h"
#import "ADDisplayView.h"
#import "ADSherfCache.h"
#import "YYModel.h"
#import "MSYReaderSetting.h"
#import "ZJPChuanShanJiaView.h"

#import "GDTNativeExpressAd.h"
#import "GDTNativeExpressAdView.h"
#import <BUAdSDK/BUAdSDK.h>
#import <Masonry/Masonry.h>

#import "FasterReader-Swift.h"

static CGFloat const titleFontSize = 12;

/// 状态栏高度
#define KStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
#define KTabBarHeight (KStatusBarHeight>20?83:49)

#define KNavBarHeight (KStatusBarHeight>20?88:64)
/// 导航栏+状态栏的高度
#define KTopHeight (KStatusBarHeight + KNavBarHeight)
/// webView 在iPhonex 底部有空隙 加上34 底部就平齐了
#define KwebViewAddHeight (KStatusBarHeight>20?34:0)

#define iPhoneXN (([[UIApplication sharedApplication] statusBarFrame].size.height == 44.0f) ? (YES):(NO))

#define TabbarHeight ([[UIApplication sharedApplication] statusBarFrame].size.height>20?83:49) // 适配iPhone x 底部高度
#define Is_Iphone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define Is_Iphone_X (Is_Iphone && [JPTool screenHeight] >= 812.0)
#define NaviHeight (Is_Iphone_X?88:64)

#define BottomHeight (Is_Iphone_X?34:0)

@interface ADContentViewController()<GDTNativeExpressAdDelegete,BUNativeAdsManagerDelegate,BUNativeAdDelegate,BURewardedVideoAdDelegate>



@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chapterTitleLableToTop;
@property (weak, nonatomic) IBOutlet UILabel *chapterTitleLable;
@property (weak, nonatomic) IBOutlet UILabel *pageNumberLable;

@property (nonatomic, strong) UIView *tapMenuView;

@property (nonatomic, strong) ADDisplayView *disPlayView;

@property (nonatomic, strong) UIView *adContentView;
@property (nonatomic, assign) CGFloat adLeftOrRight;

@property (nonatomic, assign) CGFloat adViewWidth;
@property (nonatomic, assign) CGFloat adViewHeight;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) GDTNativeExpressAd *guangDianTongNativeAd;

@property (nonatomic, strong) BUNativeAdsManager *adManager;
@property (nonatomic, strong) BURewardedVideoAd *rewardedVideoAd;
@property (nonatomic, strong) ZJPChuanShanJiaView *jpView;


@end

@implementation ADContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [MSYReaderSetting shareInstance].getReaderBackgroundColor;

    if ([JPTool screenHeight] >= 812.0) {
        self.chapterTitleLableToTop.constant = 44;
    }else{
        self.chapterTitleLableToTop.constant = 20;
    }

    //显示view
    CGFloat originY = self.chapterTitleLableToTop.constant + 13 + 5;
    self.disPlayView = [[ADDisplayView alloc] initWithFrame: CGRectMake(kYReaderLeftSpace, originY, [JPTool screenWidth] - kYReaderLeftSpace - kYReaderRightSpace, [JPTool screenHeight] - originY - kReaderBannerAdHeight)];
    self.disPlayView.backgroundColor = [UIColor clearColor];
    [self.view addSubview: self.disPlayView];
    
    //点击弹出设置阅读目录
    [self addTapMenuView];
    
    self.adLeftOrRight = 5 * [JPTool WidthScale];
    self.adViewWidth = [JPTool screenWidth] - self.adLeftOrRight * 2;
    self.adViewHeight = self.adViewWidth * 0.85;
  
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[MSYReaderSetting shareInstance].setting addObserver:self forKeyPath:@"fontSize" options:NSKeyValueObservingOptionNew context:nil];
    [[MSYReaderSetting shareInstance].setting addObserver:self forKeyPath:@"lineSpace" options:NSKeyValueObservingOptionNew context:nil];
    [[MSYReaderSetting shareInstance].setting addObserver:self forKeyPath:@"fontName" options:NSKeyValueObservingOptionNew context:nil];
    [[MSYReaderSetting shareInstance].setting addObserver:self forKeyPath:@"backGroundColor" options:NSKeyValueObservingOptionNew context:nil];
    [[MSYReaderSetting shareInstance].setting addObserver:self forKeyPath:@"unsimplified" options:NSKeyValueObservingOptionNew context:nil];
    [[MSYReaderSetting shareInstance].setting addObserver:self forKeyPath:@"dayModel" options:NSKeyValueObservingOptionNew context:nil];
    
    [self contviewClean];
    
    [self reloadData];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[MSYReaderSetting shareInstance].setting removeObserver:self forKeyPath:@"fontSize"];
    [[MSYReaderSetting shareInstance].setting removeObserver:self forKeyPath:@"lineSpace"];
    [[MSYReaderSetting shareInstance].setting removeObserver:self forKeyPath:@"fontName"];
    [[MSYReaderSetting shareInstance].setting removeObserver:self forKeyPath:@"backGroundColor"];
    [[MSYReaderSetting shareInstance].setting removeObserver:self forKeyPath:@"unsimplified"];
    [[MSYReaderSetting shareInstance].setting removeObserver:self forKeyPath:@"dayModel"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"backGroundColor"])
    {
        NSString *backGroundColor = [MSYReaderSetting shareInstance].setting.backGroundColor;
        self.view.backgroundColor = [UIColor colorWithHexString:backGroundColor];
    }
    else if ([keyPath isEqualToString:@"dayModel"])
    {
        if ([MSYReaderSetting shareInstance].setting.dayModel)
        {
            //如果是日间模式的话
            NSString *backGroundColor = [MSYReaderSetting shareInstance].setting.backGroundColor;
            self.view.backgroundColor = [UIColor colorWithHexString:backGroundColor];
        }else
        {
            //如果是夜间模式的话
            self.view.backgroundColor = [MSYReaderSetting shareInstance].setting.nightModeBackGroundColor;
        }
    }
    
    [self reloadData];
}
- (void)contviewClean{
    _disPlayView.content = nil;
}
- (void)reloadData{

    if (!self.model) {  return;  }

    self.chapterTitleLable.font = [UIFont fontWithName:[MSYReaderSetting shareInstance].setting.fontName size:titleFontSize];
    self.pageNumberLable.font = [UIFont fontWithName:[MSYReaderSetting shareInstance].setting.fontName size:titleFontSize];
    
    //章节标题
    NSString *title = self.model.title ? self.model.title : @"";
    self.chapterTitleLable.text = title;
    
    //MARK: 计算章节页数
    [self.model updateContentPaging];
    
    if (self.pageIndex >= self.model.pageCount) {
        self.pageIndex = self.model.pageCount - 1;
    }
    
    //MARK: 获取小说内容
    NSString *contentString = [self.model getStringWith: self.pageIndex];
    self.disPlayView.content = contentString;
    
    //MARK: 展示页码
    if (!contentString || [contentString isEqualToString:@""]) {
        self.pageNumberLable.hidden = YES;
    }else{
        //MARK:保存阅读历史chaptercontent
        NSString *str = [NSString stringWithFormat:@"第%ld/%ld页", (long)(self.pageIndex + 1), (long)_model.pageArray.count];
        [[MSYBrowseHistoryCache share] updateReadHistoryWithBookId:self.model.bookId chapterIndex:self.model.chapterNum pageIndex: self.pageIndex];
        self.pageNumberLable.text = str;
        self.pageNumberLable.hidden = NO;
    }
    
    // 展示广告
    [self showChapterEndAd: contentString];
}

#pragma mark - 展示广告
- (void)showChapterEndAd:(NSString*)string {
    
    //30分钟免广告
    if ([JPTool isThirtyMinuteMianAd]) {
        
        [self.adContentView removeAllSubviews];
        [self.adContentView removeFromSuperview];
        self.haveEnoughSpaceToShowAd = NO;
        return;
    }
    
    if (self.adViewHeight < 50) {  return;  }

    CGSize size = CGSizeMake(self.disPlayView.width, self.disPlayView.height);
    CGFloat textHeight = [ADChapterContentModel getTextHeight: string displyViewSize: size];
    //35 = 30(激励广告按钮的g高度) + 5(底部间距)
    CGFloat originY = self.chapterTitleLableToTop.constant + 13 + 5;
    CGFloat allViewHeight = originY + textHeight + 35 + self.adViewHeight + kReaderBannerAdHeight;
    //lineSpace是最后一行文本的行间距
    CGFloat lineSpace = [MSYReaderSetting shareInstance].setting.lineSpace;
    
//    NSLog(@"screenHeight:%f",[JPTool screenHeight]);
//    NSLog(@"originY:%f",originY);
//    NSLog(@"text内容:%@",string);
//    NSLog(@"textHeight:%f",textHeight);
//    NSLog(@"self.adViewHeight:%f",self.adViewHeight);
//    NSLog(@"kReaderBannerAdHeight:%f",kReaderBannerAdHeight);
//    NSLog(@"lineSpace:%f",lineSpace);
//
//    NSLog(@"cha:%f",[JPTool screenHeight] - allViewHeight - lineSpace);
    
    //应该是判断章节末尾是否有足够的空间,展示章节末尾广告,
    if (textHeight > 0 && ([JPTool screenHeight] - allViewHeight) > lineSpace )
    {
        [self addADContentView];
        self.haveEnoughSpaceToShowAd = YES;
    }else{
        self.haveEnoughSpaceToShowAd = NO;
        [self.adContentView removeAllSubviews];
        [self.adContentView removeFromSuperview];
    }
}

- (void)addADContentView {
    
    if (![ZJPNetWork netWorkAvailable]) { return; }
    if (self.adContentView) { return; }
    
    CGFloat contentViewHeight = self.adViewHeight + 35;
    CGFloat y = [JPTool screenHeight] - kReaderBannerAdHeight - contentViewHeight;
    self.adContentView = [[UIView alloc] initWithFrame:CGRectMake(0, y, [JPTool screenWidth], contentViewHeight)];
//    self.adContentView.backgroundColor = [UIColor greenColor];
    self.adContentView.backgroundColor = [UIColor clearColor];
    [self.view addSubview: self.adContentView];
    
    //激励视频
    if ([JPTool isShowRewardAd]) {
        [self loadChuanShanJiaRewardAd];
    }
    
    NSString *showAd = [JPTool showChapterAD];
    if ([showAd isEqualToString:@"1"])
    {
        [self loadGuangDianTongNativeAd];
    }
    else if ([showAd isEqualToString:@"2"])
    {
        [self loadChuanShanJiaNativeAd];
    }
}


- (void)loadChuanShanJiaRewardAd {
    
    UIButton *rewardButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [self.adContentView addSubview: rewardButton];

    [rewardButton setTitle: @"  观看视频免30分钟广告  " forState: UIControlStateNormal];
    rewardButton.backgroundColor = RGB_COLOR(38, 125, 244);
    rewardButton.titleLabel.font = [UIFont systemFontOfSize: 14];
    rewardButton.layer.cornerRadius = 8;
    [rewardButton sizeToFit];
    [rewardButton mas_makeConstraints:^(MASConstraintMaker *maker) {
        maker.top.centerX.equalTo(self.adContentView);
        maker.height.greaterThanOrEqualTo(@(30));
    }];
    [rewardButton addTarget:self action:@selector(goToRewardController) forControlEvents: UIControlEventTouchUpInside];
    
    BURewardedVideoModel *model = [[BURewardedVideoModel alloc] init];
    model.userId = [JPTool USER_ID];
    model.isShowDownloadBar = YES;
    self.rewardedVideoAd = [[BURewardedVideoAd alloc] initWithSlotID: BURewardAdId rewardedVideoModel:model];
    self.rewardedVideoAd.delegate = self;
    [self.rewardedVideoAd loadAdData];
}

-(void)goToRewardController {
    if (self.rewardedVideoAd.isAdValid) {
        [self.rewardedVideoAd showAdFromRootViewController: self.navigationController];
    }else{
        [ZJPAlert showAlertWithMessage:@"激励视频加载失败" time:1.0];
    }
}



#pragma mark - 穿山甲广告代理-BURewardedVideoAdDelegate
- (void)rewardedVideoAdDidLoad:(BURewardedVideoAd *)rewardedVideoAd {
    NSLog(@"rewardedVideoAd data load success");
}

- (void)rewardedVideoAdVideoDidLoad:(BURewardedVideoAd *)rewardedVideoAd {
    NSLog(@"rewardedVideoAd video load success");
}

- (void)rewardedVideoAdServerRewardDidSucceed:(BURewardedVideoAd *)rewardedVideoAd verify:(BOOL)verify {
    
    if (verify) {
        NSLog(@"rewardedVideoAdServerRewardDidSucceed,认证成功,处理免30分钟广告");
        [JPTool thirtyMinuteMianAd];
        [JPTool changeRewardAdInfo];
    }else{
        NSLog(@"虽然rewardedVideoAdServerRewardDidSucceed,但是没有认证成功");
    }
}

- (void)loadChuanShanJiaNativeAd {
    BUNativeAdsManager *chuanShanJiaNativeAd = [BUNativeAdsManager new];
    BUAdSlot *slot1 = [[BUAdSlot alloc] init];
    slot1.ID = @"916892990";
    slot1.AdType = BUAdSlotAdTypeFeed;
    slot1.position = BUAdSlotPositionTop;
    slot1.imgSize = [BUSize sizeBy: BUProposalSize_Feed690_388];
    slot1.isSupportDeepLink = YES;
    chuanShanJiaNativeAd.adslot = slot1;
    chuanShanJiaNativeAd.delegate = self;
    self.adManager = chuanShanJiaNativeAd;
    
    [chuanShanJiaNativeAd loadAdDataWithCount: 1];
    
    [MobClick event:@"ttad_feed_adv_load"];

}

- (void)chuanShanJiaNativeAdReloadData {
    
    [self.adContentView addSubview: self.jpView];
    
    BUNativeAd *nativeAd = self.dataSource[0];
    nativeAd.rootViewController = self;
    nativeAd.delegate = self;
    [nativeAd registerContainer: self.jpView withClickableViews:@[self.jpView.customBtn]];
    self.jpView.nativeAd = nativeAd;
    self.jpView.height = [ZJPChuanShanJiaView cellHeightWithModel: nativeAd width: self.adContentView.width];
}

#pragma mark - 穿山甲广告代理-BUNativeAdsManagerDelegate
- (void)nativeAdsManagerSuccessToLoad:(BUNativeAdsManager *)adsManager nativeAds:(NSArray<BUNativeAd *> *_Nullable)nativeAdDataArray {
    NSLog(@"feed datas load success");

    self.dataSource = nativeAdDataArray.mutableCopy;
   
    if (self.dataSource.count > 0) {
        [self chuanShanJiaNativeAdReloadData];
        [MobClick event:@"ttad_feed_adv_load_success"];
    }
}

- (void)nativeAdsManager:(BUNativeAdsManager *)adsManager didFailWithError:(NSError *_Nullable)error {
    NSLog(@"DrawVideo datas load fail");
    [MobClick event:@"ttad_feed_adv_load_fail"];

}

#pragma mark - 穿山甲广告代理-BUNativeAdDelegate
- (void)nativeAdDidBecomeVisible:(BUNativeAd *)nativeAd {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    // 当前时间存入本地
    [userDefaults setValue:[NSDate date] forKey: LAST_CHAPTER_AD_SHOW_TIME_KEY];
    [userDefaults synchronize];
    [MobClick event:@"ttad_feed_adv_show"];

}
- (void)nativeAdDidClick:(BUNativeAd *)nativeAd withView:(UIView *_Nullable)view {
    [MobClick event:@"ttad_feed_adv_click"];

}

- (void)nativeAd:(BUNativeAd *)nativeAd dislikeWithReason:(NSArray<BUDislikeWords *> *)filterWords {
    NSLog(@"click dislike");
    
    [self.dataSource removeObject: nativeAd];
    
    if (self.dataSource.count == 0) {
        [self.jpView removeFromSuperview];
        [self.adContentView removeFromSuperview];
      
    }else{
        [self chuanShanJiaNativeAdReloadData];
    }
}

#pragma mark - 广点通广告
- (void)loadGuangDianTongNativeAd {
//    CGFloat adHeight = ceil(self.adViewWidth * 0.6);
    self.guangDianTongNativeAd = [[GDTNativeExpressAd alloc] initWithAppId: kGDTMobSDKAppId placementId: YplacementId adSize: CGSizeMake(self.adViewWidth, self.adViewHeight)];
    self.guangDianTongNativeAd.delegate = self;
    // 非 WiFi 网络，是否自动播放。默认 NO。loadAd 前设置。
    self.guangDianTongNativeAd.videoAutoPlayOnWWAN = NO;
    //  自动播放时，是否静音。默认 YES。loadAd 前设置。
    self.guangDianTongNativeAd.videoMuted = YES;
    
    [self.guangDianTongNativeAd loadAd:(int)1];

    [MobClick event:@"gdt_native_adv_load"];

}

#pragma mark - 拉取广告成功的回调
- (void)nativeExpressAdSuccessToLoad:(GDTNativeExpressAd *)nativeExpressAd views:(NSArray<__kindof GDTNativeExpressAdView *> *)views {
    
    if (views.count == 0) { return; }
    
    [views enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GDTNativeExpressAdView *expressView = (GDTNativeExpressAdView *)obj;
        expressView.controller = self;
        [expressView render];
    }];
    
    UIView *view = [views objectAtIndex: 0];
    view.frame = CGRectMake(self.adLeftOrRight, 35, self.adViewWidth, self.adViewHeight);// 改变广告的坐标
    [self.adContentView addSubview: view];
    
    [MobClick event:@"gdt_native_adv_load_success"];

}

#pragma mark - 拉取广告失败的回调
- (void)nativeExpressAdRenderFail:(GDTNativeExpressAdView *)nativeExpressAdView {}

#pragma mark - 拉取原生模板广告失败
- (void)nativeExpressAdFailToLoad:(GDTNativeExpressAd *)nativeExpressAd error:(NSError *)error {
    NSLog(@"Express Ad Load Fail : %@",error);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.adContentView removeFromSuperview];
    });
    [MobClick event:@"gdt_native_adv_load_fail"];
}
/**
 * 原生模板广告渲染成功, 此时的 nativeExpressAdView.size.height 根据 size.width 完成了动态更新。
 */
- (void)nativeExpressAdViewRenderSuccess:(GDTNativeExpressAdView *)nativeExpressAdView {
    //    [self.tableView reloadData];
    //    CGFloat adWidth = ceil([JPTool screenWidth]-_adLeftOrRight*2);
    //    CGFloat adHeight = ceil(adWidth*0.80);
    //    nativeExpressAdView.size = CGSizeMake(adWidth, adHeight);
}
/**
 * 原生模板广告曝光成功, 就是已经显示了
 */
-(void)nativeExpressAdViewExposure:(GDTNativeExpressAdView *)nativeExpressAdView {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    // 当前时间存入本地
    [userDefaults setValue:[NSDate date] forKey: LAST_CHAPTER_AD_SHOW_TIME_KEY];
    [userDefaults synchronize];
    [MobClick event:@"gdt_native_adv_show"];
}

/**
 * 原生模板广告点击回调
 */
- (void)nativeExpressAdViewClicked:(GDTNativeExpressAdView *)nativeExpressAdView {
    [MobClick event:@"gdt_native_adv_click"];
}
#pragma mark - 原生模板广告被关闭
- (void)nativeExpressAdViewClosed:(GDTNativeExpressAdView *)nativeExpressAdView
{
    NSLog(@"--------%s-------",__FUNCTION__);
    [self.adContentView removeFromSuperview];
    
}


- (ZJPChuanShanJiaView *)jpView {
    if (!_jpView) {
        _jpView = [[ZJPChuanShanJiaView alloc] initWithFrame:CGRectMake(0, 35, self.adContentView.width, 200)];
//        _jpView.backgroundColor = [UIColor redColor];
        _jpView.backgroundColor = [UIColor whiteColor];
    }
    return _jpView;
}

- (void)addTapMenuView{
    CGFloat leftSpace = 125 * [JPTool WidthScale];
    self.tapMenuView =  [[UIView alloc] init] ;
    [self.view addSubview: self.tapMenuView];
    [self.tapMenuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.mas_equalTo([JPTool screenWidth] - leftSpace*2);
        make.height.mas_equalTo([JPTool screenHeight]);
    }];
    self.tapMenuView.backgroundColor = [UIColor clearColor];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMenu)];
    [self.tapMenuView addGestureRecognizer: tap];
}

- (void)showMenu {
    [self.delegate readContentControllerShouldMenuView: self];
}

@end
