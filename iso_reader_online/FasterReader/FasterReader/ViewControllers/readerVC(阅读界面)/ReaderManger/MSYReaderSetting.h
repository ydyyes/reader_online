//
//  ADReaderSetting.h
//  reader
//
//  Created by beequick on 2017/8/7.
//  Copyright © 2017年 beequick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSString *const ADReaderSettingDidChangeDayMode  = @"ADReaderSettingDidChangeDayMode";


static NSString *const ADMenuSettingTextColor  = @"#282828";

static NSString *const ADMenuSettingFirstThem  = @"#D8D9DA";
static NSString *const ADMenuSettingNightThem  = @"#393E43";
static NSString *const ADMenuSettingThirdThem  = @"#B5B09D";
static NSString *const ADMenuSettingFourthThem = @"#BCE7CB";


static NSString *const ADMenuSettingSelectedThem  = @"#212121";
static NSString *const ADMenuSettingSelectedThem2  = @"#c1c1c1";
static NSString *const ADMenuSettingTextColor2  = @"#767676";

@class ADBookPageModel;

@interface MSYReaderSetting : NSObject

@property (nonatomic, strong)NSDictionary *readerAttributes;
@property (nonatomic, strong)ADBookPageModel *setting;

+ (MSYReaderSetting *)shareInstance;

-(UIColor *)getReaderTextColor;

-(UIColor *)getReaderBackgroundColor;

@end

@interface ADBookPageModel : NSObject <NSCoding>

/// 是否是白天模式
@property (nonatomic, assign) BOOL dayModel;

/// 字体大小
@property (nonatomic, assign) CGFloat fontSize;
//行距
@property (nonatomic, assign) CGFloat lineSpace;
//字体
@property (nonatomic, copy) NSString *fontName;
//字体
@property (nonatomic, strong) UIFont *font;
/// 背景色
@property (nonatomic, strong) NSString *backGroundColor;
/// 夜间模式背景色
@property (nonatomic, strong, readonly) UIColor *nightModeBackGroundColor;
/// 在夜间模式的时候,是否用夜间模式自己的背景色
@property (nonatomic, assign) BOOL isUseNightBackGroundColor;

/// 透明度
@property (nonatomic, assign) CGFloat alphaValue;
//繁体
@property (nonatomic, assign) BOOL unsimplified;

@end
