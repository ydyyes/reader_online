//
//  BookCityChartsViewController.h
//  NightReader
//
//  Created by 张俊平 on 2019/2/27.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/** 书城-排行榜 */
@interface BookCityChartsViewController : UIViewController

/** title 标题类型 */
@property (nonatomic, readwrite , copy) NSString *titleType;

/** 类型 参数值 hot new reputation over,对应 新书 热门 口碑 完结 默认new */
@property (nonatomic, readwrite , copy) NSString *type;

/** 分类ID m_id */
@property (nonatomic, readwrite , copy) NSString *cateId;



@end

NS_ASSUME_NONNULL_END
