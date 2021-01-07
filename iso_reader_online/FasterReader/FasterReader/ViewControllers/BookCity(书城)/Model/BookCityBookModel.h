//
//  BookCityBookModel.h
//  NightReader
//
//  Created by 张俊平 on 2019/3/5.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** 书城 右边列表model */
@interface BookCityBookModel : NSObject<NSCoding>

/** 书ID */
@property (nonatomic , copy) NSString *bookId;

/** 书名 */
@property (nonatomic , copy) NSString *title;

/** 作者 */
@property (nonatomic , copy) NSString *author;

/** 封面 */
@property (nonatomic , copy) NSString *cover;

/** 描述 */
@property (nonatomic , copy) NSString *longIntro;

/** 本书字数 */
@property (nonatomic , copy) NSString *wordCount;

/** 男 女 */
@property (nonatomic , copy) NSString *gender;

/** 是否完结 1完结 0 没有完结 */
@property (nonatomic , copy) NSString *over;

/** 评分 */
@property (nonatomic , copy) NSString *score;

/** 日更新字数 */
@property (nonatomic , copy) NSString *serializeWordCount;

/** 追书人数 */
@property (nonatomic , copy) NSString *latelyFollower;

/**  留存率 */
@property (nonatomic , copy) NSString *retentionRatio;

/** 分类ID */
@property (nonatomic , copy) NSString *tags;

/** 是否免费 1,是 0 不是 */
@property (nonatomic , copy) NSString *isfree;

/** 分类 */
@property (nonatomic , copy) NSString *majorCate;

/** 最后一章节 */
@property (nonatomic , copy) NSString *lastChapter;

/** 书籍更新时间 */
@property (nonatomic , copy) NSString *updated;

/** 红点提示 */
@property (nonatomic , assign) BOOL redSpot;


/**  */

//@property(nonatomic,strong)NSString *_id;

@property(nonatomic,strong) NSString *referenceSource;

@property(nonatomic,assign) NSInteger chaptersCount;

@property(nonatomic,assign) NSInteger chapter;

@property(nonatomic,assign) NSInteger pageIndex;

/** 书籍阅读时间 */
@property(nonatomic,strong) NSString *readDate;

/** 更新阅读时间 */
- (void)updateModelDate;

@end

NS_ASSUME_NONNULL_END
