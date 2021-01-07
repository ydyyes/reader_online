//
//  JPNetWork.h
//  OAManagementSystem
//
//  Created by 张俊平 on 2018/9/14.
//  Copyright © 2018年 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

/** 请求成功回调block */
typedef void (^requestSuccessBlock)(id responseObject);

/** 请求失败回调block */
typedef void (^requestFailureBlock)(NSError *error);

@interface JPNetWork : AFHTTPSessionManager

+ (instancetype)sharedManager;

#pragma mark - 获取服务器时间
/** 获取服务器时间 */
- (void)requestGetServerTimeWithPathUrl:(NSString *)pathUrl Success:(requestSuccessBlock)succed
										  failure:(requestFailureBlock)failure;

#pragma mark - --------小说 通用接口----------参数加密---------

/**
 小说 通用接口 加密

 @param pathUrl <#pathUrl description#>
 @param paramsDict <#paramsDict description#>
 @param success <#success description#>
 @param failure <#failure description#>
 */
- (void)requestPostMethodWithPathUrl:(NSString *)pathUrl WithParamsDict:(NSMutableDictionary *)paramsDict WithSuccessBlock:(requestSuccessBlock)success WithFailurBlock:(requestFailureBlock)failure;

/**
 获取小说内容

 @return 返回小说内容
 */
#pragma mark - 获取小说章节内容
- (void)requestGetContentWithPathUrl:(NSString *)pathUrl
									  Success:(requestSuccessBlock)succed
									  failure:(requestFailureBlock)failure;

#pragma mark -	上传头像
/** 上传头像 */
- (void)requestPostUploadImageWithImageData:(NSData *)imageData Success:(requestSuccessBlock)succed failure:(requestFailureBlock)failure;

#pragma mark -	上传用户信息 昵称 性别
/** 上传用户信息 昵称 性别 */
- (void)requestPostUploadInfoWithParamsDict:(NSMutableDictionary*)paramsDict Success:(requestSuccessBlock)succed failure:(requestFailureBlock)failure;

#pragma mark -  JSON字符串转化为字典
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

@end
