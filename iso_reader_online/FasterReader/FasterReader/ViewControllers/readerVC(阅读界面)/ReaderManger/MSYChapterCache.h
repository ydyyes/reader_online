//
//  MSYChapterCache.h
//  NightReader
//
//  Created by Restver on 2019/3/16.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYCache/YYCache.h>

#import "ADChapterModel.h"
#import "ADChapterContentModel.h"


NS_ASSUME_NONNULL_BEGIN

/** 章节内容缓存 */
@interface MSYChapterCache : NSObject

+ (instancetype)share;

@property (nonatomic, strong) YYCache *cache;


#pragma mark -章节缓存相关

/// 删除所有缓存的小说
+ (void)removeAllBookCachedChapters;

/// 根据bookid缓存该小说的所有章节列表model
+ (void)cachedBookAllChapters:(NSArray <ADChapterModel *>*)array withBookid:(NSString*)bookid;

/// 根据bookid获取该小说的缓存的章节列表model
+ (NSArray <ADChapterModel *>*)getBookAllChaptersWithBookid:(NSString*)bookid;

/// 缓存某本小说的某个章节的内容
- (void)cachedBookChapterContent:(ADChapterContentModel *)model;

/// 获取缓存的某本小说的某个章节的内容
- (ADChapterContentModel *)getBookChapterContentWithChapterNum:(NSString*)chapterNum bookid:(NSString*)bookid;

/// 删除某本小说缓存的所有章节内容
- (void)removeBookAllInfoWithBookId:(NSString *)bookid;

/// 获取某本小说缓存的章节的数量(数组中记录的是第几章,例如: [1, 2, 3, 5, 7, 8])
+ (NSArray*)getBookDownloadChapterCount:(NSString*)bookid;



@end

NS_ASSUME_NONNULL_END
