	//
	//  RootTabBarController.m
	//  PaoTui
	//
	//  Created by wjr on 15/3/10.
	//  Copyright (c) 2015年 wjr. All rights reserved.
	//

#import "RootTabBarController.h"

#import "FasterReader-Swift.h"

#import "BookCityViewController.h"
#import "RecreationViewController.h"

#import "UIButton+SSEdgeInsets.h"


enum{
	ONE = 0,
	TWO,
	THREE,
	FOUR,
};
@interface RootTabBarController ()<UIWebViewDelegate>
{
	NSArray  *normalImageArray;
	NSArray  *pressImageArray;
	NSArray  *namesArray;
	UIButton *_tabImgBtn;
	UILabel     *_tabLb;
	UIView *_shadowView;
	UIView *_bgView;
	UIButton    *_inviteBtn;
		//    UIButton *_closeBtn;

}
@end

@implementation RootTabBarController


- (id)init{
	if (self = [super init]) {

			// 创建子导航控制器
		[self setUpChilderNav];
			// 去掉 tabBar 顶部横线
		[self removeTabBarTopLine];
			// 自定义 tabbar
		[self customTabBar];

	}


	return self;
}

#pragma mark -
- (void)viewDidLoad {
	[super viewDidLoad];
    [UITabBar appearance].translucent = NO;
}

#pragma mark -- 创建子导航控制器
- (void)setUpChilderNav {

    MSYBookShelfController *bookShelf = [[MSYBookShelfController alloc] init];
	_bookShelfNavigationController = [self setUpChildrenController: bookShelf navigtionItemTitle:@"" withTag:ONE ];

	BookCityViewController *postRewardViewController = [[BookCityViewController alloc] init];
	_bookCityNavigationController = [self setUpChildrenController:postRewardViewController navigtionItemTitle:@"" withTag:TWO ];

    MSYMineController *myViewController = [[MSYMineController alloc] init];
    _mineNavigationController = [self setUpChildrenController:myViewController navigtionItemTitle:@"" withTag:THREE ];

	NSArray *viewControllerArray = [[NSArray alloc] initWithObjects:_bookShelfNavigationController,_bookCityNavigationController,_mineNavigationController, nil];

	[self setViewControllers:viewControllerArray];
}
#pragma mark -- 创建自控制器
- (UINavigationController *)setUpChildrenController:(UIViewController *)vc navigtionItemTitle:(NSString *)navigationItemTitle withTag:(NSInteger)tag{
    
    UINavigationController *nav = [[JLXXNavgationController alloc] initWithRootViewController: vc];
    [nav.navigationBar setBackgroundImage:[UIImage imageWithColor: [UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
    [nav.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17], NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#222222"]}];
    nav.navigationBar.shadowImage = [[UIImage alloc] init];
	[vc.navigationItem setTitle:navigationItemTitle];
	[nav.tabBarItem setTag:tag];
	return nav;
}

#pragma mark -- 自定义 tabBar
- (void)customTabBar {

	normalImageArray = [[NSArray alloc] initWithObjects:@"shujiaweixuan",@"shuchengweixuan",@"wodeweixuan",@"",nil];//,@"yuleweixuan"
	pressImageArray = [[NSArray alloc] initWithObjects:@"shujiaxuanzhong",@"shuchengxuanzhong",@"wodexuanzhong",@"",nil];//,@"yulexuanzhong"
	namesArray = [[NSArray alloc] initWithObjects:@"书架",@"书城",@"我的",nil];//,@"娱乐"

	UIView *viewTabbar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [JPTool screenWidth], TabBarHeight)];
	viewTabbar.backgroundColor = [UIColor whiteColor];

	for (int i = 0; i < [self.viewControllers count]; i++) {

		UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake([JPTool screenWidth]/3.0*i, 0,[JPTool screenWidth]/3.0, TabBarHeight)];
		[button setTag:i];
		[button addTarget:self action:@selector(tabBarSelected:) forControlEvents:UIControlEventTouchUpInside];

		_tabImgBtn = [[UIButton alloc] initWithFrame:CGRectMake(([JPTool screenWidth]/3-27.5)/2, 5, 27.5, 27.5)];
		_tabImgBtn.titleLabel.textColor = [UIColor whiteColor];
		_tabImgBtn.titleLabel.font = [UIFont systemFontOfSize:11.0];
		_tabImgBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
		_tabImgBtn.tag = i+10;
		[_tabImgBtn setBackgroundImage:[UIImage imageNamed:[normalImageArray objectAtIndex:i]] forState:UIControlStateNormal];
		_tabImgBtn.userInteractionEnabled = NO;

		_tabLb = [[UILabel alloc]initWithFrame:CGRectMake(0, 27.5+5+4, [JPTool screenWidth]/3, 11)];
		_tabLb.tag  = i+20;
		_tabLb.text = [namesArray objectAtIndex:i];
		_tabLb.adjustsFontSizeToFitWidth = YES;
		_tabLb.textAlignment = NSTextAlignmentCenter;
		_tabLb.font = [UIFont systemFontOfSize:11];
		_tabLb.textColor = RGB_COLOR(31, 49, 75);//[UIColor colorWithHexString:@"#ffbe2d"];

		[button addSubview:_tabLb];
		[button addSubview:_tabImgBtn];
		[viewTabbar addSubview:button];

	}

	[self.tabBar addSubview:viewTabbar];
	[self tabBar:self.tabBar didSelectItem:_bookShelfNavigationController.tabBarItem];

}

#pragma mark -- 去掉 tabBar 上部的横线
- (void)removeTabBarTopLine {
	CGRect rect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0.5);
	UIGraphicsBeginImageContext(rect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(context, [[UIColor colorWithHexString:@"dcdcdc"] CGColor]);
	CGContextFillRect(context, rect);

		UIImage *img = [UIImage imageNamed:@"tabbar_shadow"];
//	UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	[self.tabBar setBackgroundImage:img];
	[self.tabBar setShadowImage:img];
	[self.tabBar setBackgroundColor:[UIColor whiteColor]];

	
}

-(void)tabBarSelected:(UIButton*)touchButton{

	[self selectControlAtIndex:touchButton.tag];
}
- (void)selectControlAtIndex:(NSInteger)index {
	for (UITabBarItem * tabBarItem in self.tabBar.items) {

		if (tabBarItem.tag == index) {
			[self tabBar:self.tabBar didSelectItem:tabBarItem];
			[self setSelectedIndex:tabBarItem.tag];//tabBarItem.tag

		}
	}
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{

	for (UIView *viewTabbar in [self.tabBar subviews]) {
		if ([viewTabbar isKindOfClass:[UIView class]]) {

			for (UIView *button in [viewTabbar subviews]) {

				if ([button isKindOfClass:[UIButton class]]) {

					if (button.tag != item.tag) {

						_tabImgBtn = (UIButton *)[button viewWithTag:10+button.tag];
						[_tabImgBtn setBackgroundImage:[UIImage imageNamed:[normalImageArray objectAtIndex:button.tag]] forState:UIControlStateNormal];
						[_tabImgBtn setBackgroundImage:[UIImage imageNamed:[pressImageArray objectAtIndex:button.tag]] forState:UIControlStateHighlighted];
						_tabLb = (UILabel *)[button viewWithTag:20+button.tag];
						_tabLb.textColor = RGB_COLOR(31, 49, 75);

					}else{

						_tabImgBtn = (UIButton *)[button viewWithTag:10+button.tag];
						[_tabImgBtn setBackgroundImage:[UIImage imageNamed:[pressImageArray objectAtIndex:button.tag]] forState:UIControlStateNormal];
						[_tabImgBtn setBackgroundImage:[UIImage imageNamed:[normalImageArray objectAtIndex:button.tag]] forState:UIControlStateHighlighted];
						_tabLb = (UILabel *)[button viewWithTag:20+button.tag];
						_tabLb.textColor = RGB_COLOR(32, 123, 214);

					}
				}
			}
		}
	}
}

@end
