//
//  JPLabel.h
//  NightReader
//
//  Created by 张俊平 on 2019/3/20.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef enum {
	VerticalAlignmentTop = 0, //default
	VerticalAlignmentMiddle,
	VerticalAlignmentBottom,

} VerticalAlignment;

@interface JPLabel : UILabel

/** 水平设置 */
@property (nonatomic) VerticalAlignment verticalAlignment;


@end

NS_ASSUME_NONNULL_END
