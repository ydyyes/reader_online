//
//  CalculateLabels.h
//  TestProject
//
//  Created by iOS开发T002 on 2017/9/20.
//  Copyright © 2017年 ZHANGJUNPING. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalculateLabels : UIView


#pragma mark - 根据内容计算Label的宽度 不带行间距
/**
 根据内容计算Label的宽度 不带行间距
 
 @param string Label的字
 @param height Label的高度
 @param fontSize Label的字体大小
 @return 返回Label的高度
 */

+ (CGFloat)calculateLabelWidth:(NSString*)string height:(CGFloat)height fontOfSize:(CGFloat)fontSize;

#pragma mark - 根据内容计算Label的高度 不带行间距
/**
 根据内容计算Label的高度 不带行间距

 @param string Label的字
 @param width Label的宽度
 @param fontSize Label的字体大小
 @return 返回Label的高度
 */
+ (CGFloat)calculateLabelHeight:(NSString*)string width:(CGFloat)width fontOfSize:(CGFloat)fontSize;


#pragma mark - 根据内容动态计算Label的高度 包括行间距 Label不能加高度的约束
/**
 根据内容动态计算Label的高度 包括行间距 Label不能加高度的约束
 
 @param label 需要计算的Label
 @param width Label的宽度
 @param lineSpace 间距
 @param string Label的字
 @param fontSize Label的字体大小
 @return 返回Label的高度
 */
+ (CGFloat)calculateLabelHeight:(UILabel*)label width:(CGFloat)width lineSpace:(CGFloat)lineSpace string:(NSString*)string fontOfSize:(CGFloat)fontSize;

#pragma mark - 设置Label的行间距
/**
 设置Label的行间距
 
 @param string 需要设置的Label的字
 @param lineSpace 行间距
 @return 返回设置的属性
 */
+ (NSAttributedString *)getAttributedStringWithString:(NSString *)string lineSpace:(CGFloat)lineSpace;

#pragma mark - 计算行高Size(包括行间距)
/**
 计算行高Size(包括行间距)

 @param str 需要计算的内容
 @param fontOfSize 字体大小
 @param lineSpacing 行间距
 @param width 计算的宽度
 @param height 计算的高度
 @return 返回计算的CGSize
 */
+ (CGSize)getStringSize:(NSString*)str fontOfSize:(CGFloat)fontOfSize lineSpacing:(CGFloat)lineSpacing width:(CGFloat)width height:(CGFloat)height;



/**
 计数label显示的行数

 @param width 计算的宽度
 @param string 需要计算的内容
 @param fontSize 字体大小
 @return 返回行数
 */
+ (CGFloat)calculateLabelLinesWithWidth:(CGFloat)width String:(NSString*)string FontOfSize:(CGFloat)fontSize;



/**
 计算label显示的Size

 @param text label显示的文字
 @param font 字体大小
 @return 返回计算的Size
 */
+ (CGSize)calculateLabelSizeWithText:(NSString *)text font:(NSInteger)font;


@end
