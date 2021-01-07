//
//  PersonalInfoCell.h
//  NightReader
//
//  Created by 张俊平 on 2019/5/10.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define PersonalInfoCell_Identifier @"PersonalInfoCell"

@interface PersonalInfoCell : UITableViewCell

/** 左边标题 */
@property (strong, nonatomic) IBOutlet UILabel *leftTitleLb;

/** 右边的标题 */
@property (strong, nonatomic) IBOutlet UILabel *rightTitleLb;

/** 头像 */
@property (strong, nonatomic) IBOutlet UIImageView *headImg;

/** cell分割线 */
@property (strong, nonatomic) IBOutlet UIView *line;

- (void)setCellData:(NSMutableDictionary*)dataDict AtIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
