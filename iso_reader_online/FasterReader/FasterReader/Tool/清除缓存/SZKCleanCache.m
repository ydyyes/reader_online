	//
	//  SZKCleanCache.m
	//  CleanCache
	//
	//  Created by sunzhaokai on 16/5/11.
	//  Copyright © 2016年 孙赵凯. All rights reserved.
	//

#import "SZKCleanCache.h"

@implementation SZKCleanCache
/**
 *  清理缓存
 */
+(void)cleanCache:(cleanCacheBlock)block {

		//清除本地缓存
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			//文件路径
		NSString *directoryPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];

		NSArray *subpaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:nil];

		for (NSString *subPath in subpaths) {
			NSString *filePath = [directoryPath stringByAppendingPathComponent:subPath];
			[[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
		}
			//返回主线程
		dispatch_async(dispatch_get_main_queue(), ^{
			block();
		});
	});

		//清除cookies
	NSHTTPCookie *cookie;
	NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	for (cookie in [storage cookies]){
		[storage deleteCookie:cookie];
	}
		//清除UIWebView的缓存
	[[NSURLCache sharedURLCache] removeAllCachedResponses];
	NSURLCache * cache = [NSURLCache sharedURLCache];
	[cache removeAllCachedResponses];
	[cache setDiskCapacity:0];
	[cache setMemoryCapacity:0];

}
/**
 *  计算整个目录大小
 */
+(float)folderSizeAtPath {

	NSString *folderPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];

	NSFileManager * manager = [NSFileManager defaultManager ];
	if (![manager fileExistsAtPath :folderPath]) {
		return 0 ;
	}
	NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath :folderPath] objectEnumerator ];
	NSString * fileName;
	long long folderSize = 0 ;
	while ((fileName = [childFilesEnumerator nextObject ]) != nil ){
		NSString * fileAbsolutePath = [folderPath stringByAppendingPathComponent :fileName];
		folderSize += [ self fileSizeAtPath :fileAbsolutePath];
	}

	return folderSize/( 1024.0 * 1024.0 );
}

+ (float)fileSizeWithPath:(NSString*)path {
		//文件路径
	NSString *directoryPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
	NSString *filePath = [directoryPath stringByAppendingPathComponent:path];

	NSFileManager * manager = [NSFileManager defaultManager ];
	if (![manager fileExistsAtPath :filePath]) {
		return 0;
	}
	NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath :filePath] objectEnumerator ];
	NSString * fileName;
	long long folderSize = 0 ;
	while ((fileName = [childFilesEnumerator nextObject ]) != nil ){
        if (![fileName isEqualToString:@"manifest.sqlite-wal"]) {
			NSString * fileAbsolutePath = [filePath stringByAppendingPathComponent :fileName];
			folderSize += [ self fileSizeAtPath :fileAbsolutePath];
        }
	}
	return folderSize/( 1024.0 * 1024.0 );
}
/**
 *  计算单个文件大小
 */
+(long long)fileSizeAtPath:(NSString *)filePath {

	NSFileManager *manager = [NSFileManager defaultManager];

	if ([manager fileExistsAtPath :filePath]){

		return [[manager attributesOfItemAtPath :filePath error : nil ] fileSize];
	}
	return 0 ;

}


+(void)cleanCacheShelf:(cleanCacheBlock)block {

		//清除本地缓存
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			//文件路径
		NSString *directoryPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
		NSString *filePath = [directoryPath stringByAppendingPathComponent:FasterReaderBookInfoCache];
		NSArray *subpaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filePath error:nil];

		for (NSString *subPath in subpaths) {
			NSString *filePath1 = [filePath stringByAppendingPathComponent:subPath];
			[[NSFileManager defaultManager] removeItemAtPath:filePath1 error:nil];
		}
			//返回主线程
		dispatch_async(dispatch_get_main_queue(), ^{
			block();
		});
	});

		//清除cookies
	NSHTTPCookie *cookie;
	NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	for (cookie in [storage cookies]){
		[storage deleteCookie:cookie];
	}
		//清除UIWebView的缓存
	[[NSURLCache sharedURLCache] removeAllCachedResponses];
	NSURLCache * cache = [NSURLCache sharedURLCache];
	[cache removeAllCachedResponses];
	[cache setDiskCapacity:0];
	[cache setMemoryCapacity:0];

}
+(void)cleanCacheReadHistory:(cleanCacheBlock)block {

		//清除本地缓存
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			//文件路径
		NSString *directoryPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
		NSString *filePath = [directoryPath stringByAppendingPathComponent:bookHistoryCacheName];
		NSArray *subpaths  = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filePath error:nil];

		for (NSString *subPath in subpaths) {
			NSString *filePath = [directoryPath stringByAppendingPathComponent:subPath];
			[[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
		}
			//返回主线程
		dispatch_async(dispatch_get_main_queue(), ^{
			block();
		});
	});

		//清除cookies
	NSHTTPCookie *cookie;
	NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	for (cookie in [storage cookies]){
		[storage deleteCookie:cookie];
	}
		//清除UIWebView的缓存
	[[NSURLCache sharedURLCache] removeAllCachedResponses];
	NSURLCache * cache = [NSURLCache sharedURLCache];
	[cache removeAllCachedResponses];
	[cache setDiskCapacity:0];
	[cache setMemoryCapacity:0];

}

+ (BOOL)isExistsWithfile:(NSString*)fileName {

	NSString *cacheFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
	NSString *path = [cacheFolder stringByAppendingPathComponent:fileName];
	NSFileManager *manager = [NSFileManager defaultManager ];
	BOOL exists = [manager fileExistsAtPath:path];
	return exists;
}


@end
