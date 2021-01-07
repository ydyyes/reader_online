//
//  BookCategoryViewController.m
//  NightReader
//
//  Created by 张俊平 on 2019/5/17.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import "BookCategoryViewController.h"

#import "LeftTableViewCell.h"
#import "BookCityCollectionViewCell.h"
#import "BookCityCollectionReusableView.h"
#import "BookCityChartsViewController.h"// 排行榜 页面
#import "BookCateModel.h" //左边的分类 model
#import "BookCityBookModel.h" // 右边的书籍列表model

#import "BookDetailViewController.h"//书籍详情
#import "SerachViewController.h"

#define  left (([JPTool screenWidth]-80-16-4)/3.0-2)


@interface BookCategoryViewController ()
<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,
UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

/**  tableView */
@property (nonatomic, strong) UITableView *tableView;
/**  collectionView */
@property (nonatomic, strong) UICollectionView *collectionView;

/** 图书分类 */
@property (nonatomic, strong) NSMutableArray *catecManArray;
@property (nonatomic, strong) NSMutableArray *cateWomanArray;
@property (nonatomic, strong) NSMutableArray *cateArray;// 当前分类

/** 图书列表 */
@property (nonatomic, strong) NSMutableArray *bookArray;

/** 分类ID */
@property (nonatomic, readwrite , copy) NSString *m_id;
/** 分类名称 */
@property (nonatomic, readwrite , copy) NSString *cateName;
/** 性别 */
@property (nonatomic, readwrite , copy) NSString *sex;
@property (strong, nonatomic) UIButton *rightBtn;

@end

@implementation BookCategoryViewController
{
	NSInteger _selectRow;// 左边的分类选中下标
	int _page;
	JPLoadingView *_loadView;
	BOOL _isCanTap;// 没有刷新完毕，不让点击
}

static NSString *const collectionCellId = @"BookCityCollectionViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

	[self initNav];
	[self initTableView];
	[self initCollectionView];
	_selectRow = 0;
	_page = 1;
	_isCanTap = NO;
	_loadView = [[JPLoadingView alloc] initWithFrame:CGRectMake(0, 0, [JPTool screenWidth], [JPTool screenHeight])];
	[self.view addSubview:_loadView];
	[self getBookCateData];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

    [self.navigationController setNavigationBarHidden:NO animated:NO];

}

#pragma mark - - 数据请求
- (void)getBookCateData {
    //MARK:获取分类
    if (![ZJPNetWork netWorkAvailable]) {
        [ZJPAlert showAlertWithMessage:[JPTool NoNetWorkAlert] time:0.8];
        _loadView.loadFail = YES;
        _loadView.loadFailStatus = YES;
        [_loadView.button addTarget:self action:@selector(retryAction) forControlEvents:UIControlEventTouchDown];
        return;
    }
    @WeakObj(self);
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc]init];
    [[JPNetWork sharedManager] requestPostMethodWithPathUrl:[JPTool BookCategoryPath] WithParamsDict:paramsDict WithSuccessBlock:^(id responseObject) {
        
        //编辑推荐的sex要改为0,不区分男女

        // 第一条推荐
        BookCateModel *model1 = [[BookCateModel alloc]init];
        model1.cateId = @"";
        model1.name = @"编辑推荐";
//        model1.sex = @"1";
        model1.sex = @"0";
        BookCateModel *model2 = [[BookCateModel alloc]init];
        model2.cateId = @"";
        model2.name = @"编辑推荐";
//        model2.sex = @"2";
        model2.sex = @"0";
        self.m_id = model1.cateId;
        self.cateName = model1.name;
        [selfWeak.catecManArray addObject:model1];
        [selfWeak.cateWomanArray addObject:model2];
        
        NSDictionary *dict = responseObject[@"data"];
        NSArray *array1 = [NSArray yy_modelArrayWithClass:[BookCateModel class] json:dict[@"gentleman"] ];
        NSArray *array2 = [NSArray yy_modelArrayWithClass:[BookCateModel class] json:dict[@"lady"] ];
        
        for (int i = 0; i < array1.count; i++) {
            [selfWeak.catecManArray addObject:array1[i]];//男频
        }
        for (int i = 0; i < array2.count; i++) {
            [selfWeak.cateWomanArray addObject:array2[i]];//女频
        }
        // 默认为男频
        self.cateArray = self.catecManArray;
        self.sex = @"1";
        
        [selfWeak.tableView reloadData];
        //获取推荐接口
        [self pullRefreshData];
        
    } WithFailurBlock:^(NSError *error) {
        self->_loadView.loadFail = YES;
        self->_loadView.loadFailStatus = NO;
        [self->_loadView.button addTarget:self action:@selector(retryAction) forControlEvents:UIControlEventTouchDown];
    }];
}


- (void)initNav {
    self.navigationItem.title = @"分类";

//	self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(rightBtnClick) title:@"男频" titleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];

	self.rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	self.rightBtn.frame = CGRectMake([JPTool screenWidth]-65, 10, 55, 25);
	self.rightBtn.layer.cornerRadius = 6;
	self.rightBtn.layer.masksToBounds = YES;
    self.rightBtn.backgroundColor = [UIColor colorWithHexString:@"#2F94F9"];
	[self.rightBtn setTitle:@"男频" forState:UIControlStateNormal];
	[self.rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	self.rightBtn.titleLabel.font = [UIFont systemFontOfSize:15];
	[self.rightBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
	self.rightBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15);
	self.rightBtn.selected = NO;

    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:self.rightBtn];
    [self.navigationItem setRightBarButtonItem:rightItem];

}
#pragma mark - - 搜索
- (void)rightBtnClick:(UIButton*)sender {

    self.m_id = @"";
    _selectRow = 0;
    
	sender.selected = !sender.selected;
	if (sender.selected) {
		self.rightBtn.backgroundColor = [UIColor colorWithHexString:@"#FF5795"];
		[self.rightBtn setTitle:@"女频" forState:UIControlStateNormal];
		self.sex = @"2";
		self.cateArray = self.cateWomanArray;
	}else{
		[self.rightBtn setTitle:@"男频" forState:UIControlStateNormal];
		self.rightBtn.backgroundColor = [UIColor colorWithHexString:@"#2F94F9"];
		self.sex = @"1";
		self.cateArray = self.catecManArray;
	}
    //刷新左侧数据
	[self.tableView reloadData];
    //重置下拉刷新和上拉加载更多状态
    [self.collectionView.mj_header endRefreshing];
    [self.collectionView.mj_footer endRefreshing];
    self.collectionView.mj_footer = nil;
    //重新加载相当于刷新数据
    [self pullRefreshData];
}

#pragma mark - 下拉刷新
/// 下拉刷新
- (void)pullRefreshData {

    if (![ZJPNetWork netWorkAvailable]) {
        [ZJPAlert showAlertWithMessage:[JPTool NoNetWorkAlert] time:1.5];
        [self.collectionView.mj_header endRefreshing];
        return;
    }
    
    _page = 1;
    
    [[ZJPAlert shareAlert] showLoding];
    
    if(_selectRow == 0){
        [self getBookRecommendData];
    }else{
        [self getBookListData];
    }
}

#pragma mark - 推荐接口
- (void)getBookRecommendData {
    
    NSString *sex = self.sex;;
    if (_selectRow == 0) {
        //当获取的是推荐列表的话,不分男女!!
        sex = @"0";
    }
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc]initWithDictionary:@{@"gender":sex,@"page":@"1",@"size":@"12"}];
    [self getBookData:paramsDict withPath:[JPTool BookcityRecommendPath]];
}

#pragma mark - 书籍列表
- (void)getBookListData {
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc]initWithDictionary:@{@"token":[JPTool USER_TOKEN],@"m_id":self.m_id,@"page":@"1",@"size":@"12"}];
    [self getBookData:paramsDict withPath:[JPTool BookcityBookPath]];
}
/// 书籍列表
- (void)getBookData:(NSMutableDictionary*)paramsDict withPath:(NSString*)pathUrl {
    
    @WeakObj(self);
    [[JPNetWork sharedManager] requestPostMethodWithPathUrl:pathUrl WithParamsDict:paramsDict WithSuccessBlock:^(id responseObject) {
        
        [[ZJPAlert shareAlert] hiddenHUD];
        //删除原来的数据
        [self.bookArray removeAllObjects];
        // 转模型添加数据
        NSArray *array = responseObject[@"data"];
        for (int i = 0; i < array.count; i++) {
            BookCityBookModel *model = [BookCityBookModel yy_modelWithJSON:array[i]];
            [self.bookArray addObject:model];
        }
        // 刷新数据
        [selfWeak.collectionView reloadData];
        // 结束刷新
        [selfWeak.collectionView.mj_header endRefreshing];
        selfWeak.collectionView.contentOffset = CGPointMake(0, 0);
        //判断是都要添加,上拉加载更多
        if (self.bookArray.count >= 12) {
            self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
        }
        // 移除失败view
        [self->_loadView removeFromSuperview];
        
    } WithFailurBlock:^(NSError *error) {
        //删除原来的数据,刷新数据
        [self.bookArray removeAllObjects];
        [selfWeak.collectionView reloadData];
        // 结束刷新,重置上拉加载更多
        [selfWeak.collectionView.mj_header endRefreshing];
        selfWeak.collectionView.mj_footer = nil;
        // 隐藏loding
        [[ZJPAlert shareAlert] hiddenHUD];
    }];
}


#pragma mark - 上拉加载更多
- (void)loadMoreData {

	if (![ZJPNetWork netWorkAvailable])
    {
		[ZJPAlert showAlertWithMessage:[JPTool NoNetWorkAlert] time:1.5];
		[self.collectionView.mj_footer endRefreshing];
		return;
	}
	_page ++;
	NSString *pathString = @"";
	NSString *page = [NSString stringWithFormat:@"%d",_page];
	NSMutableDictionary *paramsDict;
    NSString *sex = self.sex;

    
	if(_selectRow == 0)
    {
        //当获取的是推荐列表的话,不分男女!!
        sex = @"0";
		pathString = [JPTool BookcityRecommendPath];
		paramsDict = [[NSMutableDictionary alloc]initWithDictionary:@{@"gender":sex,@"page":page,@"size":@"12"}];
	}else
    {
        // 其他分类
        pathString = [JPTool BookcityBookPath];
		paramsDict = [[NSMutableDictionary alloc]initWithDictionary:@{@"token":[JPTool USER_TOKEN],@"m_id":self.m_id,@"page":page,@"size":@"12"}];
	}
	[self loadMoreDataWithPath:pathString paramsDict:paramsDict];
}

- (void)loadMoreDataWithPath:(NSString*)pathUrl paramsDict:(NSMutableDictionary*)paramsDict {

	@WeakObj(self);
	[[JPNetWork sharedManager] requestPostMethodWithPathUrl:pathUrl WithParamsDict:paramsDict WithSuccessBlock:^(id responseObject) {

        NSArray *array = responseObject[@"data"];
		if (array.count <= 0)
        {
			[selfWeak.collectionView.mj_footer endRefreshingWithNoMoreData];
		}
        else
        {
            //添加数据
			for (int i = 0; i < array.count; i++)
            {
				BookCityBookModel *model = [BookCityBookModel yy_modelWithJSON:array[i]];
				[self.bookArray addObject:model];
			}
            //刷新collectionView
            [self.collectionView reloadData];
            //结束刷新
            [selfWeak.collectionView.mj_footer endRefreshing];
		}

	} WithFailurBlock:^(NSError *error) {
        [selfWeak.collectionView.mj_footer endRefreshing];
	}];

}

#pragma mark - - 初始化 collectionView
- (void)initCollectionView {
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(80+16, 0, [JPTool screenWidth]-80-16-4, [JPTool screenHeight]-NavBarHeight) collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = RGB_COLOR(255, 255, 255);
    [self.view addSubview:self.collectionView];
    
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;//UIScrollView也适用
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[BookCityCollectionViewCell class] forCellWithReuseIdentifier:collectionCellId];
    
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(pullRefreshData)];
    header.automaticallyChangeAlpha = YES;// 设置自动切换透明度(在导航栏下面自动隐藏)
    header.lastUpdatedTimeLabel.hidden = YES;// 隐藏时间
    self.collectionView.mj_header = header;
}

#pragma mark - CollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return self.bookArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

	BookCityCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionCellId forIndexPath:indexPath];
	BookCityBookModel *model = self.bookArray[indexPath.row];
	[cell setCellData:model];

	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

	if (![ZJPNetWork netWorkAvailable]) {
		[ZJPAlert showAlertWithMessage:[JPTool NoNetWorkAlert] time:1.5];
		return;
	}
	BookDetailViewController *vc = [[BookDetailViewController alloc]init];
	BookCityBookModel *model = self.bookArray[indexPath.row];
	vc.bookId = model.bookId;
	[self.navigationController pushViewController:vc animated:NO];

}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
		/// cell 的大小 每行显示3个 行间距为 0
	return [self fixSizeBydisplayWidth:self.collectionView.width col:3 space:0 sizeForItemAtIndexPath:indexPath];
}
- (CGSize)fixSizeBydisplayWidth:(float)displayWidth col:(int)col space:(int)space sizeForItemAtIndexPath:(NSIndexPath *)indexPath{

	float pxWidth = displayWidth * [UIScreen mainScreen].scale;
	pxWidth = pxWidth - space * (col - 1);
	int mo = (int)pxWidth % col;
	if (mo != 0) {
			// 屏幕宽度不可以平均分配
		float fixPxWidth = pxWidth - mo;
		float itemWidth = fixPxWidth / col;
			// 高度取最高的，所以要加1
		float itemHeight = (itemWidth-12)*138/103 + 1.0;// 高度
		if (indexPath.row % col < mo) {
				// 模再分配给左边的cell，直到分配完为止
			itemWidth = itemWidth + 1.0;
		}
			// 图片的高和宽的比值

		NSNumber *numW = @(itemWidth / [UIScreen mainScreen].scale);
		NSNumber *numH = @(itemHeight / [UIScreen mainScreen].scale);
		return CGSizeMake(numW.floatValue, numH.floatValue+48);

	}else {
			// 屏幕可以平均分配
		float itemWidth = (pxWidth / col)/ [UIScreen mainScreen].scale;
		float itemHeight = (itemWidth-12)*138/103+48;//170*[JPTool WidthScale];
		return CGSizeMake(itemWidth , itemHeight);
	}
}


#pragma mark - - 初始化
- (void)initTableView {
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 80, [JPTool screenHeight]-NavBarHeight) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor lightGray_F2F2F2];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //    self.tableView.bounces = NO;
    self.tableView.showsVerticalScrollIndicator = NO;//去掉滚动条
    //    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0);
    [self.view addSubview:self.tableView];
    
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cateArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellId = @"LeftTableViewCell";
    LeftTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[LeftTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    BookCateModel *model = self.cateArray[indexPath.row];
    cell.titleLb.text = model.name;
    if (_selectRow == indexPath.row) {
        cell.backgroundColor = [UIColor whiteColor];
        cell.leftSliderView.hidden = NO;
    }else{
        cell.backgroundColor = [UIColor lightGray_F2F2F2];
        cell.leftSliderView.hidden = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 
    _selectRow = indexPath.row;
    BookCateModel *model = self.cateArray[indexPath.row];
    self.m_id = model.cateId;
    self.sex = model.sex;
    self.cateName = model.name;
    
    //刷新左侧数据
    [self.tableView reloadData];
    //重置下拉刷新和上拉加载更多状态
    [self.collectionView.mj_header endRefreshing];
    [self.collectionView.mj_footer endRefreshing];
    self.collectionView.mj_footer = nil;
    //删除数据
    [self.bookArray removeAllObjects];
    [self.collectionView reloadData];
    //重新加载相当于刷新数据
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.collectionView.mj_header beginRefreshing];
//    });
    [self pullRefreshData];
    
    [MobClick event:@"book_class_click" label:model.name];

}

- (void)retryAction {
    if (_loadView.loadFail == YES) {
        _loadView.loadFail = NO;
        [self getBookCateData];
    }
}

#pragma mark - lazy
-(NSMutableArray *)cateArray {
	if (!_cateArray) {
		_cateArray = [[NSMutableArray alloc]init];
	}
	return _cateArray;
}

-(NSMutableArray *)bookArray {
	if (!_bookArray) {
		_bookArray = [[NSMutableArray alloc]init];
	}
	return _bookArray;
}
-(NSMutableArray *)catecManArray {
	if (!_catecManArray) {
		_catecManArray = [[NSMutableArray alloc]init];
	}
	return _catecManArray;
}
-(NSMutableArray *)cateWomanArray {
	if (!_cateWomanArray) {
		_cateWomanArray = [[NSMutableArray alloc]init];
	}
	return _cateWomanArray;
}

@end
