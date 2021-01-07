//
//  JPNetWork.m
//  OAManagementSystem
//
//  Created by 张俊平 on 2018/9/14.
//  Copyright © 2018年 iOS. All rights reserved.
//

#import "JPNetWork.h"
#import "NSString+AES.h" ///加密解密

@implementation JPNetWork

+ (instancetype)sharedManager {

	static JPNetWork *manager = nil;
	static dispatch_once_t JPonce;
	dispatch_once(&JPonce, ^{

		NSURL *url = [NSURL URLWithString:APPURL_prefix];
		manager = [[self alloc] initWithBaseURL:url];
	});
	return manager;
}

- (instancetype)initWithBaseURL:(NSURL *)url {

	self = [super initWithBaseURL:url];
	if (self) {

		self.requestSerializer.timeoutInterval = 20;// 请求超时设定
		self.requestSerializer.cachePolicy     = NSURLRequestReloadIgnoringLocalCacheData;
		self.responseSerializer                = [AFHTTPResponseSerializer serializer];
//		self.requestSerializer  = [AFJSONRequestSerializer serializer];
//		self.responseSerializer = [AFJSONResponseSerializer serializer]; //申明返回的结果是json类型
		[self.requestSerializer setValue:@"" forHTTPHeaderField:@"imei"];//用户设备的imei， 可能为空
		[self.requestSerializer setValue:@"" forHTTPHeaderField:@"imsi"];
		[self.requestSerializer setValue:[ZJPNetWork getUUID] forHTTPHeaderField:@"uuid"];
		[self.requestSerializer setValue:[ZJPNetWork getAppVersion] forHTTPHeaderField:@"vcode"];//版本号
		[self.requestSerializer setValue:[ZJPNetWork getAppDisplayName] forHTTPHeaderField:@"vname"];//版本名
		[self.requestSerializer setValue:[ZJPNetWork deviceName] forHTTPHeaderField:@"model"];//设备型号 iphone 6
		[self.requestSerializer setValue:[[UIDevice currentDevice] model] forHTTPHeaderField:@"manuFacturer"];//设备制造商
		[self.requestSerializer setValue:[[UIDevice currentDevice] model] forHTTPHeaderField:@"brand"];//设备品牌 iPhone
		//
		NSString *resolution = [NSString stringWithFormat:@"%f×%f",[JPTool screenWidth],[JPTool screenHeight]];
		[self.requestSerializer setValue:resolution forHTTPHeaderField:@"resolution"];//设备的宽x高
		[self.requestSerializer setValue:[[UIDevice currentDevice] systemVersion] forHTTPHeaderField:@"sdk"];//系统版本 12.1
		[self.requestSerializer setValue:@"kdios" forHTTPHeaderField:@"channel"];//渠道号 kdios
		[self.requestSerializer setValue:[ZJPNetWork getNetWorkType] forHTTPHeaderField:@"net"];//网络类型


//		[self.requestSerializer setValue:url.absoluteString forHTTPHeaderField:@"Referer"];

		self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json", @"text/html", nil];

		self.securityPolicy.allowInvalidCertificates = YES;

	}
	return self;
}

#pragma mark - 获取服务器时间
- (void)requestGetServerTimeWithPathUrl:(NSString *)pathUrl Success:(requestSuccessBlock)succed
										  failure:(requestFailureBlock)failure {

	[self GET:pathUrl parameters: nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

		NSData *responseData;
		NSString *string = [[NSString alloc] initWithData:responseObject encoding: NSUTF8StringEncoding];
//		NSLog(@"++++网络成功string:%@", string);
		[[NSUserDefaults standardUserDefaults] setValue:string forKey:@"APPServerTime"];
		[[NSUserDefaults standardUserDefaults] synchronize];

			responseData = responseObject;

		id result = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:NULL];
		succed(result);
	} failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//		NSLog(@"++++网络错误error%@：",error);
		failure(error);
	}];
}
/**
 '0' =>'操作成功',
 '200' =>'操作成功',
 '2001' =>'操作失败',
 '300100' =>'用户唯一标识别为空',
 '300101' =>'请求类型不正确',
 '300102' =>'操作失败请稍后重试',
 '300103' =>'登陆失败',
 '300104' =>'手机号未绑定或者输入有误',
 '300105' => '密码格式错误,只含有数字、字母、下划线,6-15位',
 '300106' => '俩次输入不一致',
 '300107' => '手机号已经被绑定',
 '300108' => 'Token失效或者不存在',
 '300109' => '该用户已经绑定过手机号或者该手机号已经绑定',
 '300110' => '登录设备过多',
 '400100' =>' 参数错误',
 '400101' => '参数不能为空',
 '400102' => '手机号格式不正确',
 '400103' => 'ID必须为正整数',
 '400104' => '数据不存在或者已经下架',
 '400105' => '该栏目不存在或者已经下架',
 '400106' => '没有数据',
 '400108' => '没有找到章节列表',
 '400107' => '已经添加了,不能重复添加',
 '400109' => '内容长度不能超过10或者低于200',
 '400110' => '验证码发送次数超限',
 '400111' => '验证码错误',
 '400112' => '频繁发送验证码',
 '600101' => '订单创建失败',
 '500101' => 'sign不成功'
*
*/
#pragma mark ---------通用接口----------参数加密---------

- (void)requestPostMethodWithPathUrl:(NSString *)pathUrl WithParamsDict:(NSMutableDictionary *)paramsDict WithSuccessBlock:(requestSuccessBlock)success WithFailurBlock:(requestFailureBlock)failure {

	[self requestGetServerTimeWithPathUrl:[JPTool ServerPath] Success:^(id responseObject) {
//		NSString *str = [NSString stringWithFormat:@"%d",arc4random() % 10000];
//		[paramsDict setObject:str forKey:@"action"];
		[paramsDict setObject:[ZJPNetWork getUUID] forKey:@"uuid"];
		[paramsDict setObject:[ZJPNetWork getAppVersion] forKey:@"vcode"];
		[paramsDict setObject:[JPTool APP_ServerTime] forKey:@"requestTime"];

		NSString *paramsSting = [JPNetWork dictToJsonSring:paramsDict];//字典转字符串
//		NSLog(@"参数：%@", paramsSting);
		paramsSting = [paramsSting zjp_encryptWithAES];// 加密
		NSDictionary *parameters = @{@"sign":paramsSting};
//		NSLog(@"参数sign:%@",paramsDict);
		[self POST:pathUrl parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

//			NSString *string = [[NSString alloc] initWithData:responseObject encoding: NSUTF8StringEncoding];
//			NSLog(@"++++ string=%@", string);

			id result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:NULL];
			NSInteger errorNum = [result[@"errorno"] integerValue];
			if ( errorNum > 200 ) {// 请求成功 返回数据

				if (errorNum == 400105 || errorNum == 400104) {
					[ZJPAlert showAlertWithMessage:@"该书籍已经下架" time:2.0];
				}else if (errorNum == 300107){
					[ZJPAlert showAlertWithMessage:@"该手机号已经被绑定，请直接登录或更换手机号" time:2.0];
				}else if (errorNum == 300109){
					[ZJPAlert showAlertWithMessage:@"该用户已经绑定过手机号或者该手机号已经绑定" time:2.0];
				}else if (errorNum == 300112){
					[ZJPAlert showAlertWithMessage:@"该账号不存在" time:2.0];
				}else if (errorNum == 300108){
//					[ZJPAlert showAlertWithMessage:@"Token失效或者不存在" time:2.0];
				}else if (errorNum == 500101){
					[ZJPAlert showAlertWithMessage:@"系统出现异常，请稍后再试" time:2.0];
				}else if (errorNum == 400113){
					[ZJPAlert showAlertWithMessage:@"分享次数已达上限" time:2.0];
				}else if (errorNum == 400103){
					[ZJPAlert showAlertWithMessage:@"验证码错误" time:2.0];
					NSLog(@"\n error num : %@ --- msg:%@",result[@"errorno"],result[@"msg"]);
				}
				else{
					[ZJPAlert showAlertWithMessage:result[@"msg"] time:2.0];
				}
				
			}else{// 请求成功 返回❌信息
				NSLog(@"\n error num : %@ --- msg:%@",result[@"errorno"],result[@"msg"]);
			}

			NSString *decodeString = [result[@"data"] zjp_decryptWithAES];//解码
//			NSLog(@"%@",decodeString);
			id resultDict = [JPNetWork dictionaryWithJsonString:decodeString];// 转化为字典

			NSMutableDictionary *responseDict = [NSMutableDictionary dictionary];
			[responseDict setValue:resultDict forKey:@"data"];
			[responseDict setValue:result[@"errorno"] forKey:@"errorno"];
			[responseDict setValue:result[@"msg"] forKey:@"msg"];

//			NSLog(@"++++ JSON: %@", result);
			success(responseDict);

		} failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
			failure(error);
		}];

	} failure:^(NSError *error) {
		failure(error);
	}];


}

#pragma mark -获取小说章节内容
- (void)requestGetContentWithPathUrl:(NSString *)pathUrl Success:(requestSuccessBlock)succed
										  failure:(requestFailureBlock)failure {

	[self GET:pathUrl parameters: nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

		NSData *responseData;
		NSString *string = [[NSString alloc] initWithData:responseObject encoding: NSUTF8StringEncoding];
//		NSLog(@"++++网络成功string:%@", string);

		responseData = responseObject;

//		id result = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:NULL];
		succed(string);

	} failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
		NSLog(@"++++网络错误error%@：",error);
		failure(error);
	}];
}


#pragma mark -	上传头像
/** 上传头像 */
- (void)requestPostUploadImageWithImageData:(NSData *)imageData Success:(requestSuccessBlock)succed failure:(requestFailureBlock)failure {

	NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc]init];
	NSString *str = [NSString stringWithFormat:@"%d",arc4random() % 10000];
	[paramsDict setObject:str forKey:@"action"];
	[paramsDict setObject:[ZJPNetWork getUUID] forKey:@"uuid"];
	[paramsDict setObject:[ZJPNetWork getAppVersion] forKey:@"vcode"];
	[paramsDict setObject:[JPTool USER_TOKEN] forKey:@"token"];

	[self requestGetServerTimeWithPathUrl:[JPTool ServerPath] Success:^(id responseObject) {

		[paramsDict setObject:[JPTool APP_ServerTime] forKey:@"requestTime"];
		NSString *paramsSting = [JPNetWork dictToJsonSring:paramsDict];//字典转字符串
		paramsSting = [paramsSting zjp_encryptWithAES];// 加密
		 //NSLog(@"参数：%@", paramsSting);
		NSDictionary *parameters = @{@"sign":paramsSting};
		NSLog(@"参数sign:%@",paramsDict);
		NSString *pathUrl = [JPTool SetUserInfo];// 请求网址

		[self POST:pathUrl parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {

			[formData appendPartWithFileData:imageData name:@"portrait" fileName:@"portrait.jpg" mimeType:@"png/jpg"];

		} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

			id result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:NULL];

			NSInteger errorNum = [result[@"errorno"] integerValue];
			if (errorNum == 500101){
				[ZJPAlert showAlertWithMessage:@"系统出现异常，请稍后再试" time:2.0];
			}

			NSString *decodeString = [result[@"data"] zjp_decryptWithAES];//解码
			id resultDict = [JPNetWork dictionaryWithJsonString:decodeString];// 转化为字典
			NSMutableDictionary *responseDict = [NSMutableDictionary dictionary];
			[responseDict setValue:resultDict forKey:@"data"];
			[responseDict setValue:result[@"errorno"] forKey:@"errorno"];
			[responseDict setValue:result[@"msg"] forKey:@"msg"];

			NSLog(@"++++ JSON: %@", result);
			succed(responseDict);

		} failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
			failure(error);
		}];

	} failure:^(NSError *error) {
		failure(error);
	}];
}


#pragma mark -	上传用户信息 昵称 性别
- (void)requestPostUploadInfoWithParamsDict:(NSMutableDictionary*)paramsDict Success:(requestSuccessBlock)succed failure:(requestFailureBlock)failure {

	NSString *str = [NSString stringWithFormat:@"%d",arc4random() % 10000];
	[paramsDict setObject:str forKey:@"action"];
	[paramsDict setObject:[ZJPNetWork getUUID] forKey:@"uuid"];
	[paramsDict setObject:[ZJPNetWork getAppVersion] forKey:@"vcode"];
	[paramsDict setObject:[JPTool USER_TOKEN] forKey:@"token"];

	[self requestGetServerTimeWithPathUrl:[JPTool ServerPath] Success:^(id responseObject) {

		[paramsDict setObject:[JPTool APP_ServerTime] forKey:@"requestTime"];
		NSString *paramsSting = [JPNetWork dictToJsonSring:paramsDict];//字典转字符串
		paramsSting = [paramsSting zjp_encryptWithAES];// 加密
																	  //NSLog(@"参数：%@", paramsSting);
		NSDictionary *parameters = @{@"sign":paramsSting};
		NSLog(@"参数sign:%@",paramsDict);
		NSString *pathUrl = [JPTool SetUserInfo];// 请求网址

		[self POST:pathUrl parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

			id result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:NULL];

			NSInteger errorNum = [result[@"errorno"] integerValue];
			if (errorNum == 500101){
				[ZJPAlert showAlertWithMessage:@"系统出现异常，请稍后再试" time:2.0];
			}

			NSString *decodeString = [result[@"data"] zjp_decryptWithAES];//解码
			id resultDict = [JPNetWork dictionaryWithJsonString:decodeString];// 转化为字典
			NSMutableDictionary *responseDict = [NSMutableDictionary dictionary];
			[responseDict setValue:resultDict forKey:@"data"];
			[responseDict setValue:result[@"errorno"] forKey:@"errorno"];
			[responseDict setValue:result[@"msg"] forKey:@"msg"];

//			NSLog(@"++++ JSON: %@", result);
			succed(responseDict);

		} failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
			failure(error);
		}];

	} failure:^(NSError *error) {
		failure(error);
	}];
}

#pragma mark - - 字典转字符串
+ (NSString *)dictToJsonSring:(NSDictionary *)dict {

	NSError *error;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
	NSString *jsonString;
	if (!jsonData) {
		NSLog(@"%@",error);
	} else {
		jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
	}

	NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
	NSRange range = {0,jsonString.length};

		//去掉字符串中的空格
	[mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
	NSRange range2 = {0,mutStr.length};

		//去掉字符串中的换行符
	[mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];

	return mutStr;
}
#pragma mark -  JSON字符串转化为字典
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
	if (jsonString == nil) {
		return nil;
	}

	NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
	NSError *err;
	NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
																		 options:NSJSONReadingMutableContainers
																			error:&err];
	if(err){
		NSLog(@"json解析失败：%@",err);
		return nil;

	}
	return dic;
}

@end
