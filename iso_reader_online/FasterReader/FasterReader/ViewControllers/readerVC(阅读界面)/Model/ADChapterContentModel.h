//
//  ADChapterContentModel.h
//  reader
//
//  Created by beequick on 2017/8/7.
//  Copyright © 2017年 beequick. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADChapterContentModel : NSObject

@property (nonatomic, copy) NSString *body;

@property (nonatomic, strong) NSMutableArray *pageArray;
@property (nonatomic, assign) NSUInteger pageCount;

@property (nonatomic, copy) NSString *content;

/**
 需要手动赋值的
 */

/// 小说封面(缓存用到)
@property (nonatomic, copy) NSString *cover;
/// 小说名称
@property (nonatomic, copy) NSString *bookName;

/// 章节标题
@property (nonatomic, copy) NSString *title;
/// 书籍id
@property (nonatomic, copy) NSString *bookId;
/// 阅读到哪页
@property (nonatomic, assign) NSUInteger index;
/// 阅读到哪章
@property (nonatomic, assign) NSUInteger chapterNum;

- (void)updateContentPaging;

- (NSString *)getStringWith:(NSUInteger)page;

#pragma mark - 根据文本和显示的view的size计算显示文字高度
+ (CGFloat)getTextHeight:(NSString*)text displyViewSize:(CGSize)displyViewSize;

@end
