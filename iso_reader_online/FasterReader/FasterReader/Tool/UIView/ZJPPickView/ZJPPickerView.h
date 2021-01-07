//
//  ZJPPickerView.h
//  NightReader
//
//  Created by 张俊平 on 2019/5/14.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define MAINScreenHeight [UIScreen mainScreen].bounds.size.height
#define MAINScreenWidth [UIScreen mainScreen].bounds.size.width

typedef void(^OACancelBlock)(void);
typedef void(^OASureBlock)(NSString *nameStr, NSString *idStr);

@interface ZJPPickerView : UIView

/** 重置按钮点击调用 */
@property (nonatomic, copy) OACancelBlock oaCancelBlock;

/** 选择按钮点击调用 */
@property (nonatomic, copy) OASureBlock oaSureBlock;

/** 单例
 @return  self
 */
+ (instancetype)shareAlert;

- (void)setResultArr:(NSArray *)resultArr withType:(NSString *)type selectIndex:(NSString*)selectString withSureBlock:(OASureBlock)sureBlock withCancelClick:(OACancelBlock)cancelBlock;


@end

NS_ASSUME_NONNULL_END
