//
//  BookDetailViewController.m
//  NightReader
//
//  Created by 张俊平 on 2019/2/28.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import "BookDetailViewController.h"
#import "FasterReader-Swift.h"

#import "BookDetailTableViewCell.h"
#import "BookCityChartsModel.h"
#import "BookCityBookModel.h"
#import "UIView+AZGradient.h"
#import "ADSherfCache.h"
#import "ADPageViewController.h"
#import "BookCityViewController.h"// 书城
#import "SerachViewController.h" // 搜索
#import "BookCityChartsViewController.h" // 榜单
#import "BookCategoryViewController.h" // 分类

#import "UIControl+JPBtnClickDelay.h"
#import "LCPicShowerViewController.h"
#import "XXNavigationController.h"

#define sendNotification(key)     [[NSNotificationCenter defaultCenter] postNotificationName:key object:self userInfo:nil];

@interface BookDetailViewController ()<UITableViewDelegate,UITableViewDataSource>

/** 头视图 */
@property (strong, nonatomic) IBOutlet UIView *headView;
/** 头视图虚化背景 */
@property (strong, nonatomic) IBOutlet UIImageView *headViewbackImg;
/** 书图片 */
@property (strong, nonatomic) IBOutlet UIImageView *bookImg;
@property (strong, nonatomic) IBOutlet UIImageView *bookStateImg;
@property (strong, nonatomic) IBOutlet UILabel *bookName;
@property (strong, nonatomic) IBOutlet UILabel *followLb;
@property (strong, nonatomic) IBOutlet UILabel *characterNumLb;
@property (strong, nonatomic) IBOutlet UILabel *majorCateLb;
@property (strong, nonatomic) IBOutlet UIImageView *start1;
@property (strong, nonatomic) IBOutlet UIImageView *start2;
@property (strong, nonatomic) IBOutlet UIImageView *start3;
@property (strong, nonatomic) IBOutlet UIImageView *start4;
@property (strong, nonatomic) IBOutlet UIImageView *start5;
/// 古代言情
@property (strong, nonatomic) IBOutlet UIButton *cateOneBtn;
/// 古代言情
@property (strong, nonatomic) IBOutlet UIButton *cateTwoBtn;
@property (strong, nonatomic) IBOutlet UILabel *ratioLb;//留存率
@property (strong, nonatomic) IBOutlet UILabel *updateCount;//日更新字数
/** 头视图中 标题和头视图之间的距离 */
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topSapceWithHeadView;
/** 书籍描述 */
@property (strong, nonatomic) IBOutlet UILabel *bookDescLb;
/** 返回按钮 */
@property (strong, nonatomic) IBOutlet UIButton *backBtn;

/** 底部视图高 */
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeight;
/** 底部左边加入书架按钮 */
@property (strong, nonatomic) IBOutlet UIButton *bottomLeftBtn;
/** 底部右边开始阅读按钮 */
@property (strong, nonatomic) IBOutlet UIButton *bottomRightBtn;

/** tableView */
@property (nonatomic, strong) BaseTableView *tableView;

/** 推荐列表 */
@property (nonatomic, strong) NSMutableArray *bookArray;

/** 头视图书籍字典  */
@property (nonatomic, strong) NSDictionary *bookDetailDict;

@property (nonatomic, strong) UIView *maskView;//蒙版
@property (nonatomic, strong) UIImage *maskImg;//蒙版

@end

@implementation BookDetailViewController{
	JPLoadingView *_loadView;
	BOOL _show;//展开
	CGFloat _headViewHeight;
}

- (void)dealloc {
	self.navigationController.delegate = nil;// 导航栏代理置为nil
}
- (void)viewDidLoad {
    [super viewDidLoad];

		//	self.title = @"书籍详情";

	[self initTableView];
	_loadView = [[JPLoadingView alloc] initWithFrame:CGRectMake(0, 0, [JPTool screenWidth], [JPTool screenHeight])];
	[self.view addSubview:_loadView];

	[self getBookDetailData];

}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:YES animated:NO];

		//MARK: 小说是否存在（主要是用来判读阅读返回加入书架，更新“加入书架”按钮文字显示）
	if (self.bookDetailDict[@"id"] && [ADSherfCache queryWithBookId:self.bookDetailDict[@"id"]]) {
		[self.bottomLeftBtn setTitle:@"取消添加" forState:UIControlStateNormal];
	}else{
		[self.bottomLeftBtn setTitle:@"加入书架" forState:UIControlStateNormal];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - - 初始化
- (void)initTableView {

	self.bottomViewHeight.constant = [JPTool is_iPhoneXN] ? 60 : 50;

	self.tableView = [[BaseTableView alloc] initWithFrame:CGRectMake(0, 0, [JPTool screenWidth], [JPTool screenHeight]-self.bottomViewHeight.constant) style:UITableViewStyleGrouped];
	self.tableView.backgroundColor = [UIColor lightGray_F2F2F2];
	self.tableView.bgViewStyle = BaseTableViewNOStyleIsCustom;
	self.tableView.tipsString = @"暂无推荐书单";
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.bounces = NO;
	self.topSapceWithHeadView.constant = StatusBarHeight+10;
	self.tableView.tableHeaderView = self.headView;
//	self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];

	[self.view layoutIfNeeded];
	[self.view addSubview:self.tableView];

	if (@available(iOS 11.0, *)) {
		self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
	}else {
		self.automaticallyAdjustsScrollViewInsets = NO;
	}
}

#pragma mark - - 数据请求
- (void)getBookDetailData {

	if (![ZJPNetWork netWorkAvailable]) {
		[ZJPAlert showAlertWithMessage:[JPTool NoNetWorkAlert] time:1.5];
		_loadView.loadFail = YES;
		_loadView.loadFailStatus = YES;
		[_loadView.button addTarget:self action:@selector(retryAction) forControlEvents:UIControlEventTouchDown];
		return;
	}
	@WeakObj(self);
		//MARK:
	NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc]initWithDictionary:@{@"id":self.bookId}];
	if ([_isForm isEqualToString:@"搜索"]) {
	paramsDict = [[NSMutableDictionary alloc]initWithDictionary:@{@"id":self.bookId,@"hot_search":@"1"}];
	}

	[[JPNetWork sharedManager] requestPostMethodWithPathUrl:[JPTool BookshelfBookDetailPath] WithParamsDict:paramsDict WithSuccessBlock:^(id responseObject) {

		[selfWeak.tableView.data removeAllObjects];
		if ([responseObject[@"errorno"] integerValue] <=200 && responseObject[@"data"]) {

			NSArray *array = responseObject[@"data"][@"recommend"];
			selfWeak.bookDetailDict =  responseObject[@"data"][@"detail"];
			[selfWeak updateHeadViewData:responseObject[@"data"][@"detail"]];// 刷新数据

			for (int i = 0; i < array.count; i++) {// 推荐

				BookCityChartsModel *model = [BookCityChartsModel yy_modelWithJSON:array[i]];
				[selfWeak.tableView.data addObject:model];
			}

			[selfWeak.tableView reloadData];
			self->_loadView.hidden = YES;
		}else if ([responseObject[@"errorno"] integerValue] == 400104) {
			[self.navigationController popViewControllerAnimated:YES];
		}

		[[ZJPAlert shareAlert] hiddenHUD];


	} WithFailurBlock:^(NSError *error) {
		self->_loadView.loadFail = YES;
		self->_loadView.loadFailStatus = NO;
		[self->_loadView.button addTarget:self action:@selector(retryAction) forControlEvents:UIControlEventTouchDown];
	}];
}

- (void)retryAction {
	if (_loadView.loadFail == YES) {
		_loadView.loadFail = NO;
		[self getBookDetailData];
	}
}

#pragma mark - 字符串转化 @"10000"-> 1万
- (NSString*)changeString:(NSString*)str {

	NSInteger intValue = [str integerValue];
	if (intValue > 10000.0) {
		return [NSString stringWithFormat:@"%.f 万字",ceil(intValue/10000.0)];
	}else{
		return [NSString stringWithFormat:@"%@ 字",str];
	}
}
/// 判断是否小于0 (negative Number 负数)
- (NSString*)negativeNumberString:(NSString*)str {

	NSInteger intValue = [str integerValue];
	if (intValue < 0.0) {
		return @"0";
	}else{
		return [NSString stringWithFormat:@"%@",str];
	}
}

#pragma mark -- 刷新头视图数据
- (void)updateHeadViewData:(NSDictionary*)dict {

	NSURL *url = [NSURL URLWithString:dict[@"cover"]];
	[self.bookImg yy_setImageWithURL:url placeholder:[UIImage imageNamed:@"zhanweitu"]];//书籍封面图
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]init];
	[tap addTarget:self action:@selector(bookImgTapClick:)];
	self.bookImg.userInteractionEnabled = YES;
	[self.bookImg addGestureRecognizer:tap];//添加手势 查看大图

	self.bookName.text = dict[@"title"];// 小说名称
	self.followLb.text = dict[@"latelyFollower"];//追书人数
	self.characterNumLb.text = [self changeString:dict[@"wordCount"]];// 章节字数
	self.majorCateLb.text = [NSString stringWithFormat:@"%@ | %@",dict[@"majorCate"],dict[@"author"]];
	self.ratioLb.text    = [NSString stringWithFormat:@"%@%%",dict[@"retentionRatio"]];// 留存率

	self.updateCount.text = [self negativeNumberString:dict[@"serializeWordCount"]];// 更新字数

	//MARK: 小说的类型 例如 古代言情
	NSArray *tagsArr = [dict[@"tags"] componentsSeparatedByString:@","];
	if (tagsArr.count < 2) {
		self.cateOneBtn.hidden = YES;
		self.cateTwoBtn.hidden = YES;
	}else{
		self.cateOneBtn.hidden = NO;
		self.cateTwoBtn.hidden = NO;
		[self.cateOneBtn setTitle:tagsArr[0] forState:UIControlStateNormal];
		[self.cateTwoBtn setTitle:tagsArr[1] forState:UIControlStateNormal];
	}
	//MARK: 是否完结
	if ([dict[@"over"] isEqualToString:@"1"]) {//完结
		self.bookStateImg.image = [UIImage imageNamed:@"wangjie"];
	}else{//连载
		self.bookStateImg.image = [UIImage imageNamed:@"lianzai"];
	}

	//MARK: 星星 等级 2分为1星
	NSInteger start = floor([dict[@"score"] integerValue]/2);//floor 向下取整

	if (start == 1) {
		self.start1.image = [UIImage imageNamed:@"dengji"];
		self.start2.image = [UIImage imageNamed:@"huise"];
		self.start3.image = [UIImage imageNamed:@"huise"];
		self.start4.image = [UIImage imageNamed:@"huise"];
		self.start5.image = [UIImage imageNamed:@"huise"];
	}else if (start == 2){
		self.start1.image = [UIImage imageNamed:@"dengji"];
		self.start2.image = [UIImage imageNamed:@"dengji"];
		self.start3.image = [UIImage imageNamed:@"huise"];
		self.start4.image = [UIImage imageNamed:@"huise"];
		self.start5.image = [UIImage imageNamed:@"huise"];
	}else if (start == 3){
		self.start1.image = [UIImage imageNamed:@"dengji"];
		self.start2.image = [UIImage imageNamed:@"dengji"];
		self.start3.image = [UIImage imageNamed:@"dengji"];
		self.start4.image = [UIImage imageNamed:@"huise"];
		self.start5.image = [UIImage imageNamed:@"huise"];
	}else if (start == 4){
		self.start1.image = [UIImage imageNamed:@"dengji"];
		self.start2.image = [UIImage imageNamed:@"dengji"];
		self.start3.image = [UIImage imageNamed:@"dengji"];
		self.start4.image = [UIImage imageNamed:@"dengji"];
		self.start5.image = [UIImage imageNamed:@"huise"];
	}else if (start == 5){
		self.start1.image = [UIImage imageNamed:@"dengji"];
		self.start2.image = [UIImage imageNamed:@"dengji"];
		self.start3.image = [UIImage imageNamed:@"dengji"];
		self.start4.image = [UIImage imageNamed:@"dengji"];
		self.start5.image = [UIImage imageNamed:@"dengji"];
	}

	//MARK: 书籍介绍
	NSString *descStr = dict[@"longIntro"] ? dict[@"longIntro"]:@"";
	self.bookDescLb.attributedText = [CalculateLabels getAttributedStringWithString:descStr lineSpace:7];
	CGSize bookDescSize = [CalculateLabels getStringSize:descStr fontOfSize:15 lineSpacing:7 width:[JPTool screenWidth]-30 height:(MAXFLOAT)];

	_headViewHeight = 280+self.topSapceWithHeadView.constant+bookDescSize.height;
	if (bookDescSize.height < (15+7)*4+5) {
		self.bookDescLb.textAlignment = NSTextAlignmentJustified;
		self.bookDescLb.lineBreakMode = NSLineBreakByWordWrapping;
		_headViewHeight = 280+self.topSapceWithHeadView.constant+bookDescSize.height;
	}else{
		self.bookDescLb.textAlignment = NSTextAlignmentJustified;
		self.bookDescLb.lineBreakMode = NSLineBreakByTruncatingTail;//www...
		_headViewHeight = 280+self.topSapceWithHeadView.constant+(15+7)*4;
		UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]init];
		[tap addTarget:self action:@selector(bookDescLbTapClick:)];
		[self.bookDescLb addGestureRecognizer:tap];
		self.bookDescLb.userInteractionEnabled = YES;
		_show = YES;
	}

	[self.bookDescLb sizeToFit];
	[self addMsskView:_headViewHeight];//添加蒙版
	self.tableView.tableHeaderView.height = _headViewHeight;

	//MARK: 小说是否存在
	if ([ADSherfCache queryWithBookId:dict[@"id"]]) {
		[self.bottomLeftBtn setTitle:@"取消添加" forState:UIControlStateNormal];
	}else{
		[self.bottomLeftBtn setTitle:@"加入书架" forState:UIControlStateNormal];
	}
}

#pragma mark -高斯模糊
- (void)addMsskView:(CGFloat)height {

	UIBlurEffect * blur = [UIBlurEffect effectWithStyle:(UIBlurEffectStyleExtraLight)];
	UIVisualEffectView * effe = [[UIVisualEffectView alloc]initWithEffect:blur];
	effe.frame = CGRectMake(0,0, [JPTool screenWidth],height);//高斯模糊

	self.maskImg = [[UIImage alloc]init];
	self.maskImg = [self.bookImg.image scaleImageToSize:CGSizeMake([JPTool screenWidth]*6, [JPTool screenHeight]*5)];//放大
	self.maskImg = [self.maskImg clipImageWithClipRect:CGRectMake([JPTool screenWidth]*4.5, 0, [JPTool screenWidth]*1, [JPTool screenHeight])];//裁剪
	self.maskView.height = height;
	self.headViewbackImg.image = self.maskImg;
	[self.headViewbackImg addSubview:effe];
	[self.headViewbackImg addSubview:self.maskView];
}

#pragma mark -小说简介展示
- (void)bookDescLbTapClick:(UIGestureRecognizer*)tap {

	CGSize bookDescSize = [CalculateLabels getStringSize:self.bookDescLb.text fontOfSize:15 lineSpacing:7 width:[JPTool screenWidth]-30 height:(MAXFLOAT)];
//	CGFloat headViewHeight = 280+self.topSapceWithHeadView.constant+bookDescSize.height;
	if (_show) {// 展开
		self.bookDescLb.textAlignment = NSTextAlignmentJustified;
		self.bookDescLb.lineBreakMode = NSLineBreakByWordWrapping;
		_headViewHeight = 280+self.topSapceWithHeadView.constant+bookDescSize.height;
		_show = NO;
	}else{// 收起
		self.bookDescLb.textAlignment = NSTextAlignmentJustified;
		self.bookDescLb.lineBreakMode = NSLineBreakByTruncatingTail;//www...
		_headViewHeight = 280+self.topSapceWithHeadView.constant+(15+7)*4;
		_show = YES;
	}
	[self.bookDescLb sizeToFit];
	self.maskView.height = _headViewHeight;
	[_maskView az_setGradientBackgroundWithColors:@[[UIColor clearColor],[UIColor whiteColor]] locations:nil startPoint:CGPointMake(0, 0) endPoint:CGPointMake(0, 280/_headViewHeight)];
	[self.headViewbackImg addSubview:self.maskView];
	self.tableView.tableHeaderView.height = _headViewHeight;
	[self.tableView reloadData];
}
#pragma mark -小说图片展示
- (void)bookImgTapClick:(UIGestureRecognizer*)tap {
	[self showBigImageWithIndex:0];
}
#pragma mark -- 图片预览
- (void)showBigImageWithIndex:(NSInteger)key {

//  UIImage *image = //[UIImage imageWithContentsOfFile:GET_IMAGE_PATH(self.imgArr[key], IMG_SOURCE_BIG)];
  LCPicShowerViewController *photoController = [[LCPicShowerViewController alloc] initWithImage:self.bookImg.image];
	photoController.isHiddenDeleteBtn  = YES;
  XXNavigationController* aNavigation = [[XXNavigationController alloc] initWithRootViewController: photoController];
  aNavigation.navigationBar.tintColor = [UIColor colorWithHexString:@"2F94F9"];//ff5c5c
  aNavigation.navigationBar.barStyle  = UIBarStyleBlack;
  aNavigation.navigationBar.translucent = NO;

  if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
	  self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
  }
  [self.navigationController presentViewController:aNavigation animated:YES completion:^{
  }];

  photoController.title = NSLocalizedString(@"预览", nil);
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.tableView.data.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	static NSString *cellId = @"BookDetailTableViewCell";
	BookDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
	if (!cell) {
		cell = [[BookDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	BookCityChartsModel *model = self.tableView.data[indexPath.row];
	[cell setCellData:model AtIndexPath:indexPath];
	if (indexPath.row  == self.tableView.data.count - 1) {
		cell.line.hidden = YES;
	}else{
		cell.line.hidden = NO;
	}
	return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 110.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 47;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return CGFLOAT_MIN;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

	UIView *viewHeaderInSection = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [JPTool screenWidth], 47)];
	viewHeaderInSection.backgroundColor = [UIColor whiteColor];

	UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [JPTool screenWidth], 12)];
	lineView.backgroundColor = [UIColor lightGray_F2F2F2];
	[viewHeaderInSection addSubview:lineView];

	UIView *topLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0.2, [JPTool screenWidth], 0.5)];
	topLine.backgroundColor = RGBA_COLOR(204, 204, 204, 0.5);
	[lineView addSubview:topLine];

	UIView *bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, lineView.height-0.5, [JPTool screenWidth], 0.5)];
	bottomLine.backgroundColor = RGB_COLOR(204, 204, 204);
	[lineView addSubview:bottomLine];


	UILabel *titleLb = [[UILabel alloc]initWithFrame:CGRectMake(15, lineView.bottom+15, 100, 20)];
	titleLb.text = @"推荐书单";
	titleLb.textColor = RGB_COLOR(0, 0, 0);
	titleLb.textAlignment = NSTextAlignmentLeft;
	titleLb.font = [UIFont systemFontOfSize:16];
	[viewHeaderInSection addSubview:titleLb];

	return viewHeaderInSection;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	return [UIView new];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (![ZJPNetWork netWorkAvailable]) {
		[ZJPAlert showAlertWithMessage:[JPTool NoNetWorkAlert] time:1.5];
		return;
	}
	BookDetailViewController *vc = [[BookDetailViewController alloc]init];
	BookCityBookModel *model = [self.tableView.data objectAtIndex:indexPath.row];
	vc.bookId = model.bookId;
	vc.hidesBottomBarWhenPushed = YES;
	vc.isForm = self.isForm;
	[self.navigationController pushViewController:vc animated:YES];
	
}
#pragma mark - 返回按钮
- (IBAction)backButtonClick:(UIButton *)sender {

    [self.navigationController popViewControllerAnimated:YES];

}

#pragma mark - 加入书架 开始阅读
- (IBAction)bottomButtonClick:(UIButton *)sender {

	BookCityBookModel *bookModel = [BookCityBookModel yy_modelWithDictionary:self.bookDetailDict];
	if (sender.tag == 101) {//加入书架

		if ([self.bottomLeftBtn.titleLabel.text isEqualToString:@"加入书架"]) {
			[ADSherfCache addBook:bookModel];
		}else{
			[ADSherfCache removeBookShelfWithBookModel:bookModel];// 取消加入
		}
#pragma mark - 加入书架 成功或失败 
		if ([ADSherfCache queryWithBookId:bookModel.bookId]) {
			[self.bottomLeftBtn setTitle:@"取消添加" forState:UIControlStateNormal];
			[ZJPAlert showAlertWithMessage:@"加入书架成功" time:1.5];
		}else{
			[self.bottomLeftBtn setTitle:@"加入书架" forState:UIControlStateNormal];
			[ZJPAlert showAlertWithMessage:@"从书架移除成功" time:1.5];
		}
        

	}else{// 开始阅读
//		[ZJPAlert showAlertWithMessage:@"开始阅读被点击" time:1.5];
		ADPageViewController *pageVc = [[ADPageViewController alloc] init];
		pageVc.bookId   = self.bookDetailDict[@"id"]?self.bookDetailDict[@"id"]:@"";//
		pageVc.bookName = self.bookDetailDict[@"title"]?self.bookDetailDict[@"title"]:@"";
		pageVc.cover = bookModel.cover;
        pageVc.lastChapter = bookModel.lastChapter;
        pageVc.author = bookModel.author;
        pageVc.majorCate = bookModel.majorCate;
        pageVc.updated = bookModel.updated;

		pageVc.bookDetailDict = self.bookDetailDict;

        [self.navigationController pushViewController:pageVc animated:YES];
	}
//	NSInteger titleInteger = sender.currentTitle.integerValue;
//	[sender setTitle:@(++titleInteger).stringValue forState:UIControlStateNormal];
}

#pragma mark - lazy
-(NSMutableArray *)bookArray {
	if (!_bookArray) {
		_bookArray = [NSMutableArray array];
	}
	return _bookArray;
}

- (UIView *)maskView {
	if (!_maskView) {
		_maskView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [JPTool screenWidth], 200)];
		_maskView.backgroundColor = [UIColor clearColor];
		[_maskView az_setGradientBackgroundWithColors:@[[UIColor clearColor],[UIColor whiteColor]] locations:nil startPoint:CGPointMake(0, 0) endPoint:CGPointMake(0, 280/_headViewHeight)];
	}
	return _maskView;
}


@end
