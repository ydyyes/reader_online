//
//  BookMarkTableViewCell.h
//  NightReader
//
//  Created by 张俊平 on 2019/6/11.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BookMarkModel.h"
#define BookMarkTableViewCellId @"BookMarkTableViewCell"

NS_ASSUME_NONNULL_BEGIN
/** 书签-cell */
@interface BookMarkTableViewCell : UITableViewCell

/** 章节标题 */
@property (strong, nonatomic) IBOutlet UILabel *titleLb;

/** 日期 */
@property (strong, nonatomic) IBOutlet UILabel *dateLb;

/** 百分比 */
@property (strong, nonatomic) IBOutlet UILabel *percentageLb;

/** 设置cell数据 */
- (void)setCellData:(BookMarkModel*)model AtIndexPath:(NSIndexPath *)indexPath;


@end

NS_ASSUME_NONNULL_END
