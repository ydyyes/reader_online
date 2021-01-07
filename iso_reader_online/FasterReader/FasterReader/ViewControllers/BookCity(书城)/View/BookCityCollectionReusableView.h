//
//  BokCityCollectionReusableView.h
//  NightReader
//
//  Created by 张俊平 on 2019/2/27.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 创建点击排行榜的协议
@protocol BookCityCollectionReusableViewDelegate <NSObject>

/// 点击排行榜按钮代理方法
- (void)bookCityCollectionReusableViewDidSelectButton:(UIButton*)button;

@end

/** 书城 头视图 */
@interface BookCityCollectionReusableView : UICollectionReusableView

/** 按钮1 */
@property (strong, nonatomic) IBOutlet UIButton *buttonOne;

/** 按钮2 */
@property (strong, nonatomic) IBOutlet UIButton *buttonTwo;

/** 按钮3 */
@property (strong, nonatomic) IBOutlet UIButton *buttonThree;

/** 按钮4 */
@property (strong, nonatomic) IBOutlet UIButton *buttonFour;

/** 按钮左边的间隙 */
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *buttonLeftSpace;

/** 按钮中间的间隙 */
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *buttonMidSpace;

/** 按钮的宽度 */
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *buttonWidth;

@property (weak,   nonatomic) id <BookCityCollectionReusableViewDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
