//
//  SerachTabViewCell.h
//  NightReader
//
//  Created by 张俊平 on 2019/2/27.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SerachResultModel.h"
NS_ASSUME_NONNULL_BEGIN

#define tableViewCellId @"SerachTabViewCell"
/** 搜索tableView cell */
@interface SerachTabViewCell : UITableViewCell

/** 书籍图片 */
@property (strong, nonatomic) IBOutlet UIImageView *bookImg;

/** 书籍名称 */
@property (strong, nonatomic) IBOutlet UILabel *bookNameLb;

/** 书籍描述 */
@property (strong, nonatomic) IBOutlet UILabel *bookDescLb;

- (void)setCellDate:(NSIndexPath*)indexPath withDate:(SerachResultModel*)model;

@end

NS_ASSUME_NONNULL_END
