//
//  JPTool.h
//  NightReader
//
//  Created by 张俊平 on 2019/3/28.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define RGBA(R,G,B,A) [UIColor colorWithRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:A]
#define RGBA_COLOR(R, G, B, A) [UIColor colorWithRed:((R) / 255.0f) green:((G) / 255.0f) blue:((B) / 255.0f) alpha:A]
#define HEXCOLOR(HexString) [UIColor colorWithHexString:HexString];
#define HEXCOLOR_ALHPA(HexString,Alpha) [UIColor colorWithHexString:HexString alpha:Alpha]


typedef NS_ENUM(NSUInteger, BookshelfSortType) {
    BookshelfSortReadTime = 2,
    BookshelfSortUpdateTime = 3
};

/** 小说model信息缓存目录(阅读记录,书架记录,搜索记录) */
static NSString *const FasterReaderBookInfoCache = @"FasterReaderBookInfoCacheName";
/// 已经添加书架的的缓存key,这个key的Value是一个数组,保存着加入到书架的小说的bookid
static NSString *const FasterReaderBookBookIdCacheKey = @"FasterReaderBookBookIdCacheKey"; // bookID


/** 小说阅读历史的缓存目录 */
static NSString *const FasterReaderBookBrowseHistoryCache = @"FasterReaderBookBrowseHistoryCache";
/// 阅读历史的缓存key,这个key的Value是一个数组,保存着阅读过的小说的bookid
static NSString *const FasterReaderBookBrowseHistoryCacheKey = @"FasterReaderBookBrowseHistoryCacheKey";

/** 每一本小说的章节的缓存目录 */
static NSString *const FasterReaderChaptersCache = @"FasterReaderChaptersCacheName";
/** 某一本小说是否已经缓存的缓存key */
static NSString *const FasterReaderChaptersContentCacheKey = @"FasterReaderChaptersContentCacheKey";





/** 下载的小说的id缓存的目录 */
static NSString *const FasterReaderBookDownload = @"FasterReaderBookDownload";

/** 某本小说已经是否在添缓存列表中的key,这个key的Value是一个数组,保存着已经缓存过章节的小说的bookid,
 封面,书名,作者等信息,现在暂时定为某章节的内容模型(MSYBookCacheModel) */
static NSString *const FasterReaderBookDownloadBookIdKey = @"FasterReaderBookDownloadBookIdKey";

/** 取出今日可下载小说的id的 key */
static NSString *const FasterReaderBookTodayCanDownloadIdKey = @"FasterReaderBookTodayCanDownloadIdKey";

/** 阅读历史 */
static NSString *const bookHistoryCacheName = @"bookHistoryCacheName";//阅读历史


#define IS_IOS8 [[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0
#define IS_IOS6 [[[UIDevice currentDevice] systemVersion] doubleValue] < 7.0
#define IS_IOS9 [[[UIDevice currentDevice] systemVersion] doubleValue] > 9.0
#define IS_IOSMIN10 [[[UIDevice currentDevice] systemVersion] doubleValue] < 10.0
#define IS_IOS10 [[[UIDevice currentDevice] systemVersion] doubleValue] >= 10.0
#define IS_IOS11 [[[UIDevice currentDevice] systemVersion] doubleValue] >= 11.0
#define TABBAR_H  self.tabBarController.tabBar.frame.size.height

#pragma mark - iphone x 导航栏高度
	/// 状态栏高度
#define StatusBarHeight ([[UIApplication sharedApplication] statusBarFrame].size.height)
#define TabBarHeight (StatusBarHeight>20?83:49)

#define NavBarHeight (StatusBarHeight>20?88:64)
	/// 导航栏+状态栏的高度
#define TopHeight (StatusBarHeight + NavBarHeight)
	/// webView 在iPhonex 底部有空隙 加上34 底部就平齐了
#define webViewAddHeight (StatusBarHeight>20?34:0)

/** 自由广告展示开关 */
static NSString *const STRATEGY_FREE_AD_OPEN = @"STRATEGY_FREE_AD_OPEN";
/** 自由广告每天展示次数 */
static NSString *const STRATEGY_FREE_AD_SHOW_TIMES_EVERYDAY = @"STRATEGY_FREE_AD_SHOW_TIMES_EVERYDAY";
/** 自由广告展示间隔(单位:分钟) */
static NSString *const STRATEGY_FREE_AD_SHOW_INTV = @"STRATEGY_FREE_AD_SHOW_INTV";
/** 广告SDK展示开关 */
static NSString *const STRATEGY_AD_OPEN = @"STRATEGY_AD_OPEN";
/** 章节末广告展示间隔 */
static NSString *const STRATEGY_AD_CHAPTER_END_INTV = @"STRATEGY_AD_CHAPTER_END_INTV";
/** 每日激励视频观看总数限制 */
static NSString *const AD_BROWSE_LIMIT = @"AD_BROWSE_LIMIT";
/** 缓存一本书所需的金币 */
static NSString *const EXCHANGE_GOLD_NUM = @"EXCHANGE_GOLD_NUM";
/** 每日分享总数限制 */
static NSString *const SHARE_TIMES_LIMIT = @"SHARE_TIMES_LIMIT";

/** 章节末尾广告SDK展示配置 */
static NSString *const STRATEGY_CHAPTER_END_RATIO = @"STRATEGY_CHAPTER_END_RATIO";
/** 视频任务广告SDK展示配置 */
static NSString *const STRATEGY_VIDEO_RATIO = @"STRATEGY_VIDEO_RATIO";
/** 红包开关 1为开 0为关 */
static NSString *const STRATEGY_RED_PACKET = @"STRATEGY_RED_PACKET";
/** Banner广告开关 */
static NSString *const BANNER_AD_SWITCH = @"BANNER_AD_SWITCH";
/** Banner广告比例（广、穿、百） */
static NSString *const BANNER_AD_RATIO = @"BANNER_AD_RATIO";
/** Banner 广告间隔 */
static NSString *const BANNER_AD_LIMIT = @"BANNER_AD_LIMIT";
/** 获取服务器配置的当用户手动关闭了章节末尾广告,下次重新展示的时间间隔 */
static NSString *const BANNER_AD_LOAD = @"BANNER_AD_LOAD";

/** 开屏广告SDK展示配置 */
static NSString *const STRATEGY_START_RATIO = @"STRATEGY_START_RATIO";
/** app进入后台后,重新进入前台,超过这个时间间隔,就展示广告 */
static NSString *const STRATEGY_START_LOAD = @"STRATEGY_START_LOAD";

/** 联系客服 */
static NSString *const CONTACT_US = @"CONTACT_US";


/** 最后一app进入后台,存本地的时间的key */
static NSString *const LAST_APP_ENTER_BACKGROUND_TIME_KEY = @"LAST_APP_ENTER_BACKGROUND_TIME_KEY";

/** 最后一展示banner广告,存本地的时间key */
static NSString *const LAST_BANNER_AD_SHOW_TIME_KEY = @"LAST_BANNER_AD_SHOW_TIME_KEY";
/** 最后一次用户手动关闭了banner广告,存在本地的时间的key */
static NSString *const LAST_BANNER_USER_CLOSE_TIME_KEY = @"LAST_BANNER_USER_CLOSE_TIME_KEY";

/** 最后一展示章节末广告,存本地的时间的key */
static NSString *const LAST_CHAPTER_AD_SHOW_TIME_KEY = @"LAST_CHAPTER_AD_SHOW_TIME_KEY";

/** 最后一展示章节末激励广告,存本地的时间的key */
static NSString *const LAST_REWARD_AD_SHOW_TIME_KEY = @"LAST_REWARD_AD_SHOW_TIME_KEY";
/** 展示章节末激励广告,今天观看的次数,存本地的时间的key */
static NSString *const LAST_REWARD_AD_SHOW_COUNT_KEY = @"LAST_REWARD_AD_SHOW_COUNT_KEY";


@interface JPTool : NSObject

#pragma mark - 书架

/** 获取服务器时间 */
+ (NSString*)ServerPath;

/** 策略接口 */
+ (NSString*)StrategyPath;

/** 个人资料-设置用户信息 */
+ (NSString*)SetUserInfo;

#pragma mark -书架界面接口

/** 书架-轮播图接口 */
+ (NSString*)BookshelfBannersPath;

/** 书架-每日推荐接口 */
+ (NSString*)BookshelfDayRecommendPath;

/** 首页-书架-浮动广告 */
+ (NSString*)BookshelfFloatAdPath;

/** 书架-搜索关键字 */
+ (NSString*)BookshelfSerachKeyPath;

/** 书架-搜索结果列表 */
+ (NSString*)BookshelfSerachResultPath;

/** 书架-搜索结果列表-书籍详情 */
+ (NSString*)BookshelfBookDetailPath;

/** 书架-获取章节数 */
+ (NSString*)BookshelfBookChapterLtPath;

/** 书架-获取章节内容接口 */
+ (NSString*)BookshelfBookChapterInPath;


#pragma mark - 书城

/** 书城-左侧分类接口 */
+ (NSString*)BookcityCatePath;

/** 书城-每组的数据接口 */
+ (NSString*)BookcityBookDataPath;

/** 书城-热门更新、热门搜索更多列表 数据接口 */
+ (NSString*)BookCityHotUpdateAndSerachMorePath;

/** 分类-右侧分类接口 */
+ (NSString*)BookCategoryPath;

/** 书城-右侧分类接口 */
+ (NSString*)BookcityBookPath;

/** 书城-推荐  */
+ (NSString*)BookcityRecommendPath;

#pragma mark - 我的页面接口

/** 我的-用户信息接口 */
+ (NSString*)UserInPath;

/** 我的-用户登陆注册接口 */
+ (NSString*)LoginRegisterPath;

/** 我的-绑定手机号 */
+ (NSString*)MyMineBindphonePath;

/** 我的-发送短信验证码 */
+ (NSString*)MyMineSendCodePath;

/** 我的-用户反馈 */
+ (NSString*)MyMineFeecbackPath;

/** 我的-任务列表 */
+ (NSString*)MyMineTaskListPath;

/** 我的-任务上报 */
+ (NSString*)MyMineTaskReportPath;


#pragma mark - 提示语

/** 网络不可用，请检查网络 */
+ (NSString*)NoNetWorkAlert;

/** 数据加载失败！ */
+ (NSString*)ErrorOfNetWorkAlert;

/** 您的账号在另一设备上登录，请重新登录 */
+ (NSString*)NoLoginOfAgainLogin;

/** 请先登录!  */
+ (NSString*)NoLoginAlert;


#pragma mark - 屏幕高度 宽高比

/** 屏幕宽度 */
+ (CGFloat)screenWidth;
/** 屏幕高度 */
+ (CGFloat)screenHeight;
/** 获取Window */
+ (UIWindow*)kWindow;
/** 屏幕宽度比例 */
+ (CGFloat)WidthScale;
/** 屏幕高度比例 */
+ (CGFloat)HeightScale;
/** 是不是iPhoneX及以上机型 */
+ (BOOL)is_iPhoneXN;

//+ (CGSize)getSizeWithSpace:(CGFloat)space num:(CGFloat)num proportion:(CGFloat)proportion other:(CGFloat)other;
/** 书城 -- 计算图片的宽高 */
+ (CGSize)getSizeWithOther:(CGFloat)other;

#pragma mark - NSUserDefaults

/** 服务器时间 */
+ (NSString*)APP_ServerTime;
/** 用户邀请码*/
+ (NSString*)UserInvitationCode;
/** 用户id */
+ (NSString*)USER_ID;
/** 用户性别 */
+ (NSNumber*)USER_SEX;
/** 有无会员，如果有会员会显示到期时间戳,没有或者到期显示为0 */
+ (NSString*)USER_EXPIRE;
/** 金币数量 */
+ (NSString*)USER_GOLD;
/** 用户类型 */
+ (NSString*)USER_TYPE;
/** token */
+ (NSString*)USER_TOKEN;
/** 用户昵称 */
+ (NSString*)USER_NAME;
/** 用户真实名字 */
+ (NSString*)USER_TRUENAME;

/** 用户头像 */
+ (NSString*)USER_AVATAR;

/**  获取时间是否和昨天存入的时间相等 */
+ (BOOL)dateEqual;


#pragma mark - -- 阅读顺序相关 --
/** 书架排序类型(默认按阅读顺序) */
+ (void)ChangeBookshelfSortTypeWithType:(BookshelfSortType )type;
+ (BookshelfSortType)BookshelfSortType;

#pragma mark - -- 广告相关 --
/** 广告SDK展示开关 */
+ (NSString*)STRATEGY_AD_OPEN;

/** 开屏广告SDK展示配置 */
+ (NSString*)START_RATIO;

/** 章节广告SDK展示配置 */
+ (NSString*)CHAPTER_END_RATIO;

/** 联系客服 */
+ (NSString*)CONTACT_US;

/** 展示开屏广告 */
+ (NSString*)showAD;

/** 展示章节末尾激励广告 */
+ (BOOL)isShowRewardAd;

/** 展示章节末尾广告 */
+ (NSString*)showChapterAD;

/** 展示底部BannerAD广告 */
+ (NSString*)showBannerAD;


+(void)thirtyMinuteMianAd;
+(BOOL)isThirtyMinuteMianAd;

+(void)changeRewardAdInfo;

@end

NS_ASSUME_NONNULL_END
