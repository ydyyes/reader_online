//
//  BaseTableView.h
//  TeBrand
//
//  Created by iOS开发 on 17/1/20.
//  Copyright © 2017年 SunBo. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,BaseTableViewNOStyle) {
    BaseTableViewNoStyleDefault = 0,//暂无数据
    BaseTableViewNOStyleIsMyBrand,//我的品牌列表页面
    BaseTableViewNoStyleIsSearchPerson,// 搜索员工
    BaseTableViewNOStyleIsSearchView,// 搜索页面
	 BaseTableViewNOStyleIsCustom,// 自定义提示语
};

@interface BaseTableView : UITableView < UITableViewDataSource, UITableViewDelegate>
{
    
    BOOL _reloading;        //正在加载的提示
    BOOL _loadingMore;
    
}

@property (nonatomic, retain) NSMutableArray *data;//数据源,必须给值,否则上拉无法出现
@property (nonatomic, assign) BaseTableViewNOStyle bgViewStyle;
@property (nonatomic, retain) UIButton *nullButton;
@property (nonatomic, copy) NSString *searchKey;//综合搜索无数据时状态添加文字
@property (nonatomic, copy) NSString *tipsString;
@end
