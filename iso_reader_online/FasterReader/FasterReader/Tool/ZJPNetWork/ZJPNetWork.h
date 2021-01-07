//
//  ZJPNetWork.h
//  NightReader
//
//  Created by 张俊平 on 2019/2/20.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZJPNetWork : NSObject

#pragma mark - 判断是否有网
/** 判断是否有网 */
+(BOOL)netWorkAvailable;

#pragma mark - 获取网路类型
/** 获取网路类型 */
+ (NSString *)getNetWorkType;

#pragma mark - 获取UUID idfv+keychain
/** 获取UUID idfv+keychain */
+(NSString *)getUUID;

#pragma mark - 获取设备名称
/** 设备名称 如iPhone5 */
+ (NSString*)deviceName;

#pragma mark -  获取当前App的名称信息
+ (NSString *)getAppDisplayName;

#pragma mark - 获取当前App的版本号
+ (NSString *)getAppVersion;

#pragma mark - 获取当前App的build版本号
+ (NSString *)getAppBuild;

#pragma mark - 获取当前App的包名信息
+ (NSString *)getAppBundleId;

@end

NS_ASSUME_NONNULL_END
