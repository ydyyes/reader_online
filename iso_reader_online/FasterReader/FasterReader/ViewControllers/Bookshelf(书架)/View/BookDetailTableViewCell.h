//
//  BookDetailTableViewCell.h
//  NightReader
//
//  Created by 张俊平 on 2019/2/28.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookCityChartsModel.h"

NS_ASSUME_NONNULL_BEGIN

#define tableViewCellId @"BookDetailTableViewCell"

/** 书籍详情 cell */
@interface BookDetailTableViewCell : UITableViewCell

/** 书的图片 */
@property (strong, nonatomic) IBOutlet UIImageView *bookImg;

/** 书的名称 */
@property (strong, nonatomic) IBOutlet UILabel *bookNameLb;

/** 书的描述 */
@property (strong, nonatomic) IBOutlet UILabel *bookDescLb;

/** 书的作者名称 */
@property (strong, nonatomic) IBOutlet UILabel *bookAuthorLb;

/** cell分割线 */
@property (strong, nonatomic) IBOutlet UIView *line;

/** 设置cell数据 */
- (void)setCellData:(BookCityChartsModel*)model AtIndexPath:(NSIndexPath *)indexPath;


@end

NS_ASSUME_NONNULL_END
