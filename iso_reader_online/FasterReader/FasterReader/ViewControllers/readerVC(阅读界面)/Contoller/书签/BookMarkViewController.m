	//
	//  BookMarkViewController.m
	//  NightReader
	//
	//  Created by 张俊平 on 2019/6/11.
	//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
	//

#import "BookMarkViewController.h"

#import "BookMarkTableViewCell.h"

@interface BookMarkViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) BaseTableView *tableView;
@property (nonatomic, strong) UIBarButtonItem *rightItem ;
@property (nonatomic, strong) NSMutableArray * selectedDataArr;

@end

@implementation BookMarkViewController {
	JPLoadingView *_loadView;
	BOOL _selectAll;
}
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	[self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self.navigationController setNavigationBarHidden:NO animated:YES];

}
- (void)viewDidLoad {
	[super viewDidLoad];

	self.title = @"书签";

	[self initTableView];
	[self initNavRightItem];
	_selectAll = NO;// 默认可以多选
	_loadView = [[JPLoadingView alloc] initWithFrame:CGRectMake(0, 0, [JPTool screenWidth], [JPTool screenHeight])];
		//	[self.view addSubview:_loadView];
}

- (void)initNavRightItem {

	UIBarButtonItem *select = [[UIBarButtonItem alloc]initWithTitle:@"管理  " style:UIBarButtonItemStylePlain target:self action:@selector(rightItemAction:)];

	self.rightItem = select;
	select.tintColor = [UIColor blackColor];
	self.navigationItem.rightBarButtonItem = select;
}
#pragma mark - 批量操作按钮点击事件
- (void)rightItemAction:(UIBarButtonItem *)item{

	if (self.tableView.data.count == 0) {
		return;
	}
	self.tableView.allowsMultipleSelectionDuringEditing = !self.tableView.allowsMultipleSelectionDuringEditing;
	[self.tableView setEditing:!self.tableView.editing animated:YES];
	item.title = self.tableView.editing ? @"取消  ":@"管理  ";//@"取消";
	if (self.tableView.editing) {
		self.tableView.height  = [JPTool screenHeight]-NavBarHeight-50;
		self.bottomView.hidden = NO;
	}else{
		self.bottomView.hidden = YES;
		self.tableView.height  = [JPTool screenHeight]-NavBarHeight;
	}
	[self changeBtnTitle];

}
#pragma mark -
- (void)initTableView {

	self.tableView = [[BaseTableView alloc] initWithFrame:CGRectMake(0, 0, [JPTool screenWidth], [JPTool screenHeight]-NavBarHeight) style:UITableViewStylePlain];
	self.tableView.backgroundColor = [UIColor lightGray_F2F2F2];///lightGray_F2F2F2
	self.tableView.bgViewStyle = BaseTableViewNoStyleDefault;
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self.view addSubview:self.tableView];

	MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(pullRefreshData)];

	header.automaticallyChangeAlpha = YES;// 设置自动切换透明度(在导航栏下面自动隐藏)
	header.lastUpdatedTimeLabel.hidden = YES;	// 隐藏时间
	self.tableView.mj_header = header;

}

#pragma mark - 下拉刷新
- (void)pullRefreshData {

	if (![ZJPNetWork netWorkAvailable]) {
		[ZJPAlert showAlertWithMessage:[JPTool NoNetWorkAlert] time:1.5];
		_loadView.loadFail = YES;
		_loadView.loadFailStatus = YES;
		[_loadView.button addTarget:self action:@selector(retryAction) forControlEvents:UIControlEventTouchDown];
		[self.tableView.mj_header endRefreshing];
		return;
	}

	[self.tableView.data removeAllObjects];
	for (int i = 0; i < 20; i++) {
		BookMarkModel *model = [[BookMarkModel alloc]init];
		model.title = [NSString stringWithFormat:@"%d",i];
		model.percentage = @"0.01";
		model.timestemp = @"2019-06-11 18:15:13";
		[self.tableView.data addObject:model];
	}
		//	NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc]initWithDictionary:@{@"token":[JPTool USER_TOKEN],@"id":self.bookId}];
		//	NSString *PathUrl = [JPTool BookcityBookPath];

	@WeakObj(self);
	[selfWeak.tableView.mj_header endRefreshing];
		//	[[JPNetWork sharedManager] requestPostMethodWithPathUrl:PathUrl WithParamsDict:paramsDict WithSuccessBlock:^(id responseObject) {
		//			//		NSLog(@"%@",responseObject);
		//		[selfWeak.tableView.data removeAllObjects];
		//		NSArray *array = responseObject[@"data"];
		//		for (int i = 0; i < array.count; i++) {
		//
		//			BookMarkModel *model = [BookMarkModel yy_modelWithJSON:array[i]];
		//			[selfWeak.tableView.data addObject:model];
		//		}
		//
		//		[selfWeak.tableView.mj_header endRefreshing];
	[selfWeak.tableView reloadData];
		//		[[ZJPAlert shareAlert] hiddenHUD];
		//		self->_loadView.hidden = YES;
		//
		//	} WithFailurBlock:^(NSError *error) {
		//		self->_loadView.loadFail = YES;
		//		self->_loadView.loadFailStatus = NO;
		//		[self->_loadView.button addTarget:self action:@selector(retryAction) forControlEvents:UIControlEventTouchDown];
		//	}];

}

- (void)retryAction {
	if (_loadView.loadFail == YES) {
		_loadView.loadFail = NO;
		[self pullRefreshData];
	}
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.tableView.data.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	static NSString *cellId = BookMarkTableViewCellId;
	BookMarkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
	if (!cell) {
		cell = [[BookMarkTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
		// 分割线
		//	if (indexPath.row == self.tableView.data.count-1) {
		//		cell.bottomLine.hidden = YES;
		//	}else{
		//		cell.bottomLine.hidden = NO;
		//	}
	BookMarkModel *model = self.tableView.data[indexPath.row];
	[cell setCellData:model AtIndexPath:indexPath];
	return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	if (tableView.editing) {

		[self changeBtnTitle];
	}else{
//		BookMarkModel *model = self.tableView.data[indexPath.row];
	}
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (tableView.editing) {

		[self changeBtnTitle];
	}
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 55;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
#pragma mark - 全选
- (IBAction)selectBtnClick:(UIButton *)sender {

	if (self.tableView.editing && self.tableView.data.count > 0) {

		if (_selectAll == NO) {

			NSArray *arr = [self.tableView indexPathsForRowsInRect:CGRectMake(0, 0, self.view.frame.size.width, self.tableView.contentSize.height)];
			/** 全选 **/
			[arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
				[self.tableView selectRowAtIndexPath:obj animated:YES scrollPosition:UITableViewScrollPositionNone];
			}];

		}else{

			NSArray *arr = [self.tableView indexPathsForRowsInRect:CGRectMake(0, 0, self.view.frame.size.width, self.tableView.contentSize.height)];
			/** 取消 全选 **/
			[arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
				[self.tableView deselectRowAtIndexPath:obj animated:YES];
			}];
		}

		[self changeBtnTitle];
	}
}


#pragma mark - 删除
- (IBAction)delectBtnClick:(UIButton *)sender {

	if (self.tableView.allowsMultipleSelectionDuringEditing) {
			// 获得所有被选中的行
		NSArray *indexPaths = [self.tableView indexPathsForSelectedRows];

			// 便利所有的行号
		for (NSIndexPath *path in indexPaths) {
			[self.selectedDataArr addObject:self.tableView.data[path.row]];
		}
			// 删除模型数据
		[self.tableView.data removeObjectsInArray:self.selectedDataArr];

			// 刷新表格  一定要刷新数据
		[self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
		[self changeBtnTitle];
		[self.tableView reloadData];
	}
}

- (void)changeBtnTitle {

	if (self.tableView.editing) {
		/*** 删除 的判断 **/
		NSArray *indexPaths = [self.tableView indexPathsForSelectedRows];
		NSString *title = [NSString stringWithFormat:@"删除(%ld)",indexPaths.count];
		if (indexPaths.count > 0) {// 只有选择数大于0 就是显示删除数量
			[self.delectBtn setTitle: title forState:UIControlStateNormal];
			[self.delectBtn setTitleColor:[UIColor colorWithHexString:@"fe3b30" alpha:1.0] forState:UIControlStateNormal];
		}else{
			[self.delectBtn setTitle: @"删除" forState:UIControlStateNormal];
			[self.delectBtn setTitleColor:[UIColor colorWithHexString:@"fe3b30" alpha:0.5] forState:UIControlStateNormal];
		}
		/*** 全选 和 取消全选 的判断 **/
		if (self.tableView.data.count > 0) {

			if (self.tableView.data.count == indexPaths.count) {
				[self.selectBtn setTitle:@"取消全选" forState:UIControlStateNormal];
				_selectAll = YES;
			}else{
				[self.selectBtn setTitle:@"全选" forState:UIControlStateNormal];
				_selectAll = NO;
			}
		}else{ // 删除了所有数据时，改变所有按钮的状态
			self.tableView.allowsMultipleSelectionDuringEditing = !self.tableView.allowsMultipleSelectionDuringEditing;
			[self.tableView setEditing:!self.tableView.editing animated:YES];
			self.rightItem.title = self.tableView.editing ? @"取消  ":@"管理  ";
			self.bottomView.hidden = YES;
			[self.selectBtn setTitle:@"全选" forState:UIControlStateNormal];
			self.tableView.frame  = CGRectMake(0, 0, [JPTool screenWidth], [JPTool screenHeight]-NavBarHeight);
			_selectAll = NO;
		}

	}

}
#pragma mark - Navigation

-(NSMutableArray *)selectedDataArr {
	if (!_selectedDataArr) {
		_selectedDataArr = [NSMutableArray array];
	}
	return _selectedDataArr;
}

@end
