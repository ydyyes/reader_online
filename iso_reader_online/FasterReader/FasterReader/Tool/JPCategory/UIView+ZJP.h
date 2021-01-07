//
//  UIView+ZJP.h
//  NightReader
//
//  Created by 张俊平 on 2019/3/28.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (ZJP)

@property (nonatomic, assign) CGFloat tx;

@property (nonatomic, assign) CGFloat ty;

/** 弹窗 */
- (UIViewController *)presentViewController;


@end

NS_ASSUME_NONNULL_END
