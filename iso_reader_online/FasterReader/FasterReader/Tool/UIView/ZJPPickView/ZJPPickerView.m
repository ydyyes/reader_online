//
//  ZJPPickerView.m
//  NightReader
//
//  Created by 张俊平 on 2019/5/14.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import "ZJPPickerView.h"

@interface ZJPPickerView ()<UIPickerViewDelegate, UIPickerViewDataSource>

/** 容器视图 */
@property (nonatomic, strong) UIView *alertContainerView;
/** 透明度视图 */
@property (nonatomic, strong) UIControl *alphaView;
/** 内容背景视图 */
@property (nonatomic, strong) UIView *alertBgView;
/** 工具视图 */
@property (nonatomic, strong) UIView *toolsView;
/** 重置按钮 */
@property (nonatomic, strong) UIButton *resetBtn;
/** 确定按钮 */
@property (nonatomic, strong) UIButton *sureBtn;
/** 时间选择器 */
@property (nonatomic, strong) UIPickerView *pickerView;
/** 数据数组 */
@property (nonatomic, strong) NSMutableArray *dataArr;
/** id 数据数组 */
@property (nonatomic, strong) NSMutableArray *idDataArr;
/** 数据类型 不同的数据类型显示不同的数据 */
@property (nonatomic, copy) NSString *type;

@end

@implementation ZJPPickerView
{
	/** 名称 */
	NSString *_nameStr;
	/** id */
	NSString *_idStr;
	/** 选中索引 */
	NSInteger _selectIndex;
}

#pragma mark -- lazyLoadData
- (NSMutableArray *)dataArr
{
	if (_dataArr==nil) {
		_dataArr = [[NSMutableArray alloc] init];
	}
	return _dataArr;
}

- (NSMutableArray *)idDataArr
{
	if (_idDataArr==nil) {
		_idDataArr = [[NSMutableArray alloc] init];
	}
	return _idDataArr;
}
#pragma mark -- lazyLoadUI
- (UIView *)alertContainerView
{
	if (_alertContainerView==nil) {
		_alertContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAINScreenWidth, MAINScreenHeight)];
	}
	return _alertContainerView;
}

- (UIControl *)alphaView
{
	if (_alphaView==nil) {
		_alphaView = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, MAINScreenWidth, MAINScreenHeight)];
		_alphaView.backgroundColor = [UIColor blackColor];
		_alphaView.alpha = 0.3;
		[_alphaView addTarget:self action:@selector(alertHidden) forControlEvents:UIControlEventTouchDown];
	}
	return _alphaView;
}

- (UIView *)alertBgView
{
	if (_alertBgView==nil) {
		_alertBgView = [[UIView alloc] initWithFrame:CGRectMake(0, MAINScreenWidth-NavBarHeight-300, MAINScreenWidth, 300)];
		_alertBgView.backgroundColor = [UIColor whiteColor];
	}
	return _alertBgView;
}

- (UIView *)toolsView
{
	if (_toolsView==nil) {
		_toolsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAINScreenWidth, 45)];
		_toolsView.backgroundColor = [UIColor lightGray_F0F0F0];
	}
	return _toolsView;
}

- (UIButton *)resetBtn
{
	if (_resetBtn==nil) {
		_resetBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 45)];
		[_resetBtn setTitle:@"取消" forState:UIControlStateNormal];
		[_resetBtn setTitleColor:[UIColor lightGary_999999] forState:UIControlStateNormal];
		_resetBtn.titleLabel.font = [UIFont systemFontOfSize:16];
		[_resetBtn addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchDown];
	}
	return _resetBtn;
}

- (UIButton *)sureBtn
{
	if (_sureBtn==nil) {
		_sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(MAINScreenWidth-100, 0, 100, 45)];
		[_sureBtn setTitle:@"确定" forState:UIControlStateNormal];
		[_sureBtn setTitleColor:[UIColor blue_00a2e0] forState:UIControlStateNormal];
		_sureBtn.titleLabel.font = [UIFont systemFontOfSize:16];
		[_sureBtn addTarget:self action:@selector(sureBtnClick:) forControlEvents:UIControlEventTouchDown];
	}
	return _sureBtn;
}

- (UIPickerView *)pickerView
{
	if (_pickerView==nil) {
		_pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, MAINScreenWidth, 0)];
		_pickerView.delegate = self;
		_pickerView.dataSource = self;
	}
	return _pickerView;
}
#pragma mark - pickerViewDatasource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return self.dataArr.count;
}
#pragma mark - pickerViewDelegate
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return 45;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, MAINScreenWidth-30, 45)];
	label.text = [NSString stringWithFormat:@"%@",self.dataArr[row]];
	label.font = [UIFont systemFontOfSize:16];
	label.textAlignment = NSTextAlignmentCenter;
	if (row==_selectIndex) {
		label.textColor = [UIColor blue_00a2e0];
	} else {
		label.textColor = [UIColor lightGray_666666];
	}
	return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	_selectIndex = row;
	_nameStr = self.dataArr[row];
//	_idStr = self.idDataArr[row];
	[self.pickerView reloadAllComponents];
}
#pragma mark -- 单例
+ (instancetype)shareAlert {
	static id _instance;
	static dispatch_once_t onceToke;
	dispatch_once(&onceToke, ^{
		_instance = [[self alloc] init];
	});
	return _instance;
}

- (instancetype)init {
	if (self = [super init]) {
			// 添加视图
		[self addAlertSubView];
	}
	return self;
}
#pragma mark -- 添加视图
- (void)addAlertSubView
{
	[self.alertContainerView addSubview:self.alphaView];
	[self.alertContainerView addSubview:self.alertBgView];
	[self.alertBgView addSubview:self.toolsView];
	[self.toolsView addSubview:self.resetBtn];
	[self.toolsView addSubview:self.sureBtn];
	[self.alertBgView addSubview:self.pickerView];
	[self layoutSubViewsUI];
}
#pragma mark -- 布局视图
- (void)layoutSubViewsUI
{
	self.alertBgView.frame = CGRectMake(0, MAINScreenHeight-290, MAINScreenWidth, 290);
	self.toolsView.frame = CGRectMake(0, 0, MAINScreenWidth, 45);
	self.resetBtn.frame = CGRectMake(0, 0, 62, 45);
	self.sureBtn.frame = CGRectMake(MAINScreenWidth-62, 0, 62, 45);
	self.pickerView.frame = CGRectMake(0, self.toolsView.height, MAINScreenWidth, self.alertBgView.height-self.toolsView.height);
}

- (void)setResultArr:(NSArray *)resultArr withType:(NSString *)type selectIndex:(NSString*)selectString withSureBlock:(OASureBlock)sureBlock withCancelClick:(OACancelBlock)cancelBlock
{
	_oaCancelBlock = cancelBlock;
	_oaSureBlock = sureBlock;
	self.type = type;
	[self.dataArr removeAllObjects];
//	[self.idDataArr removeAllObjects];
	if ([type intValue]==1) {
//			[self.idDataArr addObjectsFromArray:resultArr];
			[self.dataArr addObjectsFromArray:resultArr];
	} else if ([type intValue]==2) {
	} else if ([type intValue]==3) {
	}else{
	}
	if (selectString) {// 默认选中下标
		_selectIndex = [resultArr indexOfObject:selectString];
	}else{
		_selectIndex = 0;
	}
	[self.pickerView selectRow:_selectIndex inComponent:0 animated:YES];
	[self pickerView:self.pickerView didSelectRow:_selectIndex inComponent:0];
	[self alertShow];
}
#pragma mark -- 重置按钮点击
- (void)cancelBtnClick:(UIButton *)sender
{
	if (self.oaCancelBlock) {
		self.oaCancelBlock();
	}
	[self alertHidden];
}
#pragma mark -- 确定按钮点击
- (void)sureBtnClick:(UIButton *)sender
{
	if (self.oaSureBlock) {
		self.oaSureBlock(_nameStr, _idStr);
	}
	[self alertHidden];
}
#pragma mark -- 显示弹窗
- (void)alertShow
{
	self.alphaView.alpha = 0.0;
	self.alertBgView.top = MAINScreenHeight;
	[UIView animateWithDuration:0.25f animations:^{
		self.alphaView.alpha = 0.5;
		[[UIApplication sharedApplication].keyWindow addSubview:self.alertContainerView];
		self.alertBgView.top = MAINScreenHeight-self.alertBgView.height;
	} completion:^(BOOL finished) {

	}];
}
#pragma mark -- 隐藏弹窗
- (void)alertHidden
{
	[UIView animateWithDuration:0.25f animations:^{
		self.alphaView.alpha = 0.0;
		self.alertBgView.top = MAINScreenHeight;
	} completion:^(BOOL finished) {
		[self.alertContainerView removeFromSuperview];
	}];
}


@end
