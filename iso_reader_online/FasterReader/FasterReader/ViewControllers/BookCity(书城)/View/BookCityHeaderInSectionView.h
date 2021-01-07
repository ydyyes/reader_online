//
//  BookCityHeaderInSectionView.h
//  NightReader
//
//  Created by 张俊平 on 2019/5/23.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/** 书城-tableview组头 */
@interface BookCityHeaderInSectionView : UIView

@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, assign) CGFloat lineHeigh;

@end

NS_ASSUME_NONNULL_END
