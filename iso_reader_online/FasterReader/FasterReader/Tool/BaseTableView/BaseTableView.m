	//
	//  BaseTableView.m
	//  TeBrand
	//
	//  Created by iOS开发 on 17/1/20.
	//  Copyright © 2017年 SunBo. All rights reserved.
	//

#import "BaseTableView.h"

@implementation BaseTableView
{
	UIView *_nullView;
	UIImageView *_imageView;
	UILabel *_label;
	UILabel *_label1;

}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
- (id)initWithFrame:(CGRect)frame
{
	self = [self initWithFrame:frame style:UITableViewStylePlain];
	[self initViews];
	return self;
}
- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
	self = [super initWithFrame:frame style:style];
	if (self) {
		[self initViews];
		self.backgroundColor = [UIColor lightGray_F2F2F2];
	}

	return self;
}

-(void)awakeFromNib
{
	[super awakeFromNib];
	[self initViews];
}
-(void)layoutSubviews
{
	[super layoutSubviews];
	UIImageView *imageV = (UIImageView *)[_nullView viewWithTag:1];
	UILabel *label = (UILabel *)[_nullView viewWithTag:2];

	switch (self.bgViewStyle) {
		case BaseTableViewNoStyleDefault:
		 {
		[imageV setImage:[UIImage imageNamed:@""]];
		label.text = @"暂无数据";
		_nullButton.hidden = YES;
		 }
			break;
		case BaseTableViewNOStyleIsMyBrand:
		 {
		_imageView.top = (_nullView.height-203.5 - 85)/2;
		[self.nullButton setTitle:@"去发布品牌" forState:UIControlStateNormal];
		_nullButton.frame = CGRectMake(([JPTool screenWidth]-130)/2-4, _imageView.bottom+50, 130, 35);
		[self.nullButton setTitleColor:[UIColor colorWithHexString:@"50a2e1"] forState:UIControlStateNormal];
		_nullButton.layer.cornerRadius = 17.5;
		_nullButton.clipsToBounds = YES;
		_nullButton.layer.borderColor = [UIColor colorWithHexString:@"50a2e1"].CGColor;
		_nullButton.layer.borderWidth = 0.5;
		_nullButton.hidden = NO;
		 }
			break;
		case BaseTableViewNoStyleIsSearchPerson:
		 {
		[imageV setImage:[UIImage imageNamed:@"search_empty"]];
		label.text = @"哎呦！没有找到数据哦";
		imageV.frame = CGRectMake(([JPTool screenWidth]-183)/2, 165*[JPTool HeightScale], 183, 113);
		_label.frame = CGRectMake(0,imageV.bottom+13 ,[JPTool screenWidth], 30);
		label.frame = CGRectMake(0,imageV.bottom+25 ,[JPTool screenWidth], 30);
		_label.backgroundColor = [UIColor clearColor];
		_label.textAlignment = NSTextAlignmentCenter;
		_label.font = [UIFont systemFontOfSize:15];
		_nullButton.hidden = YES;
		 }
			break;
		case BaseTableViewNOStyleIsSearchView:
		 {
		[imageV setImage:[UIImage imageNamed:@"search_empty"]];
		label.text = @"暂无搜索记录";
		imageV.frame = CGRectMake(([JPTool screenWidth]-183)/2, [JPTool WidthScale]*59, 183, 113);
		label.frame = CGRectMake(0,imageV.bottom+25 ,[JPTool screenWidth], 30);
		_nullButton.hidden = YES;
		_label1.hidden = YES;
		 }
			break;
		case BaseTableViewNOStyleIsCustom:{
			[imageV setImage:[UIImage imageNamed:@""]];
			label.text = self.tipsString;
			imageV.frame = CGRectMake(([JPTool screenWidth]-183)/2, [JPTool WidthScale]*65, 183, 50);
			label.frame = CGRectMake(0,imageV.bottom+25 ,[JPTool screenWidth], 30);
			_label1.hidden = YES;
			_nullButton.hidden = YES;
		}
		default:
			break;
	}
}
-(void)initViews
{
	self.data = [NSMutableArray array];
	self.dataSource = self;
	self.delegate = self;
	[self createNULLView];
}

- (void)createNULLView
{

	_nullView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [JPTool screenWidth], self.height)];
	_nullView.backgroundColor = [UIColor whiteColor];
	_imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"no_data"]];
	_imageView.frame = CGRectMake(([JPTool screenWidth]-200)/2, (_nullView.height-160)/3-25, 200, 160);
	_imageView.tag = 1;
	[_nullView addSubview:_imageView];

	_label = [[UILabel alloc]init];
	_label.frame = CGRectMake(([JPTool screenWidth]-300)/2, _imageView.bottom+35, 300, 20);
	_label.backgroundColor = [UIColor clearColor];
	_label.textAlignment = NSTextAlignmentCenter;
	_label.font = [UIFont systemFontOfSize:17];
	_label.text = @"暂无数据";
	_label.numberOfLines = 0;
	_label.textColor = [UIColor colorWithHexString:@"999999"];
	_label.tag = 2;
	[_nullView addSubview:_label];

	_label1 = [[UILabel alloc]init];
	_label1.frame = CGRectMake(0, _label.bottom+13, [JPTool screenWidth], 16);
	_label1.backgroundColor = [UIColor clearColor];
	_label1.textAlignment = NSTextAlignmentCenter;
	_label1.font = [UIFont systemFontOfSize:14];
	_label1.text = @"一个数据都木有，不能再低调了~";
	_label1.numberOfLines = 0;
	_label1.textColor = [UIColor colorWithHexString:@"b2b2b2"];
	_label1.tag = 3;
	[_nullView addSubview:_label1];


	_nullButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_nullButton.backgroundColor = [UIColor clearColor];
	_nullButton.titleLabel.font = [UIFont systemFontOfSize:15];
	[_nullView addSubview:_nullButton];
	[self addSubview:_nullView];
	[self bringSubviewToFront:_nullView];
	_nullView.hidden = YES;
	_nullButton.hidden = YES;
}


	//重写父类方法
-(void)reloadData
{
	_nullView.top = self.tableHeaderView.height;
	_nullView.height = self.height-self.tableHeaderView.height;
	if (![_data count]) {
		_nullView.hidden = NO;
		_imageView.hidden = NO;
	} else {
		_nullView.hidden = YES;
		_imageView.hidden = YES;

	}
	[super reloadData];

}
#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	static NSString *CellIdentifier = @"kBaseCellID";

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}

		// Configure the cell.

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
