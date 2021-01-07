//
//  UILabel+copy.h
//  NightReader
//
//  Created by 张俊平 on 2019/4/2.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/** 长按复制的Label */
@interface UILabel (copy)

/** Yes 可以复制 NO 不具备复制 */
@property (nonatomic,assign) BOOL isCopyable;


@end

NS_ASSUME_NONNULL_END
