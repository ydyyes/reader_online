	//
	//  ZJPNetWork.m
	//  NightReader
	//
	//  Created by 张俊平 on 2019/2/20.
	//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
	//

#import "ZJPNetWork.h"
#import "Reachability.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>  //为判断网络制式的主要文件
#import <CoreTelephony/CTCarrier.h> //添加获取客户端运营商 支持

#define  KEY_USERNAME_PASSWORD  @"com.company.app.usernamepassword"
#define  KEY_USERNAME           @"com.company.app.username"
#define  KEY_PASSWORD           @"com.company.app.password"

#import "sys/utsname.h"

@implementation ZJPNetWork

#pragma mark - 判断是否有网
+(BOOL)netWorkAvailable{
	if(![[Reachability reachabilityForInternetConnection] isReachableViaWWAN] && ![[Reachability reachabilityForInternetConnection] isReachableViaWiFi]) {
		return NO;

	}
	else {
		return YES;
	}
}

#pragma mark - 获取网络类型
+ (NSString *)getNetWorkType{

	NSString *netWorkType = @"";

	Reachability *reach = [Reachability reachabilityWithHostName:@"www.apple.com"];

	switch ([reach currentReachabilityStatus]) {
		case NotReachable:// 没有网络
		 {
		netWorkType = @"no network";
		 }
			break;

		case ReachableViaWiFi:// Wifi
		 {
		netWorkType = @"Wifi";
		 }
			break;

		case ReachableViaWWAN:// 手机自带网络
		 {
			// 获取手机网络类型
		CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];

		NSString *currentStatus = info.currentRadioAccessTechnology;

		if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyGPRS"]) {

			netWorkType = @"GPRS";
		}else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyEdge"]) {

			netWorkType = @"2.75G EDGE";
		}else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyWCDMA"]){

			netWorkType = @"3G";
		}else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSDPA"]){

			netWorkType = @"3.5G HSDPA";
		}else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSUPA"]){

			netWorkType = @"3.5G HSUPA";
		}else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMA1x"]){

			netWorkType = @"2G";
		}else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORev0"]){

			netWorkType = @"3G";
		}else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevA"]){

			netWorkType = @"3G";
		}else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevB"]){

			netWorkType = @"3G";
		}else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyeHRPD"]){

			netWorkType = @"HRPD";
		}else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyLTE"]){

			netWorkType = @"4G";
		}
		 }
			break;

		default:
			break;
	}

	return netWorkType;
}

#pragma mark -  获取UUID 
+(NSString *)getUUID
{
	NSString * strUUID = (NSString *)[ZJPNetWork load:@"com.company.app.usernamepassword"];
    //首次执行该方法时，uuid为空
	if ([strUUID isEqualToString:@""] || !strUUID)
    {
        //生成一个uuid的方法
		strUUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];//idfv+keychain
        //将该uuid保存到keychain
		[ZJPNetWork save:KEY_USERNAME_PASSWORD data:strUUID];
    }
	return strUUID;
}

+ (void)save:(NSString *)service data:(id)data
{
    //Get search dictionary
	NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Delete old item before add new item
	SecItemDelete((CFDictionaryRef)keychainQuery);
    //Add new object to search dictionary(Attention:the data format)
	[keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(id)kSecValueData];
    //Add item to keychain with the search dictionary
	SecItemAdd((CFDictionaryRef)keychainQuery, NULL);
}

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service
{
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (id)kSecClassGenericPassword,(id)kSecClass,
            service, (id)kSecAttrService,
            service, (id)kSecAttrAccount,
            (id)kSecAttrAccessibleAfterFirstUnlock,(id)kSecAttrAccessible,
            nil];
}

+ (id)load:(NSString *)service {
	id ret = nil;
	NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Configure the search setting
    //Since in our simple case we are expecting only a single attribute to be returned (the password) we can set the attribute kSecReturnData to kCFBooleanTrue
	[keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
	[keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
	CFDataRef keyData = NULL;
	if (SecItemCopyMatching((CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
		@try {
			ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
		} @catch (NSException *e) {
			NSLog(@"Unarchive of %@ failed: %@", service, e);
		} @finally {
		}
	}
	if (keyData)
		CFRelease(keyData);
	return ret;
}

+ (void)deleteKeyData:(NSString *)service {
	NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
	SecItemDelete((CFDictionaryRef)keychainQuery);
}

#pragma mark - 设备型号名称 如iPhone 5
+ (NSString*)deviceName {
    // 需要#import "sys/utsname.h"
	struct utsname systemInfo;
	uname(&systemInfo);
	NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];

		//iPhone
	if ([deviceString isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
	if ([deviceString isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
	if ([deviceString isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
	if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
	if ([deviceString isEqualToString:@"iPhone3,2"])    return @"Verizon iPhone 4";
	if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
	if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
	if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
	if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5C";
	if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5C";
	if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5S";
	if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5S";
	if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
	if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
	if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
	if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
	if ([deviceString  isEqualToString:@"iPhone8,4"])   return @"iPhone SE";
	if ([deviceString  isEqualToString:@"iPhone9,1"]) 	 return @"iPhone 7";
	if ([deviceString  isEqualToString:@"iPhone9,2"])   return @"iPhone 7 Plus";
	if ([deviceString  isEqualToString:@"iPhone10,1"])  return @"iPhone 8";
	if ([deviceString  isEqualToString:@"iPhone10,4"])  return @"iPhone 8";
	if ([deviceString  isEqualToString:@"iPhone10,2"])	 return @"iPhone 8 Plus";
	if ([deviceString  isEqualToString:@"iPhone10,5"])  return @"iPhone 8 Plus";
	if ([deviceString  isEqualToString:@"iPhone10,3"])  return @"iPhone X";
	if ([deviceString  isEqualToString:@"iPhone10,6"])  return @"iPhone X";
	if ([deviceString  isEqualToString:@"iPhone11,8"])  return @"iPhone XR";
	if ([deviceString  isEqualToString:@"iPhone11,2"])  return @"iPhone XS";
	if ([deviceString  isEqualToString:@"iPhone11,4"])  return @"iPhone XS Max";
	if ([deviceString  isEqualToString:@"iPhone11,6"])  return @"iPhone XS Max";

		//iPod
	if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
	if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
	if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
	if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
	if ([deviceString isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";

		//iPad
	if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
	if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
	if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
	if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
	if ([deviceString isEqualToString:@"iPad2,4"])      return @"iPad 2 (32nm)";
	if ([deviceString isEqualToString:@"iPad2,5"])      return @"iPad mini (WiFi)";
	if ([deviceString isEqualToString:@"iPad2,6"])      return @"iPad mini (GSM)";
	if ([deviceString isEqualToString:@"iPad2,7"])      return @"iPad mini (CDMA)";

	if ([deviceString isEqualToString:@"iPad3,1"])      return @"iPad 3(WiFi)";
	if ([deviceString isEqualToString:@"iPad3,2"])      return @"iPad 3(CDMA)";
	if ([deviceString isEqualToString:@"iPad3,3"])      return @"iPad 3(4G)";
	if ([deviceString isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
	if ([deviceString isEqualToString:@"iPad3,5"])      return @"iPad 4 (4G)";
	if ([deviceString isEqualToString:@"iPad3,6"])      return @"iPad 4 (CDMA)";

	if ([deviceString isEqualToString:@"iPad4,1"])      return @"iPad Air";
	if ([deviceString isEqualToString:@"iPad4,2"])      return @"iPad Air";
	if ([deviceString isEqualToString:@"iPad4,3"])      return @"iPad Air";
	if ([deviceString isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
	if ([deviceString isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
	if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
	if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";

	if ([deviceString isEqualToString:@"iPad4,4"]
		 ||[deviceString isEqualToString:@"iPad4,5"]
		 ||[deviceString isEqualToString:@"iPad4,6"])    return @"iPad mini 2";

	if ([deviceString isEqualToString:@"iPad4,7"]
		 ||[deviceString isEqualToString:@"iPad4,8"]
		 ||[deviceString isEqualToString:@"iPad4,9"])    return @"iPad mini 3";

	return deviceString;
}


#pragma mark -  获取当前App的名称信息
+ (NSString *)getAppDisplayName {
	NSBundle *currentBundle = [NSBundle mainBundle];
	NSDictionary *infoDictionary = [currentBundle infoDictionary];
	return [infoDictionary objectForKey:@"CFBundleDisplayName"];
}

#pragma mark - 获取当前App的版本号
+ (NSString *)getAppVersion
{
	NSBundle *currentBundle = [NSBundle mainBundle];
	NSDictionary *infoDictionary = [currentBundle infoDictionary];
	return [infoDictionary objectForKey:@"CFBundleShortVersionString"];
}

#pragma mark - 获取当前App的build版本号
+ (NSString *)getAppBuild
{
	NSBundle *currentBundle = [NSBundle mainBundle];
	NSDictionary *infoDictionary = [currentBundle infoDictionary];
	return [infoDictionary objectForKey:@"CFBundleVersion"];
}

#pragma mark - 获取当前App的包名信息
+ (NSString *)getAppBundleId
{
	NSBundle *currentBundle = [NSBundle mainBundle];
	NSDictionary *infoDictionary = [currentBundle infoDictionary];
	return [infoDictionary objectForKey:@"CFBundleIdentifier"];
}



@end
