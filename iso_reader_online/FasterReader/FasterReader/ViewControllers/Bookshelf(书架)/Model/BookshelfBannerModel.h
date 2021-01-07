//
//  BookshelfBannerModel.h
//  NightReader
//
//  Created by 张俊平 on 2019/3/4.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BookshelfBannerModel : NSObject

/** 轮播图ID */
@property (nonatomic , copy) NSString *bannerId;

/** 轮播图名称 */
@property (nonatomic , copy) NSString *name;

/** 小说ID */
@property (nonatomic , copy) NSString *fid;

/** 轮播图url */
@property (nonatomic , copy) NSString *img;

/** 轮播图类型 */
@property (nonatomic , copy) NSString *type;

/** 轮播图广告名称 */
@property (nonatomic , copy) NSString *title;

/** 轮播图广告链接 */
@property (nonatomic , copy) NSString *link;

/** 轮播图广告位置 1开屏；2文章末尾 */
@property (nonatomic , copy) NSString *location;

/** 轮播图广告链接 */
@property (nonatomic , copy) NSString *cover;

/** 轮播图0  不是内部链接     1 福利中心 2 兑换金币 3 邀请好友 */
@property (nonatomic , copy) NSString *inner;

/** 轮播图广告轮播位置 1 书城轮播图 2 福利中心轮播图 */
@property (nonatomic , copy) NSString *banner_local;

///** 轮播图广告更新时间 */
//@property (nonatomic , copy) NSString *update;
//
///** 轮播图广告更新时间 */
//@property (nonatomic , copy) NSString *update;





@end

NS_ASSUME_NONNULL_END
