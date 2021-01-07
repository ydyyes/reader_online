//
//  SZKCleanCache.h
//  CleanCache
//
//  Created by sunzhaokai on 16/5/11.
//  Copyright © 2016年 孙赵凯. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^cleanCacheBlock)(void);


@interface SZKCleanCache : NSObject


/** 清理缓存 */
+(void)cleanCache:(cleanCacheBlock)block;

/** 整个缓存目录的大小 */
+(float)folderSizeAtPath;

/** 清理App缓存 */
+ (float)fileSizeWithPath:(NSString*)path;

/** 清理书架缓存 */
+(void)cleanCacheShelf:(cleanCacheBlock)block;

/** 清理阅读记录缓存 */
+(void)cleanCacheReadHistory:(cleanCacheBlock)block;

/** 判读文件是否存在 */
+ (BOOL)isExistsWithfile:(NSString*)fileName;

@end
