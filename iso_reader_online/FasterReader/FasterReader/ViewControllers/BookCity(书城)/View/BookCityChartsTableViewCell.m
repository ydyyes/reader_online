//
//  BookCityChartsTableViewCell.m
//  NightReader
//
//  Created by 张俊平 on 2019/2/27.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import "BookCityChartsTableViewCell.h"

@implementation BookCityChartsTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self = [[[NSBundle mainBundle] loadNibNamed:@"BookCityChartsTableViewCell" owner:self options:nil] lastObject];

	}
	return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

/** 设置cell数据 */
- (void)setCellData:(BookCityChartsModel*)model AtIndexPath:(NSIndexPath *)indexPath {

		// MARK:设置排行榜的 图标
	if (indexPath.row == 0) {
		self.bookToplistImg.image  = [UIImage imageNamed:@"gold"];
		self.bookToplistImg.hidden = NO;
	}else if (indexPath.row == 1) {
		self.bookToplistImg.image  = [UIImage imageNamed:@"tong"];
		self.bookToplistImg.hidden = NO;
	}else if (indexPath.row == 2) {
		self.bookToplistImg.image  = [UIImage imageNamed:@"yin"];
		self.bookToplistImg.hidden = NO;
	}else {
		self.bookToplistImg.hidden = YES;
	}

	self.bookNameLb.text = model.title;// 书名
	self.bookDescLb.text = model.longIntro;// 书籍描述
	NSString *authStr = [NSString stringWithFormat:@"%@ | %@",model.author,model.majorCate];
	self.bookAuthorLb.text = authStr;// 书的作者
	// 图书封面
	NSURL *url = [NSURL URLWithString:model.cover];
//	[self.bookImg yy_setImageWithURL:url options:(YYWebImageOptionProgressive)];
	[self.bookImg yy_setImageWithURL:url placeholder:[UIImage imageNamed:@"zhanweitu"]];//书籍封面图
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
