//
//  ADSherfCache.h
//  reader
//
//  Created by beequick on 2017/8/17.
//  Copyright © 2017年 beequick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYCache/YYCache.h>
#import "ADCache.h"
#import "BookCityBookModel.h"
#import "ADChapterModel.h"
#import "ADChapterContentModel.h"

@class ADSherfModel;

@interface ADSherfCache : NSObject

+ (instancetype)share;

#pragma mark -书架相关

/**  添加书籍 */
+ (void)addBook:(BookCityBookModel *)bookinfo;
/**  添加查询书籍是否存在 */
+ (BOOL)queryWithBookId:(NSString *)bookid;

/**
 根据 书籍ID 返回模型

 @param bookid 书籍ID
 @return 返回书籍model
 */
+ (BookCityBookModel *)ADObjectForId:(NSString *)bookid;//ADSherfCusModel


/**  从书架删除删除指定的书籍 */
+ (void)removeBookShelfWithBookId:(NSString *)bookId;
+ (void)removeBookShelfWithBookModel:(BookCityBookModel *)bookinfo;

/** 移除所有书架书籍 */
+ (void)removeAllBooks;

/**
 获取缓存书籍model数组
 
 @return  获取缓存书籍model数组
 */
+ (NSMutableArray *)query;


/**
 获取缓存书籍model数组(排序了的)
 
 @return 返回排序数组
 */
+ (NSMutableArray *)queryDesending;


/**
 根据书籍ID 更新书籍model信息
 
 @param bookinfo 书籍ID
 */
+ (void)UpdateWithBookInfo:(BookCityBookModel *)bookinfo;


@end

@interface ADSherfModel : NSObject<NSCoding>

@property(nonatomic,strong) NSString *bookid;
@property(nonatomic,strong) NSString *author;
@property(nonatomic,strong) NSString *referenceSource;
@property(nonatomic,strong) NSString *updated;
@property(nonatomic,assign) NSInteger chaptersCount;
@property(nonatomic,strong) NSString *lastChapter;
@property(nonatomic,strong) NSString *cover;
@property(nonatomic,strong) NSString *title;
/** 章节 */
@property(nonatomic,assign) NSInteger chapter;

@property(nonatomic,assign) NSInteger pageIndex;
/** 保存的时间 */
@property(nonatomic,strong) NSString *updateDate;

- (void)updateModelDate;

@end


