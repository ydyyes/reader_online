//
//  BookCityChartsTableViewCell.h
//  NightReader
//
//  Created by 张俊平 on 2019/2/27.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookCityChartsModel.h"
NS_ASSUME_NONNULL_BEGIN

/** 排行榜 cell */
@interface BookCityChartsTableViewCell : UITableViewCell

/** 书的图片 */
@property (strong, nonatomic) IBOutlet UIImageView *bookImg;

/** 榜单图标  */
@property (strong, nonatomic) IBOutlet UIImageView *bookToplistImg;

/** 书的名称 */
@property (strong, nonatomic) IBOutlet UILabel *bookNameLb;

/** 书的描述 */
@property (strong, nonatomic) IBOutlet UILabel *bookDescLb;

/** 书的作者名称 */
@property (strong, nonatomic) IBOutlet UILabel *bookAuthorLb;

/** 底部灰色的线 */
@property (strong, nonatomic) IBOutlet UIView *bottomLine;

/** 设置cell数据 */
- (void)setCellData:(BookCityChartsModel*)model AtIndexPath:(NSIndexPath *)indexPath;


@end

NS_ASSUME_NONNULL_END
