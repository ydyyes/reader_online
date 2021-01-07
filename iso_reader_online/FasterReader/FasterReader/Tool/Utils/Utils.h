//
//  Utils.h
//  SK
//
//  Created by luke on 10-10-22.
//  Copyright 2010 pica.com. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <QuartzCore/QuartzCore.h>
#import "FileMgr.h"
@class User;
@interface Utils : NSObject {
	
}

+ (BOOL)isPureInt:(NSString*)string;
+ (BOOL)isRunningOniPad:(NSString *)osVer;
+ (NSString *)calcCreateTime:(NSString *)cTime;
+ (void)downLoadImageWithUrl:(NSString*)aUrl
                        path:(NSString*)aPath
                      target:(id)aDelegate
              FinishedAction:(SEL)aCBSuccess
                FailedAction:(SEL)aCBFailed;

+ (NSString*)getNowTime;
+ (NSString*)URLencode:(NSString *)originalString
        stringEncoding:(NSStringEncoding)stringEncoding ;

///计算文字长度
+ (int)convertToInt:(NSString*)strtemp;
+ (UIImage*)getImageFromView:(UIView *)view;
+ (BOOL)deleteImageName:(NSString*)fileName;
+ (BOOL)saveImageName:(NSString*)fileName image:(UIImage*)anImage;
+ (NSString*)getImagePathByName:(NSString*)fileName type:(int)aType;
+ (BOOL)checkImageExist:(NSString*)imageName type:(int)aType;
+ (UIImage*)croppingImageWithSize:(UIImage*)image targetSize:(CGSize)size;
+ (BOOL)isbreakformapp;
+ (NSString *)calcOverTime:(NSString *)overTime;
+ (NSString *)cutString:(NSString *)string utilFitWidth:(float)width;
///判定用户昵称是否格式化
+ (BOOL)parseUserName:(NSString *)string;

///提交微信加密参数
+ (NSString*)resultWXES_signatureClientid:(NSString*)clientid;
+ (NSString*)resultClientId;
/// 获取ip地址 
+ (NSString *)getIPAddress:(BOOL)preferIPv4;
+ (NSDictionary *)getIPAddresses;
+ (NSString *)localIPAddress;

/**
 *  判断字符串中是否存在emoji
 * @param string 字符串
 * @return YES(含有表情)
 */
+ (BOOL)stringContainsEmoji:(NSString *)string;

/**
 *  判断字符串中是否存在emoji
 * @param string 字符串
 * @return YES(含有表情)
 */
+ (BOOL)hasEmoji:(NSString*)string;

/**
 判断是不是九宫格
 @param string  输入的字符
 @return YES(是九宫格拼音键盘)
 */
+ (BOOL)isNineKeyBoard:(NSString *)string;

/// -----过滤字符串中的emoji
+ (NSString *)disable_emoji:(NSString *)text;

/// 去除导航栏底部的线
+ (UIImageView*)findHairlineImageViewUnder:(UIView*)view;

/// 裁剪图片(按屏幕比例) 设置图片的属性
+ (void)cutImage:(UIImageView *)aImage;


@end

///揽潮数据存储与读取
extern NSString* md5Digest(NSString* str);




