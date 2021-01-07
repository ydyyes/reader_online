//
//  MSYBrowseHistoryCache.h
//  FasterReader
//
//  Created by apple on 2019/7/12.
//  Copyright © 2019 Restver. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYCache/YYCache.h>

NS_ASSUME_NONNULL_BEGIN

@interface MSYBrowseHistoryCacheModel : NSObject<NSCoding>

@property(nonatomic,copy) NSString *bookId;

@property(nonatomic,copy) NSString *bookName;

@property(nonatomic,copy) NSString *cover;

@property(nonatomic,copy) NSString *lastChapter;

@property(nonatomic,copy) NSString *author;

@property(nonatomic,copy) NSString *majorCate;

/// 最后更新时间
@property(nonatomic,copy) NSString *updated;



/** 章节 */
@property(nonatomic,assign) NSInteger chapterIndex;

@property(nonatomic,assign) NSInteger pageIndex;

@end


@interface MSYBrowseHistoryCache : NSObject

+ (instancetype)share;

/// 添加到阅读记录中去
- (void)addBookToBrowseHistory:(MSYBrowseHistoryCacheModel *)bookModel;
/// 获取所有的阅读记录
- (NSMutableArray <MSYBrowseHistoryCacheModel *>*)getBrowseHistory;
/// 移除所有的阅读记录
- (void)removeBrowseHistory;

/**
 保存某本小说阅读到哪里的记录
 
 @param bookID 阅读书籍ID
 @param chapterIndex 阅读章节
 @param pageIndex 阅读章节的第几页
 */
- (void)updateReadHistoryWithBookId:(NSString *)bookID chapterIndex:(NSInteger)chapterIndex pageIndex:(NSInteger)pageIndex;

- (MSYBrowseHistoryCacheModel *)queryReadHistoryWithBookId:(NSString *)bookID;

- (void)removeReadHistory;


@end


NS_ASSUME_NONNULL_END
