//
//  UIColor+Hex.h
//  lian
//
//  Created by Fire on 15-9-7.
//  Copyright (c) 2015年 DuoLaiDian. All rights reserved.
//

#import <UIKit/UIKit.h>

#define RGBA_COLOR(R, G, B, A) [UIColor colorWithRed:((R) / 255.0f) green:((G) / 255.0f) blue:((B) / 255.0f) alpha:A]
#define RGB_COLOR(R, G, B) [UIColor colorWithRed:((R) / 255.0f) green:((G) / 255.0f) blue:((B) / 255.0f) alpha:1.0f]

@interface UIColor (Hex)

/** 主体蓝色 2F94F9 */
+ (UIColor *)mainBlue_2F94F9; 

/** 按钮普通状态 蓝色 2f94f9 */
+ (UIColor *)buttonNor;

/** 按钮高亮状态 蓝色 85b8fb */
+ (UIColor *)buttonHigh;

/** 浅灰色 F2F2F2 */
+ (UIColor *)lightGray_F2F2F2;

/** 浅灰色 F0F0F0 */
+ (UIColor *)lightGray_F0F0F0;

/** 浅黑色 222222 */
+ (UIColor *)black_222222;





/** 浅灰色 999999 */
+ (UIColor *)lightGary_999999;

/** 灰色 666666 */
+ (UIColor *)lightGray_666666;

/** 浅黑色 333333 */
+ (UIColor *)black_333333;

/** 浅灰色 cccccc */
+ (UIColor *)lightGray_cccccc;

/** 浅灰色分割线 dddddd */
+ (UIColor *)lightGrayLineColor_dddddd;

/** 浅灰色 e5e5e5 */
+ (UIColor *)lightGray_e5e5e5;

/** 浅灰色 b2b2b2 */
+ (UIColor *)lightGray_b2b2b2;

/** 蓝色 00a2e0 */
+ (UIColor *)blue_00a2e0;

/** 浅灰色 d5d8dc */
+ (UIColor *)lightGray_d5d8dc;

/** 浅灰色 a8a8a8 */
+ (UIColor *)lightGray_a8a8a8;

/** 消息红色 ff4141 */
+ (UIColor *)red_ff4141;

/** 浅灰色 eeeeee */
+ (UIColor *)lightGray_eeeeee;


/** 从十六进制字符串获取颜色 */
+ (UIColor *)colorWithHexString:(NSString *)color;

/** color:支持@“#123456”、 @“0X123456”、 @“123456”三种格式 */
+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;

@end
