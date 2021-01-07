//
//  SerachCollectionHeaderView.m
//  NightReader
//
//  Created by 张俊平 on 2019/2/20.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import "SerachCollectionHeaderView.h"

@implementation SerachCollectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self initHeaderView];
	}
	return self;
}

- (void)initHeaderView {

//	self.backgroundColor = [UIColor whiteColor];
	self.headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 12, 24, 25)];
//	[self addSubview:self.headImageView];

	CGSize size = [@"热门搜索" sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:19]}];
	self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, size.width, size.height)];
	self.titleLabel.centerY = self.headImageView.centerY;
	self.titleLabel.font = [UIFont systemFontOfSize:19];
	self.titleLabel.textColor = [UIColor blackColor];
	[self addSubview:self.titleLabel];

	self.clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
	self.clearButton.frame = CGRectMake(self.width - 20 - 44, 20, 44, 20);
	self.clearButton.centerY = self.headImageView.centerY;
	self.clearButton.titleLabel.font = [UIFont systemFontOfSize:12];
//	self.clearButton.backgroundColor = [UIColor orangeColor];
	[self.clearButton setTitle:@"清空" forState:UIControlStateNormal];
	[self.clearButton setImage:[UIImage imageNamed:@"search_del"] forState:UIControlStateNormal];
	[self.clearButton setImagePositionWithType:SSImagePositionTypeRight spacing:5];
	[self.clearButton setTitleColor:[UIColor black_222222] forState:UIControlStateNormal];
	[self addSubview:self.clearButton];

	self.width = [JPTool screenWidth];
//	self.height = 25 + 33 + 20;
}

@end
