//
//  BookCityViewController.h
//  NightReader
//
//  Created by 张俊平 on 2019/2/17.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDCycleScrollView.h" // 轮播图
NS_ASSUME_NONNULL_BEGIN
/** 书城 */
@interface BookCityViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *buttonViewHeigh;
/**  滚动视图 */
@property (strong, nonatomic) IBOutlet SDCycleScrollView *scrollView;

/** 按钮1 */
@property (strong, nonatomic) IBOutlet UIButton *buttonOne;

/** 按钮2 */
@property (strong, nonatomic) IBOutlet UIButton *buttonTwo;

/** 按钮3 */
@property (strong, nonatomic) IBOutlet UIButton *buttonThree;

/** 按钮4 */
@property (strong, nonatomic) IBOutlet UIButton *buttonFour;

/** 按钮5 */
@property (strong, nonatomic) IBOutlet UIButton *buttonFive;

@end

NS_ASSUME_NONNULL_END
