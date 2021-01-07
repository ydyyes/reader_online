//
//  BookCityViewController.m
//  NightReader
//
//  Created by 张俊平 on 2019/2/17.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import "BookCityViewController.h"

#import "LeftTableViewCell.h"
#import "BookCityCollectionViewCell.h"
#import "BookCityCollectionReusableView.h"
#import "BookCityChartsViewController.h"// 排行榜 页面
#import "BookCateModel.h" //左边的分类 model
#import "BookCityBookModel.h" // 右边的书籍列表model

#import "BookDetailViewController.h"//书籍详情
#import "SerachViewController.h"

#import "BookCategoryViewController.h"
#import "BookshelfBannerModel.h"//轮播图
#import "BookCityHeaderInSectionView.h"
#import "BookCityFooterInSectionView.h"
#import "BookCityTableViewCell.h"
#import "BookCityTableViewCellTwo.h"

#define  left (([JPTool screenWidth]-80-16-4)/3.0-2)

@interface BookCityViewController ()<UITableViewDelegate,UITableViewDataSource,SDCycleScrollViewDelegate>

/**  tableView */
@property (nonatomic, strong) UITableView *tableView;
/** 热门更新 */
@property (nonatomic, strong) NSMutableArray *hotUpdateArray;
/** 编辑推荐 */
@property (nonatomic, strong) NSMutableArray *recommendArray;
/** 热门搜索 */
@property (nonatomic, strong) NSMutableArray *hotSearchArray;
/** 新书榜 */
@property (nonatomic, strong) NSMutableArray *bookNewArray;
/** 完结 */
@property (nonatomic, strong) NSMutableArray *bookOverArray;

/** 图书列表 */
@property (nonatomic, strong) NSMutableDictionary *bookDict;

/** 轮播图包含的数据 */
@property (nonatomic, strong) NSMutableArray *bannerArray;
/** 轮播图图片url */
@property (nonatomic, strong) NSMutableArray *bannerImgArray;

/** 分类ID */
@property (nonatomic, readwrite , copy) NSString *m_id;
/** 分类名称 */
@property (nonatomic, readwrite , copy) NSString *cateName;
/** 性别 */
@property (nonatomic, readwrite , copy) NSString *sex;
@property(nonatomic,assign) NSInteger tagNum;


@end

@implementation BookCityViewController {
	JPLoadingView *_loadView;
}

static NSString *const collectionCellId = @"BookCityCollectionViewCell";
static NSString *const collectionHeaderId = @"BookCityCollectionReusableView";


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [MobClick event:@"book_mall_fragment"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];


    self.bookDict = [NSMutableDictionary dictionary];

    NSNumber *sexNumber = [JPTool USER_SEX];
	self.sex = [NSString stringWithFormat:@"%@",sexNumber];
	if ([self.sex isEqualToString:@"-1"]) {
		self.sex = @"0";
	}
	[self initNav];
	[self initHeaderView];
	[self initTableView];
	_loadView = [[JPLoadingView alloc] initWithFrame:CGRectMake(0, 0, [JPTool screenWidth], [JPTool screenHeight])];
	[self.view addSubview:_loadView];
	[self getBannersData];
	[self getBookCateData];

}

#pragma mark - - 搜索
- (void)initNav {
    
    //左边按钮
    UILabel *lefta = [[UILabel alloc] init];
    lefta.text = @"书城";
    lefta.textColor = [UIColor colorWithHexString:@"#333333"];
    lefta.font = [UIFont fontWithName: @"PingFangSC-Semibold" size: 16.0];
    lefta.frame = CGRectMake(0, 0, 40, 44);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: lefta];
    
    //右按钮
//    UIButton *right = [UIButton buttonWithType: UIButtonTypeCustom];
//    right.frame = CGRectMake(0, 0, 40, 44);
//    [right setImage:[UIImage imageNamed:@"liebiao_icon"] forState: UIControlStateNormal];
//    [right addTarget:self action:@selector(rightButtonClick) forControlEvents: UIControlEventTouchUpInside];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: right];

    //搜索
    CGFloat titleViewHeight = 28;
    UIButton *titleView = [[UIButton alloc] initWithFrame: CGRectMake(0, (44 - titleViewHeight) / 2, [JPTool screenWidth] - 100, titleViewHeight)];
    [titleView addTarget:self action:@selector(titleViewClick) forControlEvents: UIControlEventTouchUpInside];
    titleView.backgroundColor = [UIColor colorWithHexString:@"#F0F0F0"];
    titleView.layer.cornerRadius = titleViewHeight / 2;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"gray_sousuo"]];
    imageView.frame = CGRectMake(14, titleViewHeight / 2 - 4, 13, 13);
    [titleView addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(CGRectGetMaxX(imageView.frame) + 8, CGRectGetMinY(imageView.frame), 180, 14)];
    label.text = @"搜索书名、作者";
    label.font = [UIFont fontWithName: @"PingFangSC-Regular" size: 14.0];
    label.textColor = [UIColor colorWithHexString:@"#666666"];
    [titleView addSubview:label];
    self.navigationItem.titleView = titleView;
    
}
- (void)titleViewClick {

	SerachViewController *vc = [[SerachViewController alloc] init];
	[self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - - 头视图
- (void)initHeaderView {

	CGFloat height = 70*[JPTool WidthScale];
	self.buttonViewHeigh.constant = height;
    
	self.headerView.frame = CGRectMake(0, 0, [JPTool screenWidth], height+170*[JPTool WidthScale]);
//	[self.view addSubview:self.headerView];

	self.scrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentCenter;
	self.scrollView.currentPageDotColor = [UIColor whiteColor];
	self.scrollView.placeholderImage = [UIImage imageNamed:@"banner_bg"];
	self.scrollView.pageDotColor = [UIColor grayColor];
	self.scrollView.showPageControl = YES;
	self.scrollView.hidesForSinglePage = YES;
	self.scrollView.pageControlDotSize = CGSizeMake(8, 3);
	self.scrollView.pageControlBottomOffset = 2.0;// 分页控件距底部距离
	self.scrollView.autoScrollTimeInterval= 2;//自动滚动时间
	self.scrollView.delegate = self;
	self.tagNum = 100;
	[self setButtonConfigure:self.buttonOne];
	[self setButtonConfigure:self.buttonTwo];
	[self setButtonConfigure:self.buttonThree];
	[self setButtonConfigure:self.buttonFour];
	[self setButtonConfigure:self.buttonFive];
}
- (void)setButtonConfigure:(UIButton*)button {

	CGFloat margin = 8;
	if ([JPTool screenWidth] == 320) {
		margin = 5;
		button.titleLabel.font = [UIFont systemFontOfSize:10];
	}
	[button setImagePositionWithType:(SSImagePositionTypeTop) spacing:margin];//设置文字偏移
	self.tagNum++;
	button.tag = self.tagNum;
	[button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];

}
- (void)buttonClick:(UIButton*)button {
	NSLog(@"%ld,%ld",button.tag,self.tagNum);
	if (![ZJPNetWork netWorkAvailable]) {
		[ZJPAlert showAlertWithMessage:[JPTool NoNetWorkAlert] time:1.5];
		return;
	}
	if (button.tag == 101) {// 分类
		BookCategoryViewController *vc = [[BookCategoryViewController alloc]init];
		[self.navigationController pushViewController:vc animated:YES];
	}else{

		BookCityChartsViewController *vc = [[BookCityChartsViewController alloc]init];
		vc.titleType = button.titleLabel.text;
		vc.type = @"new";
		if (button.tag == 102) {//热门
			vc.type = @"hot";
		}else if (button.tag == 103) {//新书
			vc.type = @"new";
		}else if (button.tag == 104) {//口碑
			vc.type = @"reputation";
		}else {//tag == 104 完结
			vc.type = @"over";
		}
		[self.navigationController pushViewController:vc animated:YES];
	}

}
#pragma mark - - 初始化
- (void)initTableView {

    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat y = self.navigationController.navigationBar.bounds.size.height + statusBarHeight;
	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, y, [JPTool screenWidth], [JPTool screenHeight]-TabBarHeight-NavBarHeight) style:UITableViewStyleGrouped];
	self.tableView.backgroundColor = [UIColor lightGray_F2F2F2];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//	self.tableView.bounces = NO;
//	self.tableView.showsVerticalScrollIndicator = NO;//去掉滚动条
	self.tableView.tableHeaderView = self.headerView;
	[self.view addSubview:self.tableView];

	if (@available(iOS 11.0, *)) {
		self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
	}else {
		self.automaticallyAdjustsScrollViewInsets = NO;
	}
    self.extendedLayoutIncludesOpaqueBars = YES;
	MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(pullRefreshData)];

	header.automaticallyChangeAlpha = YES;// 设置自动切换透明度(在导航栏下面自动隐藏)
	header.lastUpdatedTimeLabel.hidden = YES;	// 隐藏时间
	//	[header beginRefreshing];// 马上进入刷新状态
	self.tableView.mj_header = header;
}
#pragma mark -***************** 数据请求 *****************
- (void)getBookCateData {
		//MARK:获取分类 
	if (![ZJPNetWork netWorkAvailable]) {
		[ZJPAlert showAlertWithMessage:[JPTool NoNetWorkAlert] time:1.0];
		_loadView.loadFail = YES;
		_loadView.loadFailStatus = YES;
		[_loadView.button addTarget:self action:@selector(retryAction) forControlEvents:UIControlEventTouchDown];
		return;
	}
	@WeakObj(self);
		//MARK:
	NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc]init];
	[[JPNetWork sharedManager] requestPostMethodWithPathUrl:[JPTool BookcityBookDataPath] WithParamsDict:paramsDict WithSuccessBlock:^(id responseObject) {

//		NSLog(@"%@",responseObject);
		NSDictionary *dict = responseObject[@"data"];
		NSArray *array1 = [NSArray yy_modelArrayWithClass:[BookCityBookModel class] json:dict[@"hot_update"] ];
		NSArray *array2 = [NSArray yy_modelArrayWithClass:[BookCityBookModel class] json:dict[@"hot_search"] ];
		NSArray *array3 = [NSArray yy_modelArrayWithClass:[BookCityBookModel class] json:dict[@"recommend"] ];
		NSArray *array4 = [NSArray yy_modelArrayWithClass:[BookCityBookModel class] json:dict[@"new"] ];
		NSArray *array5 = [NSArray yy_modelArrayWithClass:[BookCityBookModel class] json:dict[@"over"] ];
		selfWeak.hotUpdateArray = [NSMutableArray arrayWithArray:array1];//热门更新
		selfWeak.hotSearchArray = [NSMutableArray arrayWithArray:array2];//热门搜索
		selfWeak.recommendArray = [NSMutableArray arrayWithArray:array3];//编辑推荐
		selfWeak.bookNewArray  = [NSMutableArray arrayWithArray:array4];//热门更新
		selfWeak.bookOverArray = [NSMutableArray arrayWithArray:array5];//完结榜

		[selfWeak.tableView.mj_header endRefreshing];
		[selfWeak.tableView reloadData];
		[[ZJPAlert shareAlert] hiddenHUD];
		[self->_loadView removeFromSuperview];

	} WithFailurBlock:^(NSError *error) {
		self->_loadView.loadFail = YES;
		self->_loadView.loadFailStatus = NO;
		[self->_loadView.button addTarget:self action:@selector(retryAction) forControlEvents:UIControlEventTouchDown];
	}];
}
- (void)retryAction {
	if (_loadView.loadFail == YES) {
		_loadView.loadFail = NO;
		[self getBookCateData];
	}
}
#pragma mark - 下拉刷新
- (void)pullRefreshData {

	if (![ZJPNetWork netWorkAvailable]) {
		[ZJPAlert showAlertWithMessage:[JPTool NoNetWorkAlert] time:1.5];
		[self.tableView.mj_header endRefreshing];
		return;
	}
	[self getBannersData];
	[self getBookCateData];
}

//MARK:获取轮播图数据
- (void)getBannersData {

	if (![ZJPNetWork netWorkAvailable]) {
		[self bannerDataCache];// 缓存
		[ZJPAlert showAlertWithMessage:[JPTool NoNetWorkAlert] time:1.5];
		return;
	}
	NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc]initWithDictionary:@{@"token":[JPTool USER_TOKEN]}];
	[[JPNetWork sharedManager] requestPostMethodWithPathUrl:[JPTool BookshelfBannersPath] WithParamsDict:paramsDict WithSuccessBlock:^(id responseObject) {

		NSArray *array = responseObject[@"data"];
		if (array.count > 0)
		{
			[self.bannerArray removeAllObjects];
			[self.bannerImgArray removeAllObjects];

			NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
			[def setObject:array forKey:@"Banner_Data"];
			[def synchronize];

			for (int i = 0; i < array.count; i++) {
				BookshelfBannerModel *model = [BookshelfBannerModel yy_modelWithJSON:array[i]];
//				if (![model.type isEqualToString:@"ad"]) {//广告
					[self.bannerArray addObject:model];
					[self.bannerImgArray addObject:model.img];
//				}
			}
		}
		self.scrollView.imageURLStringsGroup = self.bannerImgArray;// 更新

	} WithFailurBlock:^(NSError *error) {

	}];
}
- (void)bannerDataCache {

	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Banner_Data"]) {

		NSArray *array = (NSArray*)[[NSUserDefaults standardUserDefaults] objectForKey:@"Banner_Data"];
		if (array.count != 0) {

			for (int i = 0; i < array.count; i++) {
				BookshelfBannerModel *model = [BookshelfBannerModel yy_modelWithJSON:array[i]];
				if (![model.type isEqualToString:@"ad"]) {//广告
					[self.bannerArray addObject:model];
					[self.bannerImgArray addObject:model.img];
				}
			}
		}
	}

}
#pragma mark -***************** 数据请求 *****************
#pragma mark - - 轮播图代理 SDCycelScrollViewDelegate
/** 点击图片回调 */
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {

	if (![ZJPNetWork netWorkAvailable]) {
		[ZJPAlert showAlertWithMessage:[JPTool NoNetWorkAlert] time:1.5];
		return;
	}
	BookshelfBannerModel *model = self.bannerArray[index];
	if ([model.type isEqualToString:@"ad"]) {//广告
		if(@available(iOS 10.0, *)) {
				//ios10及以后
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:model.link] options:@{} completionHandler:nil];
		}else{
				//ios10之前
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:model.link]];
		}

	}else{// 进入小说详情页面
		BookDetailViewController *BookDetailVc = [[BookDetailViewController alloc] init];
		BookDetailVc.bookId = model.fid;
		[self.navigationController pushViewController:BookDetailVc animated:YES];
	}

}

/** 图片滚动回调 */
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didScrollToIndex:(NSInteger)index {
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 5;
}
// MARK:每组的cell个数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section%2 == 0)
    {
		if (section == 0)
        {
			if (self.hotUpdateArray.count>0)
            {
				if (self.hotUpdateArray.count > 1)
                {
					return 2;
				}
                else
                {
					return 1;
				}
			}
            else
            {
				return 0;
			}
		}
        else if(section == 2)
        {
			if (self.hotSearchArray.count>0)
            {
				if (self.hotSearchArray.count > 1)
                {
					return 2;
				}
                else
                {
					return 1;
				}
			}
            else
            {
				return 0;
			}
		}
        else
        {//4
			if (self.bookOverArray.count>0) {
				if (self.bookOverArray.count > 1) {
					return 2;
				}else{
					return 1;
				}
			}else{
				return 0;
			}
		}
	}
    else
    {
		if (section == 1) {
			return self.recommendArray.count;
		}else if(section == 3){
			return self.bookNewArray.count;
		}else{
			return 0;
		}
	}

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section%2 == 0) {
		if (indexPath.row == 0) {
			return [JPTool getSizeWithOther:25].height;
		}else{
			return [JPTool getSizeWithOther:55].height;
		}
	}
	return [JPTool getSizeWithOther:25].height;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	if (indexPath.section%2 == 0){
		NSLog(@"indexPath.section:%ld",indexPath.section);
//	MARK:四个的cell
		BookCityTableViewCellTwo *cell1 = [tableView dequeueReusableCellWithIdentifier:BookCityTableViewCellTwoId];
		cell1 = [[BookCityTableViewCellTwo alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BookCityTableViewCellTwoId];
		cell1.selectionStyle = UITableViewCellSelectionStyleNone;
//	MARK:单个的cell
		BookCityTableViewCell *cell2 = [tableView dequeueReusableCellWithIdentifier:BookCityTableViewId];
		cell2 = [[BookCityTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BookCityTableViewId];
		cell2.selectionStyle = UITableViewCellSelectionStyleNone;

		if (indexPath.row==1) {

			if (indexPath.section == 0) {
				cell1.bookArray = self.hotUpdateArray;
			}else if (indexPath.section == 2){
				cell1.bookArray = self.hotSearchArray;
			}else if (indexPath.section == 4){
				cell1.bookArray = self.bookOverArray;
			}
			return cell1;
		}else{

			if (indexPath.section == 0) {
				[cell2 setCellData:self.hotUpdateArray AtIndexPath:indexPath];
			}else if (indexPath.section == 2){
				[cell2 setCellData:self.hotSearchArray AtIndexPath:indexPath];
			}else if (indexPath.section == 4){
				[cell2 setCellData:self.bookOverArray AtIndexPath:indexPath];
			}
			return cell2;
		}

	}else{
		BookCityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BookCityTableViewId];
		cell = [[BookCityTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BookCityTableViewId];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		if (indexPath.section == 1) {
		[cell setCellData:self.recommendArray AtIndexPath:indexPath];
		}else if (indexPath.section == 3){
		[cell setCellData:self.bookNewArray AtIndexPath:indexPath];
		}
		return cell;
	}


}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"didSelectRow:%ld",indexPath.row);
	BookCityBookModel *model = nil;
	if (indexPath.section == 0) {// 热门更新
		model = self.hotUpdateArray[indexPath.row];
	}else if (indexPath.section == 1){// 编辑推荐
		model = self.recommendArray[indexPath.row];
	}else if (indexPath.section == 2){// 热门搜索
		model = self.hotSearchArray[indexPath.row];
	}else if (indexPath.section == 3){// 新书榜
		model = self.bookNewArray[indexPath.row];
	}else {// 完结榜
		model = self.bookOverArray[indexPath.row];
	}
	BookDetailViewController *BookDetailVc = [[BookDetailViewController alloc] init];
	BookDetailVc.bookId = model.bookId;
	[self.navigationController pushViewController:BookDetailVc animated:YES];
}
// MARK:组头
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

	BookCityHeaderInSectionView *headerView = [[BookCityHeaderInSectionView alloc]initWithFrame:CGRectMake(0, 0, [JPTool screenWidth], 30)];
	headerView.lineHeigh = 5;
	headerView.titleLabel.text = @"";
	if (section == 0) {
		if (self.hotUpdateArray.count == 0) {
			return nil;
		}
		headerView.lineHeigh = 1;
		headerView.titleLabel.text = @"热门更新";
	}else if (section == 1) {
		if (self.recommendArray.count == 0) {
			return nil;
		}
		headerView.lineHeigh = 5;
		headerView.titleLabel.text = @"编辑推荐";
	}else if (section == 2){
		if (self.hotSearchArray.count == 0) {
			return nil;
		}
		headerView.lineHeigh = 5;
		headerView.titleLabel.text = @"热门搜索";
	}else if (section == 3){
		if (self.bookNewArray.count == 0) {
			return nil;
		}
		headerView.lineHeigh = 5;
		headerView.titleLabel.text = @"新书榜";
	}else{
		if (self.bookOverArray.count == 0) {
			return nil;
		}
		headerView.lineHeigh = 5;
		headerView.titleLabel.text = @"完结榜";
	}
	NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:headerView.titleLabel.text];
	[attributedString addAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:16],
												 NSForegroundColorAttributeName:[UIColor black_222222]}
									  range:NSMakeRange(0, headerView.titleLabel.text.length)];//加粗字体
	headerView.titleLabel.attributedText = attributedString;
	headerView.moreButton.tag = 100+section;
	[headerView.moreButton addTarget:self action:@selector(moreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
	return headerView;
}
// MARK:组尾
- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	return [UIView new];
}
// MARK:组头的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section == 0) {// 热门更新
		if (self.hotUpdateArray.count == 0) {
			return 0;
		}
	}else if (section == 1) {// 编辑推荐
		if (self.recommendArray.count == 0) {
			return 0;
		}
	}else if (section == 2){// 热门搜索
		if (self.hotSearchArray.count == 0) {
			return 0;
		}
	}else if (section == 3){// 新书榜
		if (self.bookNewArray.count == 0) {
			return 0;
		}
	}else{// 完结榜
		if (self.bookOverArray.count == 0) {
			return 0;
		}
	}
	return 40.f;
}
// MARK:组尾的高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return 0;//0.01f
}
//MARK:更多
- (void)moreButtonClick:(UIButton*)button {
	NSInteger section = button.tag-100;
		NSLog(@"%ld-%@",section,button.titleLabel.text);
	BookCityChartsViewController *vc = [[BookCityChartsViewController alloc]init];
	if (section == 0) {// 热门更新
		vc.titleType = @"热门更新";
		vc.type = @"1";
	}else if (section == 1) {// 编辑推荐
		vc.titleType = @"编辑推荐";
		vc.type = @"-1";
	}else if (section == 2) {// 热门搜索
		vc.titleType = @"热门搜索";
		vc.type = @"2";
	}else if (section == 3) {// 新书榜
		vc.titleType = @"新书榜";
		vc.type = @"new";
	}else if (section == 4) {// 完结榜
		vc.titleType = @"完结榜";
		vc.type = @"over";
	}else{
	}
	[self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - lazy

-(NSMutableArray *)bannerArray {
	if (!_bannerArray) {
		_bannerArray = [[NSMutableArray alloc]init];
	}
	return _bannerArray;
}
-(NSMutableArray *)bannerImgArray {
	if (!_bannerImgArray) {
		_bannerImgArray = [[NSMutableArray alloc]init];
	}
	return _bannerImgArray;
}
- (NSMutableArray *)hotUpdateArray {
	if (!_hotUpdateArray) {
		_hotUpdateArray = [[NSMutableArray alloc]init];
	}
	return _hotUpdateArray;
}
- (NSMutableArray *)recommendArray {
	if (!_recommendArray) {
		_recommendArray = [[NSMutableArray alloc]init];
	}
	return _recommendArray;
}
- (NSMutableArray *)hotSearchArray {
	if (!_hotSearchArray) {
		_hotSearchArray = [[NSMutableArray alloc]init];
	}
	return _hotSearchArray;
}
- (NSMutableArray *)bookNewArray {
	if (!_bookNewArray) {
		_bookNewArray = [[NSMutableArray alloc]init];
	}
	return _bookNewArray;
}
- (NSMutableArray *)bookOverArray {
	if (!_bookOverArray) {
		_bookOverArray = [[NSMutableArray alloc]init];
	}
	return _bookOverArray;
}

@end
