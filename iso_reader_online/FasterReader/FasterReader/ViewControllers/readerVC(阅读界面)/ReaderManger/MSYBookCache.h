//
//  MSYBookCache.h
//  FasterReader
//
//  Created by apple on 2019/7/7.
//  Copyright © 2019 Restver. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYCache/YYCache.h>

NS_ASSUME_NONNULL_BEGIN

@class MSYBookCacheModel;

/**  设置小说的下载状态 没有下载0 下载中1 下载暂停2 下载完成3  */
typedef NS_ENUM(NSUInteger, MSYBookDownloadStatus) {
    MSYBookNotDownload = 0,
    MSYBookDownloaing = 1,
    MSYBookSuspendDownload = 2,
    MSYBookSuccessDownloaded = 3,
};

@interface MSYBookCache : NSObject

+ (instancetype)share;

//MARK: -根据bookcacheModel把从这本书添加到下载列表中
- (void)cachedBookWithCacheModel:(MSYBookCacheModel *)model;

//MARK: -根据bookId从下载列表中删除这本书
- (void)removeBookCacheWithBookId:(NSString *)bookid;

/// 获取所有缓存的小说的信息
+ (NSArray <MSYBookCacheModel *>*)getAllBookCacheArray;


/** 设置今日可下载小说的ID */
- (void)setTodayCanDownloaBookWithBookid:(NSString*)bookid;

/// 根据小说的ID判断它是否在今天可下载的小说范围内
- (BOOL)isCanDownloadBookWithBookid:(NSString*)bookid;

/// 设置小说的下载状态 没有下载0 下载中1 下载暂停2 下载完成3
+ (void)setDownloadState:(MSYBookDownloadStatus)state bookid:(NSString*)bookid;

/// 获取小说的下载状态
+ (MSYBookDownloadStatus)getDownloadStateWithBookid:(NSString*)bookid;


@end

NS_ASSUME_NONNULL_END
