//
//  OCAppdelegate.m
//  FasterReader
//
//  Created by apple on 2019/7/1.
//  Copyright © 2019 Restver. All rights reserved.
//

#import "OCAppdelegate.h"
#import "RootTabBarController.h"
#import <Bugly/Bugly.h>
#import <UMAnalytics/MobClick.h>
#import <UMCommon/UMCommon.h>

#define BUGLY_APP_ID @"1bcf9c7157"

#define APP_URL @"http://itunes.apple.com/cn/lookup?id=1457293407"

static NSString *const key = @"CFBundleShortVersionString";//CFBundleShortVersionString  CFBundleVersion


@interface OCAppdelegate()

@property (strong, nonatomic) RootTabBarController *rootTabBarController;

@property (strong, nonatomic) GDTSplashAd *splash;
/// 穿山甲倒计时
@property (nonatomic, assign) CFTimeInterval startTime;

@end

@implementation OCAppdelegate


+ (instancetype)shared {
    static OCAppdelegate *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[OCAppdelegate alloc] init];
    });
    return instance;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // MARK: 检查是否有版本更新
    [self checkUpVersion];
    //广告展示策略
    [self getStrategy];
    
    [self loadWindows];
    
    // 友盟
    [self youmeng];
    
    if ([JPTool is_iPhoneXN]) {
        NSLog(@"iphoneX");
    }
    return YES;
}

-(void)youmeng{
    [UMConfigure initWithAppkey:@"5d284b133fc1950df2000bc4" channel:nil];
    [MobClick setScenarioType:E_UM_NORMAL];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:LAST_APP_ENTER_BACKGROUND_TIME_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastEnterBackGroundDate = (NSDate*)[userDefaults objectForKey: LAST_APP_ENTER_BACKGROUND_TIME_KEY];
    //取不到就返回,防止崩溃(虽然必然会取到的.....)
    if (!lastEnterBackGroundDate) {
        return;
    }
    NSString *serverReloadScreenADTimeInterve = [userDefaults objectForKey: STRATEGY_START_LOAD];
    NSInteger reloadScreenADTimeInterve = [serverReloadScreenADTimeInterve integerValue];
    
    NSTimeInterval timerInterval = [[NSDate date] timeIntervalSinceDate: lastEnterBackGroundDate];
    if (timerInterval > reloadScreenADTimeInterve) {
        [self showOpenAD];
    }
}


#pragma mark -- 加载 window
- (void)loadWindows {
    
    self.rootTabBarController = [[RootTabBarController alloc] init];
    
    [Bugly startWithAppId:BUGLY_APP_ID];
    
    // 1.设置根控制器
    if ([self currentVersionIsEqualToLastVersion]) {
        self.window.rootViewController = self.rootTabBarController;
    }else {
        self.window.rootViewController = [[IntroduceViewController alloc] init] ;
    }
    [BUAdSDKManager setAppID: BUAdAppId];
    [BUAdSDKManager setIsPaidApp:NO];
    [BUAdSDKManager setLoglevel:BUAdSDKLogLevelDebug];
    
    [self showOpenAD];
    [self.window makeKeyAndVisible];
    [NSThread sleepForTimeInterval:1.0];
    //避免多个按钮同时点击 --
    [[UIButton appearance] setExclusiveTouch:YES];
}
#pragma mark - 是否展示开屏广告
- (void)showOpenAD {
    NSString *str = [JPTool showAD];// 开屏广告配置
    if ([str isEqualToString:@"1"]) {
        [self GDTAd];
    }else if ([str isEqualToString:@"2"]){
        [self BUAd];
    }
}

#pragma mark - -- 广点通 腾讯广告 --
- (void)GDTAd {
    //开屏广告初始化并展示代码
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        //美阅开屏：7050267068908346
        self.splash = [[GDTSplashAd alloc] initWithAppId:kGDTMobSDKAppId placementId:kplacementId];
        self.splash.delegate = self;
        UIImage *splashImage = [UIImage imageNamed:@"K_640-1136"];
        if (isIPhoneXSeries()) {
            splashImage = [UIImage imageNamed:@"XS-Max"];
        } else if ([UIScreen mainScreen].bounds.size.height == 480) {
            splashImage = [UIImage imageNamed:@"320-480"];
        }
        self.splash.backgroundImage = splashImage;
        self.splash.fetchDelay = 3;//拉取广告超时时间，默认为3秒
        self.startTime = CACurrentMediaTime();
        [self.splash loadAdAndShowInWindow: self.window];
        
        [MobClick event:@"gdt_splash_adv_load"];
    }
}
#pragma mark - -- 穿山甲广告 --
- (void)BUAd {
    CGRect frame = [UIScreen mainScreen].bounds;
    BUSplashAdView *splashView = [[BUSplashAdView alloc] initWithSlotID:kSlotID frame:frame];
    splashView.delegate = self;
    splashView.tolerateTimeout = 2;
    
    UIWindow *keyWindow = [UIApplication sharedApplication].windows.firstObject;
    self.startTime = CACurrentMediaTime();
    [splashView loadAdData];
    [keyWindow.rootViewController.view addSubview:splashView];
    splashView.rootViewController = keyWindow.rootViewController;
    
    [MobClick event:@"ttad_splash_adv_load"];

}
#pragma mark - 判断版本号
- (BOOL)currentVersionIsEqualToLastVersion {
    
    //判断是否第一次运行
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"First_Installation"]) {
        return YES;// 版本号相同：这次打开和上次打开的是同一个版本
    } else {// 将当前的版本号存进沙盒
        [[NSUserDefaults standardUserDefaults] setObject:@"First_Installation" forKey:@"First_Installation"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return NO;
    }
}

#pragma mark - 策略接口
- (void)getStrategy {
    if (![ZJPNetWork netWorkAvailable]) {
        return;
    }
    NSMutableDictionary *para = [[NSMutableDictionary alloc]init];
    [[JPNetWork sharedManager] requestPostMethodWithPathUrl:[JPTool StrategyPath] WithParamsDict:para WithSuccessBlock:^(id responseObject) {
        
        NSDictionary *dataDict = responseObject[@"data"];
        
        NSLog(@"%@",responseObject[@"data"]);
        
        NSUserDefaults *userDefaults =[NSUserDefaults standardUserDefaults];
        
        //Banner广告开关
        [userDefaults setValue:dataDict[@"BANNER_AD_SWITCH"] forKey: BANNER_AD_SWITCH];
        //Banner广告比例（广、穿、百）
        [userDefaults setValue:dataDict[@"BANNER_AD_RATIO"] forKey:BANNER_AD_RATIO];
        //Banner 广告间隔
        [userDefaults setValue:dataDict[@"BANNER_AD_LIMIT"] forKey:BANNER_AD_LIMIT];
        //用户关闭Banner广告,后重新展示需要的间隔
        [userDefaults setValue:dataDict[@"BANNER_AD_LOAD"] forKey: BANNER_AD_LOAD];
        
        //开屏广告SDK展示配置
        [userDefaults setValue:dataDict[@"STRATEGY_START_RATIO"] forKey:STRATEGY_START_RATIO];
        /** app进入后台后,重新进入前台,超过这个时间间隔,就展示广告 */
        [userDefaults setValue:dataDict[@"STRATEGY_START_LOAD"] forKey:STRATEGY_START_LOAD];
        
        //章节末广告展示间隔
        [userDefaults setValue:dataDict[@"STRATEGY_AD_CHAPTER_END_INTV"] forKey: STRATEGY_AD_CHAPTER_END_INTV];
        
        //红包开关 1为开 0为关
        [userDefaults setValue:dataDict[@"STRATEGY_RED_PACKET"] forKey:STRATEGY_RED_PACKET];
        
        //每日激励视频观看总数限制
        [userDefaults setValue:dataDict[@"AD_BROWSE_LIMIT"] forKey:AD_BROWSE_LIMIT];

        
        [userDefaults setValue:dataDict[@"STRATEGY_FREE_AD_OPEN"] forKey:@"STRATEGY_FREE_AD_OPEN"];//自由广告展示开关
        [userDefaults setValue:dataDict[@"STRATEGY_FREE_AD_SHOW_TIMES_EVERYDAY"] forKey:@"STRATEGY_FREE_AD_SHOW_TIMES_EVERYDAY"];//自由广告每天展示次数
        [userDefaults setValue:dataDict[@"STRATEGY_FREE_AD_SHOW_INTV"] forKey:@"STRATEGY_FREE_AD_SHOW_INTV"];//自由广告展示间隔(单位:分钟)
        [userDefaults setValue:dataDict[@"STRATEGY_AD_OPEN"] forKey:@"STRATEGY_AD_OPEN"];//广告SDK展示开关
        
        [userDefaults setValue:dataDict[@"EXCHANGE_GOLD_NUM"] forKey:@"EXCHANGE_GOLD_NUM"];//缓存一本书所需的金币
        [userDefaults setValue:dataDict[@"SHARE_TIMES_LIMIT"] forKey:@"SHARE_TIMES_LIMIT"];//每日分享总数限制
        [userDefaults setValue:dataDict[@"STRATEGY_CHAPTER_END_RATIO"] forKey:@"STRATEGY_CHAPTER_END_RATIO"];//章节末尾广告SDK展示配置
        [userDefaults setValue:dataDict[@"STRATEGY_VIDEO_RATIO"] forKey:@"STRATEGY_VIDEO_RATIO"];//视频任务广告SDK展示配置
        
        [userDefaults setValue:dataDict[@"CONTACT_US"] forKey:@"CONTACT_US"];//首页 公告 信息
        
        [userDefaults synchronize];
        //        [self showOpenAD];
        
    } WithFailurBlock:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}
#pragma mark - 检查更新
- (void)checkUpVersion {
    //        NSLog(@"%@",responseObject);
    /*responseObject是个字典{}，有两个key
     KEYresultCount = 1//表示搜到一个符合你要求的APP
     results =（）//这是个只有一个元素的数组，里面都是app信息，那一个元素就是一个字典。里面有各种key。
     其中有 trackName （名称）trackViewUrl = （下载地址）version （可显示的版本号）等等
     */
    if (![ZJPNetWork netWorkAvailable]) {
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:APP_URL parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSArray *array = [responseObject objectForKey:@"results"];
        NSDictionary *dic = [array firstObject];
        NSString *versionStr   = [dic objectForKey:@"version"];// 版本号
        NSString *trackViewUrl = [dic objectForKey:@"trackViewUrl"];// App Store网址
        NSString *releaseNotes = [dic objectForKey:@"releaseNotes"];//更新日志信息
        
        if (versionStr && ![versionStr isEqualToString:@""]) {//版本存在并且不为空
            
            if ([self compareVesionWithServerVersion:versionStr] == 1) {//比较版本号
                
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"发现新版本:%@\n为了不影响使用请更新到最新版本",versionStr] message:releaseNotes preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction  = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    //NSLog(@"点击了取消");
                }];
                
                UIAlertAction *OKAction  = [UIAlertAction actionWithTitle:@"去更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    //NSLog(@"点击了知道了");
                    NSURL * url = [NSURL URLWithString:trackViewUrl];//itunesURL = trackViewUrl的内容
                    [[UIApplication sharedApplication] openURL:url];
                }];
                [alertVC addAction:cancelAction];
                [alertVC addAction:OKAction];
                [self.rootTabBarController presentViewController:alertVC animated:YES completion:nil];
                
            }
            else{
                //[ZJPAlert showAlertWithMessage:@"当前已是最新版本" time:1.2];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    
}
/**
 比较两个版本号的大小
 
 */
- (NSInteger)compareVesionWithServerVersion:(NSString *)v1 {
 
    //当前版本
    NSString *v2 = [self getCurrentVersion];

    // 都为空，相等，返回0
    if (!v1 && !v2) {
        return 0;
    }
    // v1为空，v2不为空，返回-1
    if (!v1 && v2) {
        return -1;
    }
    // v2为空，v1不为空，返回1
    if (v1 && !v2) {
        return 1;
    }
    // 获取版本号字段
    NSArray *v1Array = [v1 componentsSeparatedByString:@"."];
    NSArray *v2Array = [v2 componentsSeparatedByString:@"."];
    // 取字段最大的，进行循环比较
    NSInteger bigCount = (v1Array.count > v2Array.count) ? v1Array.count : v2Array.count;
    for (int i = 0; i < bigCount; i++) {
        // 字段有值，取值；字段无值，置0。
        NSInteger value1 = (v1Array.count > i) ? [[v1Array objectAtIndex:i] integerValue] : 0;
        NSInteger value2 = (v2Array.count > i) ? [[v2Array objectAtIndex:i] integerValue] : 0;
        if (value1 > value2) {
            // v1版本字段大于v2版本字段，返回1
            return 1;
        } else if (value1 < value2) {
            // v2版本字段大于v1版本字段，返回-1
            return -1;
        }
        // 版本相等，继续循环。
    }
    // 版本号相等
    return 0;
}

#pragma mark - 获取APP当前版本号
- (NSString *)getCurrentVersion {
    NSDictionary *infoDict   = [[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion = [infoDict objectForKey:key];
    NSLog(@"当前版本号：%@",currentVersion);
    return currentVersion;
}

#pragma mark - 穿山甲广告代理
/**
 关闭开屏广告， {点击广告， 点击跳过，超时}
 - Parameter splashAd: 产生该事件的 SplashView 对象.
 */
- (void)splashAdDidClose:(BUSplashAdView *)splashAd {
    [splashAd removeFromSuperview];
    CFTimeInterval endTime = CACurrentMediaTime();
    NSLog(@"Total Runtime: %g s", endTime - self.startTime);
}
/**
 splashAd 加载失败
 
 - Parameter splashAd: 产生该事件的 SplashView 对象.
 - Parameter error: 包含详细是失败信息.
 */
- (void)splashAd:(BUSplashAdView *)splashAd didFailWithError:(NSError *)error {
    [splashAd removeFromSuperview];
    CFTimeInterval endTime = CACurrentMediaTime();
    NSLog(@"Total Runtime: %g s error=%@", endTime - self.startTime, error);
    
    [MobClick event:@"ttad_splash_adv_load_fail"];
}

-(void)splashAdDidLoad:(BUSplashAdView *)splashAd{
    [MobClick event:@"ttad_splash_adv_load_success"];

}
- (void)splashAdWillVisible:(BUSplashAdView *)splashAd {
    [MobClick event:@"ttad_splash_adv_show"];
}

-(void)splashAdDidClick:(BUSplashAdView *)splashAd {
    [MobClick event:@"ttad_splash_adv_click"];
}

#pragma mark - 腾讯广告代理
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    // 开发者在该回调函数中对传入的URL进行分析，展示详情页面。
    return YES;
}

- (void)splashAdApplicationWillEnterBackground:(GDTSplashAd *)splashAd
{
    NSLog(@"%s",__FUNCTION__);
}

-(void)splashAdSuccessPresentScreen:(GDTSplashAd *)splashAd
{
    NSLog(@"%s",__FUNCTION__);
    
    [MobClick event:@"gdt_splash_adv_show"];

}

-(void)splashAdFailToPresent:(GDTSplashAd *)splashAd withError:(NSError *)error
{
    NSLog(@"%s%@",__FUNCTION__,error);
    self.splash = nil;
    
    [MobClick event:@"gdt_splash_adv_load_fail"];

}

- (void)splashAdWillClosed:(GDTSplashAd *)splashAd
{
    NSLog(@"%s",__FUNCTION__);
}
-(void)splashAdClosed:(GDTSplashAd *)splashAd
{
    NSLog(@"%s",__FUNCTION__);
    self.splash = nil;
}

- (void)splashAdWillPresentFullScreenModal:(GDTSplashAd *)splashAd
{
    NSLog(@"%s",__FUNCTION__);
}

- (void)splashAdDidPresentFullScreenModal:(GDTSplashAd *)splashAd
{
    NSLog(@"%s",__FUNCTION__);
}

- (void)splashAdExposured:(GDTSplashAd *)splashAd
{
    NSLog(@"%s",__FUNCTION__);
    
    [MobClick event:@"gdt_splash_adv_load_success"];
}

- (void)splashAdClicked:(GDTSplashAd *)splashAd
{
    NSLog(@"%s",__FUNCTION__);
    
    [MobClick event:@"gdt_splash_adv_click"];
}

- (void)splashAdWillDismissFullScreenModal:(GDTSplashAd *)splashAd
{
    NSLog(@"%s",__FUNCTION__);
}

- (void)splashAdDidDismissFullScreenModal:(GDTSplashAd *)splashAd
{
    NSLog(@"%s",__FUNCTION__);
}


@end
