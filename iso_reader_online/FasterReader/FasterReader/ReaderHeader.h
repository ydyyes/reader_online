//
//  ReaderHeader.h
//  NightReader
//
//  Created by 张俊平 on 2019/2/20.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#ifndef ReaderHeader_h
#define ReaderHeader_h

#import "Utils.h"
#import "CalculateLabels.h"
#import "UIColor+Hex.h"
#import "UIViewExt.h"
#import "UIButton+SSEdgeInsets.h"
#import "UIScrollView+UITouch.h"
#import "UIBarButtonItem+SXCreate.h"
#import "UINavigationBar+Awesome.h"
	//#import "NSObject+SXRuntime.h"
	//#import "UIBarButtonItem+SXCreate.h"
	//#import "UINavigation+SXFixSpace.h"

#import <YYWebImage/YYWebImage.h>
#import "ZJPAlert.h"
#import "JPLoadingView.h"
#import "UIImage+Tools.h"

#import "SureCanceAlert.h"

#import "BaseTableView.h"

#import "ZZCameraController.h"
#import "ZZPhoto.h"
#import "ZZPhotoListModel.h"
#import "ZZCamera.h"

#import "ZJPNetWork.h" //判断网络
#import "JPNetWork.h" //网络请求 

#import "MJRefreshStateHeader.h"
#import "MJRefreshNormalHeader.h"
#import "MJRefreshHeader.h"

#import "MJRefreshAutoNormalFooter.h"
#import "MJRefreshFooter.h"

#import "SZKCleanCache.h"
#import <YYCategories/YYCategories.h>
#import "YYCategories.h"
#import "NSObject+YYModel.h" 
#import "SVProgressHUD.h"


#import "UIButton+SSEdgeInsets.h"

#import "JPTool.h"

static NSString *const cacheReadSetting = @"readSetting";
static NSString *const aSystemFontName = @"STHeitiSC-Light";

#define WeakSelf __weak typeof(self) weakSelf = self;
#define StrongSelf typeof(weakSelf) __strong strongSelf = weakSelf;

#define UIScreen_SetLightValue ([[NSUserDefaults standardUserDefaults] setFloat:[UIScreen mainScreen].brightness forKey:@"ADUserLightValue"])

/*********************  宏定义 ***************************/
#pragma mark - 宏定义

#define isIPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? [[UIScreen mainScreen] currentMode].size.height>=2436 : NO)
/** 导航栏高度 */
#define  ADNavBarHeight  (isIPhoneX ? 88.0 : 64.0)
/** 底部Tabbar 高度  */
#define ADTabBarHeight  isIPhoneX ? 83.0 : 49.0
/** 底部Tabbar在iPhoneX上增加高度 */
#define ADTabBarHeight_Add  isIPhoneX ? 34.0 : 0.0
/** 状态栏高度  */
#define ADStatusBarHeight  isIPhoneX ? 44.0 : 20.0

/// 阅读
#define kYReaderLeftSpace 15.0
#define kYReaderRightSpace 15.0
#define kYReaderTopSpace  StatusBarHeight
#define kYReaderBottomSpace 30.0
/// 阅读页下边的广告高度
#define kReaderBannerAdHeight 55.0


//美阅小说ios


/******************** 接口 ****************************/

#pragma mark - 接口

//线下  http://online_rd.enjoynut.cn


// 线上
#define APPURL_prefix  @"http://drapi.17k.ren/"

// 测试接口 本地电脑
//#define APPURL_prefix  @"http://172.16.2.160:9000/"

// 线上：测试接口
//#define APPURL_prefix  @"http://book.shuyumsy.com/"


/** 去除警告  */
#pragma clang diagnostic ignored "-Wimplicit-retain-self"

#endif /* ReaderHeader_h */
