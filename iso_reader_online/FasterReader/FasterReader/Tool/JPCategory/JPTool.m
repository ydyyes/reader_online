//
//  JPTool.m
//  NightReader
//
//  Created by 张俊平 on 2019/3/28.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import "JPTool.h"

@implementation JPTool

#pragma mark - 接口相关
/** 获取服务器时间 */
+ (NSString*)ServerPath {
	return @"GetTime/1";
}

/** 策略接口 */
+ (NSString*)StrategyPath {
	return @"VthStra/1";
}

/** 设置用户信息 */
+ (NSString*)SetUserInfo {
	return @"VtwSetUserInfo/1";
}

#pragma mark -书架界面接口
/** 书架-轮播图接口 */
+ (NSString*)BookshelfBannersPath {
	return @"Banners/1";
}

/** 书架-每日推荐接口 */
+ (NSString*)BookshelfDayRecommendPath {
	return @"VthDayRecommend/1";
}

+ (NSString *)BookshelfFloatAdPath {
    return @"VthAdList/1";
}

/** 书架-搜索关键字 */
+ (NSString*)BookshelfSerachKeyPath {
	return @"Key/1";
}

/** 书架-搜索结果列表 */
+ (NSString*)BookshelfSerachResultPath {
	return @"Search/1";
}

/** 书架-搜索结果列表-书籍详情 */
+ (NSString*)BookshelfBookDetailPath {
	return @"Detail/1";
}

/** 书架-获取章节数 */
+ (NSString*)BookshelfBookChapterLtPath {
	return @"VthChapterLt/1";
}

/** 书架-获章节内容接口 */
+ (NSString*)BookshelfBookChapterInPath {
	return @"VthChapterIn/1";
}

#pragma mark -书城界面接口
/** 书城-左侧分类接口 */
+ (NSString*)BookcityCatePath {
	return @"Cate/1";
}

/** 书城-右侧分类接口 */
+ (NSString*)BookcityBookPath {
	return @"Novel/1";
}

/** 书城-每组的数据接口 */
+ (NSString*)BookcityBookDataPath {
	return @"VthBookM/1";
}

/** 书城-热门更新、热门搜索更多列表 数据接口 */
+ (NSString*)BookCityHotUpdateAndSerachMorePath {
	return @"VthList/1";
}


/** 分类-右侧分类接口 */
+ (NSString*)BookCategoryPath {
	return @"VthCates/1";
}


/** 书城-推荐  */
+ (NSString*)BookcityRecommendPath {
	return @"ReCommence/1";
}

#pragma mark -我的页面接口
/** 我的-用户信息接口 */
+ (NSString*)UserInPath {
	return @"UserIn/1";
}

/** 我的-用户登陆注册接口 */
+ (NSString*)LoginRegisterPath {
	return @"ApinRegist/1";
}

/** 我的-绑定手机号 */
+ (NSString*)MyMineBindphonePath {
	return @"Bindph/1";
}

/** 我的-发送短信验证码 */
+ (NSString*)MyMineSendCodePath {
	return @"sms/1";
}

/** 我的-用户反馈 */
+ (NSString*)MyMineFeecbackPath {
	return @"Feecba/1";
}

/** 我的-任务列表 */
+ (NSString*)MyMineTaskListPath {
	return @"Ta/1";
}

/** 我的-任务上报 */
+ (NSString*)MyMineTaskReportPath {
	return @"TastL/1";
}

#pragma mark - 提示语
/** 网络不可用，请检查网络 */
+ (NSString*)NoNetWorkAlert {
	return @"网络不可用，请检查网络！";
}

/** 数据加载失败！ */
+ (NSString*)ErrorOfNetWorkAlert {
	return @"数据加载失败！";
}
/** 您的账号在另一设备上登录，请重新登录 */
+ (NSString*)NoLoginOfAgainLogin {
	return @"您的账号在另一设备上登录，请重新登录";
}

/** 请先登录!  */
+ (NSString*)NoLoginAlert {
	return @"请先登录! ";
}

#pragma mark - 屏幕高度 宽高比

+ (CGFloat)screenWidth {
	return [UIScreen mainScreen].bounds.size.width;
}

+ (CGFloat)screenHeight {
	return [UIScreen mainScreen].bounds.size.height;
}
+ (UIWindow*)kWindow {
	return [UIApplication sharedApplication].keyWindow;
}
+ (CGFloat)WidthScale {
	return [JPTool screenWidth]/375.0f;
}
+ (CGFloat)HeightScale {
	return [JPTool screenHeight]/667.0f;
}
+ (BOOL)is_iPhoneXN {
	BOOL isX = (([[UIApplication sharedApplication] statusBarFrame].size.height == 44.0f) ? (YES):(NO));
	return isX;
}

+ (CGSize)getSizeWithSpace:(CGFloat)space num:(CGFloat)num proportion:(CGFloat)proportion other:(CGFloat)other {
	CGFloat width = ([JPTool screenWidth]-space*(num+1))/num;
	CGFloat height = width/proportion+other;
	return CGSizeMake(width, height);
}
+ (CGSize)getSizeWithOther:(CGFloat)other{//other 为固定高度
	CGFloat width = ([JPTool screenWidth]-15*(4+1))/4;
	CGFloat height = width*96/72+other;
	return CGSizeMake(width, height);
}


#pragma mark - -- NSUserDefaults

/** 服务器时间 */
+ (NSString*)APP_ServerTime {
	return [[NSUserDefaults standardUserDefaults] objectForKey:@"APPServerTime"];
}

+ (NSString*)UserInvitationCode {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"invitation_code"] ? [[NSUserDefaults standardUserDefaults] objectForKey:@"invitation_code"]:@"";
}

/** 用户id */
+ (NSString*)USER_ID {
	return [[NSUserDefaults standardUserDefaults] objectForKey:@"userid"];
}

/** 用户性别 */
+ (NSNumber*)USER_SEX {
    id gender = [[NSUserDefaults standardUserDefaults] objectForKey:@"gender"];
    if ([gender isKindOfClass: [NSString class]] && [gender length] <= 0) {
        NSLog(@"NSString.gender%@",gender);
        gender = @(-1);
    }
	return gender ? gender : @(-1);
}

/** 有无会员，如果有会员会显示到期时间戳,没有或者到期显示为0 */
+ (NSString*)USER_EXPIRE {
	return [[NSUserDefaults standardUserDefaults] objectForKey:@"expire"] ? [[NSUserDefaults standardUserDefaults] objectForKey:@"expire"]:@"";
}
/** 金币数量 */
+ (NSString*)USER_GOLD {
	return [[NSUserDefaults standardUserDefaults] objectForKey:@"gold"] ? [[NSUserDefaults standardUserDefaults] objectForKey:@"gold"]:@"";
}

/** 用户类型 */
+ (NSString*)USER_TYPE {
	return [[NSUserDefaults standardUserDefaults] objectForKey:@"u_type"];
}

/** token */
+ (NSString*)USER_TOKEN {
	return [[NSUserDefaults standardUserDefaults] objectForKey:@"APP_token"]? [[NSUserDefaults standardUserDefaults] objectForKey:@"APP_token"]:@"";
}

/** 用户昵称 */
+ (NSString*)USER_NAME {
	return [[NSUserDefaults standardUserDefaults] objectForKey:@"username"]? [[NSUserDefaults standardUserDefaults] objectForKey:@"username"]:@"";
}
/** 用户真实名字 */
+ (NSString*)USER_TRUENAME {
	return [[NSUserDefaults standardUserDefaults] objectForKey:@"truename"]? [[NSUserDefaults standardUserDefaults] objectForKey:@"truename"]:@"";
}

/** 用户头像 */
+ (NSString*)USER_AVATAR {
	return [[NSUserDefaults standardUserDefaults] objectForKey:@"USER_AVATAR"];
}

+ (void)ChangeBookshelfSortTypeWithType:(BookshelfSortType)type{
    [[NSUserDefaults standardUserDefaults] setInteger:type forKey:@"MSYBookshelfSortType"];
}
+ (BookshelfSortType)BookshelfSortType{
    
   BookshelfSortType type = [[NSUserDefaults standardUserDefaults] integerForKey:@"MSYBookshelfSortType"];
    
    return type ? type : BookshelfSortReadTime;
}


#pragma mark -- 比较系统时间 --
+ (BOOL)dateEqual {

	NSDateFormatter *formater = [[ NSDateFormatter alloc] init];
	[formater setDateFormat:@"yyyy-MM-dd"];
	NSDate *currentDate = [NSDate date];//获取当前日期
	NSString *currentDateStr = [formater stringFromDate: currentDate];

	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"currentDate"] isEqualToString: currentDateStr]) {
			//        比较上一次和本地存的时间，相等就不弹广告窗口
		return NO;
	}else{
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		[userDefaults setObject:currentDateStr forKey:@"currentDate"];
		[userDefaults setObject:@"0" forKey:@"downLoadNum"];// 小说下载次数
		[userDefaults synchronize];
			//        不相等就弹，当前时间存入本地
		return YES;
	}
}


#pragma mark - -- 广告相关 --
/** 开屏广告SDK展示开关 */
+ (NSString*)STRATEGY_AD_OPEN {
	return [[NSUserDefaults standardUserDefaults] objectForKey:STRATEGY_AD_OPEN];
}

/** banner广告SDK展示开关 */
+ (NSString*)BANNER_AD_SWITCH {
	return [[NSUserDefaults standardUserDefaults] objectForKey:BANNER_AD_SWITCH];
}

/** 开屏广告SDK展示配置 */
+ (NSString*)START_RATIO {
	return [[NSUserDefaults standardUserDefaults] objectForKey:STRATEGY_START_RATIO];
}

/** banner广告SDK展示配置 */
+ (NSString*)BANNER_AD_RATIO {
	return [[NSUserDefaults standardUserDefaults] objectForKey:BANNER_AD_RATIO];
}

/** 章节广告SDK展示配置 */
+ (NSString*)CHAPTER_END_RATIO {
	return [[NSUserDefaults standardUserDefaults] objectForKey:STRATEGY_CHAPTER_END_RATIO];
}

/** 联系客服 */
+ (NSString*)CONTACT_US {
	return [[NSUserDefaults standardUserDefaults] objectForKey:CONTACT_US];
}


/** 展示开屏广告 */
+ (NSString*)showAD {
    return [self showADWithType:@"1"];
}

+ (BOOL)isShowRewardAd{
    if ([self isThirtyMinuteMianAd]) {
        return NO;
    }
    
    // 获取服务器配置的,每章末尾展示广告的时间间隔
    NSString *serverRewardLimit = [[NSUserDefaults standardUserDefaults] objectForKey: AD_BROWSE_LIMIT];
    NSInteger rewardLimit = [serverRewardLimit integerValue];
    
    NSDate *lastShowRewardDate = (NSDate*)[[NSUserDefaults standardUserDefaults] objectForKey: LAST_REWARD_AD_SHOW_TIME_KEY];
    
    if (!lastShowRewardDate) {
        return YES;
    }

    NSDateComponents *lastDateComponents = [self convertDateToDateComponents: lastShowRewardDate];
    NSDateComponents *todayDateComponents = [self convertDateToDateComponents: [NSDate date]];

    if (todayDateComponents.month > lastDateComponents.month) {
        return YES;
    }
    
    if (todayDateComponents.day > lastDateComponents.day) {
        return YES;
    }
    
    NSInteger reeardShowCount = [[NSUserDefaults standardUserDefaults] integerForKey:LAST_REWARD_AD_SHOW_COUNT_KEY];
    
    if (reeardShowCount >= rewardLimit) {
        return NO;
    }
    
    return YES;
}

+(void)changeRewardAdInfo {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger reeardShowCount = [userDefaults integerForKey:LAST_REWARD_AD_SHOW_COUNT_KEY];
    [userDefaults setObject:[NSDate date] forKey:LAST_REWARD_AD_SHOW_TIME_KEY];
    [userDefaults setInteger: reeardShowCount + 1 forKey:LAST_REWARD_AD_SHOW_COUNT_KEY];
}


/** 展示章节末尾广告 */
+ (NSString*)showChapterAD {
    
    if ([JPTool isThirtyMinuteMianAd]) {
        return @"0";
    }
   
    //这里面就是先根据 LAST_CHAPTER_AD_SHOW_TIME_KEY 上一次章节末尾广告展示的时间
    //或者当已经看过这个广告,会重新设置了 LAST_CHAPTER_AD_SHOW_TIME_KEY 时间
	NSDate *lastShowChapterDate = (NSDate*)[[NSUserDefaults standardUserDefaults] objectForKey: LAST_CHAPTER_AD_SHOW_TIME_KEY];
    //没有,说明章节末尾广告没有展示过,直接直接展示
    if (!lastShowChapterDate) {
        return [self showADWithType:@"2"];
    }
    
    // 获取服务器配置的,每章末尾展示广告的时间间隔
    NSString *serverChapterAdTimeInterval = [[NSUserDefaults standardUserDefaults] objectForKey: STRATEGY_AD_CHAPTER_END_INTV];
    NSInteger chapterTimeInterval = [serverChapterAdTimeInterval integerValue];
    
    //判断取出的时间和现在时间相比,是否大于服务器配置的每次展示章节末尾广告的时间间隔
    //大于就显示banner广告
	NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate: lastShowChapterDate];
    NSLog(@"广告时间差：%f",timeInterval);
	if (timeInterval > chapterTimeInterval) {
		return [self showADWithType:@"2"];
	}
	return @"0";
}

/** 展示底部Banner广告 */
+ (NSString*)showBannerAD {
	
    if ([JPTool isThirtyMinuteMianAd]) {
        return @"0";
    }
 
    NSDate *userCloseLastDate = (NSDate*)[[NSUserDefaults standardUserDefaults] objectForKey: LAST_BANNER_USER_CLOSE_TIME_KEY];
    //有值,说明用户手动关闭过banner广告,需要判断了
    if (userCloseLastDate) {
        // 获取服务器配置的当用户手动关闭了章节末尾广告,下次重新展示的时间间隔
        NSString *serverBannerAdReloadTimeInterval = [[NSUserDefaults standardUserDefaults] objectForKey: BANNER_AD_LOAD];
        NSInteger serverReloadTimeInterval = [serverBannerAdReloadTimeInterval integerValue];
        NSTimeInterval currentReloadInterval = [[NSDate date] timeIntervalSinceDate: userCloseLastDate];
        NSLog(@"用户手动关闭banner广告时间差：%f",currentReloadInterval);
        if (serverReloadTimeInterval > currentReloadInterval) {
            //如果时间差小于服务器给定的时间,不需要更换的广告
            return @"0";
        }
    }
    //这里面就是先根据 LAST_BANNER_AD_SHOW_TIME_KEY 取出上次banner广告展示的时间
    //当这个广告已经曝光(展示了),会重新设置 LAST_BANNER_AD_SHOW_TIME_KEY 时间
	NSDate *lastDate = (NSDate*)[[NSUserDefaults standardUserDefaults] objectForKey: LAST_BANNER_AD_SHOW_TIME_KEY];
    //如果取不到,表示,没有展示过banner广告,需要显示banner广告了
    if (!lastDate) {
        return [JPTool bannerAD];
    }
    // 获取服务器配置的banner广告时间间隔
    NSString *serverBannerTimeInterval = [[NSUserDefaults standardUserDefaults] objectForKey: BANNER_AD_LIMIT];
    NSInteger bannerTimeInterval = [serverBannerTimeInterval integerValue];
    //判断取出的时间和现在时间相比,是否大于服务器配置的每次显示banner广告的时间间隔
	NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate: lastDate];
	NSLog(@"底部Banner广告展示时间差：%f",timeInterval);
	if (timeInterval >  bannerTimeInterval) {
        //如果时间差大于服务器给定的时间,需要更换的广告了
		return [JPTool bannerAD];
	}
	return @"0";
}

+(void)thirtyMinuteMianAd{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate *date = [NSDate date];
    [userDefaults setObject: date forKey:@"thirtyMinuteMianAd"];
}

+(BOOL)isThirtyMinuteMianAd{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastDate = [userDefaults objectForKey: @"thirtyMinuteMianAd"];
    //如果上次都没有存,说明没有免广告
    if (!lastDate) {
        return NO;
    }
    NSDate *nowDate = [NSDate date];
    NSTimeInterval timeInterval = [nowDate timeIntervalSinceDate: lastDate];
    NSTimeInterval thirtyMinute = 60 * 30;
    //超过30分钟了,说明不能在免广告了
    if (timeInterval > thirtyMinute) {
        return NO;
    }
    return YES;
}

//根据date获取月/日
+ (NSDateComponents *)convertDateToDateComponents:(NSDate *)date {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute) fromDate:date];
    return components;
}

/** 底部Banner广告 */
+ (NSString*)bannerAD {
    NSString *ADRATIO = nil;
    ADRATIO = [JPTool BANNER_AD_RATIO];// banner广告配置比例
    int allNum = 0;
    NSArray *array;
    if ([JPTool BANNER_AD_SWITCH]&&[[JPTool BANNER_AD_SWITCH] isEqualToString:@"1"]) {// 广告开关打开
        
        if (ADRATIO){// 广告配置存在
            array = [ADRATIO componentsSeparatedByString:@","];// feng
            for (int i = 0; i < array.count-1; i++) {
                allNum += [array[i] integerValue];
            }
            return [JPTool comp:array allNum:allNum];
        }else{// 没有就默认1：1
            int x = 1+arc4random() % 10;
            if (x >= 1 && x <= 5) {
                return @"1";
            }else{
                return @"2";
            }
        }
        
    }else{
        return @"0";// 不展示广告
    }
}

/** 广告展示配置,开屏广告和章节末尾广告*/
+ (NSString*)showADWithType:(NSString*)type {
    
    NSString *ADRATIO = nil;
    if ([type isEqualToString:@"1"]) {
        ADRATIO = [JPTool START_RATIO];// 开屏广告
    }else{
        ADRATIO = [JPTool CHAPTER_END_RATIO];// 章节末尾广告
    }
    int allNum = 0;
    NSArray *array;
    if ([JPTool STRATEGY_AD_OPEN] && [[JPTool STRATEGY_AD_OPEN] isEqualToString:@"1"]) {// 广告开关打开
        
        if (ADRATIO){// 广告配置存在
            array = [ADRATIO componentsSeparatedByString:@","];// feng
            for (int i = 0; i < array.count-1; i++) {
                allNum += [array[i] integerValue];
            }
            return [JPTool comp:array allNum:allNum];
        }else{// 没有就默认1：1
            int x = 1+arc4random() % 10;
            if (x >= 1 && x <= 5) {
                return @"1";
            }else{
                return @"2";
            }
        }
    }else{
        return @"0";// 不展示广告
    }
}


// 展示配比 计算概率
+ (NSString*)comp:(NSArray*)array allNum:(NSInteger)allNum {
    
    int x = 1+arc4random() % allNum;
    if ([array[0] integerValue] > [array[1] integerValue]) {// [60,35]
        
        if (x >= 0 && x <= [array[1] integerValue]) {
            return @"2";
        }else {//(x > [array[1] integerValue])
            return @"1";
        }
        
    }else if ([array[0] integerValue] < [array[1] integerValue]) {// [35,60]
        
        if (x >= 0 && x <= [array[0] integerValue]) {
            return @"1";
        }else {//(x > [array[0] integerValue])
            return @"2";
        }
    }else {// [50,50] 比例1：1
        int x = 1+arc4random() % 10;
        if (x >= 1 && x <= 5) {
            return @"1";
        }else {// (x > 5 && x <= 10 )
            return @"2";
        }
    }
}

@end
