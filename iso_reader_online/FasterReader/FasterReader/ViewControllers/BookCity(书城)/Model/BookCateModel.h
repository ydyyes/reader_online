//
//  BookCateModel.h
//  NightReader
//
//  Created by 张俊平 on 2019/3/4.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** 书城-左侧书籍分类 */
@interface BookCateModel : NSObject

/** 分类ID */
@property (nonatomic , copy) NSString *cateId;

/** 分类名称 */
@property (nonatomic , copy) NSString *name;

/** 性别 */
@property (nonatomic , copy) NSString *sex;

/** 图片 */
@property (nonatomic , copy) NSString *cover;


@end

NS_ASSUME_NONNULL_END
