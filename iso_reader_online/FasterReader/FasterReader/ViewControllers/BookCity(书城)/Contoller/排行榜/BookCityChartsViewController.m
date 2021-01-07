	//
	//  BookCityChartsViewController.m
	//  NightReader
	//
	//  Created by 张俊平 on 2019/2/27.
	//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
	//

#import "BookCityChartsViewController.h"

#import "BookCityChartsTableViewCell.h"
#import "BookCityChartsModel.h"
#import "BookDetailViewController.h" // 书籍详情

@interface BookCityChartsViewController ()<UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate>

/** tableView */
@property (nonatomic, strong) BaseTableView *tableView;
/** 性别 */
@property (nonatomic, readwrite , copy) NSString *sex;

@end

@implementation BookCityChartsViewController {

	int _page;//页码
	JPLoadingView *_loadView;
}

- (void)dealloc {
	self.navigationController.delegate = nil;// 导航栏代理置为nil
}
#pragma mark - UINavigationControllerDelegate
	// 将要显示控制器
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	[self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
	[super viewDidLoad];

	self.title = self.titleType;
	_page = 1;
	[self initTableView];
	_loadView = [[JPLoadingView alloc] initWithFrame:CGRectMake(0, 0, [JPTool screenWidth], [JPTool screenHeight])];
	[self.view addSubview:_loadView];
    
    
    NSNumber *sexNumber = [JPTool USER_SEX];
    self.sex = [NSString stringWithFormat:@"%@",sexNumber];
	if ([self.sex isEqualToString:@"-1"]) {
		self.sex = @"0";
	}
	[self getBookListData];

}
-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	

	self.navigationController.delegate = self;// 导航栏代理置为nil
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSString *label = @"";
    if ([self.type isEqualToString: @"1"]) {//热门更新
        label = @"热门更新";
    }else if ([self.type isEqualToString: @"-1"]) {//编辑推荐
        label = @"编辑推荐";
    }else if ([self.type isEqualToString: @"2"]) {//热门搜索
        label = @"热门搜索";
    }else if ([self.type isEqualToString: @"hot"]) {//热门榜
        label = @"热门榜";
    }else if ([self.type isEqualToString: @"new"]) {//新书榜
        label = @"新书榜";
    }else if ([self.type isEqualToString: @"reputation"]) {//口碑榜
        label = @"口碑榜";
    }else  if ([self.type isEqualToString: @"over"]) {//完结榜
        label = @"完结榜";
    }
    [MobClick event:@"book_mall_all_kinds_list_page" label:label];
}

- (void)viewWillDisappear:(BOOL)animated {

	[super viewWillDisappear:animated];
	self.navigationController.delegate = nil;// 导航栏代理置为nil

}
#pragma mark - 书籍列表
- (void)getBookListData {
	[self pullRefreshData];
}

#pragma mark - - 初始化
- (void)initTableView {

	self.tableView = [[BaseTableView alloc] initWithFrame:CGRectMake(0, 0, [JPTool screenWidth], [JPTool screenHeight]-NavBarHeight) style:UITableViewStylePlain];
	self.tableView.backgroundColor = [UIColor lightGray_F2F2F2];
	self.tableView.bgViewStyle = BaseTableViewNoStyleDefault;
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self.view addSubview:self.tableView];

	MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(pullRefreshData)];

	header.automaticallyChangeAlpha = YES;// 设置自动切换透明度(在导航栏下面自动隐藏)
	header.lastUpdatedTimeLabel.hidden = YES;	// 隐藏时间
		//	[header beginRefreshing];// 马上进入刷新状态
	self.tableView.mj_header = header;

	__weak __typeof(self) weakSelf = self;
		// 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
	self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
		[weakSelf loadMoreData];
	}];

}
#pragma mark -
/// 下拉刷新
- (void)pullRefreshData {

	if (![ZJPNetWork netWorkAvailable]) {
		[ZJPAlert showAlertWithMessage:[JPTool NoNetWorkAlert] time:1.5];
		_loadView.loadFail = YES;
		_loadView.loadFailStatus = YES;
		[_loadView.button addTarget:self action:@selector(retryAction) forControlEvents:UIControlEventTouchDown];
		[self.tableView.mj_header endRefreshing];
		return;
	}
	_page = 1;
	[self.tableView.mj_footer resetNoMoreData];

	NSString *page = [NSString stringWithFormat:@"%d",_page];///@"m_id":self.cateId
	NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc]initWithDictionary:@{@"token":[JPTool USER_TOKEN],@"type":self.type,@"page":page,@"size":@"10"}];
	NSString *PathUrl = [JPTool BookcityBookPath];

	if ([_titleType isEqualToString:@"编辑推荐"]) {
		[paramsDict removeAllObjects];
		paramsDict = [[NSMutableDictionary alloc]initWithDictionary:@{@"gender":self.sex,@"page":page,@"size":@"10"}];
		PathUrl = [JPTool BookcityRecommendPath];
	}
	if ([_type isEqualToString:@"1"]||[_type isEqualToString:@"2"]) {// 热门更新、热门搜索
		PathUrl = [JPTool BookCityHotUpdateAndSerachMorePath];
	}

	@WeakObj(self);
	[[JPNetWork sharedManager] requestPostMethodWithPathUrl:PathUrl WithParamsDict:paramsDict WithSuccessBlock:^(id responseObject) {

//		NSLog(@"%@",responseObject);
		[selfWeak.tableView.data removeAllObjects];
		NSArray *array = responseObject[@"data"];
		for (int i = 0; i < array.count; i++) {

			BookCityChartsModel *model = [BookCityChartsModel yy_modelWithJSON:array[i]];
			[selfWeak.tableView.data addObject:model];
		}

		[selfWeak.tableView.mj_header endRefreshing];
		[selfWeak.tableView reloadData];
		[[ZJPAlert shareAlert] hiddenHUD];
		self->_loadView.hidden = YES;

	} WithFailurBlock:^(NSError *error) {
		self->_loadView.loadFail = YES;
		self->_loadView.loadFailStatus = NO;
		[self->_loadView.button addTarget:self action:@selector(retryAction) forControlEvents:UIControlEventTouchDown];
	}];


}

- (void)retryAction {
	if (_loadView.loadFail == YES) {
		_loadView.loadFail = NO;
		[self pullRefreshData];
	}
}

#pragma mark - 上拉加载更多

- (void)loadMoreData {

	_page ++;
//	NSLog(@"loadMoreData Page=%d",_page);

	if (![ZJPNetWork netWorkAvailable]) {
		[ZJPAlert showAlertWithMessage:[JPTool NoNetWorkAlert] time:1.5];
		[self.tableView.mj_footer endRefreshing];
		return;
	}
	@WeakObj(self);
	NSString *page = [NSString stringWithFormat:@"%d",_page];
	NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc]initWithDictionary:@{@"token":@"",@"m_id":@"",@"type":self.type,@"page":page,@"size":@"10"}];
	NSString *PathUrl = [JPTool BookcityBookPath];
	if ([_titleType isEqualToString:@"编辑推荐"]) {
		paramsDict = [[NSMutableDictionary alloc]initWithDictionary:@{@"gender":self.sex,@"page":page,@"size":@"10"}];
		PathUrl = [JPTool BookcityRecommendPath];
	}
	if ([_type isEqualToString:@"1"]||[_type isEqualToString:@"2"]) {// 热门更新、热门搜索
		PathUrl = [JPTool BookCityHotUpdateAndSerachMorePath];
	}
	[[JPNetWork sharedManager] requestPostMethodWithPathUrl:PathUrl WithParamsDict:paramsDict WithSuccessBlock:^(id responseObject) {

		[self.tableView.mj_footer endRefreshing];
		NSArray *array = responseObject[@"data"];

		if (array.count <= 0) {
			[selfWeak.tableView.mj_footer endRefreshingWithNoMoreData];
		}else {
//			NSLog(@"%@",responseObject);
			[selfWeak.tableView.mj_footer resetNoMoreData];// = MJRefreshStateIdle;
			for (int i = 0; i < array.count; i++) {

				BookCityChartsModel *model = [BookCityChartsModel yy_modelWithJSON:array[i]];
				[self.tableView.data addObject:model];
			}

		}

		[self.tableView reloadData];

	} WithFailurBlock:^(NSError *error) {

	}];


}
#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.tableView.data.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	static NSString *cellId = @"BookCityChartsTableViewCell";
	BookCityChartsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
	if (!cell) {
		cell = [[BookCityChartsTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
		// 分割线
	if (indexPath.row == self.tableView.data.count-1) {
		cell.bottomLine.hidden = YES;
	}else{
		cell.bottomLine.hidden = NO;
	}
	BookCityChartsModel *model = self.tableView.data[indexPath.row];
	[cell setCellData:model AtIndexPath:indexPath];
	return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	BookCityChartsModel *model = self.tableView.data[indexPath.row];
	BookDetailViewController *BookDetailVc = [[BookDetailViewController alloc] init];
	BookDetailVc.bookId = model.bookId;//m
	BookDetailVc.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:BookDetailVc animated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 130.f;
}


#pragma mark - lazy



@end
