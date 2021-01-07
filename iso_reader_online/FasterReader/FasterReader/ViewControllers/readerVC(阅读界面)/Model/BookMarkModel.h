//
//  BookMarkModel.h
//  NightReader
//
//  Created by 张俊平 on 2019/6/11.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BookMarkModel : NSObject

/** 书签时间 */
@property (nonatomic, copy) NSString *timestemp;

/** 书签百分比 */
@property (nonatomic, copy) NSString *percentage;

/** 章节标题 */
@property (nonatomic, copy) NSString *title;

/** 章节标签 相当于ID */
@property (nonatomic, copy) NSString *label;


@end

NS_ASSUME_NONNULL_END
