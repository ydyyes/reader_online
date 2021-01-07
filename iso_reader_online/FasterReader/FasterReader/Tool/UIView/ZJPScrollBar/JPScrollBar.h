//
//  JPScrollBar.h
//  NightReader
//
//  Created by 张俊平 on 2019/6/3.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class JPScrollBar;

@protocol JPScrollBarDelegate <NSObject>

	//滚动条滑动代理事件
- (void)jpScrollBarDidScroll:(JPScrollBar *)scrollBar;

	//滚动条点击代理事件
- (void)jpScrollBarTouchAction:(JPScrollBar *)scrollBar;

@end

/** 自定义的滚动条 */
@interface JPScrollBar : UIView

	//背景色
@property (nonatomic, strong) UIColor *backColor;

	//前景色
@property (nonatomic, strong) UIColor *foreColor;

	//滚动动画时长
@property (nonatomic, assign) CGFloat barMoveDuration;

	//限制滚动条最小高度
@property (nonatomic, assign) CGFloat minBarHeight;

	//滚动条实际高度
@property (nonatomic, assign) CGFloat barHeight;

	//滚动条Y向位置
@property (nonatomic, assign) CGFloat yPosition;

	//代理
@property (nonatomic, weak) id<JPScrollBarDelegate> delegate;

- (void)hidden;
- (void)show;
- (void)cancelHideWithDelay;

@end

NS_ASSUME_NONNULL_END
