//
//  RootTabBarController.h
//  PaoTui
//
//  Created by wjr on 15/3/10.
//  Copyright (c) 2015年 wjr. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^Sure) (void);
typedef void(^Cancel) (void);

@interface RootTabBarController : UITabBarController

/** 书架 */
@property(nonatomic,strong) UINavigationController *bookShelfNavigationController;
/** 书城*/
@property(nonatomic,strong) UINavigationController *bookCityNavigationController;
/** 娱乐 */
@property(nonatomic,strong) UINavigationController *recreationNavigationController;
/** 我的 */
@property(nonatomic,strong) UINavigationController *mineNavigationController;

@property (nonatomic,copy) Sure sure;//确定

@property (nonatomic,copy) Cancel cancel;//取消

- (void)selectControlAtIndex:(NSInteger)index;

@end


