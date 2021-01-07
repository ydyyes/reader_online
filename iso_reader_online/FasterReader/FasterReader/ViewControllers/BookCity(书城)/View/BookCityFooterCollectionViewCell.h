//
//  BookCityFooterCollectionViewCell.h
//  NightReader
//
//  Created by 张俊平 on 2019/5/23.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookCityBookModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface BookCityFooterCollectionViewCell : UICollectionViewCell

/** 小说图片 */
@property (strong, nonatomic) IBOutlet UIImageView *bookImg;

/** 书的名称 */
@property (strong, nonatomic) IBOutlet UILabel *bookNameLb;

/** 书的作者名称 */
@property (strong, nonatomic) IBOutlet UILabel *bookAuthorLb;

/** 小说名称 */
//@property (strong, nonatomic) IBOutlet JPLabel *bookNameLb;

///** 书图片的高 */
//@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bookImgHeight;
//@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bookNameLeftSpace;
//
///** 图片的右边间隙 */
//@property (strong, nonatomic) IBOutlet NSLayoutConstraint *rightSpace;

- (void)setCellData:(NSMutableArray*)dataArr AtIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
