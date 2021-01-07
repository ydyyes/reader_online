//
//  BookCityCollectionViewCell.h
//  NightReader
//
//  Created by 张俊平 on 2019/2/27.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookCityBookModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface BookCityCollectionViewCell : UICollectionViewCell

/** 书的图片 */
@property (strong, nonatomic) IBOutlet UIImageView *bookImg;

/** 书的名称 */
@property (strong, nonatomic) IBOutlet UILabel *bookNameLb;

/** 小说完结or连载 */
@property (strong, nonatomic) IBOutlet UIImageView *bookStateImg;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bookImgHeight;

/** 书的图片的左边间隙 */
//@property (strong, nonatomic) IBOutlet NSLayoutConstraint *leftSpace;

- (void)setCellData:(BookCityBookModel*)model;

@end

NS_ASSUME_NONNULL_END
