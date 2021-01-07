//
//  ShareViewController.h
//  NightReader
//
//  Created by 张俊平 on 2019/2/20.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <YYText/YYText.h>
#import <YYText/YYLabel.h>
NS_ASSUME_NONNULL_BEGIN

/** 我的-分享 */
@interface ShareViewController : UIViewController


@property (strong, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) IBOutlet UIButton *shareButton;

/** 顶部标题 */
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

/** 二维码 */
@property (strong, nonatomic) IBOutlet UIImageView *qrImgView;

/** 邀请码 */
@property (weak, nonatomic) IBOutlet UILabel *invitationCodeLabel;

/** 网址 */
@property (strong, nonatomic) IBOutlet UILabel *websiteLb;

/** 顶部间隔 */
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topSpace;
/** 底部两个按钮之间的间隔 */
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *buttonSpace;
/** 按钮宽度 */
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *buttonWidth;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qrImgViewWidth;

@end

NS_ASSUME_NONNULL_END
