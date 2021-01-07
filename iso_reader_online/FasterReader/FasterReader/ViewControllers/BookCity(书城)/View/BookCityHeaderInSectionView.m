//
//  BookCityHeaderInSectionView.m
//  NightReader
//
//  Created by 张俊平 on 2019/5/23.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import "BookCityHeaderInSectionView.h"

@interface BookCityHeaderInSectionView ()

/** 分割线 */
@property (nonatomic, readwrite , strong) UIView *lineView;

@end

@implementation BookCityHeaderInSectionView

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self initHeaderView];
	}
	return self;
}

- (void)initHeaderView {

	self.backgroundColor = [UIColor whiteColor];
	self.lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [JPTool screenWidth], self.lineHeigh)];
	self.lineView.backgroundColor = [UIColor colorWithHexString:@"f6f6f6"];
	[self addSubview:self.lineView];

	CGSize size = [@"热门更新" sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:19]}];
	self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, self.lineView.bottom, size.width, size.height)];
//	self.titleLabel.font = [UIFont systemFontOfSize:16];
//	self.titleLabel.textColor = [UIColor black_222222];
	[self addSubview:self.titleLabel];

	self.moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
	self.moreButton.frame = CGRectMake(self.width - 20 - 44, 20, 50, 20);
	self.moreButton.titleLabel.font = [UIFont systemFontOfSize:13];
		//	self.moreButton.backgroundColor = [UIColor orangeColor];
	[self.moreButton setTitle:@"更多" forState:UIControlStateNormal];
	[self.moreButton setImage:[UIImage imageNamed:@"right_icon"] forState:UIControlStateNormal];
	[self.moreButton setImagePositionWithType:SSImagePositionTypeRight spacing:5];
	[self.moreButton setTitleColor:[UIColor black_222222] forState:UIControlStateNormal];
	[self addSubview:self.moreButton];

}

-(void)setLineHeigh:(CGFloat)lineHeigh {
	_lineHeigh = lineHeigh;
	self.lineView.height = _lineHeigh;
	self.titleLabel.mj_y = (self.height-_lineHeigh)/2.0;
	self.moreButton.centerY = self.titleLabel.centerY;
}












/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
