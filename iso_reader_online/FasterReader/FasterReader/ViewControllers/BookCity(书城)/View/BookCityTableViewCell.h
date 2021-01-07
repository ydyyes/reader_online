//
//  BookCityTableViewCell.h
//  NightReader
//
//  Created by 张俊平 on 2019/5/23.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookCityBookModel.h"

NS_ASSUME_NONNULL_BEGIN

#define BookCityTableViewId @"BookCityTableViewCell"

/** 书城-tableView cell */
@interface BookCityTableViewCell : UITableViewCell

/** 小说图片 */
@property (strong, nonatomic) IBOutlet UIImageView *bookImg;

/** 书的名称 */
@property (strong, nonatomic) IBOutlet UILabel *bookNameLb;


/** 书的描述 */
@property (strong, nonatomic) IBOutlet UILabel *bookDescLb;

/** 书的作者名称 */
@property (strong, nonatomic) IBOutlet UILabel *bookAuthorLb;

/** 图片的宽度 */
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bookImgWidth;

/** 书名的右边与屏幕的间隙 */
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bookNameRightSpace;

/** 图片的左边与屏幕间隙 */
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bookImgLeftSpace;

- (void)setCellData:(NSMutableArray*)dataArr AtIndexPath:(NSIndexPath *)indexPath;


@end

NS_ASSUME_NONNULL_END
