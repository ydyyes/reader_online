//
//  SerachResultModel.h
//  NightReader
//
//  Created by 张俊平 on 2019/3/6.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/** 搜索结果Model */
@interface SerachResultModel : NSObject

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

/** 现代言情 | 古代言情 */
@property (nonatomic , copy) NSString *tags;

/** 是否免费 1,是 0 不是 */
@property (nonatomic , copy) NSString *isfree;

/** 分类 */
@property (nonatomic , copy) NSString *majorCate;

/** 最后一章节 */
@property (nonatomic , copy) NSString *lastChapter;

/** 最后书籍时间 */
@property (nonatomic , copy) NSString *updated;


@end

NS_ASSUME_NONNULL_END
