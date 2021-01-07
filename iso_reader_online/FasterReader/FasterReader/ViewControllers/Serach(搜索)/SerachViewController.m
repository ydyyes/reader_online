	//
	//  SerachViewController.m
	//  NightReader
	//
	//  Created by 张俊平 on 2019/2/18.
	//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
	//

#import "SerachViewController.h"
#import "MSYTextField.h"

#import "SearchCollectionFlowLayout.h"
#import "SerachCollectionHeaderView.h"
#import "SerachTabViewCell.h"
#import "BookDetailViewController.h"
#import "SerachResultModel.h"

@interface SerachViewController ()
<UITextFieldDelegate,UICollectionViewDataSource,UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,UITableViewDelegate,
UITableViewDataSource,UIGestureRecognizerDelegate,UINavigationControllerDelegate
>

@property (nonatomic, strong) MSYTextField *searchTextField;
#pragma mark -- UICollectionView定义
@property (nonatomic, strong) UICollectionView *collectionView;

/** 热门搜索 数组 */
@property (nonatomic, strong) NSMutableArray *hotArray;
/** 历史搜索记录 数组 */
@property (nonatomic, strong) NSMutableArray *historyArray;
#pragma mark -- UITableView
@property (nonatomic, strong) BaseTableView *tableView;

/** 图书列表 */
@property (nonatomic, strong) NSMutableArray *bookArray;

/** 搜索内容  */
@property (nonatomic, readwrite , copy) NSString *serachString;

@end

static NSString *const collectionCellId = @"cellId";
static NSString *const collectionHeaderId = @"headerId";
static NSString *const collecitonFooterId = @"footerId";
static NSInteger historyNum = 6;//搜索历史数量

@implementation SerachViewController {
	
	int _page;//页码
}


- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self initNav];
	[self initCollectionView];
	[self initTableView];
	[self getSerachKeyData];
	[self.searchTextField becomeFirstResponder];
	
}

- (void)viewWillAppear:(BOOL)animated{
    
	[super viewWillAppear:animated];
	
	self.searchTextField.hidden = NO;

}

- (void)viewWillDisappear:(BOOL)animated {
	
	[super viewWillDisappear:animated];
	[self.searchTextField resignFirstResponder];
	self.searchTextField.hidden = YES;
	self.navigationController.delegate = nil;// 导航栏代理置为nil
	
}

#pragma mark - - 设置导航栏
- (void)initNav {
		//MARK:设置取消按钮
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(startSearch) image: [UIImage imageNamed:@"gray_sousuo"]];
    
		//MARK:设置输入框
	CGSize cancelSize = [@"取消" sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}];
	self.searchTextField = [[MSYTextField alloc] initWithFrame:CGRectMake(15, 5, [JPTool screenWidth] - cancelSize.width - 30 - 0, 32)];
    self.searchTextField.backgroundColor = [UIColor colorWithHexString:@"#F0F0F0"];
	self.searchTextField.font = [UIFont systemFontOfSize:15];
	self.searchTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	self.searchTextField.delegate = self;
	self.searchTextField.returnKeyType = UIReturnKeySearch;
	self.searchTextField.clearButtonMode = UITextFieldViewModeAlways;
	self.searchTextField.leftViewMode = UITextFieldViewModeAlways;
	self.searchTextField.textColor = RGB_COLOR(153, 153, 153);
    self.searchTextField.layer.cornerRadius = 16;
    
		//MARK:设置输入框提示属性
	UILabel * placeholderLabel = [self.searchTextField valueForKey:@"_placeholderLabel"];
	placeholderLabel.textAlignment = NSTextAlignmentCenter;
	self.searchTextField.placeholder = @" 请输入书名、作者";
	[self.searchTextField setValue:RGB_COLOR(153, 153, 153) forKeyPath:@"_placeholderLabel.textColor"];
	[self.searchTextField setValue:[UIFont systemFontOfSize:15] forKeyPath:@"_placeholderLabel.font"];
	self.searchTextField.tintColor = [UIColor lightGrayColor];
    self.navigationItem.titleView = self.searchTextField;
	
}

#pragma mark - - 取消按钮事件
- (void)startSearch {
	
    [self searchTextAction];
}

- (void)initCollectionView {
		// 自定义布局
//	SearchCollectionFlowLayout *flowLayout = [[SearchCollectionFlowLayout alloc] init];
	UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
	flowLayout.minimumLineSpacing = 15;// 最小行间距
	flowLayout.minimumInteritemSpacing = 0;// 最小列间距
	flowLayout.headerReferenceSize = CGSizeMake([JPTool screenWidth], 48);// section头视图
	flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;// 竖直方向移动
	// MARK:UIcollectionView初始化
	self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0,[JPTool screenWidth], [JPTool screenHeight]-NavBarHeight) collectionViewLayout:flowLayout];
	self.collectionView.backgroundColor = [UIColor whiteColor];
	self.collectionView.dataSource = self;
	self.collectionView.delegate = self;
	[self.view addSubview:self.collectionView];
	
	[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:collectionCellId];
	[self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:collectionHeaderId];
	[self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:collecitonFooterId];
		/// 添加手势 隐藏 键盘
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
	tap.delegate = self;
	[self.collectionView addGestureRecognizer:tap];
	
	if (@available(iOS 11.0, *)) {
		self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
	}else {
		self.automaticallyAdjustsScrollViewInsets = NO;
	}
	
}

-(void)tapClick{
	[self.searchTextField resignFirstResponder];
}
	// MARK:TableView初始化
- (void)initTableView {
	
	self.tableView = [[BaseTableView alloc] initWithFrame:CGRectMake(0, 0, [JPTool screenWidth], [JPTool screenHeight]-NavBarHeight) style:UITableViewStylePlain];
	self.tableView.backgroundColor = [UIColor lightGray_F2F2F2];
	self.tableView.bgViewStyle = BaseTableViewNOStyleIsCustom;
	self.tableView.tipsString  = @"暂无搜索内容";
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	[self.view addSubview:self.tableView];
	
	if (@available(iOS 11.0, *)) {
		self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
	}else {
		self.automaticallyAdjustsScrollViewInsets = NO;
	}
	
	self.tableView.hidden = YES;
	MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(pullRefreshData)];
		// 设置自动切换透明度(在导航栏下面自动隐藏)
	header.automaticallyChangeAlpha = YES;
		// 隐藏时间
	header.lastUpdatedTimeLabel.hidden = YES;
		// 马上进入刷新状态
		//	[header beginRefreshing];
	self.tableView.mj_header = header;
	
	__weak __typeof(self) weakSelf = self;
		// 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
	self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
		[weakSelf loadMoreData];
	}];
	
}

#pragma mark - **************** 数据请求 ******************
	//MARK:获取搜索关键字
- (void)getSerachKeyData {

	[self.historyArray removeAllObjects];

	NSArray *arr1 = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:@"historySearch"];;

	for (int i = 0; i < MIN(historyNum, arr1.count); i++) {
		[self.historyArray addObject:arr1[i]];
	}

	if (![ZJPNetWork netWorkAvailable]) {
		if ([[NSUserDefaults standardUserDefaults] objectForKey:@"SerachKeyData"]) {//获取缓存
			self.hotArray = (NSMutableArray *)[[NSUserDefaults standardUserDefaults] objectForKey:@"SerachKeyData"];
		}
		[ZJPAlert showAlertWithMessage:[JPTool NoNetWorkAlert] time:0.8];
		return;
	}
	@WeakObj(self);
		//MARK:
	NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc]initWithDictionary:@{@"token":@""}];
	[[JPNetWork sharedManager] requestPostMethodWithPathUrl:[JPTool BookshelfSerachKeyPath] WithParamsDict:paramsDict WithSuccessBlock:^(id responseObject) {
		
		[selfWeak.hotArray removeAllObjects];
		NSArray *array = responseObject[@"data"];
		if (array.count > 0) {

			for (int i = 0; i < array.count; i++) {

				[selfWeak.hotArray addObject:array[i]];
			}
			NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
			[userDefaults setValue:selfWeak.hotArray forKey:@"SerachKeyData"];// 加入缓存
			[userDefaults synchronize];
		}
		
		[selfWeak.collectionView reloadData];

	} WithFailurBlock:^(NSError *error) {
		
	}];
}
#pragma mark - 下拉刷新
- (void)pullRefreshData {
	[self pullRefreshData:self.serachString];
}

- (void)pullRefreshData:(NSString*)keyString {

	self.serachString = keyString;
		//MARK:
	if (![ZJPNetWork netWorkAvailable]) {
		[ZJPAlert showAlertWithMessage:[JPTool NoNetWorkAlert] time:1.5];
		[self.tableView.mj_header endRefreshing];
		return;
	}
	_page = 1;
	[self.tableView.mj_footer resetNoMoreData];
	NSString *page = [NSString stringWithFormat:@"%d",_page];
	NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc]initWithDictionary:@{@"token":[JPTool USER_TOKEN],@"key":keyString,@"page":page,@"size":@"10"}];
	
	@WeakObj(self);
	
	[[JPNetWork sharedManager] requestPostMethodWithPathUrl:[JPTool BookshelfSerachResultPath] WithParamsDict:paramsDict WithSuccessBlock:^(id responseObject) {
		
//		NSLog(@"%@",responseObject);
		[self.tableView.data removeAllObjects];
		NSArray *array = responseObject[@"data"];
		if (array.count > 0) {// 有数据

			for (int i = 0; i < array.count; i++) {

				SerachResultModel *model = [SerachResultModel yy_modelWithJSON:array[i]];
				[selfWeak.tableView.data addObject:model];
			}
				//MARK: 有数据就 保存到搜索历史
			[self saveHistoryWithString:keyString];
		}
		
		[[ZJPAlert shareAlert] hiddenHUD];
		[selfWeak.tableView reloadData];
		[selfWeak.tableView.mj_header endRefreshing];
		selfWeak.tableView.hidden = NO;

	} WithFailurBlock:^(NSError *error) {
		[self.tableView.mj_header endRefreshing];
	}];
	
}

	//MARK:加载更多
- (void)loadMoreData {
	
	if (![ZJPNetWork netWorkAvailable]) {
		[ZJPAlert showAlertWithMessage:[JPTool NoNetWorkAlert] time:1.5];
		[self.tableView.mj_footer endRefreshing];
		return;
	}
	@WeakObj(self);
	_page++;
	NSString *page = [NSString stringWithFormat:@"%d",_page];
	NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc]initWithDictionary:@{@"token":@"",@"key":self.serachString,@"page":page,@"size":@"10"}];
	
	[[JPNetWork sharedManager] requestPostMethodWithPathUrl:[JPTool BookshelfSerachResultPath] WithParamsDict:paramsDict WithSuccessBlock:^(id responseObject) {
		//		NSLog(@"%@",responseObject);
		[selfWeak.tableView.mj_footer endRefreshing];
		NSArray *array = responseObject[@"data"];

		if (array.count <= 0) {
			[selfWeak.tableView reloadData];
			[selfWeak.tableView.mj_footer endRefreshingWithNoMoreData];
		}else {
			for (int i = 0; i < array.count; i++) {
				SerachResultModel *model = [SerachResultModel yy_modelWithJSON:array[i]];
				[selfWeak.tableView.data addObject:model];
			}
			[selfWeak.tableView reloadData];
		}
		
		[[ZJPAlert shareAlert] hiddenHUD];
		
	} WithFailurBlock:^(NSError *error) {
		[self.tableView.mj_footer endRefreshing];
	}];
}
#pragma mark **************** 数据请求 ******************

#pragma mark - - UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	if (self.historyArray.count == 0) {
		if (self.hotArray.count == 0) {
			return 0;
		} else {
			return 1;
		}
	} else {
		if (self.hotArray.count == 0) {
			return 1;
		} else {
			return 2;
		}
	}
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	
	if (self.historyArray.count == 0) {
		if (self.hotArray.count == 0) {
			return 0;
		} else {
			return self.hotArray.count;
		}
	} else {
		if (self.hotArray.count == 0) {
			return self.historyArray.count;
		} else {
			if (section == 0) {
				return self.historyArray.count;
			} else {
				return self.hotArray.count;
			}
		}
	}
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	
	UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionCellId forIndexPath:indexPath];
	for (UIView *view in [cell.contentView subviews]){
		[view removeFromSuperview];
	}
	NSString *textString = @"";
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15,10 , ([JPTool screenWidth]-1)/2-30, 20)];
	if (self.historyArray.count == 0) {
		if (self.hotArray.count == 0) {
			return nil;// 都没有数据
		} else {
			textString = self.hotArray[indexPath.row];// 热门搜索有数据
			titleLabel.textAlignment = NSTextAlignmentLeft;
		}

	} else {

		if (self.hotArray.count == 0) {// 历史搜索有数据，热门没有数据
			textString = self.historyArray[indexPath.row];
		} else {// 都有数据
			if (indexPath.section == 0) {
				textString = self.historyArray[indexPath.row];
			} else {
				textString = self.hotArray[indexPath.row];
				titleLabel.textAlignment = NSTextAlignmentLeft;
			}
		}

	}

	CGSize titleSize = [textString sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}];
	if (self.historyArray.count > 0) {
		if (self.hotArray.count == 0) {
			titleLabel.frame = CGRectMake(15, 4 , titleSize.width+20 , 28);
			titleLabel.textAlignment = NSTextAlignmentCenter;
			titleLabel.layer.cornerRadius  = 8;
			titleLabel.layer.masksToBounds = YES;
			titleLabel.backgroundColor     = [UIColor lightGray_F0F0F0];
		}else{
			if (indexPath.section == 0) {
				titleLabel.frame = CGRectMake(15, 4 , titleSize.width+20 , 28);
				titleLabel.textAlignment = NSTextAlignmentCenter;
				titleLabel.layer.cornerRadius  = 8;
				titleLabel.layer.masksToBounds = YES;
				titleLabel.backgroundColor     = [UIColor lightGray_F0F0F0];
			}
		}
	}
	titleLabel.textColor = [UIColor black_222222];
	titleLabel.font = [UIFont systemFontOfSize:13];
	titleLabel.numberOfLines = 1;
	titleLabel.text = textString;
//	cell.backgroundColor   = [UIColor redColor];
	cell.backgroundColor   = [UIColor whiteColor];
	cell.contentView.backgroundColor = [UIColor whiteColor];
	[cell.contentView addSubview:titleLabel];

	return cell;
	
}
	// UIcollectionview设置段头段尾
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
	
	if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
		UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:collectionHeaderId forIndexPath:indexPath];
		for (UIView *view in [headerView subviews]){
			[view removeFromSuperview];
		}
		SerachCollectionHeaderView *collectionHeadView = [[SerachCollectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, [JPTool screenWidth], 48)];

		if (self.historyArray.count == 0) {
			if (self.hotArray.count == 0) {
				return nil;
			} else {
				collectionHeadView.headImageView.image = [UIImage imageNamed:@"remen"];
				collectionHeadView.titleLabel.text = @"热门搜索";
				collectionHeadView.clearButton.hidden = YES;
			}
		}else {

			if (self.hotArray.count == 0) {
				collectionHeadView.headImageView.image = [UIImage imageNamed:@"search_history"];
				collectionHeadView.titleLabel.text = @"搜索历史";
				collectionHeadView.clearButton.hidden = NO;
			} else {
				if (indexPath.section == 0) {
					collectionHeadView.headImageView.image = [UIImage imageNamed:@"search_history"];
					collectionHeadView.titleLabel.text = @"搜索历史";
					collectionHeadView.clearButton.hidden = NO;
				} else {
					collectionHeadView.headImageView.image = [UIImage imageNamed:@"search_hot"];
					collectionHeadView.titleLabel.text = @"热门搜索";
					collectionHeadView.clearButton.hidden = YES;
				}
			}

		}
		[collectionHeadView.clearButton addTarget:self action:@selector(clearHistoryData) forControlEvents:UIControlEventTouchUpInside];
		[headerView addSubview:collectionHeadView];
		
		return headerView;

	} else {
		return nil;
	}

}
	// 清除历史记录
- (void)clearHistoryData {
	[self.historyArray removeAllObjects];
	[[NSUserDefaults standardUserDefaults] setValue:self.historyArray forKey:@"historySearch"];
	[self.collectionView reloadData];
}
	// 设置cell样式
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
		NSString *titleString = @"";
	if (self.historyArray.count == 0) {
		if (self.hotArray.count == 0) {
			return CGSizeZero;
		} else {
			return CGSizeMake(([JPTool screenWidth]-1)/2.f, 40);
		}

	} else {
		if (self.hotArray.count == 0) {
			titleString = self.historyArray[indexPath.row];
		} else {
			if (indexPath.section == 0) {
				titleString = self.historyArray[indexPath.row];
			} else {
				return CGSizeMake(([JPTool screenWidth]-1)/2.f, 40);
			}
		}
	}

	CGSize titleSize = [titleString sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}];
	CGFloat cellWidth;
	if (titleSize.width + 30+20 < [JPTool screenWidth]-30) {
		cellWidth = titleSize.width + 30+20;
	} else {
		cellWidth = [JPTool screenWidth] - 30;
	}
	return CGSizeMake(cellWidth, titleSize.height + 20);

}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
	if (self.historyArray.count == 0) {
		return 0;
	} else {
		if (self.hotArray.count == 0) {
			return 15;
		} else {
			if (section == 0) {
				return 15;
			}else{
				return 0;
			}
		}
	}
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

	if (self.historyArray.count > 0) {
		if (indexPath.section == 0) {
			self.searchTextField.text = self.historyArray[indexPath.row];
		}else{
			self.searchTextField.text = self.hotArray[indexPath.row];
		}
	}else{
		self.searchTextField.text = self.hotArray[indexPath.row];
	}

    [self searchTextAction];
}

#pragma mark -- UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.tableView.data.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 90;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *cellId = @"SerachTabViewCell";
	SerachTabViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
	if (!cell) {//UITableViewCellStyleSubtitle
		cell = [[SerachTabViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
		cell.selectionStyle = UITableViewCellEditingStyleNone;
	}
	SerachResultModel *model = [self.tableView.data objectAtIndex:indexPath.row];
	[cell setCellDate:indexPath withDate:model];//设置数据显示
	return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	if (![ZJPNetWork netWorkAvailable]) {
		[ZJPAlert showAlertWithMessage:[JPTool NoNetWorkAlert] time:1.5];
		return;
	}
	BookDetailViewController *vc = [[BookDetailViewController alloc]init];
	SerachResultModel *model = [self.tableView.data objectAtIndex:indexPath.row];
	vc.bookId = model.bookId;
	vc.isForm = @"搜索";
	[self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - - UITextField


- (void)textFieldDidBeginEditing:(UITextField *)textField {
	_tableView.hidden = YES;
	[_tableView.data removeAllObjects];
	[_tableView reloadData];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
    // 显示搜索结果
	[self searchTextAction];
	return YES;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField {
	[self.tableView.data removeAllObjects];
	[self.tableView reloadData];
	self.tableView.hidden = YES;
	return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	
//	if (textField == self.searchTextField) {
//		if (string.length == 0) return YES;
//		
//		NSInteger existedLength = textField.text.length;
//		NSInteger selectedLength = range.length;
//		NSInteger replaceLength = string.length;
//		if (existedLength - selectedLength + replaceLength > 10) {
//			return NO;
//		}
//	}
	return YES;
}
#pragma mark -- 开始搜索
- (void)searchTextAction {
    
    NSString *text = [self.searchTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (text.length < 1 ) {//|| textField.text.length > 10
        [ZJPAlert showAlertWithMessage:@"请输入书名|作者" time:1.5];
        return ;
    }
    [self.searchTextField resignFirstResponder];
    
	[self pullRefreshData:text];
    
    [MobClick event:@"book_search" label:text];
    
}
#pragma mark -- 保存历史记录
- (void)saveHistoryWithString:(NSString *)string
{
	NSMutableArray *tempArr = [NSMutableArray arrayWithArray:self.historyArray];
	for (NSString *tempString in tempArr) {
		if ([string isEqualToString:tempString]) {
			[self.historyArray removeObject:tempString];
		}

	}
	[self.historyArray insertObject:string atIndex:0];
	if (self.historyArray.count > historyNum) {
		[self.historyArray removeLastObject];
	}
	[[NSUserDefaults standardUserDefaults] setValue:self.historyArray forKey:@"historySearch"];
	[self.collectionView reloadData];
}
#pragma mark - -- 键盘消失 --
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	[self.searchTextField resignFirstResponder];
}

#pragma mark - 手势代理  解决点击cell不响应问题
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
	if (touch.view != self.collectionView) {
		return NO;
	}
	return YES;
}

#pragma mark - lazy
- (NSMutableArray *)hotArray {
	if (!_hotArray) {
		_hotArray = [NSMutableArray array];
	}
	return _hotArray;
}

- (NSMutableArray *)bookArray {
	if (!_bookArray) {
		_bookArray = [NSMutableArray array];
	}
	return _bookArray;
}
- (NSMutableArray *)historyArray
{
	if (!_historyArray) {
		_historyArray = [NSMutableArray array];
	}
	return _historyArray;
}

@end
